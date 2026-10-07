(* ::Section:: *)

(* Core bootstrap and shared symbolic conventions *)

(* Communicates with:
   - AntennaPipeline.wl, which loads this file first so
     every later layer sees a consistent FeynCalc/FeynArts environment.
   - src/core/kinematics_and_utilities.wl,
     which consumes the propagator and coupling substitutions defined here.
   - The engine files under `src/engines/`, which rely on the globally initialized
     FeynCalc session, renamed symbols, and denominator normalization rules.

   Why this file exists:
   The package uses FeynCalc/FeynArts as a symbolic physics backend.  Their global
   state affects almost every downstream computation, so the project centralizes
   startup choices here instead of letting each route configure the algebra in its
   own way.  That keeps notebook runs and script runs physically equivalent and
   avoids convention drift between antenna families. *)

$RenameFeynCalcObjects = {"MetricTensor" -> "FCMetricTensor", "Factor1"
    -> "FCFactor1", "Factor2" -> "FCFactor2"};
Global`$RenameFeynCalcObjects = $RenameFeynCalcObjects;

(* AntCalc owns the startup presentation in both notebooks and scripts. *)
$FeynCalcStartupMessages = False;
Global`$FeynCalcStartupMessages = False;

$LoadAddOns = {"FeynArts", "FeynHelpers", "FeynCalcLegacy"};
Global`$LoadAddOns = $LoadAddOns;

<<FeynCalc`

FeynArts`$FAVerbose = 0;

(* The tested toolchain is recorded in AntennaPipelineConventionReport[].
   Do not retain a copied version gate from an upstream tutorial here: it would
   turn historical tutorial provenance into a false AntCalc compatibility claim.
   Route regressions, rather than an old minimum-version assertion, establish
   the supported environment. *)

(* prefactors *)

upQuarkElectricCharge = 2/3;

electricCouplingConstant = SMP["e"];

strongCouplingConstant = SMP["g_s"];

(* Keep the electroweak source normalization explicit here so later stripping
   helpers can remove or keep couplings in a controlled, route-independent way.
   The package treats this factor as physics metadata, not as incidental syntax. *)

photonQuarkCoupling = upQuarkElectricCharge * electricCoupling;

(* substitutions *)

(* Translate the abstract adjoint/fundamental Casimirs into explicit SU(N)
   expressions when the downstream route needs colour algebra in one canonical
   representation.  This is used after symbolic simplification so the package can
   postpone committing to a specific colour basis until comparison or extraction
   requires it. *)

CasimirSubs = {CA -> SUNN, CF -> (SUNN^2 - 1) / (2 SUNN)};

(* FeynCalc can package several propagators inside one FeynAmpDenominator head.
   The rest of the pipeline reasons more simply about products of one-denominator
   factors because those map cleanly to Mandelstam invariants and to LiteRed
   denominator families.  These rules normalize the syntax early for that reason. *)

FeynAmpDenSub = {FeynAmpDenominator[PropagatorDenominator[x__], PropagatorDenominator[
   y__]] :> FeynAmpDenominator[PropagatorDenominator[x]] FeynAmpDenominator[
   PropagatorDenominator[y]], FeynAmpDenominator[PropagatorDenominator[x__
   ], PropagatorDenominator[y__], PropagatorDenominator[z__]] :> FeynAmpDenominator[
   PropagatorDenominator[x]] FeynAmpDenominator[PropagatorDenominator[y]
   ] FeynAmpDenominator[PropagatorDenominator[z]], FeynAmpDenominator[PropagatorDenominator[
   x__], PropagatorDenominator[y__], PropagatorDenominator[z__], PropagatorDenominator[
   a__]] :> FeynAmpDenominator[PropagatorDenominator[x]] FeynAmpDenominator[
   PropagatorDenominator[y]] FeynAmpDenominator[PropagatorDenominator[z]
   ] FeynAmpDenominator[PropagatorDenominator[a]]};

(* Some generated amplitudes carry an overall minus sign inside massless
   propagator momenta.  Physically these are the same on-shell channels, but
   if the sign is left in place the route-specific denominator lookup tables
   miss them.  The point of these replacements is not algebraic simplification
   alone; it is compatibility with the project’s canonical invariant naming. *)

NegativePropDenSub = {PropagatorDenominator[Plus[Times[-1, Momentum[k1_,
    D]], Times[-1, Momentum[k2_, D]]], 0] :> PropagatorDenominator[Plus[
   Momentum[k1, D], Momentum[k2, D]], 0], PropagatorDenominator[Plus[Times[
   -1, Momentum[k1_, D]], Times[-1, Momentum[k2_, D]], Times[-1, Momentum[
   k3_, D]]], 0] :> PropagatorDenominator[Plus[Momentum[k1, D], Momentum[
   k2, D], Momentum[k3, D]], 0], PropagatorDenominator[Times[-1, Momentum[
   Plus[k1_, k2_], D]], 0] :> PropagatorDenominator[Momentum[Plus[k1, k2
   ], D], 0]};

(* This lookup is the bridge from explicit propagator structure to the compact
   antenna kinematics used everywhere else in the project.  Converting to
   `s12`, `s123`, etc. makes the expressions comparable to the literature,
   readable in diagnostics, and compatible with the integration families that
   are organized around these invariants rather than raw momentum sums. *)

FeynPropListSubs = {FeynAmpDenominator[PropagatorDenominator[Plus[Momentum[
   k1, D], Momentum[k2, D]], 0]] -> 1 / s12, FeynAmpDenominator[PropagatorDenominator[
   Plus[Momentum[k1, D], Momentum[k3, D]], 0]] -> 1 / s13, FeynAmpDenominator[
   PropagatorDenominator[Plus[Momentum[k1, D], Momentum[k4, D]], 0]] -> 
   1 / s14, FeynAmpDenominator[PropagatorDenominator[Plus[Momentum[k2, D
   ], Momentum[k3, D]], 0]] -> 1 / s23, FeynAmpDenominator[PropagatorDenominator[
   Plus[Momentum[k2, D], Momentum[k4, D]], 0]] -> 1 / s24, FeynAmpDenominator[
   PropagatorDenominator[Plus[Momentum[k3, D], Momentum[k4, D]], 0]] -> 
   1 / s34, FeynAmpDenominator[PropagatorDenominator[Plus[Momentum[k1, D
   ], Momentum[k2, D], Momentum[k3, D]], 0]] -> 1 / s123, FeynAmpDenominator[
   PropagatorDenominator[Plus[Momentum[k1, D], Momentum[k2, D], Momentum[
   k4, D]], 0]] -> 1 / s124, FeynAmpDenominator[PropagatorDenominator[Plus[
   Momentum[k1, D], Momentum[k3, D], Momentum[k4, D]], 0]] -> 1 / s134, 
   FeynAmpDenominator[PropagatorDenominator[Plus[Momentum[k2, D], Momentum[
   k3, D], Momentum[k4, D]], 0]] -> 1 / s234, FeynAmpDenominator[PropagatorDenominator[
   Momentum[Plus[k1, k2], D], 0]] -> 1 / s12, FeynAmpDenominator[PropagatorDenominator[
   Momentum[Plus[k1, k3], D], 0]] -> 1 / s13, FeynAmpDenominator[PropagatorDenominator[
   Momentum[Plus[k1, k4], D], 0]] -> 1 / s14, FeynAmpDenominator[PropagatorDenominator[
   Momentum[Plus[k2, k3], D], 0]] -> 1 / s23, FeynAmpDenominator[PropagatorDenominator[
   Momentum[Plus[k2, k4], D], 0]] -> 1 / s24, FeynAmpDenominator[PropagatorDenominator[
   Momentum[Plus[k3, k4], D], 0]] -> 1 / s34, FeynAmpDenominator[PropagatorDenominator[
   Momentum[Plus[k1, k2, k3], D], 0]] -> 1 / s123, FeynAmpDenominator[PropagatorDenominator[
   Momentum[Plus[k1, k2, k4], D], 0]] -> 1 / s124, FeynAmpDenominator[PropagatorDenominator[
   Momentum[Plus[k1, k3, k4], D], 0]] -> 1 / s134, FeynAmpDenominator[PropagatorDenominator[
   Momentum[Plus[k2, k3, k4], D], 0]] -> 1 / s234};
