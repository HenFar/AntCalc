(* ::Section:: *)
(* Route declarations and resolution

   This is the only registry boundary for supported antenna families.  Family
   files under routes/families/ own editable physics settings; funnels consume
   the resolved association returned here and never inspect an antenna name. *)

AntennaRouteDefinition::usage = "AntennaRouteDefinition[key] returns the editable declaration for one supported antenna family.";
ResolveAntennaRoute::usage = "ResolveAntennaRoute[key, options] resolves a supported antenna family and exactly one named variant into an immutable execution association.";
AntennaRouteReport::usage = "AntennaRouteReport[key, options] returns a concise report of the editable route declaration, selected variant, funnels, adapters, conventions, and validation contract.";
AntennaRouteVariant::usage = "AntennaRouteVariant[key, options] returns the selected named route variant, or Missing when the route cannot be resolved.";
AntennaSupportedRouteKeys::usage = "AntennaSupportedRouteKeys[] returns the canonical keys declared by active supported family files.";

Clear[AntennaRouteDefinitions];
AntennaRouteDefinitions = <||>;

AntennaCanonicalKey[{type_Symbol, multiplicity_Integer, loops_Integer}] :=
  {Symbol[SymbolName[Unevaluated[type]]], multiplicity, loops};
AntennaCanonicalKey[key_] := key;

AntennaRouteRegistryKey[key_] :=
  ToString[AntennaCanonicalKey[key], InputForm];

RegisterAntennaRouteDefinition[definition_Association] :=
  Module[{key = AntennaCanonicalKey[Lookup[definition, "Key", Missing["Key"]]]},
    If[!MatchQ[key, {_Symbol, _Integer, _Integer}], Return[$Failed]];
    AssociateTo[AntennaRouteDefinitions,
      AntennaRouteRegistryKey[key] -> Join[definition, <|"Key" -> key|>]];
    key
  ];

AntennaRouteDefinition[key_] :=
  Lookup[AntennaRouteDefinitions, AntennaRouteRegistryKey[key],
    Missing["UnsupportedRoute", key]];

AntennaSupportedRouteKeys[] := Lookup[Values[AntennaRouteDefinitions], "Key", {}];

AntennaRouteVariantMatchesQ[variant_Association, options_Association] :=
  TrueQ[Quiet@Check[Lookup[variant, "Activation", Function[opts, True]][options], False]];

ResolveAntennaRoute[key_, options_:<||>] :=
  Module[{canonicalKey, declaration, normalizedOptions, variants, matching,
     variantName, variant, build, integration, resolved},
    canonicalKey = AntennaCanonicalKey[key];
    declaration = AntennaRouteDefinition[canonicalKey];
    normalizedOptions = If[AssociationQ[options], options, Association[options]];
    If[MissingQ[declaration],
      Return[<|"Resolved" -> False, "Key" -> canonicalKey,
        "Reason" -> "UnsupportedRoute"|>]
    ];
    variants = Lookup[declaration, "Variants", <||>];
    matching = Select[Keys[variants],
      AntennaRouteVariantMatchesQ[variants[#], normalizedOptions]&];
    If[Length[matching] =!= 1,
      Return[<|"Resolved" -> False, "Key" -> canonicalKey,
        "Reason" -> If[Length[matching] == 0, "NoMatchingVariant", "AmbiguousVariants"],
        "MatchingVariants" -> matching|>]
    ];
    variantName = First[matching];
    variant = variants[variantName];
    build = Join[Lookup[declaration, "Build", <||>], Lookup[variant, "Build", <||>]];
    integration = Join[Lookup[declaration, "Integration", <||>], Lookup[variant, "Integration", <||>]];
    resolved = Join[
      KeyDrop[declaration, {"Variants", "Build", "Integration"}],
      <|"Resolved" -> True, "Variant" -> variantName, "Options" -> normalizedOptions,
        "Build" -> build, "Integration" -> integration,
        "Funnels" -> <|"Build" -> Lookup[build, "Funnel", Missing["NotDeclared"]],
          "Integration" -> Lookup[integration, "Funnel", Missing["NotDeclared"]]|>,
        "Adapters" -> <|"Build" -> Lookup[build, "Adapter", "None"],
          "Integration" -> Lookup[integration, "Adapter", "None"]|>|>
    ];
    resolved
  ];

AntennaRouteVariant[key_, options_:<||>] :=
  Lookup[ResolveAntennaRoute[key, options], "Variant", Missing["UnresolvedVariant"]];

AntennaRouteReport[key_, options_:<||>] :=
  Module[{resolved = ResolveAntennaRoute[key, options]},
    If[!TrueQ[Lookup[resolved, "Resolved", False]], Return[resolved]];
    <|"Key" -> resolved["Key"], "Name" -> resolved["Name"],
      "Variant" -> resolved["Variant"], "Status" -> resolved["Status"],
      "EditFile" -> resolved["EditFile"], "Funnels" -> resolved["Funnels"],
      "Adapters" -> resolved["Adapters"], "Build" -> resolved["Build"],
      "Integration" -> resolved["Integration"],
      "Conventions" -> Lookup[resolved, "Conventions", <||>],
      "Validation" -> Lookup[resolved, "Validation", <||>],
      "Notes" -> Lookup[resolved, "Notes", {}]|>
  ];

MassiveA30ResolvedRouteQ[key_, options_:<||>] :=
  TrueQ[Lookup[ResolveAntennaRoute[key, options], "Variant", None] === "Massive"];

InstallAntennaRouteCompatibilityFacades[] := (
  DownValues[AntennaProfile] = {};
  AntennaProfile[key_] := Module[{resolved = ResolveAntennaRoute[key, <||>]},
    If[!TrueQ[Lookup[resolved, "Resolved", False]], Return[$Failed]];
    Join[
      KeyTake[resolved, {"Key", "Name"}],
      Lookup[resolved, "Build", <||>],
      <|"AntennaType" -> First[resolved["Key"]],
        "NumFinalParticles" -> resolved["Key"][[2]],
        "ConventionProfile" -> Lookup[Lookup[resolved, "Conventions", <||>],
          "Build", BuildAntennaConventionProfile[resolved["Key"]]]|>
    ]
  ];
  DownValues[AntennaIntegrationProfile] = {};
  AntennaIntegrationProfile[key_] := Module[{resolved = ResolveAntennaRoute[key, <||>]},
    If[!TrueQ[Lookup[resolved, "Resolved", False]], Return[$Failed]];
    Join[Lookup[resolved, "Integration", <||>],
      <|"DefaultBackend" -> Switch[Lookup[resolved["Integration"], "Funnel", "IBP"],
        "PaVe", PaVe, _, IBP]|>,
      <|"ConventionProfile" -> Lookup[Lookup[resolved, "Conventions", <||>],
        "Integration", IntegrationAntennaConventionProfile[resolved["Key"]]]|>]
  ];
);
