const _WORDLE_DIR = abspath(joinpath(Base.@__DIR__, ".."))

push!(LOAD_PATH, _WORDLE_DIR)
push!(LOAD_PATH, abspath(Base.@__DIR__))

import WordleSolver
using SolutionBuilder

const _GAMES = [:Termo, :Wordle]
const _BRANCH_SIZE = 150
const _MAX_DEPTH = 6
const _ALPHAS_MINMAX = Dict(
	:Termo => 4,
	:Wordle => 5
)

function do_it()
	build_AVG()
	build_MAX()
end

function build_AVG()
	for game in _GAMES
		println("\n****************\nLoading game...")
		@show game
		@time W = WordleSolver.T_Wordle(game)
		@time solver = WordleSolver.T_MinAvg5(_MAX_DEPTH, W, _BRANCH_SIZE)

		node = build_solution(solver, W)
		lines = printa(W.lexicon, node)

		open(get_file_path(string(game)*"_AVG"), "w") do fp
			for line in lines
				write(fp, line*"\n")
			end
		end

		@show node.opt
	end
end

function build_MAX()
	for game in _GAMES
		println("\n****************\nLoading game...")
		@show game
		@time W = WordleSolver.T_Wordle(game)
		@time solver = WordleSolver.T_MinMax4(_MAX_DEPTH, W, _BRANCH_SIZE)

		node = build_solution(solver, W)
		lines = printa(W.lexicon, node)

		open(get_file_path(string(game)*"_MAX"), "w") do fp
			for line in lines
				write(fp, line*"\n")
			end
		end

		@show node.opt
	end
end

get_file_name(name::String) = "out_" * name * "_" * string(Int64(round(time()))) * ".txt"
get_file_path(name::String) = joinpath(Base.@__DIR__, "explicit", get_file_name(name))

do_it()