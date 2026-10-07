(*************************************************)

(*
  Public result cache utilities.
  The computation pipeline remains the source of truth; this layer only
  stores and restores generated public-route outputs on disk.
*)

(*************************************************)

DefaultStoredResultsRoot::usage =
  "DefaultStoredResultsRoot[] returns the repo-local root directory used for generated stored results.";

ResolveStoredResultsRoot::usage =
  "ResolveStoredResultsRoot[root] resolves Automatic to the default stored-results root and otherwise passes explicit roots through.";

StoredResultsEnabledQ::usage =
  "StoredResultsEnabledQ[useStored, storeStored, refreshStored] returns True when any stored-result behavior has been requested.";

StoredResultsSubdirectory::usage =
  "StoredResultsSubdirectory[routeKind] returns the subdirectory name used for the selected cached public route family.";

StoredResultsRouteKindFromSubdirectory::usage =
  "StoredResultsRouteKindFromSubdirectory[subdir] maps a cache subdirectory name back to its public route kind.";

NormalizeStoredResultRouteKind::usage =
  "NormalizeStoredResultRouteKind[routeKind] normalizes route-kind selectors used by the cache inspection helpers.";

NormalizeStoredResultOptionAssociation::usage =
  "NormalizeStoredResultOptionAssociation[assoc] converts option keys into the string-keyed form used by the cache key builders.";

NormalizeStoredResultKeyValue::usage =
  "NormalizeStoredResultKeyValue[value] recursively normalizes values before they are hashed into stored-result request keys.";

StoredResultKeyAssociation::usage =
  "StoredResultKeyAssociation[routeKind, request] builds the normalized association used as the canonical stored-result key.";

StoredResultKeyHash::usage =
  "StoredResultKeyHash[key] returns the deterministic SHA-based hash used in stored-result filenames.";

SanitizeStoredResultLabel::usage =
  "SanitizeStoredResultLabel[label] converts a human-readable cache label into a filename-safe stem.";

StoredResultTypeLabel::usage =
  "StoredResultTypeLabel[type] converts an antenna or model symbol into the label fragment used by stored-result filenames.";

StoredResultPath::usage =
  "StoredResultPath[routeKind, key, root, label] returns the on-disk path for a stored-result entry.";

StoredResultIdentifier::usage =
  "StoredResultIdentifier[root, path] returns the root-relative identifier used by the cache inspection helpers.";

EnsureStoredResultsDirectory::usage =
  "EnsureStoredResultsDirectory[path] creates the parent directory needed to write a stored-result file.";

StoredResultPayload::usage =
  "StoredResultPayload[result, diagnostics, routeKind, key, label] constructs the association stored on disk for a cached result.";

StoredResultLoad::usage =
  "StoredResultLoad[path] safely loads one stored-result file and returns $Failed when the payload is unreadable.";

StoredResultPayloadValidQ::usage =
  "StoredResultPayloadValidQ[data] returns True when a loaded stored-result payload is structurally usable.";

StoredResultResultSummary::usage =
  "StoredResultResultSummary[result] builds a lightweight structural summary of a cached result payload.";

StoredResultEntryInfoFromData::usage =
  "StoredResultEntryInfoFromData[data, path, root] builds the inspection summary returned for a readable stored-result payload.";

StoredResultUnreadableInfo::usage =
  "StoredResultUnreadableInfo[path, root] builds the inspection summary returned for an unreadable stored-result file.";

StoredResultEntryInfo::usage =
  "StoredResultEntryInfo[path, root] returns the inspection summary for one stored-result file.";

StoredResultFiles::usage =
  "StoredResultFiles[root, routeKind] enumerates the stored-result files present under the selected cache root.";

StoredResultInfoNotFound::usage =
  "StoredResultInfoNotFound[root, request] returns the structured not-found result used by the cache inspection helpers.";

StoredResultInfoForPath::usage =
  "StoredResultInfoForPath[path, root] resolves a path or root-relative identifier to a stored-result inspection summary.";

StoredResultInfoForLabel::usage =
  "StoredResultInfoForLabel[label, root] resolves a human-readable cache label to a stored-result inspection summary.";

LoadStoredResultEntry::usage =
  "LoadStoredResultEntry[routeKind, key, root, label] loads and validates one exact stored-result entry for use in the public routes.";

StoreStoredResultEntry::usage =
  "StoreStoredResultEntry[routeKind, key, root, label, result, diagnostics] writes one successful public result to the stored-results cache.";

StoredResultCacheMetadata::usage =
  "StoredResultCacheMetadata[data] extracts the cache-origin metadata attached to a loaded stored-result diagnostics payload.";

SelectStoredIntermediateSteps::usage =
  "SelectStoredIntermediateSteps[diagnostics, requestedSteps] selects the requested intermediate stages from a stored diagnostics payload.";

AnnotateStoredResultDiagnostics::usage =
  "AnnotateStoredResultDiagnostics[diagnostics, loadedData, requestedSteps] annotates cached diagnostics so callers can distinguish stored from fresh runs.";

PrintStoredResultHit::usage =
  "PrintStoredResultHit[label] prints the short message shown when a stored result is reused.";

FormatStoredResultReturn::usage =
  "FormatStoredResultReturn[result, diagnostics, loadedData, returnDiagnostics, returnRecord, requestedSteps, printSteps, routeKind, metadata] formats a cache hit in the same public shape as a fresh computation.";

ListStoredResults::usage =
  "ListStoredResults[...] returns compact metadata for the stored-result entries currently present under the cache root.";

StoredResultInfoRouteRequest::usage =
  "StoredResultInfoRouteRequest[routeKind, label, key, root] resolves one exact cache entry from a route-specific request.";

StoredResultInfo::usage =
  "StoredResultInfo[...] returns metadata and a lightweight structural summary for one stored-result entry, by identifier or by public-route request.";

If[!ValueQ[$AntennaPipelineBypassStoredResults],
  $AntennaPipelineBypassStoredResults = False;
];

$AntennaPipelineStoredResultsSchemaVersion = 1;

$StoredResultRouteKinds = {
  "BuildAntenna",
  "BuildAntennaObject",
  "IntegrateAntenna",
  "BuildAndIntegrateAntenna",
  "BuildRRatio"
};

DefaultStoredResultsRoot[] :=
  FileNameJoin[{$AntennaPipelineRoot, "stored_results"}];

ResolveStoredResultsRoot[root_] :=
  If[root === Automatic,
    DefaultStoredResultsRoot[]
    ,
    root
  ];

StoredResultsEnabledQ[useStored_, storeStored_, refreshStored_] :=
  TrueQ[useStored] || TrueQ[storeStored] || TrueQ[refreshStored];

StoredResultsSubdirectory["BuildAntenna"] := "build";

StoredResultsSubdirectory["BuildAntennaObject"] := "build_objects";

StoredResultsSubdirectory["IntegrateAntenna"] := "integrated";

StoredResultsSubdirectory["BuildAndIntegrateAntenna"] := "build_and_integrate";

StoredResultsSubdirectory["BuildRRatio"] := "rratio";

StoredResultsSubdirectory[routeKind_] :=
  StringReplace[ToLowerCase[routeKind], " " -> "_"];

StoredResultsRouteKindFromSubdirectory["build"] := "BuildAntenna";

StoredResultsRouteKindFromSubdirectory["build_objects"] :=
  "BuildAntennaObject";

StoredResultsRouteKindFromSubdirectory["integrated"] :=
  "IntegrateAntenna";

StoredResultsRouteKindFromSubdirectory["build_and_integrate"] :=
  "BuildAndIntegrateAntenna";

StoredResultsRouteKindFromSubdirectory["rratio"] := "BuildRRatio";

StoredResultsRouteKindFromSubdirectory[subdir_String] := subdir;

NormalizeStoredResultRouteKind[All] := All;

NormalizeStoredResultRouteKind[routeKind_String] /;
   MemberQ[$StoredResultRouteKinds, routeKind] := routeKind;

NormalizeStoredResultRouteKind[routeKind_Symbol] :=
  NormalizeStoredResultRouteKind[SymbolName[Unevaluated[routeKind]]];

NormalizeStoredResultRouteKind[routeKind_] := routeKind;

NormalizeStoredResultOptionAssociation[assoc_Association] :=
  Association @ KeyValueMap[
    With[{normalizedKey =
        If[Head[#1] === Symbol, SymbolName[Unevaluated[#1]], #1]},
      normalizedKey -> #2
    ]&,
    assoc
  ];

NormalizeStoredResultKeyValue[value_] :=
  Which[
    AssociationQ[value],
      KeySort[Association @ KeyValueMap[
        #1 -> NormalizeStoredResultKeyValue[#2]&,
        value
      ]]
    ,
    ListQ[value],
      NormalizeStoredResultKeyValue /@ value
    ,
    MatchQ[value, _Rule | _RuleDelayed],
      NormalizeStoredResultKeyValue[First[value]] ->
        NormalizeStoredResultKeyValue[Last[value]]
    ,
    Head[value] === Symbol,
      SymbolName[Unevaluated[value]]
    ,
    MatchQ[value, _Missing],
      ToString[value, InputForm]
    ,
    True,
      value
  ];

StoredResultKeyAssociation[routeKind_String, request_Association] :=
  KeySort@Join[
    <|"RouteKind" -> routeKind|>,
    NormalizeStoredResultKeyValue[request]
  ];

StoredResultKeyHash[key_Association] :=
  IntegerString[
    Hash[HoldComplete[key], "SHA256"],
    16,
    64
  ];

SanitizeStoredResultLabel[label_String] :=
  Module[{sanitized},
    sanitized =
      StringReplace[
        ToLowerCase[label],
        {
          WhitespaceCharacter .. -> "-",
          "/" -> "-",
          ":" -> "-",
          "[" -> "",
          "]" -> "",
          "(" -> "",
          ")" -> "",
          "," -> "-",
          "." -> "-",
          "\"" -> "",
          "'" -> "",
          RegularExpression["[^a-z0-9_-]"] -> "-"
        }
      ];
    sanitized = StringReplace[sanitized, RegularExpression["-+"] -> "-"];
    StringTrim[sanitized, "-"]
  ];

StoredResultTypeLabel[type_] :=
  If[Head[type] === Symbol,
    SymbolName[Unevaluated[type]]
    ,
    ToString[type, InputForm]
  ];

StoredResultPath[routeKind_String, key_Association, root_, label_String] :=
  Module[{resolvedRoot, subdir, stem, hash},
    resolvedRoot = ResolveStoredResultsRoot[root];
    subdir = StoredResultsSubdirectory[routeKind];
    hash = StoredResultKeyHash[key];
    stem = StringTake[SanitizeStoredResultLabel[label], UpTo[48]];
    FileNameJoin[{resolvedRoot, subdir, stem <> "-" <> hash <> ".wl"}]
  ];

StoredResultIdentifier[root_String, path_String] :=
  Module[{resolvedRoot},
    resolvedRoot = ExpandFileName[root];
    StringReplace[
      ExpandFileName[path],
      StartOfString ~~ resolvedRoot ~~ "/" -> ""
    ]
  ];

EnsureStoredResultsDirectory[path_String] :=
  Module[{dir},
    dir = DirectoryName[path];
    If[!DirectoryQ[dir],
      CreateDirectory[dir, CreateIntermediateDirectories -> True]
    ];
    dir
  ];

StoredResultPayload[result_, diagnostics_, routeKind_, key_Association,
   label_String] :=
  <|
    "SchemaVersion" -> $AntennaPipelineStoredResultsSchemaVersion,
    "RouteKind" -> routeKind,
    "RequestKey" -> key,
    "CreatedAt" -> DateString[{"ISODate", "T", "Time"}],
    "Label" -> label,
    "HasDiagnostics" -> AssociationQ[diagnostics],
    "Result" -> result,
    "Diagnostics" ->
      If[AssociationQ[diagnostics], diagnostics, <||>]
  |>;

StoredResultLoad[path_String] :=
  Module[{data},
    If[!FileExistsQ[path],
      Return[$Failed]
    ];
    data = Quiet[Check[Get[path], $Failed]];
    If[!AssociationQ[data],
      Return[$Failed]
    ];
    data
  ];

StoredResultPayloadValidQ[data_Association] :=
  Module[{result},
    result = Lookup[data, "Result", Missing["MissingResult"]];
    If[result === Missing["MissingResult"],
      Return[False]
    ];
    If[!FreeQ[result, Missing["KeyAbsent", __]],
      Return[False]
    ];
    True
  ];

StoredResultResultSummary[result_] :=
  <|
    "Head" -> ToString[Head[result], InputForm],
    "Length" ->
      If[ListQ[result] || AssociationQ[result],
        Length[result],
        Missing["NotApplicable"]
      ]
  |>;

StoredResultEntryInfoFromData[data_Association, path_String, root_String] :=
  Module[{requestKey, routeKind, result, diagnostics, validPayloadQ},
    requestKey = Lookup[data, "RequestKey", <||>];
    routeKind = Lookup[data, "RouteKind",
      StoredResultsRouteKindFromSubdirectory[DirectoryName[path] // FileNameTake]];
    result = Lookup[data, "Result", Missing["MissingResult"]];
    diagnostics = Lookup[data, "Diagnostics", <||>];
    validPayloadQ = StoredResultPayloadValidQ[data];
    <|
      "SchemaVersion" -> Lookup[data, "SchemaVersion",
        Missing["UnknownSchemaVersion"]],
      "RouteKind" -> routeKind,
      "Label" -> Lookup[data, "Label", FileBaseName[path]],
      "RequestKey" -> requestKey,
      "RequestSummary" ->
        If[AssociationQ[requestKey],
          KeyDrop[requestKey, {"RouteKind"}],
          Missing["UnknownRequestSummary"]
        ],
      "CreatedAt" -> Lookup[data, "CreatedAt", Missing["UnknownCreatedAt"]],
      "Path" -> path,
      "Identifier" -> StoredResultIdentifier[root, path],
      "HasDiagnostics" -> TrueQ[Lookup[data, "HasDiagnostics", False]],
      "ValidPayloadQ" -> validPayloadQ,
      "ResultSummary" -> StoredResultResultSummary[result],
      "DiagnosticsSummary" ->
        <|
          "Head" -> ToString[Head[diagnostics], InputForm],
          "Length" ->
            If[AssociationQ[diagnostics],
              Length[diagnostics],
              Missing["NotApplicable"]
            ]
        |>
    |>
  ];

StoredResultUnreadableInfo[path_String, root_String] :=
  <|
    "SchemaVersion" -> Missing["UnreadableSchemaVersion"],
    "RouteKind" ->
      StoredResultsRouteKindFromSubdirectory[DirectoryName[path] // FileNameTake],
    "Label" -> FileBaseName[path],
    "RequestKey" -> Missing["UnreadableRequestKey"],
    "RequestSummary" -> Missing["UnreadableRequestSummary"],
    "CreatedAt" -> Missing["UnreadableCreatedAt"],
    "Path" -> path,
    "Identifier" -> StoredResultIdentifier[root, path],
    "HasDiagnostics" -> False,
    "ValidPayloadQ" -> False,
    "ResultSummary" -> <|"Head" -> "Unreadable", "Length" -> Missing["Unreadable"]|>,
    "DiagnosticsSummary" ->
      <|"Head" -> "Unreadable", "Length" -> Missing["Unreadable"]|>
  |>;

StoredResultEntryInfo[path_String, root_String] :=
  Module[{data},
    data = StoredResultLoad[path];
    If[data === $Failed,
      Return[StoredResultUnreadableInfo[path, root]]
    ];
    StoredResultEntryInfoFromData[data, path, root]
  ];

StoredResultFiles[root_String, routeKind_:All] :=
  Module[{resolvedRoot, routeKinds, subdirs},
    resolvedRoot = ResolveStoredResultsRoot[root];
    routeKinds =
      If[routeKind === All,
        $StoredResultRouteKinds,
        {NormalizeStoredResultRouteKind[routeKind]}
      ];
    subdirs = StoredResultsSubdirectory /@ routeKinds;
    Sort @ Flatten[
      FileNames["*.wl", FileNameJoin[{resolvedRoot, #}], Infinity]& /@ subdirs
    ]
  ];

StoredResultInfoNotFound[root_, request_] :=
  <|
    "Failed" -> True,
    "Reason" -> "StoredResultNotFound",
    "ResultsCacheRoot" -> ResolveStoredResultsRoot[root],
    "Request" -> request
  |>;

StoredResultInfoForPath[path_String, root_String] :=
  Module[{resolvedRoot, resolvedPath},
    resolvedRoot = ResolveStoredResultsRoot[root];
    resolvedPath =
      Which[
        FileExistsQ[path], path,
        FileExistsQ[FileNameJoin[{resolvedRoot, path}]],
          FileNameJoin[{resolvedRoot, path}],
        True,
          Missing["NotFound"]
      ];
    If[resolvedPath === Missing["NotFound"],
      Return[StoredResultInfoNotFound[root, <|"Identifier" -> path|>]]
    ];
    StoredResultEntryInfo[resolvedPath, resolvedRoot]
  ];

StoredResultInfoForLabel[label_String, root_String] :=
  Module[{entries, matches},
    entries = ListStoredResults[ResultsCacheRoot -> root];
    matches = Select[entries, Lookup[#, "Label", Missing["Absent"]] === label &];
    Which[
      Length[matches] == 1,
        StoredResultInfoForPath[matches[[1, "Path"]], root],
      Length[matches] == 0,
        StoredResultInfoNotFound[root, <|"Label" -> label|>],
      True,
        <|
          "Failed" -> True,
          "Reason" -> "StoredResultLabelAmbiguous",
          "ResultsCacheRoot" -> ResolveStoredResultsRoot[root],
          "Label" -> label,
          "Matches" -> Lookup[matches, "Identifier", {}]
        |>
    ]
  ];

LoadStoredResultEntry[routeKind_String, key_Association, root_, label_String] :=
  Module[{path, data},
    path = StoredResultPath[routeKind, key, root, label];
    data = StoredResultLoad[path];
    If[data === $Failed,
      Return[$Failed]
    ];
    If[Lookup[data, "SchemaVersion", Missing["MissingSchemaVersion"]] =!=
         $AntennaPipelineStoredResultsSchemaVersion ||
       Lookup[data, "RouteKind", Missing["MissingRouteKind"]] =!= routeKind ||
       Lookup[data, "RequestKey", Missing["MissingRequestKey"]] =!= key,
      Return[$Failed]
    ];
    If[!StoredResultPayloadValidQ[data],
      Return[$Failed]
    ];
    Join[data, <|"Path" -> path|>]
  ];

StoreStoredResultEntry[routeKind_String, key_Association, root_,
   label_String, result_, diagnostics_] :=
  Module[{path, payload},
    path = StoredResultPath[routeKind, key, root, label];
    EnsureStoredResultsDirectory[path];
    payload = StoredResultPayload[result, diagnostics, routeKind, key, label];
    Put[payload, path];
    path
  ];

StoredResultCacheMetadata[data_Association] :=
  <|
    "LoadedFromStoredResults" -> True,
    "Path" -> Lookup[data, "Path", Missing["UnknownPath"]],
    "CreatedAt" -> Lookup[data, "CreatedAt", Missing["UnknownCreatedAt"]],
    "SchemaVersion" -> Lookup[data, "SchemaVersion",
      Missing["UnknownSchemaVersion"]],
    "RouteKind" -> Lookup[data, "RouteKind", Missing["UnknownRouteKind"]],
    "Label" -> Lookup[data, "Label", Missing["UnknownLabel"]]
  |>;

SelectStoredIntermediateSteps[diagnostics_Association, requestedSteps_List] :=
  Module[{stored},
    stored = Lookup[diagnostics, "IntermediateSteps", <||>];
    If[!AssociationQ[stored],
      Return[<||>]
    ];
    Association @ KeyValueMap[
      If[RequestedIntermediateStepQ[requestedSteps, #1],
        #1 -> #2,
        Nothing
      ]&,
      stored
    ]
  ];

AnnotateStoredResultDiagnostics[diagnostics_Association, loadedData_Association,
   requestedSteps_List] :=
  Module[{stripped, cacheInfo, backendDiagnostics, timingDiagnostics,
     selectedSteps},
    stripped = KeyDrop[diagnostics, {"IntermediateSteps"}];
    cacheInfo = StoredResultCacheMetadata[loadedData];
    backendDiagnostics = Lookup[stripped, "BackendDiagnostics", Missing["Absent"]];
    If[AssociationQ[backendDiagnostics],
      timingDiagnostics = Lookup[backendDiagnostics, "TimingDiagnostics",
        Missing["Absent"]];
      If[AssociationQ[timingDiagnostics],
        backendDiagnostics =
          Join[
            backendDiagnostics,
            <|"TimingDiagnostics" ->
                Join[timingDiagnostics,
                  <|
                    "LoadedFromStoredResults" -> True,
                    "FreshRuntimeUnavailable" -> True
                  |>
                ]|>
          ];
        stripped = Join[stripped, <|"BackendDiagnostics" -> backendDiagnostics|>]
      ]
    ];
    selectedSteps = SelectStoredIntermediateSteps[diagnostics, requestedSteps];
    Join[
      stripped,
      <|"StoredResultCache" -> cacheInfo|>,
      If[Length[selectedSteps] > 0 || Length[requestedSteps] > 0,
        <|"IntermediateSteps" -> selectedSteps|>,
        <||>
      ]
    ]
  ];

PrintStoredResultHit[label_String] :=
  Print["Using stored result for ", label, "."];

FormatStoredResultReturn[result_, diagnostics_, loadedData_Association,
   returnDiagnostics_, returnRecord_, requestedSteps_List, printSteps_,
   routeKind_String, recordMetadata_Association:<||>] :=
  Module[{annotatedDiagnostics, selectedSteps, stages, cacheMetadata,
     mergedMetadata, record},
    annotatedDiagnostics =
      If[AssociationQ[diagnostics],
        AnnotateStoredResultDiagnostics[diagnostics, loadedData,
          requestedSteps]
        ,
        <|"StoredResultCache" -> StoredResultCacheMetadata[loadedData]|>
      ];
    selectedSteps = Lookup[annotatedDiagnostics, "IntermediateSteps", <||>];
    If[TrueQ[returnRecord],
      stages =
        If[AssociationQ[selectedSteps],
          selectedSteps
          ,
          <||>
        ];
      cacheMetadata =
        Lookup[annotatedDiagnostics, "StoredResultCache",
          StoredResultCacheMetadata[loadedData]];
      mergedMetadata = Join[recordMetadata, <|"StoredResultCache" ->
            cacheMetadata|>];
      record =
        If[MemberQ[{"BuildAntenna", "BuildAntennaObject"}, routeKind],
          BuildRunRecord[routeKind, result, annotatedDiagnostics, stages,
            mergedMetadata]
          ,
          IntegrationRunRecord[routeKind, result, annotatedDiagnostics,
            stages, mergedMetadata]
        ];
      If[TrueQ[printSteps] && AssociationQ[record["IntermediateSteps"]] &&
          Length[record["IntermediateSteps"]] > 0,
        PrintIntermediateStepsAssociation[record["IntermediateSteps"]]
      ];
      Return[record]
    ];
    If[TrueQ[printSteps] && AssociationQ[selectedSteps] && Length[
        selectedSteps] > 0,
      PrintIntermediateStepsAssociation[selectedSteps]
    ];
    If[TrueQ[returnDiagnostics],
      {result, annotatedDiagnostics}
      ,
      If[Length[requestedSteps] > 0,
        {result, selectedSteps}
        ,
        result
      ]
    ]
  ];

Options[ListStoredResults] = {
  ResultsCacheRoot -> Automatic,
  RouteKind -> All
};

ListStoredResults[OptionsPattern[]] :=
  Module[{root, routeKind, files},
    root = ResolveStoredResultsRoot[OptionValue[ResultsCacheRoot]];
    routeKind = NormalizeStoredResultRouteKind[OptionValue[RouteKind]];
    files = StoredResultFiles[root, routeKind];
    StoredResultEntryInfo[#, root]& /@ files
  ];

StoredResultInfoRouteRequest[routeKind_String, label_String, key_Association,
   root_] :=
  Module[{path, info},
    path = StoredResultPath[routeKind, key, root, label];
    If[!FileExistsQ[path],
      Return[
        StoredResultInfoNotFound[
          root,
          <|"RouteKind" -> routeKind, "Label" -> label, "RequestKey" -> key|>
        ]
      ]
    ];
    info = StoredResultEntryInfo[path, ResolveStoredResultsRoot[root]];
    If[Lookup[info, "RequestKey", Missing["MissingRequestKey"]] =!= key,
      Return[
        <|
          "Failed" -> True,
          "Reason" -> "StoredResultKeyMismatch",
          "ResultsCacheRoot" -> ResolveStoredResultsRoot[root],
          "Path" -> path,
          "ExpectedRequestKey" -> key,
          "ActualRequestKey" -> Lookup[info, "RequestKey",
            Missing["MissingRequestKey"]]
        |>
      ]
    ];
    info
  ];

Options[StoredResultInfo] = {
  ResultsCacheRoot -> Automatic
};

StoredResultInfo[identifier_String, opts:OptionsPattern[]] :=
  Module[{root, pathInfo, labelInfo},
    root = ResolveStoredResultsRoot[OptionValue[ResultsCacheRoot]];
    pathInfo = StoredResultInfoForPath[identifier, root];
    If[!TrueQ[Lookup[pathInfo, "Failed", False]],
      Return[pathInfo]
    ];
    labelInfo = StoredResultInfoForLabel[identifier, root];
    If[!TrueQ[Lookup[labelInfo, "Failed", False]],
      Return[labelInfo]
    ];
    pathInfo
  ];

StoredResultInfo[BuildAntenna, type_, numFinalParticles_, loopOrder_,
   opts___Rule] :=
  Module[{optionsAssoc, root, requestOptions, key, label},
    optionsAssoc = NormalizeStoredResultOptionAssociation[
      Association[Flatten[{opts}]]
    ];
    root = Lookup[optionsAssoc, ResultsCacheRoot,
      Lookup[optionsAssoc, "ResultsCacheRoot", Automatic]];
    requestOptions = KeyDrop[optionsAssoc, {ResultsCacheRoot, "ResultsCacheRoot"}];
    key = BuildAntennaStoredResultKey[type, numFinalParticles, loopOrder,
      requestOptions];
    label = BuildAntennaStoredResultLabel[type, numFinalParticles, loopOrder,
      requestOptions];
    StoredResultInfoRouteRequest["BuildAntenna", label, key, root]
  ];

StoredResultInfo[BuildAntennaObject, type_, numFinalParticles_, loopOrder_,
   opts___Rule] :=
  Module[{optionsAssoc, root, requestOptions, key, label},
    optionsAssoc = NormalizeStoredResultOptionAssociation[
      Association[Flatten[{opts}]]
    ];
    root = Lookup[optionsAssoc, ResultsCacheRoot,
      Lookup[optionsAssoc, "ResultsCacheRoot", Automatic]];
    requestOptions = KeyDrop[optionsAssoc, {ResultsCacheRoot, "ResultsCacheRoot"}];
    key = BuildAntennaObjectStoredResultKey[type, numFinalParticles, loopOrder,
      requestOptions];
    label = BuildAntennaObjectStoredResultLabel[type, numFinalParticles,
      loopOrder, requestOptions];
    StoredResultInfoRouteRequest["BuildAntennaObject", label, key, root]
  ];

StoredResultInfo[IntegrateAntenna, obj_AntennaObject, opts___Rule] :=
  Module[{optionsAssoc, root, requestOptions, key, label},
    optionsAssoc = NormalizeStoredResultOptionAssociation[
      Association[Flatten[{opts}]]
    ];
    root = Lookup[optionsAssoc, ResultsCacheRoot,
      Lookup[optionsAssoc, "ResultsCacheRoot", Automatic]];
    requestOptions = KeyDrop[optionsAssoc, {ResultsCacheRoot, "ResultsCacheRoot"}];
    key = IntegrateAntennaStoredResultKey[obj, requestOptions];
    label = IntegrateAntennaStoredResultLabel[obj, requestOptions];
    StoredResultInfoRouteRequest["IntegrateAntenna", label, key, root]
  ];

StoredResultInfo[BuildAndIntegrateAntenna, type_, numFinalParticles_,
   loopOrder_, opts___Rule] :=
  Module[{optionsAssoc, root, requestOptions, key, label},
    optionsAssoc = NormalizeStoredResultOptionAssociation[
      Association[Flatten[{opts}]]
    ];
    root = Lookup[optionsAssoc, ResultsCacheRoot,
      Lookup[optionsAssoc, "ResultsCacheRoot", Automatic]];
    requestOptions = KeyDrop[optionsAssoc, {ResultsCacheRoot, "ResultsCacheRoot"}];
    key = BuildAndIntegrateStoredResultKey[type, numFinalParticles, loopOrder,
      requestOptions];
    label = BuildAndIntegrateStoredResultLabel[type, numFinalParticles,
      loopOrder, requestOptions];
    StoredResultInfoRouteRequest["BuildAndIntegrateAntenna", label, key, root]
  ];

StoredResultInfo[BuildRRatio, model_Symbol, opts___Rule] :=
  Module[{optionsAssoc, root, requestOptions, key, label},
    optionsAssoc = NormalizeStoredResultOptionAssociation[
      Association[Flatten[{opts}]]
    ];
    root = Lookup[optionsAssoc, ResultsCacheRoot,
      Lookup[optionsAssoc, "ResultsCacheRoot", Automatic]];
    requestOptions = KeyDrop[optionsAssoc, {ResultsCacheRoot, "ResultsCacheRoot"}];
    key = BuildRRatioStoredResultKey[model, requestOptions];
    label = BuildRRatioStoredResultLabel[model, requestOptions];
    StoredResultInfoRouteRequest["BuildRRatio", label, key, root]
  ];
