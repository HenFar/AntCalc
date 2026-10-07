* R4, R6, R8a, R8b of hep-ph/0311276 times C(ep,2)/Phi2, at mu^2 = q2.
* d = 4 - 2*ep, z3 = zeta(3).

Symbols ep, pi, z3, n;

id chainBasis1234(1,1,1,1,0,0,0,0,0) = q2^2*(
      1/48
    + 59/288*ep
    + (2263/1728 - 1/32*pi^2)*ep^2
    + (72023/10368 - 59/192*pi^2 - 5/9*z3)*ep^3
    + (2073631/62208 - 2263/1152*pi^2 - 295/54*z3 + 29/5760*pi^4)*ep^4
    );

id chainBasis1234(1,1,1,1,0,0,0,1,1) = (
      - 1/4 + 1/24*pi^2
    + (- 3 + 5/24*pi^2 + 9/4*z3)*ep
    + (- 91/4 + 7/6*pi^2 + 45/4*z3 + 7/90*pi^4)*ep^2
    );

id boxBasis1234(1,1,1,1,1,1,1,1,0) = q2^-2*(
      5/4*ep^-4
    - 15/8*pi^2*ep^-2
    - 97/3*z3*ep^-1
    + 37/96*pi^4
    );

id hybridBasis1234(1,1,1,1,1,0,1,1,1) = q2^-2*(
      3/16*ep^-4
    - 37/96*pi^2*ep^-2
    - 89/8*z3*ep^-1
    - 223/1152*pi^4
    );

.sort

* Expand in ep up to ep^0. The expand order counts from each rat's leading power.
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
  id ep^n?pos_ = 0;
endargument;

.sort

PolyRatFun rat(expand,ep,8);
