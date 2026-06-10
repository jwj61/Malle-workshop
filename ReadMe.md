Workspace for ICERM workshop on Malle's conjecture - Inductive methods group

grouplist is magma readable file setting a variable called `grouplist` which is the list of Galois groups in the LMFDB of order $$>1$$ sorted by order.  `grouplist.1000` and `grouplist.10000` are the first 1000 and 10000 groups to use in testing

Currently to run the program on a file `grouplistfile` which has a list of gruops, the command is
```
magma grouplistfile CreateDatabase.mag
```
