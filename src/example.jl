using Infiltrator
using IterTools
using Plots

function simulate(force, x0, dt, nt)
  xs = []  # this will cause runtime dispatch
  push!(xs, x0)
  for i in 1:nt
    push!(xs, xs[end] .+ dt .* force(xs[end]))
  end
  return xs
end

# the above function has multiple flaws
# when running 
# `@profview myexperiment()`
# we will see that the simulate call is red, indicating that
# 'runtime-dispatch', i.e. looking up the variables types during
# runtime.
# This is because `xs=[]` creates an Array of type Any.
# So whenever we access xs[end] the compiler doesn't know which type it will be.

# the second thing that springs to eye in the profiler output 
# are the yellow bars, indicating garbage collection.
# This happens because we are allocating, i.e. reserving lots of memory over and over
# The final way to avoid this would be to reserve an output array at the beginning
# and let the forces write into that memory.

# in my experience the most problems are due to type-instabilities / runtime-dispatch
# and this is what i look out for first


function myspecialforce(x)
  return x^3 - x
end
myspecialforce(x::Vector) = myspecialforce.(x) 

# here we used multiple dispatch to define the function for scalars and delegate the vector case to 
# a 'broadcast' over the scalar case.

myshortimplementation(x) = @. x^3 - x

# this would be another way to implement both cases directly using the broadcasting macro `@.`

# good to have for correctness / alternative implementation / performance tests
function checkedforce(x)
  x1 = myspecialforce(x)
  x2 = myshortimplementation(x)

  @assert isapprox(x1, x2)
  return x1
end

# above function allows to check the correctness of one implementation against the other,
# also when profiling (`@profview`) checkedforce we immediately get a graphical representation
# of the differences in the implementations

# it is always convenient to have some visualization of the data you are working with at you fingertips:

function visualize(xs; dt = 1)
  plot(range(0, step=dt, length=length(xs)), stack(xs)')
end

# as well as to have some example data

exampledata(; ndim=1, n=1) = collect(eachcol(rand(ndim, n)))

# note on the oneline-functions: they are very convenient, but their definitions may be harder to find via ctrl+f.
# in this regard using the `function` block explicitly can be better:

function test_visualize()
  data = exampledata()

  # lets imagine we want to know what the data looked like here
  # we can use 

  Infiltrator.@exfiltrate

  # to put the whole scope (variables)
  # at this position into a 'safehouse'

  visualize(exampledata())
end

# we can look at the exfiltrated values via 
safehouse

# This can be convenient (but dangerous due to global state):
Infiltrator.set_store!(Main)
# whenever we exfiltrate now the variables get copied to our Main namespace


# we dont have to use types at all, small functions with few (untyped) arguments
# allow for great flexibility, at the cost of explicitness.
function myexperiment(force, x0, dt, nt)
  xs = simulate(force, x0, dt, nt)
  plot = visualize(xs)
  return xs, plot
end

# globals should be avoided, however when we use them one way to make them "type stable"
# and somewhat safer is by passing them down the call chain to begin with
# this way we can set some default values globalwide, but they will be treated as local variables
# further down the call chain
global defaultdt = .001

# when working from the repl we may not want to type all the arguments all the time
# here convenience wrappers using named tuples are super flexible and handy

function myexperiment(; 
  force = checkedforce,
  dim = 2,
  x0 = 2*rand(dim) .- 1,
  dt = defaultdt,
  nt = 100, kwargs...)

  xs, plot = myexperiment(force, x0, dt, nt)

  return (; force, dim, x0, dt, nt, xs, plot)
end

MyExperiment = NamedTuple

visualize(exp::MyExperiment) = visualize(exp.xs; exp.dt)

# now we can simply have different runs without changing global values (like we would maybe do in notebooks)

result = myexperiment()
res2 = myexperiment(dt=2)

visualize(res2)

res2changed = myexperiment(; res2..., force=myshortimplementation)


using Transducers: Map
# it makes sense to explicitly indicate which functions you will be using
# this way it is simple to track which functionality a package is providing to your code


### it also makes it easy to alter the experiments programatically


function metaexperiment(;ndims=3, kwargs...)

  # here we show 3 different way to iterate over different dimensions

  # list comprehension
  exps = [myexperiment(; dim=i, kwargs...) for i in 1:ndims]

  # map
  exps = map(1:ndims) do dim
    myexperiment(; dim, kwargs...)
  end

  # Transducers.Map: automatic parallelization (in a very smart way, go look it up)
  exps = 1:ndims |> Map(dim -> myexperiment(; dim, kwargs...)) |> collect

  plt = plot([e.plot for e in exps]...)

  # let us return the experiments and plots for further analysis: as NamedTuple :)
  return (;exps, plt)
end



# now lets profile our experiment
e = myexperiment()

# this only works when you connect the REPL to VSCode, either explicitly or by starting it through VSCode
@profview myexperiment(; e...)
@benchmark myexperiment(n=1000000)