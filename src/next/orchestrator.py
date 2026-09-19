import json
from pathlib import Path
from wolframclient.evaluation import WolframLanguageSession
from wolframclient.language import wl, wlexpr
import platform
import subprocess

########################################
## setup

AntCalcVersion = "AntCalc 0.4.0"

########################################
## setup

# pathing for this file and the json runcard (set for just one card, may need to change later)
here = Path(__file__).parent
runcard = json.load(open(here.parent.parent / "runcards" / "runcard.json"))

# define os and wolfram kernel location
os_name = platform.system()

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

########################################
## runcard

antenna_family = runcard["family"]        # antenna family e.g. A, B, C, ...
multiplicity = runcard["multiplicity"]     # number of final-state particles n
loop_order = runcard["loop_order"]         # number of loops l

# particle masses
particle1_mass = runcard["p1_mass"]
particle2_mass = runcard["p2_mass"]
particle3_mass = runcard["p3_mass"]
particle4_mass = runcard["p4_mass"]
particle_mass_tuple = (particle1_mass, particle2_mass, particle3_mass, particle4_mass)[:multiplicity]

# operations
operation_tuple = (runcard["build"], runcard["integrate"])
build_method = runcard["build_method"]
integrate_method = runcard["integrate_method"]

########################################
## definitions
antenna_particles = {
    "A": ("q", "barq", "g", "g"),
    "B": ("q", "barq", "qprime", "barqprime"),
    "C": ("q", "barq", "q", "barq")
}
if antenna_family not in antenna_particles:
    raise ValueError(f"Unknown antenna family: {antenna_family!r}. Currently implemented families are {list(antenna_particles)}")
particle_tuple = antenna_particles[antenna_family][:multiplicity]

# build and/or integrate defs
operations = {
    (1,0): "build",
    (0,1): "integrate",
    (1,1): "build and integrate"
}
try:
    running_operation = operations[operation_tuple]
except KeyError:
    raise ValueError("Error! No valid opertaion selected. The build and integrate toggles must select with 1 for active or 0 for inactive.")

# mass defs
if not any(particle_mass_tuple):
    mass_condition = "massless"
else:
    mass_condition = "massive"

# definition raises
raise_codition_n = not (2 <= multiplicity <= 4 and multiplicity + loop_order <= 4 and loop_order <= multiplicity)
if(raise_codition_n):
    raise Exception("Error! Maximum order implemented is NNLO. This makes multiplicity to be 2 <= n <= 4 and l may not be larger than n.")
raise_codition_B = (antenna_family == "B" and multiplicity < 4)
raise_codition_C = (antenna_family == "C" and multiplicity < 4)
if(raise_codition_B or raise_codition_C):
    raise Exception("Error! Antenna facilies B and C are not defined for n < 4.")
raise_condition_masses = (particle1_mass != particle2_mass or particle3_mass != particle4_mass)
if(raise_condition_masses):
    raise Exception("Error! At the moment only complete hard-parton massive cases are implemented.")

########################################
# initial print
print(AntCalcVersion, "\n")
print(f"Running {running_operation} for antenna {antenna_family}{multiplicity}{loop_order}.")
if(mass_condition == "massless"):
    print(f"Ran in the full-massless regime for particles {particle_tuple}.")
else:
    print(f"Ran in the massive regime with masses {particle_mass_tuple} for the respective particles {particle_tuple}.")


########################################
# build stage (first prototype)

output_destination_build = "".join(("build", antenna_family, str(multiplicity), str(loop_order)))

def build_stage(runcard):
    with WolframLanguageSession(wolfram_loc) as session:
        session.evaluate(wl.Get(str(here / "build_pipeline.wl")))
        session.evaluate(wl.Put(
            session.evaluate(wlexpr(f"BuildAntenna[{runcard["family"]}, {runcard["multiplicity"]}, {runcard["loop_order"]}]")),
            str(here.parent.parent / "results" / f"{output_destination_build}.m"),
        ))

output_destination_build_p1p2_massive = "".join(("build", antenna_family, str(multiplicity), str(loop_order), "p1p2Massive"))

def build_stage_p1p2_massive(runcard):       # currently only works for A30
    with WolframLanguageSession(wolfram_loc) as session:
        session.evaluate(wl.Get(str(here / "build_pipeline.wl")))
        session.evaluate(wl.Put(
            session.evaluate(wlexpr(f"BuildAntenna[{runcard["family"]}, {runcard["multiplicity"]}, {runcard["loop_order"]}, quarkMass -> {runcard["p1_mass"]}]")),
            str(here.parent.parent / "results" / f"{output_destination_build_p1p2_massive}.m"),
        ))

hard_parton_mass_tuple = particle_mass_tuple[:2]

if operation_tuple[0] == 1:                 # if build
    print("\nStarting build process...")
    match mass_condition:
        case "massless":
            build_stage(runcard)
        case "massive":
            if(hard_parton_mass_tuple[0] != 0 and hard_parton_mass_tuple[1] != 0):
                build_stage_p1p2_massive(runcard)
            else:
                raise Exception("Error! Massive topologies where only one hard parton in massive are not yet implemented.")
        case _:
            raise Exception(f"Error! Unknown mass condition: {mass_condition!r}.")
    print("Build process completed.")


########################################
# integrate stage (first prototype)

output_destination_integrate = "".join(("integrate", antenna_family, str(multiplicity), str(loop_order)))

def integrate_stage(runcard):
    match integrate_method:
        case "mathematica":
            with WolframLanguageSession(wolfram_loc) as session:
                session.evaluate(wl.Get(str(here / "build_pipeline.wl")))
                session.evaluate(wl.Get(str(here / "integrate_pipeline.wl")))
                session.evaluate(wl.Put(
                    session.evaluate(wlexpr(f"BuildAndIntegrateAntenna[{runcard["family"]}, {runcard["multiplicity"]}, {runcard["loop_order"]}]")),
                    str(here.parent.parent / "results" / f"{output_destination_integrate}.m"),
            ))
        case "kira":
            raise Exception("At the moment, the reduction method via kira is under development.")
        case _:
            raise Exception(f"Error! Unknown integrate method: {integrate_method!r}.")

output_destination_integrate_p1p2_massive = "".join(("integrate", antenna_family, str(multiplicity), str(loop_order), "p1p2Massive"))

def integrate_stage_p1p2_massive(runcard):       # currently only works for A30
    with WolframLanguageSession(wolfram_loc) as session:
        session.evaluate(wl.Get(str(here / "build_pipeline.wl")))
        session.evaluate(wl.Get(str(here / "integrate_pipeline.wl")))
        session.evaluate(wl.Put(
            session.evaluate(wlexpr(f"BuildAndIntegrateAntenna[{runcard["family"]}, {runcard["multiplicity"]}, {runcard["loop_order"]}, quarkMass -> {runcard["p1_mass"]}]")),
            str(here.parent.parent / "results" / f"{output_destination_integrate_p1p2_massive}.m"),
        ))

if operation_tuple[1] == 1:                 # if integrate
    print("\nStarting integrate process...")
    match mass_condition:
        case "massless":
            integrate_stage(runcard)
        case "massive":
            if(hard_parton_mass_tuple[0] != 0 and hard_parton_mass_tuple[1] != 0):
                integrate_stage_p1p2_massive(runcard)
            else:
                raise Exception("Error! Massive topologies where only one hard parton in massive are not yet implemented.")
        case _:
            raise Exception(f"Error! Unknown mass condition: {mass_condition!r}.")
    print("Integrate process completed.")
