(*************************************************)

(*
  File role and communication map
  -------------------------------
  This file communicates with:
    - src/engines/integration_pave.wl and src/engines/integration_ibp.wl, whose
      raw integrated outputs are post-processed here.
    - src/routes/integration_workflows.wl, which calls these helpers to convert
      backend-integrated objects into public integrated antennae.
    - src/interface/paper_targets.wl, whose encoded targets are reused for the
      integrated residual diagnostics defined later in this file.

  Why this file exists:
  Backend integration does not always return the final literature object
  directly.  Sometimes it returns a colour bracket or T-function quantity that
  still needs subtraction-term and convention-level post-processing.  This file
  isolates that final physics translation step.

  Integrated antenna extraction.
  IBP and PaVe backends integrate the objects they are given.  For some
  antennae the integrated object is naturally a colour bracket in a T-function,
  not yet the final integrated antenna quoted in the subtraction literature.
  This layer applies those T-to-antenna formulae explicitly.
*)

(*************************************************)

IntegratedAntennaTTerms::usage =
  "IntegratedAntennaTTerms[key, integratedRaw, ...] converts a backend-integrated object into the T-function pieces used by the literature formulae.";

ExtractIntegratedAntenna::usage =
  "ExtractIntegratedAntenna[key, tTerms, ...] converts T-function pieces into the final integrated antennae returned publicly.";

A31PaperConventionFactor::usage =
  "A31PaperConventionFactor[] returns the overall convention factor used when mapping integrated A31 objects to the paper normalization.";

IntegratedAntennaSeries::usage =
  "IntegratedAntennaSeries[expr, order] truncates and simplifies an epsilon series in the package convention.";

IntegratedAntennaDependencyExpansionOrder::usage =
  "IntegratedAntennaDependencyExpansionOrder[order] returns the lower-order epsilon depth needed by subtraction terms at the requested final order.";

IntegratedA21SubtractionSeries::usage =
  "IntegratedA21SubtractionSeries[order] returns the encoded integrated A21 series used in higher-order antenna reconstructions.";

IntegratedA30SubtractionSeries::usage =
  "IntegratedA30SubtractionSeries[order] returns the encoded integrated A30 series used in higher-order antenna reconstructions.";

IntegratedLowerAntenna::usage =
  "IntegratedLowerAntenna[key, order] memoizes the lower-order integrated antenna building blocks needed by higher-order extraction formulae.";

IntegratedAntennaSeriesSafe::usage =
  "IntegratedAntennaSeriesSafe[expr, order] applies series truncation while preserving $Failed outputs unchanged.";

SafeIntegratedResidualSimplify::usage =
  "SafeIntegratedResidualSimplify[expr] simplifies an integrated residual with extra safeguards around singular intermediate forms.";

A31TTermTargets::usage =
  "A31TTermTargets[order] returns the encoded literature targets for the integrated A31 T-function brackets.";

A31IntegratedAntennaTargets::usage =
  "A31IntegratedAntennaTargets[order] returns the encoded literature targets for the final integrated A31 antennae.";

A31TTermTargetForComponent::usage =
  "A31TTermTargetForComponent[component, order] returns the encoded T-function target for one public A31 component.";

A31IntegratedAntennaTargetForComponent::usage =
  "A31IntegratedAntennaTargetForComponent[component, order] returns the encoded final integrated target for one public A31 component.";

A31TargetResidualAssociation::usage =
  "A31TargetResidualAssociation[result, targets] returns the residual of one A31 expression against each public component target label.";

A31IntegratedResiduals::usage =
  "A31IntegratedResiduals[result, targets] computes diagnostic residuals for the integrated A31 route.";

A22TTermTargets::usage =
  "A22TTermTargets[order] returns the encoded literature targets for the integrated A22 T-function brackets.";

A22TTermTargetForComponent::usage =
  "A22TTermTargetForComponent[component, order] returns the encoded T-function target for one public A22 component.";

A22ResidualSimplify::usage =
  "A22ResidualSimplify[expr] applies the special simplification strategy used by A22 diagnostic residuals.";

A22TTermResiduals::usage =
  "A22TTermResiduals[result, ...] computes diagnostic residuals for A22 T-function outputs.";

A22IntegratedResiduals::usage =
  "A22IntegratedResiduals[result, ...] computes diagnostic residuals for final integrated A22 antennae.";

Options[IntegratedAntennaTTerms] = {ExpansionOrder -> 2, Component -> All};

Options[ExtractIntegratedAntenna] = {ExpansionOrder -> 2, Component -> All};

(* A31PaperConventionFactor[]
   ==========================
   Overall convention factor used when mapping the integrated A31 backend output
   into the paper normalization. *)
A31PaperConventionFactor[] :=
  2 Pi^2;

(* IntegratedAntennaSeries[expr, order]
   ====================================
   Truncate and simplify an epsilon series in the package convention. *)
IntegratedAntennaSeries[expr_, order_Integer] :=
  Module[{eps},
    eps = FeynCalc`Epsilon;
    Normal[Series[expr, {eps, 0, order}]] //
      FullSimplify //
      Collect[#, eps]&
  ];

IntegratedAntennaDependencyExpansionOrder[order_Integer] :=
  order + 2;

(* The lower-order integrated A21 and A30 series are encoded here because
   higher-order extraction formulae depend on them as subtraction building
   blocks.  Treating them as explicit functions rather than inline constants
   makes that dependency visible to later readers. *)
IntegratedA21SubtractionSeries[order_Integer] :=
  Module[{eps, series},
    eps = FeynCalc`Epsilon;
    series =
      -1/eps^2 - 3/(2 eps) - 4 + 7 Pi^2/12 +
        eps (-8 + 7 Pi^2/8 + 7 Zeta[3]/3) +
        eps^2 (-16 + 7 Pi^2/3 + 7 Zeta[3]/2 - 73 Pi^4/1440);
    IntegratedAntennaSeries[series, order]
  ];

IntegratedA30SubtractionSeries[order_Integer] :=
  Module[{eps, series},
    eps = FeynCalc`Epsilon;
    series =
      1/eps^2 + 3/(2 eps) + 19/4 - 7 Pi^2/12 +
        eps (109/8 - 7 Pi^2/8 - 25 Zeta[3]/3) +
        eps^2 (639/16 - 133 Pi^2/48 - 25 Zeta[3]/2 -
          71 Pi^4/1440);
    IntegratedAntennaSeries[series, order]
  ];

IntegratedLowerAntenna[{a_Symbol /; SymbolName[a] === "A", 2, 1}, order_Integer] :=
  IntegratedLowerAntenna[{a, 2, 1}, order] =
    IntegratedA21SubtractionSeries[order];

IntegratedLowerAntenna[{a_Symbol /; SymbolName[a] === "A", 3, 0}, order_Integer] :=
  IntegratedLowerAntenna[{a, 3, 0}, order] =
    IntegratedA30SubtractionSeries[order];

IntegratedAntennaSeriesSafe[expr_, order_Integer] :=
  If[expr === $Failed,
    $Failed
    ,
    IntegratedAntennaSeries[expr, order]
  ];

SafeIntegratedResidualSimplify[expr_] :=
  Module[{togetherResidual, simplifiedResidual},
    togetherResidual =
      Quiet[
        Check[Together[expr], expr],
        {Power::infy, Infinity::indet}
      ];
    If[TrueQ[togetherResidual === 0],
      Return[0]
    ];
    simplifiedResidual =
      Quiet[
        Check[
          togetherResidual //
            FunctionExpand //
            FullSimplify,
          togetherResidual
        ],
        {Power::infy, Infinity::indet}
      ];
    If[TrueQ[Together[simplifiedResidual] === 0],
      0
      ,
      simplifiedResidual
    ]
  ];

(* IntegratedAntennaTTerms[key, integratedRaw, ...]
   ================================================
   Convert backend-integrated objects into the T-function-like pieces used by
   the literature formulae.

   Notes
     For A31 and A22 this stage is where UV counterterm pieces involving lower
     integrated antennae are applied.  Keeping that step separate from the raw
     backend makes the physics bookkeeping much easier to audit. *)
IntegratedAntennaTTerms[{a_Symbol /; SymbolName[a] === "A", 3, 1}, integratedRaw_List, OptionsPattern[]] :=
  Module[{eps, order, dependencyOrder, integratedA30, rawPaper, tTerms},
    eps = FeynCalc`Epsilon;
    order = OptionValue["ExpansionOrder"];
    dependencyOrder = IntegratedAntennaDependencyExpansionOrder[order];
    integratedA30 = IntegratedLowerAntenna[{a, 3, 0}, dependencyOrder];
    rawPaper = A31PaperConventionFactor[] integratedRaw;
    tTerms = {
      rawPaper[[1]] - 11/(6 eps) integratedA30,
      rawPaper[[2]],
      rawPaper[[3]] - (-2/(6 eps)) integratedA30
    };
    IntegratedAntennaSeries[#, order]& /@ tTerms
  ];

(* A31 scalar route: the raw colour coefficients can be reduced independently.
   Apply exactly the counterterm belonging to the requested coefficient before
   returning its one-component T term. *)
IntegratedAntennaTTerms[{a_Symbol /; SymbolName[a] === "A", 3, 1}, integratedRaw_, OptionsPattern[]] :=
  Module[{eps, order, dependencyOrder, integratedA30, rawPaper, component},
    eps = FeynCalc`Epsilon;
    order = OptionValue["ExpansionOrder"];
    component = CanonicalAntennaComponentName[OptionValue["Component"]];
    dependencyOrder = IntegratedAntennaDependencyExpansionOrder[order];
    integratedA30 = IntegratedLowerAntenna[{a, 3, 0}, dependencyOrder];
    rawPaper = A31PaperConventionFactor[] integratedRaw;
    Switch[component,
      "Leading",
        IntegratedAntennaSeries[rawPaper - 11/(6 eps) integratedA30, order]
      ,
      "Subleading",
        IntegratedAntennaSeries[rawPaper, order]
      ,
      "Nf",
        IntegratedAntennaSeries[rawPaper - (-2/(6 eps)) integratedA30, order]
      ,
      _,
        integratedRaw
    ]
  ];

(* A22 TwoLoopTree: {Leading, Subleading, Nf} list from a combined run.
   UV coupling renormalization: T_ren = T_bare - (beta0/eps) * A21, decomposed by colour.
   Leading gets -(11/6)/eps, Subleading gets nothing, Nf gets +(1/3)/eps. *)
IntegratedAntennaTTerms[{a_Symbol /; SymbolName[a] === "A", 2, 2}, integratedRaw_List, OptionsPattern[]] :=
  Module[{eps, order, dependencyOrder, intA21, tTerms},
    eps = FeynCalc`Epsilon;
    order = OptionValue["ExpansionOrder"];
    dependencyOrder = IntegratedAntennaDependencyExpansionOrder[order];
    intA21 = IntegratedLowerAntenna[{a, 2, 1}, dependencyOrder];
    Which[
      Length[integratedRaw] === 3,
        tTerms = {
          integratedRaw[[1]] - 11/(6 eps) intA21,
          integratedRaw[[2]],
          integratedRaw[[3]] - (-2/(6 eps)) intA21
        };
        IntegratedAntennaSeriesSafe[#, order]& /@ tTerms
      ,
      Length[integratedRaw] === 4,
        tTerms = {
          If[integratedRaw[[1]] === $Failed, $Failed,
            integratedRaw[[1]] - 11/(6 eps) intA21],
          integratedRaw[[2]],
          If[integratedRaw[[3]] === $Failed, $Failed,
            integratedRaw[[3]] - (-2/(6 eps)) intA21],
          integratedRaw[[4]]
        };
        IntegratedAntennaSeriesSafe[#, order]& /@ tTerms
      ,
      True,
        integratedRaw
    ]
  ];

(* A22 TwoLoopTree scalar route: a single component reduced in isolation.
   The Component option identifies which colour bracket and applies its counterterm. *)
IntegratedAntennaTTerms[{a_Symbol /; SymbolName[a] === "A", 2, 2}, integratedRaw_, OptionsPattern[]] :=
  Module[{eps, order, dependencyOrder, intA21, component},
    eps = FeynCalc`Epsilon;
    order = OptionValue["ExpansionOrder"];
    component = CanonicalAntennaComponentName[OptionValue["Component"]];
    dependencyOrder = IntegratedAntennaDependencyExpansionOrder[order];
    intA21 = IntegratedLowerAntenna[{a, 2, 1}, dependencyOrder];
    Switch[component,
      "Leading",
        IntegratedAntennaSeries[integratedRaw - 11/(6 eps) intA21, order]
      ,
      "Nf",
        IntegratedAntennaSeries[integratedRaw - (-2/(6 eps)) intA21, order]
      ,
      _,
        integratedRaw
    ]
  ];

IntegratedAntennaTTerms[key_, integratedRaw_, OptionsPattern[]] :=
  integratedRaw;

ExtractIntegratedAntenna[{a_Symbol /; SymbolName[a] === "A", 3, 1}, tTerms_List, OptionsPattern[]] :=
  Module[{order, dependencyOrder, integratedA21, integratedA30, product,
     finalAntennae},
    order = OptionValue["ExpansionOrder"];
    dependencyOrder = IntegratedAntennaDependencyExpansionOrder[order];
    integratedA21 = IntegratedLowerAntenna[{a, 2, 1}, dependencyOrder];
    integratedA30 = IntegratedLowerAntenna[{a, 3, 0}, dependencyOrder];
    product = IntegratedAntennaSeries[integratedA21 integratedA30, order];
    finalAntennae = {
      tTerms[[1]] - product,
      -(tTerms[[2]] + product),
      tTerms[[3]]
    };
    IntegratedAntennaSeries[#, order]& /@ finalAntennae
  ];

(* A31 scalar route: mirror the appropriate slot of the combined extraction.
   The common A21 A30 product is therefore retained without reducing the
   unrelated raw colour components. *)
ExtractIntegratedAntenna[{a_Symbol /; SymbolName[a] === "A", 3, 1}, tTerm_, OptionsPattern[]] :=
  Module[{order, dependencyOrder, integratedA21, integratedA30, product,
     component},
    order = OptionValue["ExpansionOrder"];
    component = CanonicalAntennaComponentName[OptionValue["Component"]];
    dependencyOrder = IntegratedAntennaDependencyExpansionOrder[order];
    integratedA21 = IntegratedLowerAntenna[{a, 2, 1}, dependencyOrder];
    integratedA30 = IntegratedLowerAntenna[{a, 3, 0}, dependencyOrder];
    product = IntegratedAntennaSeries[integratedA21 integratedA30, order];
    Switch[component,
      "Leading",
        IntegratedAntennaSeries[tTerm - product, order]
      ,
      "Subleading",
        IntegratedAntennaSeries[-(tTerm + product), order]
      ,
      "Nf",
        IntegratedAntennaSeries[tTerm, order]
      ,
      _,
        tTerm
    ]
  ];

(* For A22 the matched colour-bracket objects are already the final public
   integrated antenna components in this project:
   {A22, tildeA22, hatA22} come from the tree/two-loop T object, while
   breveA22 comes from the separate one-loop-self T object.  The extraction
   layer therefore preserves the component values but makes the routing
   explicit so the public API can return the full four-slot object by default. *)
ExtractIntegratedAntenna[{a_Symbol /; SymbolName[a] === "A", 2, 2}, tTerms_List, OptionsPattern[]] :=
  tTerms;

ExtractIntegratedAntenna[{a_Symbol /; SymbolName[a] === "A", 2, 2}, tTerm_, OptionsPattern[]] :=
  tTerm;

ExtractIntegratedAntenna[key_, tTerms_, OptionsPattern[]] :=
  tTerms;

(*************************************************)

(* Reference targets for integrated A31 diagnostics *)

A31TTermTargets[order_Integer] :=
  Module[{eps, targets},
    eps = FeynCalc`Epsilon;
    targets = {
      -5/(4 eps^4) - 67/(12 eps^3) +
        (-141/8 + 13 Pi^2/8)/eps^2 +
        (-1481/24 + 107 Pi^2/18 + 55 Zeta[3]/3)/eps +
        (-10385/48 + 64 Pi^2/3 + 1265 Zeta[3]/18 - 41 Pi^4/96),
      1/eps^4 + 3/eps^3 + (93/8 - 4 Pi^2/3)/eps^2 +
        (79/2 - 15 Pi^2/4 - 53 Zeta[3]/3)/eps +
        (1069/8 - 697 Pi^2/48 - 91 Zeta[3]/2 + 19 Pi^4/72),
      (* The older arXiv v2 TeX printed 19/2 here. The corrected arXiv v3
         source, Eq. (5.20), has 19/12, matching the public convention and
         the paper's NNLO pole cancellation. *)
      1/(3 eps^3) + 1/(2 eps^2) +
        (19/12 - 7 Pi^2/36)/eps +
        (109/24 - 7 Pi^2/24 - 25 Zeta[3]/9)
    };
    IntegratedAntennaSeries[#, order]& /@ targets
  ];

A31IntegratedAntennaTargets[order_Integer] :=
  Module[{eps, targets},
    eps = FeynCalc`Epsilon;
    targets = {
      -1/(4 eps^4) - 31/(12 eps^3) +
        (-53/8 + 11 Pi^2/24)/eps^2 +
        (-647/24 + 22 Pi^2/9 + 23 Zeta[3]/3)/eps +
        (-5231/48 + 17 Pi^2/2 + 689 Zeta[3]/18 - 41 Pi^4/480),
      (-5/8 + Pi^2/6)/eps^2 +
        (-19/4 + Pi^2/4 + 7 Zeta[3])/eps +
        (-105/4 + 27 Pi^2/16 + 27 Zeta[3]/2 + 7 Pi^4/90),
      1/(3 eps^3) + 1/(2 eps^2) +
        (19/12 - 7 Pi^2/36)/eps +
        (109/24 - 7 Pi^2/24 - 25 Zeta[3]/9)
    };
    IntegratedAntennaSeries[#, order]& /@ targets
  ];

A31TTermTargetForComponent[component_, order_Integer] :=
  Module[{componentName, targets},
    componentName = CanonicalAntennaComponentName[component];
    targets = A31TTermTargets[order];
    Switch[componentName,
      "Leading",
        targets[[1]]
      ,
      "Subleading",
        targets[[2]]
      ,
      "Nf",
        targets[[3]]
      ,
      _,
        Missing["UnknownA31Component", componentName]
    ]
  ];

A31IntegratedAntennaTargetForComponent[component_, order_Integer] :=
  Module[{componentName, targets},
    componentName = CanonicalAntennaComponentName[component];
    targets = A31IntegratedAntennaTargets[order];
    Switch[componentName,
      "Leading",
        targets[[1]]
      ,
      "Subleading",
        targets[[2]]
      ,
      "Nf",
        targets[[3]]
      ,
      _,
        Missing["UnknownA31Component", componentName]
    ]
  ];

A31TargetResidualAssociation[result_, targets_List] :=
  AssociationThread[
    {"Leading", "Subleading", "Nf"},
    SafeIntegratedResidualSimplify[result - #]& /@ targets
  ];

A31IntegratedResiduals[result_List, targets_List] :=
  MapThread[SafeIntegratedResidualSimplify[#1 - #2]&, {result, targets}];

(*************************************************)

(* Reference targets for integrated A22 T-object diagnostics *)

A22TTermTargets[order_Integer] :=
  Module[{eps, targets},
    eps = FeynCalc`Epsilon;
    targets = {
      1/(4 eps^4) + 17/(8 eps^3) +
        (433/144 - Pi^2/2)/eps^2 +
        (4045/864 - 83 Pi^2/48 + 7 Zeta[3]/12)/eps +
        (-9083/5184 - 2153 Pi^2/864 + 13 Zeta[3]/9 +
          263 Pi^4/1440),
      -1/(4 eps^4) - 3/(4 eps^3) +
        (-41/16 + 13 Pi^2/24)/eps^2 +
        (-221/32 + 3 Pi^2/2 + 8 Zeta[3]/3)/eps +
        (-1151/64 + 475 Pi^2/96 + 29 Zeta[3]/4 -
          59 Pi^4/288),
      -1/(4 eps^3) - 1/(9 eps^2) +
        (65/216 + Pi^2/24)/eps +
        (4085/1296 - 91 Pi^2/216 + Zeta[3]/18),
      1/(4 eps^4) + 3/(4 eps^3) +
        (41/16 - Pi^2/24)/eps^2 +
        (7 - Pi^2/8 + 7 Zeta[3]/6)/eps +
        (18 - 41 Pi^2/96 - 7 Zeta[3]/2 - 7 Pi^4/480)
    };
    IntegratedAntennaSeries[#, order]& /@ targets
  ];

A22TTermTargetForComponent[component_, order_Integer] :=
  Module[{componentName, position},
    componentName = CanonicalAntennaComponentName[component];
    position =
      FirstPosition[
        CanonicalAntennaComponentName /@ {Leading, Subleading, Nf, Breve},
        componentName,
        Missing["UnknownComponent"]
      ];
    If[position === Missing["UnknownComponent"],
      Missing["UnknownA22Component", component]
      ,
      A22TTermTargets[order][[position[[1]]]]
    ]
  ];

A22ResidualSimplify[expr_] :=
  FullSimplify[FunctionExpand[expr]];

A22TTermResiduals[result_List, order_Integer] :=
  MapThread[
    A22ResidualSimplify[#1 - #2]&,
    {result, A22TTermTargets[order]}
  ];

A22TTermResiduals[result_, component_, order_Integer] :=
  Module[{target},
    target = A22TTermTargetForComponent[component, order];
    If[MissingQ[target],
      target
      ,
      A22ResidualSimplify[result - target]
    ]
  ];

A22IntegratedResiduals[result_List, order_Integer] :=
  A22TTermResiduals[result, order];

A22IntegratedResiduals[result_, component_, order_Integer] :=
  A22TTermResiduals[result, component, order];
