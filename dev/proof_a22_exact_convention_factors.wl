(* Small-kernel symbolic proofs for the exact A22 convention factors.
   This file intentionally does not load AntennaPipeline.wl. *)

ClearAll[eps, proofCoefficient, proofResiduals, proofPrint, sGammaPerLoop,
  sEpsilonPerLoop, normalizedLoopRatio, gammaConversion, exactTreeConversion,
  timelikePhase, realTimelikePhase,
  oldBrevePolynomial, oldVirtualPolynomial, oldTreePolynomial,
  oldTreeProduct, treeFactorDifference, a22Core, breveCoefficient,
  breveFiniteDifference, treeMasterLeadingPoleOrders,
  treeFiniteDifferences, treeFirstAffectedOrders,
  oldBreveTreeRatio, exactBreveTreeRatio];

proofCoefficient[expr_, k_Integer] :=
  FullSimplify[FunctionExpand[SeriesCoefficient[expr, {eps, 0, k}]]];
proofResiduals[left_, right_, degrees_List] :=
  AssociationThread[degrees,
    (proofCoefficient[left, #] - proofCoefficient[right, #])& /@ degrees];
proofPrint[label_, value_] := Print[label, " = ", InputForm[value]];

(* Declared loop measures: A22SGamma supplies
   S_Gamma=(4 Pi)^eps/(16 Pi^2 Gamma[1-eps]); A31Ceps supplies
   S_epsilon/(8 Pi^2)=(4 Pi)^eps Exp[-EulerGamma eps]/(8 Pi^2).
   The common 16 Pi^2 per loop is included before taking their ratio. *)
sGammaPerLoop = (4 Pi)^eps/(16 Pi^2 Gamma[1 - eps]);
sEpsilonPerLoop = 8 Pi^2 (4 Pi)^eps Exp[-EulerGamma eps]/(8 Pi^2);
normalizedLoopRatio = FullSimplify[16 Pi^2 sGammaPerLoop/sEpsilonPerLoop];
gammaConversion = FullSimplify[normalizedLoopRatio^2];
timelikePhase = Exp[-2 Pi I eps];
realTimelikePhase = FullSimplify[ComplexExpand[Re[timelikePhase]]];
exactTreeConversion = realTimelikePhase gammaConversion;
proofPrint["Normalized one-loop S_Gamma/S_epsilon ratio", normalizedLoopRatio];
proofPrint["Derived two-loop conversion", gammaConversion];
proofPrint["Real part of timelike phase Exp[-2 Pi I eps]",
  realTimelikePhase];

(* The current Breve polynomial and the separate old tree-route factors are
   comparison data only.  They are not loaded into the runtime pipeline. *)
oldBrevePolynomial = 1 - Pi^2 eps^2/6 - (2 Zeta[3] eps^3)/3 +
  (Pi^4 eps^4)/120;
oldVirtualPolynomial = 1 - Pi^2 eps^2/6 + (26 Zeta[3] eps^3)/3 +
  (Pi^4/120 - 28 Zeta[3]) eps^4;
oldTreePolynomial = 1 - 2 Pi^2 eps^2 - (28 Zeta[3] eps^3)/3 +
  (2 (Pi^4 + 42 Zeta[3]) eps^4)/3;
oldTreeProduct = oldVirtualPolynomial oldTreePolynomial;
treeFactorDifference = exactTreeConversion - oldTreeProduct;

proofPrint["Breve exact-minus-old coefficients eps^0..4",
  proofResiduals[gammaConversion, oldBrevePolynomial, Range[0, 4]]];
proofPrint["Breve exact-minus-old coefficients eps^5..8",
  proofResiduals[gammaConversion, oldBrevePolynomial, Range[5, 8]]];
proofPrint["Old virtual factor minus exact Gamma factor eps^0..4",
  proofResiduals[oldVirtualPolynomial, gammaConversion, Range[0, 4]]];
proofPrint["Old tree factor minus exact cosine eps^0..4",
  proofResiduals[oldTreePolynomial, Cos[2 Pi eps], Range[0, 4]]];
proofPrint["Tree combined exact-minus-old product eps^0..4",
  proofResiduals[exactTreeConversion, oldTreeProduct, Range[0, 4]]];
proofPrint["Tree combined exact-minus-old product eps^5..8",
  proofResiduals[exactTreeConversion, oldTreeProduct, Range[5, 8]]];

exactBreveTreeRatio = FullSimplify[
  gammaConversion/(-gammaConversion Cos[2 Pi eps])];
oldBreveTreeRatio = -oldBrevePolynomial/oldTreeProduct;
proofPrint["Exact Breve-to-tree A22LO master conversion",
  exactBreveTreeRatio];
proofPrint["Exact-minus-old Breve-to-tree ratio eps^0..4",
  proofResiduals[exactBreveTreeRatio, oldBreveTreeRatio, Range[0, 4]]];
proofPrint["Exact-minus-old Breve-to-tree ratio eps^5..8",
  proofResiduals[exactBreveTreeRatio, oldBreveTreeRatio, Range[5, 8]]];

(* The combined tree conversion agrees through eps^4 and first differs at
   eps^5.  The leading poles below are read from the exact source masters, so
   each product change starts at the listed pole order plus five. *)
treeMasterLeadingPoleOrders = <|
  "A22LO" -> -2, "A3" -> -1, "A4" -> -2, "A6" -> -4|>;
treeFirstAffectedOrders = Map[# + 5 &, treeMasterLeadingPoleOrders];
treeFiniteDifferences = Association @ KeyValueMap[
  Function[{name, firstAffected}, name -> If[firstAffected > 0, 0,
    "not established through eps^0"]],
  treeFirstAffectedOrders];
proofPrint["Tree-master changes through eps^0 (A22LO, A3, A4, A6)",
  treeFiniteDifferences];
proofPrint["Tree-master leading-pole orders (A22LO, A3, A4, A6)",
  treeMasterLeadingPoleOrders];
proofPrint["Tree-master first possible changed powers",
  treeFirstAffectedOrders];

(* Breve has a rational coefficient with eps^-2 multiplying a master with
   eps^-2, so the eps^5 factor difference first contributes at eps^1. *)
a22Core = Pi^4 Gamma[1 + eps]^2 Gamma[1 - eps]^6/
  (eps^2 Gamma[2 - 2 eps]^2);
breveCoefficient = (-2 + eps - 2 eps^2)^2/(16 Pi^4 eps^2);
breveFiniteDifference = FullSimplify[FunctionExpand[
  SeriesCoefficient[
    breveCoefficient a22Core (gammaConversion - oldBrevePolynomial),
    {eps, 0, 0}]]];
proofPrint["Breve change through eps^0", breveFiniteDifference];

Quit[];
