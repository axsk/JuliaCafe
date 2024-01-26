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

function myspecialforce(x)
  return x^3 - x
end
myspecialforce(x::Vector) = myspecialforce.(x) 



myshortimplementation(x) = @. x^3 - x

function checkedforce(x)  # good to have for correctness / alternative implementation / performance tests
  x1 = myspecialforce(x)
  x2 = myshortimplementation(x)

  @assert isapprox(x1, x2)
  return x1
end

function visualize(xs; dt = 1)
  plot(range(0, step=dt, length=length(xs)), stack(xs)')
end

function test_visualize(ndim=1, n=1)
  xs = IterTools.repeatedly(() -> rand(ndim), n) |> collect
  xs = collect(eachcol(rand(ndim, n)))
  #@infiltrate
  #@exfiltrate
  visualize(xs)
end

#safehouse
#Infiltrator.set_store!(Main)

global defaultdt = 1

function myexperiment(force, x0, dt, nt)
  xs = simulate(force, x0, dt, nt)
  plot = visualize(xs) |> display
  return xs, plot
end

# named tuple wrappers for repl convenience

global defaultdt = .001

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

### lets compare different runs

function metaexperiment(;ndims=3, kwargs...)
  exps = [myexperiment(; dim=i, kwargs...) for i in 1:ndims]

  exps = map(1:ndims) do dim
    myexperiment(; dim, kwargs...)
  end

  #exps = 1:ndims |> Map(dim -> myexperiment(; dim, kwargs...)) |> collect

  plt = plot([e.plot for e in exps]...)

  return (;exps, plt)
end



# now lets profile our experiment
e = myexperiment()

# @profview myexperiment(;e...)
# @benchmark myexperiment(n=1000000)