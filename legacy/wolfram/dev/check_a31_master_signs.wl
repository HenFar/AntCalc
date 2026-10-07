(* Fast Task 10b guard: compare the checked-in runtime A31 values directly
   with the Appendix A.2 V5a/V5b closed forms, including qMI == -I V5a and
   qkMI == -I V5b.  This intentionally avoids loading master helper symbols,
   whose definitions can be preloaded by a Wolfram init file. *)

Module[{artifactValues, expectedQMI, expectedQKMI},
  artifactValues = Get[FileNameJoin[
    {Directory[], "masterIntegrals", "master_values_runtime.wl"}
  ]]["A31"];
  expectedQMI =
    I 2^(-11 + 6 eps) Pi^(-5 + 3 eps) q2^(1 - 3 eps)
      Cos[Pi eps] Gamma[1 - eps]^5 Gamma[1 + eps] /
      (eps Gamma[3 - 3 eps] Gamma[2 - 2 eps]^2);
  expectedQKMI =
    I 2^(-11 + 6 eps) Pi^(-5 + 3 eps) q2^(1 - 3 eps)
      Cos[Pi eps] Gamma[1 - 2 eps] Gamma[1 - eps]^4 Gamma[1 + eps] /
      (eps Gamma[3 - 4 eps] Gamma[2 - 2 eps]^2);
  Print["Checked-in qMI matches Appendix A.2 V5a:"];
  Print[Together[artifactValues["qMI"] / expectedQMI] === 1];
  Print["Checked-in qkMI matches Appendix A.2 V5b:"];
  Print[Together[artifactValues["qkMI"] / expectedQKMI] === 1];
];
