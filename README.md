# ocaml-cpm
Ocaml bindings to (a fork of) Alex Kantchelian's Convex Polytope Machine code for binary classification.

*Alpha/Experimental Code*

A CPM can be used for binary classification tasks in much the same way as a support vector machine.
So if you've done say, binary document classification using liblinear or libsvm you should be able to use
CPM for similar tasks. One benefit of a CPM over a SVM is typically a vast improvement in training time.
For details on the performance see Table 1 in Alex's nips14 paper linked below.
The interface here is intended to be scikit-learn-esque.

- The paper: https://www.eecs.berkeley.edu/~akant/papers/nips14-cpm.pdf
- Alex's page: https://www.eecs.berkeley.edu/~akant/
- My fork on which this code depends: https://github.com/travisbrady/cpm
- Alex's original CPM repo: https://github.com/alkant/cpm
