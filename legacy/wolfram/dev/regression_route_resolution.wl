(* Route declaration regression: no amplitude generation or integration. *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "AntennaPipeline.wl"}]];

expected = {{A, 2, 0}, {A, 3, 0}, {A, 2, 1}, {A, 3, 1}, {A, 2, 2},
  {A, 4, 0}, {B, 4, 0}, {C, 4, 0}};

If[Sort[AntennaSupportedRouteKeys[]] =!= Sort[expected],
  Print["route registry mismatch: ", InputForm[AntennaSupportedRouteKeys[]]];
  Exit[1]
];
If[AntennaRouteVariant[{A, 3, 0}, <|"quarkMass" -> 0|>] =!= "Massless", Exit[1]];
If[AntennaRouteVariant[{A, 3, 0}, <|"quarkMass" -> mQ|>] =!= "Massive", Exit[1]];
If[Lookup[ResolveAntennaRoute[{D, 3, 0}, <||>], "Reason", None] =!= "UnsupportedRoute", Exit[1]];
If[!AssociationQ[AntennaRouteReport[{A, 3, 0}, <|"quarkMass" -> mQ|>]], Exit[1]];
Print["route resolution regression: PASS"];
