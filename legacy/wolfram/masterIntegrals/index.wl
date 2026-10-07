masterIntegralDirectory =
  Replace[
    DirectoryName[$InputFileName],
    "" :> FileNameJoin[{Directory[], "masterIntegrals"}]
  ];

Get[FileNameJoin[{masterIntegralDirectory, "common.wl"}]];
If[
  FileExistsQ[FileNameJoin[{masterIntegralDirectory, "R3.wl"}]],
  Get[FileNameJoin[{masterIntegralDirectory, "R3.wl"}]]
];
If[
  FileExistsQ[FileNameJoin[{masterIntegralDirectory, "A22LO.wl"}]],
  Get[FileNameJoin[{masterIntegralDirectory, "A22LO.wl"}]]
];
If[
  FileExistsQ[FileNameJoin[{masterIntegralDirectory, "A3.wl"}]],
  Get[FileNameJoin[{masterIntegralDirectory, "A3.wl"}]]
];
If[
  FileExistsQ[FileNameJoin[{masterIntegralDirectory, "A4.wl"}]],
  Get[FileNameJoin[{masterIntegralDirectory, "A4.wl"}]]
];
If[
  FileExistsQ[FileNameJoin[{masterIntegralDirectory, "A6.wl"}]],
  Get[FileNameJoin[{masterIntegralDirectory, "A6.wl"}]]
];
Get[FileNameJoin[{masterIntegralDirectory, "R4.wl"}]];
Get[FileNameJoin[{masterIntegralDirectory, "R8a.wl"}]];
Get[FileNameJoin[{masterIntegralDirectory, "R6.wl"}]];
Get[FileNameJoin[{masterIntegralDirectory, "R8b.wl"}]];
If[
  FileExistsQ[FileNameJoin[{masterIntegralDirectory, "V5a.wl"}]],
  Get[FileNameJoin[{masterIntegralDirectory, "V5a.wl"}]]
];
If[
  FileExistsQ[FileNameJoin[{masterIntegralDirectory, "V5b.wl"}]],
  Get[FileNameJoin[{masterIntegralDirectory, "V5b.wl"}]]
];
If[
  FileExistsQ[FileNameJoin[{masterIntegralDirectory, "V8.wl"}]],
  Get[FileNameJoin[{masterIntegralDirectory, "V8.wl"}]]
];
If[
  FileExistsQ[FileNameJoin[{masterIntegralDirectory, "MX30I1.wl"}]],
  Get[FileNameJoin[{masterIntegralDirectory, "MX30I1.wl"}]]
];
If[
  FileExistsQ[FileNameJoin[{masterIntegralDirectory, "MX30I2.wl"}]],
  Get[FileNameJoin[{masterIntegralDirectory, "MX30I2.wl"}]]
];

MasterIntegralRegistry[] :=
  <|
    "R3" -> If[ValueQ[MasterIntegralR3Data], MasterIntegralR3Data[], Missing["NotAvailable"]],
    "A22LO" -> If[ValueQ[MasterIntegralA22LOData], MasterIntegralA22LOData[], Missing["NotAvailable"]],
    "A3" -> If[ValueQ[MasterIntegralA3Data], MasterIntegralA3Data[], Missing["NotAvailable"]],
    "A4" -> If[ValueQ[MasterIntegralA4Data], MasterIntegralA4Data[], Missing["NotAvailable"]],
    "A6" -> If[ValueQ[MasterIntegralA6Data], MasterIntegralA6Data[], Missing["NotAvailable"]],
    "R4" -> R4Report[],
    "R8a" -> MasterIntegralR8aData[],
    "R6" -> R6Report[],
    "R8b" -> MasterIntegralR8bData[],
    "V5a" -> If[ValueQ[MasterIntegralV5aData], MasterIntegralV5aData[], Missing["NotAvailable"]],
    "V5b" -> If[ValueQ[MasterIntegralV5bData], MasterIntegralV5bData[], Missing["NotAvailable"]],
    "V8" -> If[ValueQ[MasterIntegralV8Data], MasterIntegralV8Data[], Missing["NotAvailable"]],
    "MX30I1" -> If[ValueQ[MasterIntegralMX30I1Data], MasterIntegralMX30I1Data[], Missing["NotAvailable"]],
    "MX30I2" -> If[ValueQ[MasterIntegralMX30I2Data], MasterIntegralMX30I2Data[], Missing["NotAvailable"]]
  |>;
