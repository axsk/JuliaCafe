# Julia Cafe

## 1. General setup
- use juliaup for convenience and automatic version control:
  `curl -fsSL https://install.julialang.org | sh`
- Let julia use a directory-specific history file. Add this to your .bashrc:
  `alias julia="JULIA_HISTORY=./.history.jl_ command julia`
- if desired modify your [startup file](startup.jl)

## 2. VSCode
- I prefer to start REPL manually
  - about the [Julia](https://www.julia-vscode.org/docs/stable/) and the VSCode remote extensions.
  - tmux
  - code > connect external REPL


## 4. Packages:
- Nested environments: global vs project
- use a [Project.toml](assets/ISOKANN/Project.toml) for each project, version-control the Manifest.toml

- Recommended "global" packages:
Revise (using, includet)
BenchmarkTools (@benchmark)
OhMyREPL
Plots
StatsBase (mean, std, ...)

Optional:
Infiltrator (@infiltrate, @exfiltrate)
Chain / Lazy (@chain, @|>)

Shoutout:
Transducers (Map, ...) / Folds (Folds.sum) (unclear future)

## 5. Short excursion to Functional Programming
- immutability / no state
  - parallelisation
  - simple reasoning
  - reproducability
- higher order functions 
  - map, reduce [Folds](assets/advent-of-code/2023/9.jl)
- functional data: array, map, set. simple interfaces
- objects vs types
  - seperation of data and behavior
    - oop via multiple dispatch

    ```julia
    struct MyObject
      field
    end
    x = MyObject(1)

    mymethod(x::MyObject) = x.field
    mymethod(x) # similar to x.mymethod
    mymethod(x::MyObject, y::MyOtherObject) = x.field + y.field # where do we put this in oop?
    ```

    - "composition over inheritance" -> supposedly more flexible but requires method delegation
    ```julia 
    struct A end
    struct B <: A end # this is not valid because A is not an abstract type
    #but we can have
    struct B
      a::A
    end

    ```

    - example of extension: [CUDA integration](assets/ISOKANN/src/cuda.jl)

## 6. Numerical Experiments
- KISS / simple vs easy ("Simple made easy" - Rich Hickey 2011 https://www.youtube.com/watch?v=LKtk3HCgTa8)
- many small functions - make use of dispatch to link them together
- structs vs namedtuples [see the example](src/example.jl)

## 7. Performance
- @profile / @code_warntype / @benchmark
  - watch out for runtime dispatch / allocations
- @views / @.


## 8. useful references 
Must read sections from the Julia docs
- https://docs.julialang.org/en/v1/manual/performance-tips/
- https://docs.julialang.org/en/v1/manual/workflow-tips/
- https://docs.julialang.org/en/v1/manual/style-guide/
- https://docs.julialang.org/en/v1/manual/faq/