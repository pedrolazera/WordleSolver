const _NULL_SOL_MINMAX = -1
const _INF_SOLVER_MINMAX = 1_000_000_000

abstract type Abs_MinMaxSolver end

mutable struct T_MinMax <: Abs_MinMaxSolver
	max_depth::Int64
	best_i::Int64

	T_MinMax(max_depth::Int64) = new(max_depth, _NULL_SOL_MINMAX)
end

include("MinMax2.jl")
include("MinMax3.jl")
include("MinMax4.jl")

##################################
########### Interface ############
##################################

function f_min_terminal(solver::Abs_MinMaxSolver, W::T_Wordle,
	S::T_Layer, depth::Int64)
	if length(S) == 1
		if (depth == 1) solver.best_i = S.head end
		return 1
	else
		return _NULL_SOL_MINMAX
	end
end

f_min_special(solver::Abs_MinMaxSolver, W::T_Wordle,
	P::T_Ids, S::T_Layer, alpha::Int64, beta::Int64, depth::Int64) = _NULL_SOL_MINMAX

get_moves(solver::Abs_MinMaxSolver, W::T_Wordle,
	P::T_Ids, S::T_Layer, depth::Int64)::T_Ids = P

get_lb(solver::Abs_MinMaxSolver, len_S::Int64) = 0

##################################
############## min ###############
##################################

f_min(solver::Abs_MinMaxSolver, W::T_Wordle) = f_min(solver, W, copy(W.ids), copy(W.G_ids))

function f_min(solver::Abs_MinMaxSolver, W::T_Wordle, P::T_Ids, S::T_Ids,
	alpha::Int64=0, beta::Int64=_INF_SOLVER_MINAVG, depth::Int64=1)::T_Solution
	# build layers
	layers = create_layers(W.lexicon_size, W.qtd_colors, W.guesses_limit)
	update_layer!(layers[1], S)

	opt = _f_min(solver, W, P, layers, alpha, beta, depth)
	best_i = solver.best_i

	return (opt, best_i)
end

function _f_min(solver::Abs_MinMaxSolver, W::T_Wordle, P::T_Ids,
	layers::Vector{T_Layer}, alpha::Int64, beta::Int64, depth::Int64)::Int64
	(depth > W.guesses_limit) &&  return _INF_SOLVER_MINAVG
	S = layers[depth]

	# case 1: terminal node
	opt = f_min_terminal(solver, W, S, depth)
	(opt != _NULL_SOL_MINMAX) && return opt

	# case 2: search must stop before reaching a terminal node
	(depth > solver.max_depth) && return length(S)

	# case 3: special cases
	opt = f_min_special(solver, W, P, S, alpha, beta, depth)
	(opt != _NULL_SOL_MINMAX) && return opt

	# case 4: let's do some work
	Sj = layers[depth+1]
	alpha = max(alpha, get_lb(solver, length(S)))

	for i in get_moves(solver, W, P, S, depth)
		(beta <= alpha) && break

		create_partition!(S, Sj, W.colors, i)

		if (length(Sj.partition) == 1) && (Sj.p_sizes[Sj.partition[1]] == length(S))
			continue
		end

		val_i = 1 + _g_max(solver, W, P, layers, alpha-1, beta-1, depth)

		if val_i < beta
			beta = val_i
			if (depth == 1) solver.best_i = i end
		end
	end

	return beta
end

function _g_max(solver::Abs_MinMaxSolver, W::T_Wordle, P::T_Ids,
	layers::Vector{T_Layer}, alpha::Int64, beta::Int64, depth::Int64)
	Sj = layers[depth+1]

	sort!(Sj.partition, by=x->Sj.p_sizes[x], rev=true)

	for color in Sj.partition
		update_layer!(Sj, color)
		(length(Sj) <= alpha) && break # lenght(Sj) is limSup of _f_min!(Sj) // partition is ordered

		val_color = _f_min(solver, W, P, layers, alpha, beta, depth+1)
		alpha = max(alpha, val_color)

		(alpha >= beta) && break
	end

	return alpha
end