(* Development script: regression check for the A30 sequential-call state bug.
   It verifies that a one-shot A30 integration does not poison later A30
   build or higher-order one-shot calls in the same kernel. *)

Get[FileNameJoin[{DirectoryName[DirectoryName[$InputFileName]],
  "AntennaPipeline.wl"}]];

first = BuildAndIntegrateAntenna[A, 3, 0];
second = BuildAndIntegrateAntenna[A, 3, 0, ExpansionOrder -> 2];
third = BuildAntenna[A, 3, 0];

expectedFirst =
  19/4 + Epsilon^(-2) + 3/(2 Epsilon) - 7 Pi^2/12;

expectedSecond =
  expectedFirst +
    Epsilon (109/8 - 7 Pi^2/8 - 25 Zeta[3]/3) +
    Epsilon^2 (639/16 - 133 Pi^2/48 - 25 Zeta[3]/2 - 71 Pi^4/1440);

expectedThird =
  (-2 Epsilon)/q2 + (2 s12)/(q2 s13) + (2 s12)/(q2 s23) +
    (2 s12^2)/(q2 s13 s23) + s13/(q2 s23) - (Epsilon s13)/(q2 s23) +
    s23/(q2 s13) - (Epsilon s23)/(q2 s13);

firstOk = TrueQ[Together[first - expectedFirst] === 0];
secondOk = TrueQ[Together[second - expectedSecond] === 0];
thirdOk = TrueQ[Together[third - expectedThird] === 0];

Print["A30 sequential regression"];
Print["  first one-shot ok: ", firstOk];
Print["  second one-shot ok: ", secondOk];
Print["  later build ok: ", thirdOk];

If[!And[firstOk, secondOk, thirdOk],
  Print["Regression failure details:"];
  Print["  first  = ", InputForm[first]];
  Print["  second = ", InputForm[second]];
  Print["  third  = ", InputForm[third]];
  Quit[1]
];

Print["A30 sequential regression passed."];
