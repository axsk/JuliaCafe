# ~/.julia/config/startup.jl

# add the following line to your .bashrc to let julia use a directory specific history file.
#  alias julia="JULIA_HISTORY=./.history.jl_ command julia

ENV["PLOTS_DEFAULT_BACKEND"] = "Plotly"

using Revise

using OhMyREPL

using BenchmarkTools: @benchmark
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 5


""" export all names from a module """
function exportall(mod)
    for n in names(mod, all=true)
        if Base.isidentifier(n) && n ∉ (Symbol(mod), :eval)
            @eval mod export $n
        end
    end
end


# change project to current directory
import Pkg
Pkg.activate(".")

# how many threads are we running
import LinearAlgebra
println("Running on $(Threads.nthreads()) threads ($(LinearAlgebra.BLAS.get_num_threads()) BLAS threads)")
