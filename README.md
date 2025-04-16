# Julia Cafe

##  General setup
- use juliaup for convenience and automatic version control:
  `curl -fsSL https://install.julialang.org | sh`
- Let julia use a directory-specific history file. Add this to your .bashrc:
  `alias julia="JULIA_HISTORY=./.history.jl_ command julia`
  This is especially cool when using `OhMyREPL`s `Ctrl+r`
- if desired modify your [startup file](startup.jl)

##  VSCode
- I prefer to start REPL manually
  - about the [Julia](https://www.julia-vscode.org/docs/stable/) and the VSCode remote extensions.
  - tmux
  - code > connect external REPL
- I think there are not so many musthave VSCode extensions, except for `Julia` (and the vim bindings, but if you want them you already know that :)

##  Packages:
- Nested environments: global vs project
  when `using` a package it is first looked for in the project, and the global is a fallback (read the Pkg documentation!)
- use a [Project.toml](assets/ISOKANN/Project.toml) for each project, version-control the `Manifest.toml``

- Recommended "global" packages:
Revise (using, includet)
BenchmarkTools (@benchmark)
OhMyREPL - ctrl+r gives me fzf
Plots
StatsBase (mean, std, ...)

Optional:
Infiltrator (@infiltrate, @exfiltrate)
Chain / Lazy (@chain, @|>)

Shoutout:
Transducers (Map, ...) / Folds (Folds.sum) (unclear future)

##  Performance
These macros are great for inspecting performance
- @profile / @code_warntype / @benchmark
  - watch out for runtime dispatch (red) / allocations (yellow)
- @views / @.

## Compiling a sysimage
When using big packages such that loading times become an issue, "caching" the compiled state may be a solution. This has become quite straightforward by now.
```julia
julia> Pkg.add("PackageCompiler")
julia> using PackageCompiler
julia> create_sysimage(["PackageToBeIncluded"]; sysimage_path="ExampleSysimage.so")
julia> exit()
❯ julia -JExampleSysimage.so
```
## References 
These sections appear rather late in the Julia docs, but are quite essential:
- https://docs.julialang.org/en/v1/manual/noteworthy-differences/#Noteworthy-differences-from-Python (when coming from Python this may be useful)
- https://docs.julialang.org/en/v1/stdlib/Pkg/ (very important read to understand the Pkg management)
- https://docs.julialang.org/en/v1/manual/performance-tips/ (avoid common pitfalls)
- https://docs.julialang.org/en/v1/manual/workflow-tips/ 
- https://docs.julialang.org/en/v1/manual/style-guide/
- https://docs.julialang.org/en/v1/manual/faq/

# Advanced

## Short excursion to Functional Programming
- immutability / no state
  - parallelisation
  - simple reasoning
  - reproducability
- higher order functions 
  - map, reduce [Folds](assets/advent-of-code/2023/9.jl)
- functional data: array, map, set. simple interfaces

- Excursion on objects (python) vs types (julia)
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

    - this shows how the seperation of data and behavior allows for easy extension of behavior, in this case lifting the package to CUDA compatibility example of extension: [CUDA integration](https://github.com/axsk/ISOKANN.jl/blob/60b1b3d6a87346fba7916eafa2be0f6d0e6d5652/src/cuda.jl)

## Numerical "Experiments"
- KISS / simple vs easy ("Simple made easy" - Rich Hickey 2011 https://www.youtube.com/watch?v=LKtk3HCgTa8)
- many small functions - make use of dispatch to link them together
- structs vs namedtuples [see the example](src/example.jl)
  - structs often need planning ahead, not useful for exploration/iterative design
  - NamedTuples give a lot of flexibility with very few drawbacks
  
