abstract type Abs_MinMaxSolver3 <: Abs_MinMaxSolver2 end

mutable struct T_MinMax3 <: Abs_MinMaxSolver3
	max_depth::Int64
	best_i::Int64
	LBs::Vector{Int64} # [lexicon_size]
	cumLBs::Vector{Int64} # [lexicon_size]

	T_MinMax3(max_depth::Int64, W::T_Wordle) = new(
		max_depth,
		_NULL_SOL_MINMAX,
		zeros(Int64, W.lexicon_size),
		zeros(Int64, W.lexicon_size)
	)
end

#############################
######## Interface ##########
#############################

function get_moves_and_bounds!(solver::Abs_MinMaxSolver3,
	colors::T_Colors, P::T_Ids, S::T_Layer,
	alpha::Int64, beta::Int64, depth::Int64)
	return (P, solver.LBs, solver.cumLBs)
end

##################################
############## min ###############
##################################

function _f_min(solver::Abs_MinMaxSolver3, W::T_Wordle, P::T_Ids,
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
	(beta <= alpha) && return beta
	
	new_P, LBs, cumLBs = get_moves_and_bounds!(solver, W.colors, P, S, alpha, beta, depth)

	for (cnt, i) in enumerate(new_P)
		(cumLBs[i] >= beta) && break
		(LBs[i] >= beta) && continue

		create_partition!(S, Sj, W.colors, i)

		if (length(Sj.partition) == 1) && (Sj.p_sizes[Sj.partition[1]] == length(S))
			continue
		end

		val_i = 1 + _g_max(solver, W, P, layers, alpha-1, beta-1, depth)

		if val_i < beta
			beta = val_i
			if (depth == 1) solver.best_i = i end
		end

		(beta <= alpha) && break
	end

	return beta
end