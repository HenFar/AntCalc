* R3 = int dPhi3 times C(ep,1)/Phi2, at mu^2 = q2 (thesis, Chapter 4).
* d = 4 - 2*ep, z3 = zeta(3). Kept to ep^4, so the antenna is exact to ep^2.

Symbols ep, pi, z3, n;

id A30(1,1,1,0,0) = q2*(
      1/4
    + 9/8*ep
    + (63/16 - 7/48*pi^2)*ep^2
    + (405/32 - 21/32*pi^2 - 25/12*z3)*ep^3
    + (2511/64 - 147/64*pi^2 - 75/8*z3 - 71/5760*pi^4)*ep^4
    );

.sort

* Expand in ep up to ep^2. The expand order counts from each rat's leading power.
PolyRatFun;
argument rat;
  id d = 4 - 2*ep;
  id q2 = 1;
endargument;
id q2^n? = 1;
id ep^n?pos_ = rat(ep^n,1);
id ep^n?neg_ = rat(1,ep^-n);

.sort

PolyRatFun rat(expand,ep,8);

.sort

PolyRatFun;
argument rat;
  if (count(ep,1) > 2) discard;
endargument;

.sort

PolyRatFun rat(expand,ep,8);
