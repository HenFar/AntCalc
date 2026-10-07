(* Fast Task 10b guard: A31's runtime masters and IBP normalization already
   implement the required convention, so no additional post-reduction bridge
   may be applied. No antenna build or LiteRed reduction is performed. *)

Get["AntennaPipeline.wl"];

Module[{profile, bridge},
  profile = IBPProfile["A31"];
  bridge = IBPConventionBridgeFactor[profile, True, 0];
  Print["A31 bridge:"];
  Print[bridge];
  Print["A31 bridge is the required identity:"];
  Print[bridge === 1];
];
