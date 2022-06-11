# JEXPRESSO
JEXPRESSO

MINIMAL CODE FOR DISCOURSE.JULIA.ORG
https://discourse.julialang.org/t/unexpected-allocation-at-each-loop-iteration/82600

# Some notes on using JEXPRESSO

To install and run the code assume Julia
version 1.7.2.

The [MPI.jl][0] package that is used assumes that you have a working MPI installation

## Setup with CPUs

```bash
julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.API.precompile()"
```
You can test that things were installed properly with
```bash
julia --project=. $JEXPRESSO_HOME/src/jexpresso.jl
```

where `$JEXPRESSO_HOME` is your path to the base JEXPRESSO directory (you can export it in your .bashrc or simply replace its value with the explicit name of the path)
