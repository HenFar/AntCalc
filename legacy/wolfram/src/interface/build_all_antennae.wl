(*************************************************)

(*

    This file holds quality-of-life functions to enable the user to, in one run, build all antennae of a certain model up to a certain maximum order of perturbation.

    It only communicates with BuildAntenna[] to build those same antennae. 

    So far only SMQCD (for antennae types A, B and C) is completely implemented up to NNLO. Other orders of perturbation may also be called and only antennae up to that order will be 
    built. The current skeleton also accounts for the future implementation of the SUSY (D and E antennae) and HiggsEFT (F, G and H antennae) models.

    The skeleton also accounts for the future implementation of massive antennae, though up to the current build only A30 has it implemented. That is accessed using the quarkMass option.

    The current error calls are supposed to be patched out as the package grows in complexity.

*)

(*************************************************)

BuildAntennaOrderFromList::usage = "Runs BuildAntenna[] for all elements of a list containing antennae definitions (list {A, 2, 0}) and returns a list of the built antenna. The function is initiated as BuildAntennaeOrderFromList[list, quarkMass -> 0]";

BuildAllAntennae::usage = "Runs BuildAntennaOrderFromList[] for increasing orders of complexity (LO, NLO, NNLO) and returns the built antennae list based on the model chosen and the maximum order of complexity chosen. The function is initiated as BuildAllAntennae[model, maxOrder -> NNLO, quarkMass -> 0]. The other two maxOrder options as LO and NLO. The maxOrder argument accepts the uppercase symbols LO, NLO, NNLO and the corresponding uppercase strings.";

Options[BuildAntennaOrderFromList] = {quarkMass -> 0};

bulkRouteProgressPrint[routeKind_String, key_List, index_Integer,
   total_Integer, status_String] :=
    Print[
        "[", DateString[{"ISODate", " ", "Time"}], "] ",
        routeKind, " [", index, "/", total, "]: ", status, " ",
        key[[1]], key[[2]], key[[3]]
    ];

BuildAntennaOrderFromList[list_, OptionsPattern[]] :=
    Module[{qM, listLength, builtAntennaeList},
        qM = OptionValue["quarkMass"];
        listLength = Length[list];
        builtAntennaeList = {};
        Do[
            bulkRouteProgressPrint["BuildAllAntennae", list[[i]], i,
                listLength, "starting"];
            AppendTo[builtAntennaeList, BuildAntenna[Sequence @@ list
                [[i]], quarkMass -> qM]];
            bulkRouteProgressPrint["BuildAllAntennae", list[[i]], i,
                listLength, "finished"];
            ,
            {i, listLength}
        ];
        builtAntennaeList
    ];

Options[BuildAllAntennae] = {maxOrder -> NNLO, quarkMass -> 0};

normalizeBulkMaxOrder[maxOrder_] :=
    Module[{normalized},
        normalized = ToString[Unevaluated[maxOrder], InputForm];
        Switch[normalized,
            "LO",
                LO
            ,
            "\"LO\"",
                LO
            ,
            "NLO",
                NLO
            ,
            "\"NLO\"",
                NLO
            ,
            "NNLO",
                NNLO
            ,
            "\"NNLO\"",
                NNLO
            ,
            _,
                maxOrder
        ]
    ];

BuildAllAntennae[model_, OptionsPattern[]] :=
    Module[{maxOrder, qM, type1, type2, type3, loList, nloList, nnloList,
         builtAntennaeList},
        maxOrder = normalizeBulkMaxOrder[OptionValue["maxOrder"]];
        qM = OptionValue["quarkMass"];
        If[qM =!= 0,
            Print["Massive antennae are not yet fully implemented. Only A30 has this feature as of the current build. Aborting..."
                ];
            Abort[]
        ];
        Switch[model,
            SMQCD,
                type1 = A;
                type2 = B;
                type3 = C
            ,
            SUSY,
                Print["The SUSY model has not been completely implemented yet. Aborting..."
                    ];
                Abort[]
            ,
            HiggsEFT,
                Print["The Higgs to gg EFT model has not been completely implemented yet. Aborting..."
                    ];
                Abort[]
            ,
            _,
                Print["At the moment only the SMQCD, SUSY and HiggsEFT models are considered within the scope of the package. Aborting..."
                    ];
                Abort[]
        ];
        loList = {{type1, 2, 0}};
        nloList = {{type1, 3, 0}, {type1, 2, 1}};
        nnloList = {{type1, 4, 0}, {type2, 4, 0}, {type3, 4, 0}, {type1,
             3, 1}, {type1, 2, 2}};
        Switch[maxOrder,
            LO,
                builtAntennaeList = BuildAntennaOrderFromList[loList,
                     quarkMass -> qM]
            ,
            NLO,
                builtAntennaeList = BuildAntennaOrderFromList[Join[loList,
                     nloList], quarkMass -> qM]
            ,
            NNLO,
                builtAntennaeList = BuildAntennaOrderFromList[Join[loList,
                     nloList, nnloList], quarkMass -> qM]
            ,
            _,
                Print["The maximum order at the moment is NNLO. LO and NLO are also implemented. This error might have also been triggered by calling the maxOrder argument using lowercase letters; the correct call uses uppercase. Aborting..."
                    ];
                Abort[]
        ];
        builtAntennaeList
    ];

(* build and integrate all antennae *)

Options[BuildAndIntegrateAntennaOrderFromList] = {quarkMass -> 0, ExpansionOrder
     -> Automatic};

BuildAndIntegrateAntennaOrderFromList[list_, OptionsPattern[]] :=
    Module[{qM, eO, listLength, builtAntennaeList},
        qM = OptionValue["quarkMass"];
        eO = OptionValue["ExpansionOrder"];
        listLength = Length[list];
        builtAntennaeList = {};
        Do[
            bulkRouteProgressPrint["BuildAndIntegrateAllAntennae", list[[i]],
                i, listLength, "starting"];
            AppendTo[builtAntennaeList, BuildAndIntegrateAntenna[Sequence
                 @@ list[[i]], ExpansionOrder -> eO, quarkMass -> qM]];
            bulkRouteProgressPrint["BuildAndIntegrateAllAntennae", list[[i]],
                i, listLength, "finished"];
            ,
            {i, listLength}
        ];
        builtAntennaeList
    ];

Options[BuildAndIntegrateAllAntennae] = {ExpansionOrder -> Automatic, maxOrder
     -> NNLO, quarkMass -> 0};

BuildAndIntegrateAllAntennae[model_, OptionsPattern[]] :=
    Module[{eO, maxOrder, qM, type1, type2, type3, loList, nloList, nnloList,
         builtAntennaeList},
        eO = OptionValue["ExpansionOrder"];
        maxOrder = normalizeBulkMaxOrder[OptionValue["maxOrder"]];
        qM = OptionValue["quarkMass"];
        If[qM =!= 0,
            Print["Massive antennae are not yet fully implemented. Only A30 has this feature as of the current build. Aborting..."
                ];
            Abort[]
        ];
        Switch[model,
            SMQCD,
                type1 = A;
                type2 = B;
                type3 = C
            ,
            SUSY,
                Print["The SUSY model has not been completely implemented yet. Aborting..."
                    ];
                Abort[]
            ,
            HiggsEFT,
                Print["The Higgs to gg EFT model has not been completely implemented yet. Aborting..."
                    ];
                Abort[]
            ,
            _,
                Print["At the moment only the SMQCD, SUSY and HiggsEFT models are considered within the scope of the package. Aborting..."
                    ];
                Abort[]
        ];
        loList = {{type1, 2, 0}};
        nloList = {{type1, 3, 0}, {type1, 2, 1}};
        nnloList = {{type1, 4, 0}, {type2, 4, 0}, {type3, 4, 0}, {type1,
             3, 1}, {type1, 2, 2}};
        Switch[maxOrder,
            LO,
                builtAntennaeList = BuildAndIntegrateAntennaOrderFromList[
                    loList, ExpansionOrder -> eO, quarkMass -> qM]
            ,
            NLO,
                builtAntennaeList = BuildAndIntegrateAntennaOrderFromList[
                    Join[loList, nloList], ExpansionOrder -> eO, quarkMass -> qM]
            ,
            NNLO,
                builtAntennaeList = BuildAndIntegrateAntennaOrderFromList[
                    Join[loList, nloList, nnloList], ExpansionOrder -> eO, quarkMass -> qM
                    ]
            ,
            _,
                Print["The maximum order at the moment is NNLO. LO and NLO are also implemented. This error might have also been triggered by calling the maxOrder argument using lowercase letters; the correct call uses uppercase. Aborting..."
                    ];
                Abort[]
        ];
        builtAntennaeList
    ];
