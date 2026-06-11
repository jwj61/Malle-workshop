# Possible multiplicity bug in `PD_H1ur_Bound`

The function `PD_H1ur_Bound(G,T)` tries, internally, to compute the number of
generators of

```text
T / (T cap Hypercenter(G))
```

as a module for `G / Hypercenter(G)` under conjugation.  The current code uses

```magma
CompositionFactors,Multiplicity := Constituents(SocM);
```

and then takes the maximum entry of `Multiplicity`.

This appears to undercount in examples where the same simple constituent occurs
more than once.  In those cases, Magma's `Constituents` output need not aggregate
the repeated isomorphic constituents in the way this code expects.  The intrinsic
`ConstituentsWithMultiplicities(SocM)` gives the aggregated multiplicities.

## Smallest example found

The smallest example found in the SmallGroups library is:

```magma
load "utils/Pontryagin_Dual_Class_Group_Bounds.mag";

G := SmallGroup(18,4);
T := sub<G | G.2, G.3>;

print IdentifyGroup(G);     // <18, 4>
print #T;                   // 9
print IsNormal(G,T);        // true
print IsAbelian(T);         // true
print #Hypercenter(G);      // 1
print PD_H1ur_Bound(G,T);   // current output: 1/2
```

Mathematically, `G` is `C3^2 semidirect C2`, where `C2` acts on
`T = C3^2` by inversion.  The hypercenter is trivial, so
`T / (T cap Hypercenter(G)) = T`.

As an `F_3[G]`-module, `T` is the direct sum of two copies of the same
one-dimensional nontrivial simple module.  Hence the module-generator count
should be `2`, so the value returned by `PD_H1ur_Bound` should be `2/2 = 1`.

The current code computes the generator count as `1`, and therefore returns
`1/2`.

For this example, the relevant Magma outputs are:

```magma
Constituents(SocM);
// [
//     GModule of dimension 1 over GF(3)
// ]
// [ 1, 1 ]

ConstituentsWithMultiplicities(SocM);
// [
//     <GModule of dimension 1 over GF(3), 2>
// ]
```

## Search performed

I checked all `SmallGroup(n,i)` with `n < 18` and all normal abelian subgroups
against the same comparison; no smaller counterexample appeared.

This note documents the issue but does not by itself change the computation.
