(* Development script: probe whether LiteRed accepts the first MX30 basis. *)

(* ::Package:: *)

If[$FrontEnd === Null,
  $FeynCalcStartupMessages = False;
];

Get["LiteRed2`"];

basisRoot =
  FileNameJoin[{DirectoryName[DirectoryName[DirectoryName[$InputFileName]]],
    "generated_bases", "MX30_probe"}];

If[!DirectoryQ[basisRoot],
  CreateDirectory[basisRoot, CreateIntermediateDirectories -> True]
];

SetDim[d];
Declare[{p1, p2, q}, Vector];
Declare[{q2, m2}, Number];

sp[q, q] = q2;

Clear[MX30Basis123];

newBasisResult =
  Check[
    NewDsBasis[
      MX30Basis123,
      {
        sp[p1, p1] - m2,
        sp[p2, p2] - m2,
        sp[-p1 - p2 + q, -p1 - p2 + q],
        sp[-p2 + q, -p2 + q] - m2,
        sp[-p1 + q, -p1 + q] - m2
      },
      {p1, p2},
      CutDs -> {1, 1, 1, 0, 0},
      Append -> True,
      Directory -> basisRoot
    ],
    $Failed
  ];

Print["NewDsBasis result = ", newBasisResult];
Print["CurrentState = ", CurrentState[MX30Basis123]];
Print["Ds = ", Ds[MX30Basis123]];
Print["CutDs = ", CutDs[MX30Basis123]];
