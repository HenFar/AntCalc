$RenameFeynCalcObjects = {"MetricTensor" -> "FCMetricTensor", "Factor1"
   -> "FCFactor1", "Factor2" -> "FCFactor2"};
If[$Notebooks === False,
  $FeynCalcStartupMessages = False
];

$LoadAddOns = {"FeynArts", "FeynHelpers"};

<<FeynCalc`

$FAVerbose = 0;

FCCheckVersion[9, 3, 1];

(* prefactors *)

upQuarkElectricCharge = 2/3;

electricCouplingConstant = SMP["e"];

strongCouplingConstant = SMP["g_s"];

photonQuarkCoupling = upQuarkElectricCharge * electricCoupling;

(* substitutions *)

CasimirSubs = {CA -> SUNN, CF -> (SUNN^2 - 1) / (2 SUNN)};

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

NegativePropDenSub = {PropagatorDenominator[Plus[Times[-1, Momentum[k1_,
   D]], Times[-1, Momentum[k2_, D]]], 0] :> PropagatorDenominator[Plus[
  Momentum[k1, D], Momentum[k2, D]], 0], PropagatorDenominator[Plus[Times[
  -1, Momentum[k1_, D]], Times[-1, Momentum[k2_, D]], Times[-1, Momentum[
  k3_, D]]], 0] :> PropagatorDenominator[Plus[Momentum[k1, D], Momentum[
  k2, D], Momentum[k3, D]], 0], PropagatorDenominator[Times[-1, Momentum[
  Plus[k1_, k2_], D]], 0] :> PropagatorDenominator[Momentum[Plus[k1, k2
  ], D], 0]};

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
