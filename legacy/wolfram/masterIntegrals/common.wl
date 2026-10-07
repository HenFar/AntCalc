MIExpand[expr_, order_:2] :=
  Normal[Series[FunctionExpand[Together[expr]], {eps, 0, order}]];

MIFullExpand[expr_, order_:2] :=
  FullSimplify[MIExpand[expr, order]];

MIBeta[x_, y_] :=
  Gamma[x] Gamma[y] / Gamma[x + y];

MIUnitIntegral[powerA_, powerB_] :=
  MIBeta[powerA + 1, powerB + 1];

A22SGammaMI[] :=
  ((4 Pi)^eps / (16 Pi^2 Gamma[1 - eps]))^2;

R4ExpectedClosedForm[] :=
  A22SGammaMI[] q2^(2 - 2 eps) Gamma[1 - eps]^5 Gamma[2 - 2 eps] /
    (Gamma[3 - 3 eps] Gamma[4 - 4 eps]);

R4ExpectedPackageValue[] :=
  q2^(-2 eps) * (
    (-3*Pi^4)/(8*eps^2) -
    Pi^4/eps +
    (Pi^4*(-53 + 14*Pi^2))/32 -
    (Pi^4*(-2239 + 6*Pi^2 + 3264*Zeta[3])/288) * eps +
    (Pi^4*(1338445 - 141690*Pi^2 + 3468*Pi^4 - 888480*Zeta[3])/17280) * eps^2
  );
