(* Fast Task 10b diagnostic: expose any mismatch between the V5b-derived
   source value and the checked-in qkMI runtime artifact. *)

masterDirectory = FileNameJoin[{Directory[], "masterIntegrals"}];
ClearAll["Global`V5b*"];
Get[FileNameJoin[{masterDirectory, "common.wl"}]];
Get[FileNameJoin[{masterDirectory, "V5b.wl"}]];

Module[{sourceValue, artifactValue},
  sourceValue = I V5bBackendScalarPart[];
  artifactValue = Get[FileNameJoin[
    {masterDirectory, "master_values_runtime.wl"}
  ]]["A31"]["qkMI"];
  Print["V5b-derived qkMI source (InputForm):"];
  Print[InputForm[sourceValue]];
  Print["Checked-in qkMI artifact (InputForm):"];
  Print[InputForm[artifactValue]];
  Print["Artifact/source ratio:"];
  Print[FullSimplify[Together[artifactValue/sourceValue]]];
];
