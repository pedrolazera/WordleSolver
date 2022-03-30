abstract type Abs_MinAvgSolver3 <: Abs_MinAvgSolver2 end

mutable struct T_MinAvg3 <: Abs_MinAvgSolver3
	max_depth::Int64
	best_i::Int64
	LBs::Vector{Vector{Int64}} # [max_depth][lexicon_size]
	cumLBs::Vector{Vector{Int64}} # [max_depth][lexicon_size]

	T_MinAvg3(max_depth::Int64, W::T_Wordle) = new(
		max_depth,
		_NULL_SOL_MINAVG,
		[zeros(Int64, W.lexicon_size) for __ in 1:(max_depth)],
		[zeros(Int64, W.lexicon_size) for __ in 1:(max_depth)],
	)
end

#############################
######## Interface ##########
#############################

"""
The value returned by get_lb should take into consideration
the values returned by get_moves_and_bounds!. Check the
'get_moves_and_bounds!' function for further details
"""
@inline get_lb(solver::Abs_MinAvgSolver3, len_S::Int64) = 0

"""
get_moves_and_bounds! must return three things:
(i) a vector new_P of all possible moves (words to pick as testword)
(ii) a vector LBs, with LBs[i] === lower bound for move i
....... equals length(S) + sum(get_lb(solver, Sj.p_sizes[color]) for color in partition)
............. where 'partition' is the partition from i
(iii) cumLBs[new_P[i]] === min(LBs[new_P[i]], LBs[new_P[i+1]], ..., LBs[new_P[end]] )
"""
function get_moves_and_bounds!(solver::Abs_MinAvgSolver3, colors::T_Colors,
	P::T_Ids, S::T_Layer, beta::Int64, depth::Int64)
	LBs = solver.LBs[depth]
	cumLBs = solver.cumLBs[depth]

	LBs .= length(S) # assumes  get_lb(solver, len_S) = 0
	cumLBs .= length(S) # assumes  get_lb(solver, len_S) = 0

	return (P, LBs, cumLBs)
end

##################################
############## min ###############
##################################

function _f_min(solver::Abs_MinAvgSolver3, W::T_Wordle,
	P::T_Ids, layers::Vector{T_Layer},
	beta::Int64, depth::Int64)::Int64
	S = layers[depth]

	(beta <= 2*length(S)-1) && return beta # it is impossible to improve when beta <= 2|S|-1

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

	new_P, LBs, cumLBs = get_moves_and_bounds!(solver, W.colors, P, S, beta, depth)

	for (cnt, i) in enumerate(new_P)
		(cumLBs[i] >= beta) && break
		lb_i = LBs[i]
		#(depth == 1) && (mod(cnt, 10) == 1) && println('\t'^(depth-1), "*** cnt = $cnt // i  = $(i) // lb_i = $(lb_i) // beta = $(beta)")
		(lb_i >= beta) && continue

		create_partition!(S, Sj, W.colors, i)

		if (length(Sj.partition) == 1) && (Sj.p_sizes[Sj.partition[1]] == length(S))
			continue
		end

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
