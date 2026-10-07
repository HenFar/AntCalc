prefactor = 16 ^ (-2 + eps) Pi ^ (-5 + 2 eps) / Gamma[1 - 2 eps];

sGamma = P2 ((4 Pi) ^ eps / (16 Pi^2 Gamma[1 - eps])) ^ 2;

sGammaSub[expr_] :=
    Sg expr / sGamma // Simplify;

(* R4 *)

R4init = P2 * prefactor * q2 ^ (2 - 2 eps) (1 - y134) ^ (1 - 2 eps) (
    -Delta4Prime) ^ (-1/2 - eps);

R4mid = (R4init // sGammaSub) /. {(-Delta4Prime) ^ (-1/2 - eps) -> (1
     - z1) ^ (1 - 2 eps) Dy13 ^ (-2 eps) (chi (1 - chi)) ^ (-1/2 - eps)} /.
     {Dy13 ^ (-2 eps) -> y134 (16 y134^2 z1 t (1 - t) v (1 - v)) ^ (-eps)
    } // Simplify

R4ints =
    R4mid //
    Integrate[#, {y134, 0, 1}]& //
    Integrate[#, {z1, 0, 1}]& //
    Integrate[#, {t, 0, 1}]& //
    Integrate[#, {v, 0, 1}]& //
    Integrate[#, {chi, 0, 1}]&;

R4 = R4ints // Simplify;

(* R8a *)

R8ainit = P2 q2 ^ (-2 - 2 eps) prefactor (1 - y134) ^ (-1 - 2 eps) (-
    Delta4Prime) ^ (-1/2 - eps) / (y13 y14 z1 z2);

R8amid = R8ainit /. {(-Delta4Prime) ^ (-1/2 - eps) / y13 -> (1 - z1) 
    ^ (1 - 2 eps) Dy13 ^ (-2 eps) (chi (1 - chi)) ^ (-1/2 - eps) (Dy13 chi
     + y13a) ^ (-1)} /. {y14 -> y134 (1 - z1) v} /. {z2 -> (1 - z1) t};

(* integration is going to be handled as chi -> v -> y134 -> t -> z1 *)

(* chi *)

chiTerms = (chi (1 - chi)) ^ (-1/2 - eps) (Dy13 chi + y13a) ^ (-1);

chiR8aint = Integrate[chiTerms, {chi, 0, 1}];

chiR8ainit = chiR8aint /. {-Dy13 / y13a -> 4 Z / (1 + Z) ^ 2} /. Hypergeometric2F1Regularized[
    a_, b_, c_, x_] :> Hypergeometric2F1[a, b, c, x] / Gamma[1 - 2 eps] /.
     Hypergeometric2F1[1, 1/2 - eps, 1 - 2 eps, 4 Z / (1 + Z) ^ 2] -> (1 
    + Z) ^ 2 Hypergeometric2F1[1, 1 + eps, 1 - eps, Z^2];

chiR8amid = chiR8ainit /. (1 + Z) ^ 2 -> y13a / (y134 A^2) /. Z -> -B /
     A /. A -> Sqrt[(1 - t) (1 - v)] /. B -> Sqrt[z1 t v];

chiR8aSub = chiR8amid[[1]] / chiTerms;

R8aaftchi =
    R8amid * chiR8aSub //
    sGammaSub //
    Simplify;

R8aaftchi = R8aaftchi /. Dy13 -> (t (1 - t) v (1 - v) y134^2 z1 / 16) ^
     (1/2) // Simplify;

(* v *)

vTerms = v ^ (1 - eps) (1 - v) ^ (1 - eps) Hypergeometric2F1[1, 1 + eps,
     1 - eps, z1 t v / ((1 - t) (1 - v))];

vR8aHG = vTerms /. Hypergeometric2F1[1, 1 + eps, 1 - eps, z1 t v / ((
    1 - t) (1 - v))] -> Pochhammer[1 + eps, n] / Pochhammer[1 - eps, n] (
    z1 t / (1 - t)) ^ n v^n (1 - v) ^ (-n);

vR8aint = Integrate[vR8aHG, {v, 0, 1}];

Print[vR8aint];
