import json
import sys
from pathlib import Path
import platform
import subprocess
import shutil

if __package__:
    from .build_methods import build_massless_legacy, build_massless_pythonToWl
    from .integrate_methods import integrate_massless_legacy
    from .paths import REPO_ROOT, LEGACY_LOADERS_DIR
    from . import integrate_kira
else:
    from build_methods import build_massless_legacy, build_massless_pythonToWl
    from integrate_methods import integrate_massless_legacy
    from paths import REPO_ROOT, LEGACY_LOADERS_DIR
    import integrate_kira

########################################
## setup

AntCalcVersion = "AntCalc 0.3.5"

########################################
## main

def orchestrator(runcard_name = "runcard"):
    here, repo_root, results_dir, os_name, runcard = define_general_paths(runcard_name)
    build_set, build_method, build_print, integrate_set, integrate_method, integrate_print, operations_tuple, antenna_family, multiplicity, loop_order = runcard_settings(runcard)
    particle_tuple, running_operation = runcard_conditions(operations_tuple, antenna_family, multiplicity, loop_order)
    antcalc_launch_print(AntCalcVersion, running_operation, antenna_family, multiplicity, loop_order, particle_tuple)
    # runner
    match operations_tuple:
        case (1, 0):
            build_runner(build_method, antenna_family, multiplicity, loop_order, operations_tuple, results_dir, here, os_name)
        case (0, 1):
            integrate_runner(integrate_method, runcard, antenna_family, multiplicity, loop_order, operations_tuple, results_dir, here, os_name)
        case (1, 1):
            build_runner(build_method, antenna_family, multiplicity, loop_order, operations_tuple, results_dir, here, os_name)
            integrate_runner(integrate_method, runcard, antenna_family, multiplicity, loop_order, operations_tuple, results_dir, here, os_name)
        case _:
            raise ValueError("Error! No valid opertaion selected. The build and integrate toggles must select with 1 for active or 0 for inactive.")


def define_general_paths(runcard_name):     # may define another runcard name
    here = Path(__file__).resolve().parent
    repo_root = REPO_ROOT
    results_dir = repo_root / "results"
    results_dir.mkdir(parents=True, exist_ok=True)
    os_name = platform.system()

    runcard_path = repo_root / "runcards" / ".".join((runcard_name, "json"))
    with open(runcard_path, encoding = "utf-8") as f:
        runcard = json.load(f)

    return here, repo_root, results_dir, os_name, runcard

### runcard variables

def runcard_settings(runcard):
    # build side
    build_set = runcard["build"]
    build_method = runcard["build_method"]
    build_print = runcard["build_print_to_terminal"]
    # integrate side
    integrate_set = runcard["integrate"]
    integrate_method = runcard["integrate_method"]
    integrate_print = runcard["integrate_print_to_terminal"]
    # operations
    operations_tuple = (build_set, integrate_set)
    # run settings
    antenna_family = runcard["family"]        # antenna family e.g. A, B, C, ...
    multiplicity = runcard["multiplicity"]     # number of final-state particles n
    loop_order = runcard["loop_order"]         # number of loops l
    return build_set, build_method, build_print, integrate_set, integrate_method, integrate_print, operations_tuple, antenna_family, multiplicity, loop_order

def runcard_conditions(operations_tuple, antenna_family, multiplicity, loop_order):
    # sets
    antenna_particles = {
        "A": ("q", "barq", "g", "g"),
        "B": ("q", "barq", "qprime", "barqprime"),
        "C": ("q", "barq", "q", "barq")
    }
    if antenna_family not in antenna_particles:
        raise ValueError(f"Unknown antenna family: {antenna_family!r}. Currently implemented families are {list(antenna_particles)}")
    particle_tuple = antenna_particles[antenna_family][:multiplicity]

    # operations
    operations = {
        (1,0): "build",
        (0,1): "integrate",
        (1,1): "build and integrate"
    }
    try:
        running_operation = operations[operations_tuple]
    except KeyError:
        raise ValueError("Error! No valid opertaion selected. The build and integrate toggles must select with 1 for active or 0 for inactive.")

    # definition raises
    raise_codition_n = not (2 <= multiplicity <= 4 and multiplicity + loop_order <= 4 and loop_order <= multiplicity)
    if(raise_codition_n):
        raise Exception("Error! Maximum order implemented is NNLO. This makes multiplicity to be 2 <= n <= 4 and l may not be larger than n.")
    raise_codition_B = (antenna_family == "B" and multiplicity < 4)
    raise_codition_C = (antenna_family == "C" and multiplicity < 4)
    if(raise_codition_B or raise_codition_C):
        raise Exception("Error! Antenna facilies B and C are not defined for n < 4.")

    return particle_tuple, running_operation

########################################
# initial print
def antcalc_launch_print(AntCalcVersion, running_operation, antenna_family, multiplicity, loop_order, particle_tuple):
    print(AntCalcVersion, "\n")
    print(f"Running {running_operation} for antenna {antenna_family}{multiplicity}{loop_order}.")
    print(f"Ran in the full-massless regime for particles {particle_tuple}.")

### build-side

def get_wolfram_loc(os_name):
    match os_name:
        case "Darwin":
            kernel_loc = "MacOS/WolframKernel" # macOS
        case "Windows":
            kernel_loc = "WolframKernel.exe"
        case "Linux":
            kernel_loc = "Executables/WolframKernel"
        case _:
            raise Exception(f"Error! Unsupported operating system: {os_name!r}.")
    # get system dependent wolfram location
    ws_call = subprocess.run(
        ["wolframscript", "-code", "$InstallationDirectory"],
        capture_output=True,
        text=True,
    )
    # wolfram location
    wolfram_loc = "/".join((ws_call.stdout.strip(), kernel_loc))
    return wolfram_loc

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


def define_build_paths(build_method, os_name):
    match build_method:
        case "legacy":
            wolfram_loc = get_wolfram_loc(os_name)
            form_loc = None
        case "pythonToWl":
            wolfram_loc = get_wolfram_loc(os_name)
            form_loc = get_form_loc()
        case _:
            raise Exception("Error! Expected build methods are legacy and pythonToWl.")
    return wolfram_loc, form_loc

#### runner
def build_runner(build_method, antenna_family, multiplicity, loop_order, operation_tuple, results_dir, path_to_file, os_name):
    if operation_tuple[0] == 1:                 # if build
        print("\nStarting build process...")
        wolfram_loc, form_loc = define_build_paths(build_method, os_name)
        build_stage(build_method, antenna_family, multiplicity, loop_order, wolfram_loc, path_to_file, results_dir)
        print("Build process completed.")

def build_stage(build_method, antenna_family, multiplicity, loop_order, wolfram_loc, path_to_file, results_dir):
    # Each build method writes unintegratedXij.m to its own folder; pythonToWl's is the integrator's input.
    output_destination = "".join(("unintegrated", antenna_family, str(multiplicity), str(loop_order)))
    match build_method:
        case "legacy":
            output_dir = results_dir / "unintegrated_legacy"
            output_dir.mkdir(parents=True, exist_ok=True)
            build_massless_legacy(wolfram_loc, LEGACY_LOADERS_DIR, output_dir, antenna_family, multiplicity, loop_order, output_destination)
        case "pythonToWl":
            output_dir = results_dir / "unintegrated"
            output_dir.mkdir(parents=True, exist_ok=True)
            build_massless_pythonToWl(wolfram_loc, LEGACY_LOADERS_DIR, output_dir, antenna_family, multiplicity, loop_order, output_destination)
        case _:
            raise Exception("Error! Expected build methods are legacy and pythonToWl.")

### integrate-side

#### runner
def integrate_runner(integrate_method, runcard, antenna_family, multiplicity, loop_order, operation_tuple, results_dir, path_to_file, os_name):
    if operation_tuple[1] == 1:                 # if integrate
        print("\nStarting integrate process...")
        integrate_stage(integrate_method, runcard, antenna_family, multiplicity, loop_order, path_to_file, results_dir, os_name)
        print("Integrate process completed.")

def integrate_stage(integrate_method, runcard, antenna_family, multiplicity, loop_order, path_to_file, results_dir, os_name):
    match integrate_method:
        case "legacy":
            output_dir = results_dir / "integrated_legacy"
            output_dir.mkdir(parents=True, exist_ok=True)
            output_destination = "".join(("integrated", antenna_family, str(multiplicity), str(loop_order)))
            integrate_massless_legacy(get_wolfram_loc(os_name), LEGACY_LOADERS_DIR, output_dir, antenna_family, multiplicity, loop_order, output_destination)
        case "kira":
            run = integrate_kira.IntegrationRun(
                antenna_family = antenna_family,
                multiplicity = multiplicity,
                loop_order = loop_order,
                auto_input_path = bool(runcard.get("auto_input_path", 1)),
                manual_input_path = Path(runcard.get("manual_input_path", "")),
                substitute_masters = bool(runcard.get("substitute_masters", 1)),
            )
            integrate_kira.run_integration(run)
        case _:
            raise Exception("Error! Only expected integration methods are legacy and kira.")


########################################
# entry point

if __name__ == "__main__":
    orchestrator(*sys.argv[1:2])            # optional runcard name, without .json; default runcard
