# i often start with a handful of scripts
# a single dev.jl file which runs `includet`
# on my scripts allows me to simply load my scripts
# so they are all tracked by revise

# when i later want to change this to a project I replace the includet by include
# and paste them into the Cafe.jl
# ]generate generates the parts for the Project.toml which are necessary

using Revise

includet("example.jl")