## Code related to the paper "Inductive methods for counting number fields", by Brandon Alberts, Robert J. Lemke Oliver, Jiuya Wang, and Melanie Matchett Wood

To view this page in the traditional github tree view, click [here](https://github.com/lemkeoliver/lemkeoliver.github.io/tree/main/docs/code/inductivemethods).

All references below are to the arxiv version of this paper, available [here](https://arxiv.org/abs/2501.18574).

### Files

- The file [`SavedDatabase_23_3.mag`](SavedDatabase_23_3.mag) is a Magma file containing the output of the computation described in Section 7.1, which was recorded in Corollary 1.8.  It was created by running the file `CreateDatabase.mag` described below.
	- More specifically, this database contains an array called `Database` of 4953 `GroupCountingInfo` records, corresponding to the 4953 transitive groups of degree up to 23.
	- The `GroupCountingInfo` record is a bespoke record type, whose objects have the following properties:
		- `degree`: The degree of the permutation group
		- `label`: The label of the permutaiton group within its degree, i.e. the group is `TransitiveGroup(degree, label)` in Magma
		- `malleindex`: The Malle index of the group
		- `bound`: The best known exponent in an upper bound for G-extensions that follows from our methods
		- `conjecture`: A boolean indicating whether the number field counting conjecture is known for G-extensions over Q.
		- `isnilpotent`: A boolean indicating whether G is nilpotent
		- `issolvable`: A boolean indicating whether G is solvable
		- `isconcentrated`: A boolean indicating whether G is concentrated.
- The file [`output.txt`](output.txt) contains the text output of running the file `CreateDatabase.mag`.
- The file [`CreateDatabase.mag`](CreateDatabase.mag) is the main Magma file used to generate the database.
	- Inside it, there are two important variables: `MaxDegree` (set to 23) and `number_of_repeats` (set to 3), which is the number of times to iterate through the list.
	- Otherwise, the mathematical content is compartmentalized into a number of separate Magma files in the [`utils/`](utils/) directory:
		- [`utils/CountingInvariants.mag`](utils/CountingInvariants.mag): Computes the index of a permutation group and the minimal index subgroup
		- [`utils/NumberFieldBounds.mag`](utils/NumberFieldBounds.mag): Computes various upper bounds on the number of G-extensions
		- [`utils/InitializeDatabase.mag`](utils/InitializeDatabase.mag): Initializes the database, and contains the definition of the `GroupCountingInfo` record.
		- [`utils/GroupConstructions.mag`](utils/GroupConstructions.mag): Creates certain different types of groups
		- [`utils/Comparing_Orderings.mag`](utils/Comparing_Orderings.mag): Has code used to compare the different pushforward discriminants
		- [`utils/Pontryagin_Dual_Class_Group_Bounds.mag`](utils/Pontryagin_Dual_Class_Group_Bounds.mag): Implements an upper bound on H1_ur using the Pontryagin dual, i.e. Lemma 4.1
		- [`utils/ConjectureIsKnown.mag`](utils/ConjectureIsKnown.mag): Runs through the database, and records some groups for which the field counting conjecture is known
		- [`utils/InductiveCounting.mag`](utils/InductiveCounting.mag): Does the hard work, and actually iterates through the database, updating the best known upper bound and detecting whether we may infer the field counting conjecture.
- There is also a tarball [`inductivemethods.tar.gz`](inductivemethods.tar.gz) containing all the contents of this folder.
