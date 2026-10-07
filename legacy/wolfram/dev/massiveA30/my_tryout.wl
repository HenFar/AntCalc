(*
$LoadAddOns = {"FeynArts"};

<<FeynCalc`
*)

(* feynman diagram *)

diagA30Massive = FeynArts`InsertFields[FeynArts`CreateTopologies[0, 1
      -> 3], {FeynArts`V[1]} -> {FeynArts`F[4, {3}], -FeynArts`F[4, {3}], 
     FeynArts`V[5]}, FeynArts`InsertionLevel -> {FeynArts`Classes}, FeynArts`Model
      -> "SMQCD", FeynArts`ExcludeParticles -> {}];

paintedDiag = FeynArts`Paint[diagA30Massive, ColumnsXRows -> {2, 1}, 
     Numbering -> Simple, SheetHeader -> None, ImageSize -> {512, 256}, DisplayFunction
      -> Identity];

Export["/Users/henriquefarinha/Library/CloudStorage/Dropbox/msc_thesis/thesis_docs/codexAlley/antenna_pipeline/dev/massiveA30/massiveA30_diagrams.png",
      paintedDiag];

(* amplitude computation *)

FCClearScalarProducts[];

SPD[k1, k1] = mQ^2;

SPD[k2, k2] = mQ^2;

SPD[k3, k3] = 0; (* gluon remains massless *)

ampA30Massive =
     FCFAConvert[CreateFeynAmp[diagA30Massive], IncomingMomenta -> {p
          }, OutgoingMomenta -> {k1, k2, k3}, UndoChiralSplittings -> True, ChangeDimension
           -> D, List -> False, SMP -> True, Contract -> True, DropSumOver -> True,
           FinalSubstitutions -> {SMP["m_u"] -> 0, SMP["m_d"] -> 0, SMP["m_s"] 
          -> 0, SMP["m_c"] -> 0, SMP["m_b"] -> mQ, SMP["m_t"] -> 0}] //
     SUNSimplify //
     Simplify;

(* interference *)

interferenceA30Massive = InterfereMAmplitudes[ampA30Massive, ampA30Massive,
      3, ApplyCasimirSubstitution -> True, ApplyDimReg -> True, AntennaType
      -> A, quarkMass -> mQ];

interfA30MassiveCanonical =
     interferenceA30Massive /. {Pair[Momentum[k1, _], Momentum[k1, _]
          ] -> mQ^2, Pair[Momentum[k2, _], Momentum[k2, _]] -> mQ^2, Pair[Momentum[
          k3, _], Momentum[k3, _]] -> 0, Pair[Momentum[k1, _], Momentum[k2, _]]
           -> s12 / 2, Pair[Momentum[k2, _], Momentum[k1, _]] -> s12 / 2, Pair[
          Momentum[k1, _], Momentum[k3, _]] -> s13 / 2, Pair[Momentum[k3, _], Momentum[
          k1, _]] -> s13 / 2, Pair[Momentum[k2, _], Momentum[k3, _]] -> s23 / 2,
           Pair[Momentum[k3, _], Momentum[k2, _]] -> s23 / 2, FeynAmpDenominator[
          PropagatorDenominator[Plus[Times[-1, Momentum[k1, _]], Times[-1, Momentum[
          k3, _]]], mQ]] :> 1 / s13, FeynAmpDenominator[PropagatorDenominator[Plus[
          Momentum[k2, _], Momentum[k3, _]], mQ]] :> 1 / s23} //
     Together //
     Expand //
     Simplify;

interfA30MassiveStripped =
     interfA30MassiveCanonical / (SMP["e"] ^ 2 SMP["g_s"] ^ 2) //
     Together //
     Simplify;

(* to antenna *)

(* consider q2 = (k1 + k2 + k3)^2 = 2 mQ^2 + s12 + s13 + s23 = s123 + 2 mQ^2 *)

MassiveA30BornNormalizationPaper[] :=
     4 ((1 - epsilon) q2 + 2 mf^2);

thesisBornOnShell = MassiveA30BornNormalizationPaper[] /. {mf -> mQ, 
     epsilon -> 0, q2 -> 2 mQ^2 + s12 + s13 + s23} // Together;

derived =
     ((interfA30MassiveStripped /. SUNN -> 3 /. Epsilon -> 0) / ((4/3
          ) (colourNorm /. SUNN -> 3) thesisBornOnShell)) /. q2 -> 2 mQ^2 + s12 +
           s13 + s23 //
     Together //
     Simplify;

Print[derived];
