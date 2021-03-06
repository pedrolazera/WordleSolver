const _WORDLE_DIR = abspath(joinpath(Base.@__DIR__, ".."))

push!(LOAD_PATH, _WORDLE_DIR)

import WordleSolver

const _GAMES = [:Termo, :Wordle]
const _BRANCH_SIZE = 150
const _MAX_DEPTH = 6
const _ALPHAS_MINMAX = Dict(
	:Termo => 4,
	:Wordle => 5
)

function do_it()
	find_best_first_word_AVG()
	find_best_first_word_MAX()
end

function find_best_first_word_AVG()
	for game in _GAMES
		println("\n****************\nLoading game...")
		@show game
		@time W = WordleSolver.T_Wordle(game)
		@time solver = WordleSolver.T_MinAvg5(_MAX_DEPTH, W, _BRANCH_SIZE)

		println("\n****************\nSolving...")
		@time (opt, i) = WordleSolver.f_min(solver, W)
		println(W.lexicon[i], "($i)", " --> ", opt)
	end
end

function find_best_first_word_MAX()
	for game in _GAMES
		println("\n****************\nLoading game...")
		@show game
		@time W = WordleSolver.T_Wordle(game)
		@time solver = WordleSolver.T_MinMax4(_MAX_DEPTH, W, _BRANCH_SIZE)
		alpha = _ALPHAS_MINMAX[game]
		beta = 1_000_000

		println("\n****************\nSolving...")
		@time (opt, i) = WordleSolver.f_min(solver, W, W.ids, W.G_ids, alpha, beta) 
		println(W.lexicon[i], "($i)", " --> ", opt)
	end
end


do_it()