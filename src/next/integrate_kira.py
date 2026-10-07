# Integration of an unintegrated antenna through FORM and Kira: IBP reduction to master
# integrals, the antenna's scale, and the substitution of the analytic masters.

import sympy as sp
from sympy.parsing.mathematica import parse_mathematica
from pathlib import Path
from dataclasses import dataclass
from itertools import combinations
import yaml, subprocess, shutil, os, re, json, tempfile


q2, d = sp.symbols("q2 d")

SRC_DIR = Path(__file__).resolve().parent
ROOT_DIR = SRC_DIR.parent.parent                   # src/next -> repository root
TEMPLATES_DIR = SRC_DIR / "kira" / "templates"
FORM_DIR = SRC_DIR / "form"
MASTERS_DIR = SRC_DIR / "masters"
WORK_DIR = SRC_DIR / "tmp"                          # FORM's include files: the scripts read ../tmp/
# Kira runs outside the repository: a synced folder (Dropbox) splits its database mid-run.
KIRA_RUN_DIR = Path(os.environ.get("ANTCALC_KIRA_DIR", Path(tempfile.gettempdir()) / "antcalc_kira"))
UNINTEGRATED_DIR = ROOT_DIR / "results" / "unintegrated"
INTEGRATED_DIR = ROOT_DIR / "results" / "integrated"

# general defs

@dataclass
class IntegrationRun:
    antenna_family: str
    multiplicity: int
    loop_order: int
    auto_input_path: bool
    manual_input_path: Path
    substitute_masters: bool

def antenna_name(run):
    return "".join((run.antenna_family, str(run.multiplicity), str(run.loop_order)))

def perturbative_order(run):
    return run.multiplicity - 2 + run.loop_order

def order(run):
    match perturbative_order(run):
        case 1:
            return "NLO"
        case 2:
            return "NNLO"
        case _:
            raise ValueError("Error! Supported antennae are NLO and NNLO: (multiplicity - 2) + loop_order must be 1 or 2.")

def template_dir(run):
    return TEMPLATES_DIR / antenna_name(run)

def kira_dir(run):
    return KIRA_RUN_DIR / antenna_name(run)

def integralfamilies_path(run):
    return template_dir(run) / "config/integralfamilies.yaml"

# from the run settings

def get_input_path(run):
    if run.auto_input_path:
        return UNINTEGRATED_DIR / f"unintegrated{antenna_name(run)}.m"
    return ROOT_DIR / run.manual_input_path

def read_input(input_path):
    with open(str(input_path)) as f:
        expr = f.read()

    parsed = parse_mathematica(expr)
    if isinstance(parsed, (sp.Tuple, tuple, list)):
        return tuple(parsed)
    return (parsed,)

# extracted expression, one component per list element

@dataclass
class Kinematics:
    multiplicity: int
    invariants: tuple
    invariant_vectors: dict

def invariant_symbol(particles):
    return sp.Symbol("s" + "".join(str(particle) for particle in sorted(particles)))

def build_kinematics(multiplicity):
    particles = range(1, multiplicity + 1)
    pairs = list(combinations(particles, 2))
    subsets = [
        subset
        for size in range(2, multiplicity)
        for subset in combinations(particles, size)
    ]

    invariants = tuple(invariant_symbol(subset) for subset in subsets)

    # s_I is the sum of s_ij over the pairs inside I; q2 is the sum over all pairs.
    invariant_vectors = {
        invariant_symbol(subset): tuple(int(set(pair) <= set(subset)) for pair in pairs)
        for subset in subsets
    }
    invariant_vectors[q2] = (1,) * len(pairs)

    return Kinematics(multiplicity, invariants, invariant_vectors)

# invariants and their vectors for n massless final-state partons

def read_to_dict_tuple(expr, invariants):
    monomial_list = []

    for term in expr:
        num, den = sp.fraction(term)
        small_fractions = [t/den for t in sp.Add.make_args(num)]
        for element in small_fractions:
            coeff, rest = element.as_independent(*invariants)
            power = {} if rest == 1 else dict(rest.as_powers_dict())   # a constant has no invariants
            monomial_list.append((coeff, power))

    return tuple(monomial_list)

# read expression into tuple

def propagator_invariant(momentum, loop_momenta, multiplicity):
    if len(loop_momenta) != multiplicity - 1:
        raise ValueError(f"Expected {multiplicity - 1} loop momenta, found {loop_momenta}.")

    particles = sp.symbols(f"P1:{multiplicity + 1}")
    momenta = {name: particle for name, particle in zip(loop_momenta, particles)}
    momenta["q"] = sum(particles)

    expression = sp.expand(sp.sympify(momentum, locals=momenta))
    coefficients = [expression.coeff(particle) for particle in particles]

    if set(coefficients) <= {0, 1}:
        subset = [index for index, c in enumerate(coefficients, start=1) if c == 1]
    elif set(coefficients) <= {0, -1}:
        subset = [index for index, c in enumerate(coefficients, start=1) if c == -1]
    else:
        raise ValueError(f"Propagator momentum {momentum} is not a sum of final-state momenta.")

    if len(subset) == 1:
        return None                      # on-shell parton: a cut propagator
    if len(subset) == multiplicity:
        return q2
    return invariant_symbol(subset)

def kira_integral_families(run, kinematics):
    families_list = []
    family_layout = {}
    kira_families_loc = integralfamilies_path(run)

    with open(kira_families_loc) as file:
        families = yaml.safe_load(file)["integralfamilies"]

    for family in families:
        name = family["name"]
        cuts = set(family.get("cut_propagators", []))

        family_invariants = []
        for position, prop in enumerate(family["propagators"], start=1):
            if not isinstance(prop, list) or prop[1] != 0:
                raise ValueError(f"{name}: propagator #{position} {prop} is not a massless propagator")
            if position in cuts:
                continue
            invariant = propagator_invariant(prop[0], family["loop_momenta"], kinematics.multiplicity)
            if invariant is None:
                raise ValueError(f"{name}: propagator #{position} {prop} is on-shell but not cut")
            family_invariants.append(invariant)

        families_list.append((name, tuple(family_invariants)))
        family_layout[name] = (len(family["propagators"]), cuts)
    return families_list, family_layout

# extracted list of families

def masters_pattern(families_list):
    names = "|".join(sorted((name for name, invariants in families_list), key=len, reverse=True))
    return re.compile(rf"\b((?:{names})\([-\d,]+\))")

# integral pattern built from the family names

def to_kira_family(term, family):
    coeff, factors_dict = term
    integrand_powers = []
    family_name, family_factors = family
    for family_inv in family_factors:
        if family_inv in factors_dict:
            integrand_powers.append(factors_dict[family_inv])
        else:
            integrand_powers.append(0)
    return (coeff, (family_name, tuple(integrand_powers)))

# term to kira family shape

def numerator_expand(factors, family, invariant_vectors):
    family_name, available_invs = family
    allowed_names = sorted(
                        available_invs, key=sp.default_sort_key
                    ) + [q2]

    matrix = sp.Matrix.hstack(*(
        sp.Matrix(invariant_vectors[name])
        for name in allowed_names
    ))

    term = 1
    for inv, power in factors.items():
        if(power > 0):
            term *= inv**power
            if inv not in available_invs: # if invariant isnt in the basis
                target = sp.Matrix(invariant_vectors[inv])
                try:
                    weights = matrix.LUsolve(target)
                except ValueError:
                    return None, 1   # num fails to resolve in this basis
                replacement = sum(
                    weight * invariant
                    for invariant, weight in zip(allowed_names, weights)
                )
                term = term.subs(inv, replacement)
        elif(power < 0):
            term *= inv**power

    return term.expand(), 0

# expanded the possible implicitly in basis numerator

def expanded_num_to_kira(expanded_num, family, invariants):
    num_list = read_to_dict_tuple(sp.Add.make_args(expanded_num), invariants)
    available = set(family[1])

    for coefficient, factors in num_list:
        required = {inv for inv, power in factors.items() if power != 0}
        if not required <= available:
            return None, 1

    result_list = [
        to_kira_family(term, family)
        for term in num_list
    ]
    return result_list, 0

# made expanded numerator terms into kira bases

def list_to_basis(monomial_list, families_list, kinematics):
    integrands_list = []
    for term in monomial_list:
        coeff, factors = term
        num = {inv: power for inv, power in factors.items() if power > 0}
        den = {inv: power for inv, power in factors.items() if power < 0}

        for family in families_list:
            family_name, family_factors = family
            den_set = set(den.keys())
            if not den_set <= set(family_factors):  # den fails to match family
                continue
            else:
                num_set = set(num.keys())
                if not num_set <= set(family_factors):  # num fails to match family
                    expanded_expr, fail_flag = numerator_expand(factors, family, kinematics.invariant_vectors)
                    if fail_flag == 1:
                        continue
                    else:
                        exp_num_to_kira, fail = expanded_num_to_kira(expanded_expr, family, kinematics.invariants)
                        if fail == 1:
                            continue
                        integrands_list.extend(
                            (coeff * rewrite_coeff, integral)
                            for rewrite_coeff, integral in exp_num_to_kira
                        )
                        break
                else:
                    integrands_list.append(to_kira_family(term, family))
                    break
        else:
            raise ValueError(
                f"No suitable integral family found for term {term}"
            )
    return integrands_list

# to basis

def term_to_form(term, family_layout):
    coefficient, (family_name, powers) = term
    number_of_propagators, cuts = family_layout[family_name]

    remaining_powers = iter(-power for power in powers)
    arguments = ",".join(
        str(1 if position in cuts else next(remaining_powers))
        for position in range(1, number_of_propagators + 1)
        )

    numerator, denominator = sp.fraction(sp.cancel(coefficient))
    numerator_text = str(numerator).replace("**", "^")
    denominator_text = str(denominator).replace("**", "^")

    return (
        f"rat({numerator_text},{denominator_text})"
        f"*{family_name}({arguments})"
    )

def create_form_declarations(integrands_list, families_list):
    form_symbols = {d, q2}
    for coefficient, integral in integrands_list:
        form_symbols.update(sp.sympify(coefficient).free_symbols)

    symbol_names = ",".join(
        str(symbol)
        for symbol in sorted(form_symbols, key=sp.default_sort_key)
    )
    # Include configured families so Kira can introduce a different master family.
    family_names = sorted({name for name, invariants in families_list})
    function_names = ",".join(["rat", "num", "den"] + family_names)

    with Path(WORK_DIR / "declarations.inc").open("w") as file:
        file.write(f"Symbols {symbol_names};\n")
        file.write(f"CFunctions {function_names};\n")
        file.write("PolyRatFun rat;\n")


def create_form_input(integrands_list, family_layout):
    form_terms = [
        term_to_form(term, family_layout)
        for term in integrands_list
    ]
    expression_text = "\n + ".join(form_terms) if form_terms else "0"

    with Path(WORK_DIR / "antenna.inc").open("w") as file:
        file.write(f"Local antenna = \n {expression_text};\n")

# created form input

def get_form_loc():
    form_loc = None

    for binary_name in ["form", "tform", "parform"]:
        form_locator = shutil.which(binary_name)
        if form_locator:
            form_loc = form_locator
            break

    if not form_loc:
        raise Exception("Error! Form not found.")
    return form_loc

def run_form(form_loc, input_path, defines=None):
    script_path = Path(input_path).resolve()
    define_args = [
        argument
        for name, value in (defines or {}).items()
        for argument in ("-D", f"{name}={value}")
    ]
    proc = subprocess.run(
        [form_loc, "-q", *define_args, str(script_path)],
        cwd=str(script_path.parent),
        capture_output=True,
        text=True,
        check=True,
    )

    with Path(WORK_DIR / "antenna.inc").open("w") as file:
        file.write(f"Local antenna = \n {form_to_python(proc)};\n")

    return proc

def form_to_python(proc):
    form_output = proc.stdout
    label = "antenna ="
    before, separator, after = form_output.partition(label)
    if not separator:
        raise ValueError("FORM output does not contain antenna.")

    expression_text, terminator, remainder = after.partition(";")
    if not terminator:
        raise ValueError("FORM expression has no terminating semicolon.")

    return "".join(expression_text.split())

# take form result to list (coeff, basis)

def split_form_terms(expression_text):
    terms = []
    depth = 0
    start = 0

    for position, character in enumerate(expression_text):
        if character == "(":
            depth += 1

        elif character == ")":
            depth -= 1

        elif character in "+-" and depth == 0 and position > start:
            terms.append(expression_text[start:position])
            start = position

    terms.append(expression_text[start:])
    return [term.removeprefix("+") for term in terms]

def form_to_pairs(expression_text):
    result = []

    for term in split_form_terms(expression_text):
        sign = "-" if term.startswith("-") else ""
        term = term.removeprefix("+").removeprefix("-")

        depth = 0

        for position, character in enumerate(term):
            if character == "(":
                depth += 1
            elif character == ")":
                depth -= 1
            elif character == "*" and depth == 0:
                left = term[:position]
                right = term[position + 1:]
                break
        else:
            raise ValueError(f"No coefficient–integral product in {term}")

        if left.startswith("rat("):
            coefficient, integrand = left, right
        elif right.startswith("rat("):
            coefficient, integrand = right, left
        else:
            raise ValueError(f"No rat coefficient in {term}")

        result.append((sign + coefficient, integrand))

    return result

# wrote to list

def write_toReduce(run, terms):
    toReduce_path = kira_dir(run) / "toReduce"

    with open(toReduce_path, "w") as file:
        for coefficient, integrand in terms:
            kira_integral = integrand.replace("(", "[").replace(")", "]")
            file.write(kira_integral + "\n")

# wrote toReduce

def integral_seeds(integrand):
    family_name, indices = integrand.split("(", 1)
    indices = [int(index) for index in indices.rstrip(")").split(",")]
    r = sum(index for index in indices if index > 0)
    s = -sum(index for index in indices if index < 0)
    dots = r - sum(1 for index in indices if index > 0)
    return family_name, r, s, dots

def write_jobs_yaml(run, terms, previous_seeds=None, target=None):
    with open(integralfamilies_path(run)) as file:
        families = {family["name"]: family for family in yaml.safe_load(file)["integralfamilies"]}

    needed = {}
    for coefficient, integrand in terms:
        family_name, r, s, dots = integral_seeds(integrand)
        old_r, old_s, old_dots = needed.get(family_name, (0, 0, 0))
        needed[family_name] = (max(old_r, r), max(old_s, s), max(old_dots, dots))

    # Seeds only grow from one Kira pass to the next: families are kept, and r, s, d never shrink.
    seeds = dict(previous_seeds or {})
    for family_name, (r, s, dots) in needed.items():
        top_sector = families[family_name]["top_level_sectors"][0]
        top_lines = bin(top_sector).count("1")
        new = (max(top_lines, r) + 1, s + 1, dots + 1)
        old = seeds.get(family_name, (0, 0, 0))
        seeds[family_name] = tuple(max(a, b) for a, b in zip(old, new))

    names = sorted(seeds)
    target = target or names[0]
    jobs = {"jobs": [
        {"reduce_sectors": {
            "reduce": [
                {"topologies": [name], "sectors": [families[name]["top_level_sectors"][0]],
                 "r": seeds[name][0], "s": seeds[name][1], "d": seeds[name][2]}
                for name in names
            ],
            "select_integrals": {"select_mandatory_list": [[name, "toReduce"] for name in names]},
        }},
        # One target, kept from the first pass: its export holds the rules of every integral in toReduce.
        {"kira2form": {"target": [[target, "toReduce"]]}},
    ]}

    with open(kira_dir(run) / "jobs.yaml", "w") as file:
        yaml.safe_dump(jobs, file, sort_keys=False, default_flow_style=None)

    return seeds, target

# wrote jobs.yaml from the integrals in toReduce

def get_kira_loc():
    kira_loc = shutil.which("kira")
    if not kira_loc:
        raise Exception("Error! Location for Kira not found.")

    fermat_loc = os.environ.get("FERMATPATH")
    if not fermat_loc:
        raise Exception("Error! Fermat location not found.")
    return kira_loc

def run_kira(kira_loc, run):
    subprocess.run(
        [kira_loc, "jobs.yaml"],
        cwd = str(kira_dir(run)),
        capture_output = True,
        text = True,
        check = True,
    )

def get_masters_list_kira(pattern, requested):
    with open(WORK_DIR / "kira_substitutions.inc", "r", encoding="utf-8") as f:
        content = f.read()

    s = 0
    reduced = set()
    masters_list = []
    for rule in content.split(";"):
        lhs, separator, rhs = rule.partition("=")
        if not separator:
            continue
        s += 1
        reduced.update(pattern.findall(lhs))
        for master in pattern.findall(rhs):
            if (1, master) not in masters_list:
                masters_list.append((1, master))

    # An integral asked for that got no rule is a master, or one Kira could not reduce:
    # either way it stays in the list, so it is fed back and must have an analytic expression.
    for integral in requested:
        if (1, integral) not in masters_list:
            masters_list.append((1, integral))

    masters_list = [(1, m) for _, m in masters_list if m not in reduced]

    return masters_list, s

def export_path(run, target):
    return kira_dir(run) / "results" / target / "kira_toReduce.inc"

def extract_kira_results(run, target):
    export_file = export_path(run, target)
    if not export_file.exists():
        raise ValueError(f"Kira wrote no substitution file for the target {target}.")
    return export_file

def run_kira_pass(run, target):
    export_path(run, target).unlink(missing_ok=True)   # never read an export left by an earlier run
    run_kira(get_kira_loc(), run)
    return extract_kira_results(run, target)

def clear_kira_results(run):
    # Kira skips a topology it finds already reduced, and keeps the sector mappings it built for
    # the topologies of an earlier job: either, kept from another expression, leaves this
    # expression's integrals without rules or mapped onto other masters. Every expression starts
    # in a fresh Kira folder holding only the template's config.
    shutil.rmtree(kira_dir(run), ignore_errors=True)
    shutil.copytree(template_dir(run) / "config", kira_dir(run) / "config")

def run_kira_reduction_complete(run, initial_terms, pattern):
    clear_kira_results(run)
    requested = [integrand for coefficient, integrand in initial_terms]
    write_toReduce(run, initial_terms)
    seeds, target = write_jobs_yaml(run, initial_terms)
    export_file = run_kira_pass(run, target)
    shutil.copyfile(
        export_file,
        WORK_DIR / "kira_substitutions.inc",
    )
    masters_list, s = get_masters_list_kira(pattern, requested)
    s_prev = 0
    while s - s_prev != 0:
        s_prev = s
        requested += [m for _, m in masters_list if m not in requested]
        write_toReduce(run, masters_list)
        seeds, target = write_jobs_yaml(run, masters_list, seeds, target)
        export_file = run_kira_pass(run, target)
        with open(WORK_DIR / "kira_substitutions.inc", "a") as out:
            out.write("\n.sort\n")
            out.write(export_file.read_text())
        masters_list, s = get_masters_list_kira(pattern, requested)

    return masters_list

# reduced until no new rules appear

def masters_file(multiplicity):
    match multiplicity:
        case 3:
            return MASTERS_DIR / "masters_R3.inc"
        case 4:
            return MASTERS_DIR / "masters_R4.inc"
        case _:
            raise ValueError(f"No analytic master integrals for multiplicity {multiplicity} yet.")

def unreduced_in_kira_log(run):
    log = kira_dir(run) / "kira.log"
    if not log.exists():
        return set()
    return {
        integral.replace("[", "(").replace("]", ")")
        for integral in re.findall(r"This integral is unreduced: (\S+)", log.read_text())
    }

def check_masters_covered(masters_list, masters_path, pattern, unreduced=frozenset()):
    covered = set()
    for statement in Path(masters_path).read_text().split(";"):
        lhs, separator, rhs = statement.partition("=")
        if separator and lhs.strip().startswith("id"):
            covered.update(pattern.findall(lhs))

    missing = [master for _, master in masters_list if master not in covered]
    if missing:
        flagged = [master for master in missing if master in unreduced]
        reason = f" Kira reported these as unreduced: {flagged}." if flagged else ""
        raise ValueError(f"No analytic expression in {masters_path} for: {missing}.{reason}")

def check_fully_substituted(integrated, pattern):
    leftover = sorted(set(pattern.findall(integrated)))
    if leftover:
        raise ValueError(f"Integrals left in the integrated antenna after substitution: {leftover}")

# every master has an analytic expression

def save_result(name, kind, expression_text):
    INTEGRATED_DIR.mkdir(parents=True, exist_ok=True)
    result_path = INTEGRATED_DIR / f"{name}_{kind}.inc"
    result_path.write_text(f"Local antenna = \n {expression_text};\n")
    return result_path

def q2_power(coefficient_text):
    numerator_text, denominator_text = coefficient_text.removeprefix("rat(").removesuffix(")").split(",", 1)
    power = 0
    for text, sign in ((numerator_text, 1), (denominator_text, -1)):
        degrees = {monomial[0] for monomial in sp.Poly(sp.sympify(text.replace("^", "**")), q2).monoms()}
        if len(degrees) != 1:
            raise ValueError(f"Coefficient {coefficient_text} is not a single power of q2.")
        power += sign * degrees.pop()
    return power

def antenna_scale(run, master_combination):
    with open(integralfamilies_path(run)) as file:
        loop_momenta = {family["name"]: len(family["loop_momenta"]) for family in yaml.safe_load(file)["integralfamilies"]}

    # An integral with L integration momenta and indices a_i scales as (q2)^(2L - sum a_i - L*ep).
    terms = form_to_pairs(master_combination)
    integration_momenta = set()
    for coefficient, integral in terms:
        family_name, indices = integral.split("(", 1)
        indices = [int(index) for index in indices.rstrip(")").split(",")]
        L = loop_momenta[family_name]
        integration_momenta.add(L)
        total = q2_power(coefficient.lstrip("-")) + 2 * L - sum(indices)
        if total != 0:
            raise ValueError(f"Integer power of q2 does not cancel ({total}) in the term {coefficient}*{integral}.")

    if len(integration_momenta) != 1:
        raise ValueError(f"Masters with different numbers of integration momenta: {integration_momenta}.")
    k = integration_momenta.pop() - 1               # 1/Phi2 removes one power of (q2)^(-ep)
    expected_k = perturbative_order(run)
    if k != expected_k:
        raise ValueError(f"Scale (q2)^(-{k}*ep) does not match the perturbative order k = {expected_k}.")

    return {"q2_power": 0, "q2_ep_power": -k, "factor": f"(q2/mu2)^(-{k}*ep)", "terms_checked": len(terms)}

# the antenna's scale, from the dimensions of the integrals in the master combination

def integrate_antenna(run, expression, name):
    kinematics = build_kinematics(run.multiplicity)
    families_list, family_layout = kira_integral_families(run, kinematics)
    pattern = masters_pattern(families_list)

    monomial_list = read_to_dict_tuple((expression,), kinematics.invariants)
    integrands_list = list_to_basis(monomial_list, families_list, kinematics)

    create_form_declarations(integrands_list, families_list)
    create_form_input(integrands_list, family_layout)
    expression_text = form_to_python(run_form(get_form_loc(), FORM_DIR / "simplify_before_kira.frm"))
    terms = form_to_pairs(expression_text)

    masters_list = run_kira_reduction_complete(run, terms, pattern)
    master_combination = form_to_python(run_form(get_form_loc(), FORM_DIR / "simplify_after_kira.frm"))
    save_result(name, "masters", master_combination)
    scale = antenna_scale(run, master_combination)
    (INTEGRATED_DIR / f"{name}_scale.json").write_text(json.dumps(scale, indent=2) + "\n")
    if not run.substitute_masters:
        return master_combination, scale, None

    masters_path = masters_file(run.multiplicity)
    check_masters_covered(masters_list, masters_path, pattern, unreduced_in_kira_log(run))
    proc_form = run_form(get_form_loc(), FORM_DIR / "substitute_masters.frm", {"MASTERS": masters_path.name})
    integrated = form_to_python(proc_form)
    check_fully_substituted(integrated, pattern)
    save_result(name, "integrated", integrated)
    return master_combination, scale, integrated

# master combination, its scale, and the integrated antenna when masters are substituted, one expression at a time

def run_integration(run):
    order(run)                                          # refuses antennae beyond NNLO before anything runs
    WORK_DIR.mkdir(exist_ok=True)
    input_path = get_input_path(run)
    print(f"{antenna_name(run)}: {order(run)} antenna, from {input_path}")

    results = []
    for index, expression in enumerate(read_input(input_path)):
        master_combination, scale, integrated = integrate_antenna(run, expression, f"{antenna_name(run)}_{index}")
        print(f"component {index}, in master integrals:")
        print(master_combination)
        print(f"component {index}, scale: {scale['factor']}")
        if integrated is not None:
            print(f"component {index}, integrated:")
            print(integrated)
        results.append((master_combination, scale, integrated))
    return results
