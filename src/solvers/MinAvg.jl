const _NULL_SOL_MINAVG = -1
const _INF_SOLVER_MINAVG = 1_000_000_000

abstract type Abs_MinAvgSolver end

mutable struct T_MinAvg <: Abs_MinAvgSolver
	max_depth::Int64
	best_i::Int64

	T_MinAvg(max_depth::Int64) = new(max_depth, _NULL_SOL_MINAVG)
end

include("MinAvg2.jl")
include("MinAvg3.jl")
include("MinAvg4.jl")
include("MinAvg5.jl")

##################################
########### Interface ############
##################################

get_lb(solver::Abs_MinAvgSolver, len_S::Int64) = 0

f_min_special(solver::Abs_MinAvgSolver, W::T_Wordle,
	P::T_Ids, S::T_Layer, beta::Int64, depth::Int64) = _NULL_SOL_MINAVG

get_moves(solver::Abs_MinAvgSolver, W::T_Wordle,
	P::T_Ids, S::T_Layer, depth::Int64)::T_Ids = P

function f_min_terminal(solver::Abs_MinAvgSolver, W::T_Wordle,
	S::T_Layer, depth::Int64)
	if length(S) == 1
		if (depth == 1) solver.best_i = S.head end
		return 1
	else
		return _NULL_SOL_MINAVG
	end
end

##################################
############## min ###############
##################################

f_min(solver::Abs_MinAvgSolver, W::T_Wordle) = f_min(solver, W, copy(W.ids), copy(W.G_ids))

function f_min(solver::Abs_MinAvgSolver, W::T_Wordle, P::T_Ids, S::T_Ids,
	beta::Int64=_INF_SOLVER_MINAVG, depth::Int64=1)::T_Solution
	# build layers
	layers = create_layers(W.lexicon_size, W.qtd_colors, W.guesses_limit)
	update_layer!(layers[1], S)

	opt = _f_min(solver, W, P, layers, beta, depth)
	best_i = solver.best_i

	return (opt, best_i)
end

function _f_min(solver::Abs_MinAvgSolver, W::T_Wordle, P::T_Ids,
	layers::Vector{T_Layer}, beta::Int64, depth::Int64)::Int64
	(depth > W.guesses_limit) &&  return _INF_SOLVER_MINAVG

	S = layers[depth]

	# case 1: terminal node
	opt = f_min_terminal(solver, W, S, depth)
	(opt != _NULL_SOL_MINAVG) && return opt

	# case 2: search must stop before reaching a terminal node
	if depth > solver.max_depth
		if (depth == 1) solver.best_i = S.head end
		n = length(S)
		return div(n*(n+1), 2)
	end

	# case 3: special cases
	opt = f_min_special(solver, W, P, S, beta, depth)
	(opt != _NULL_SOL_MINAVG) && return opt

	# case 4: let's do some work
	Sj = layers[depth+1]
	alpha = get_lb(solver, length(S))

	for i in get_moves(solver, W, P, S, depth)
		(beta <= alpha) && continue
		
		create_partition!(S, Sj, W.colors, i)

		if (length(Sj.partition) == 1) && (Sj.p_sizes[Sj.partition[1]] == length(S))
			continue
		end

		lb_i = sum(get_lb(solver, Sj.p_sizes[color]) for color in Sj.partition) + length(S)
		(lb_i >= beta) && continue

		# visit colors in increasing order of size
		sort!(Sj.partition, by=x->Sj.p_sizes[x])

		for color in Sj.partition
			update_layer!(Sj, color)

			lb_ij = get_lb(solver, Sj.p_sizes[color])
			beta_ij = beta - lb_i + lb_ij
			val_ij = _f_min(solver, W, P, layers, beta_ij, depth+1)
			lb_i += (val_ij - lb_ij) # keep in mind we always have val_ij >= lb_ij

			(lb_i >= beta) && break
		end

		if lb_i < beta
			beta = lb_i
			if (depth == 1) solver.best_i = i end # save solution
		end
	end

	return beta
end
