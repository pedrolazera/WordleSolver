module WordleSolver

include("types.jl")

include("_WordsList.jl")
using ._WordsList

include("_Colors.jl")
using ._Colors

include("_Partition.jl")
using ._Partition

include("t_wordle.jl")

# solvers
include("solvers/MinAvg.jl")
include("solvers/MinMax.jl")


end # module WordleSolver
