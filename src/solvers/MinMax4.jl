abstract type Abs_MinMaxSolver4 <: Abs_MinMaxSolver3 end

"""
T_MinMax4 has a branch size parameter, which limits the search to the
best branch_size candidates, according to the upperbound of each
candidate i in P
"""
mutable struct T_MinMax4 <: Abs_MinMaxSolver4
	max_depth::Int64
	best_i::Int64

	# guesses ordering
	curr_seen_id::Int64
	UBs::Vector{Int64} # [lexicon_size]
	seens::Vector{Int64} # [qtd_colors]
	sizes::Vector{Int64} # [qtd_colors]
	new_P::Vector{Vector{Int64}} # [max_depth][branch_size]
	ix::Vector{Int64} # [lexicon_size]
	branch_size::Int64

	# lower bounds per depth
	caps::Vector{Int64} # [tam_lexico]
	max_cap::Int64
	LBs::Vector{Vector{Int64}} # [max_depth][lexicon_size]
	cumLBs::Vector{Vector{Int64}} # [max_depth][lexicon_size]

	function T_MinMax4(max_depth::Int64, W::T_Wordle, branch_size::Int64)
		caps = get_capacities(W)
		max_cap = maximum(caps)

		return new(
			max_depth,
			_NULL_SOL_MINMAX,
			0,
			zeros(Int64, W.lexicon_size),
			zeros(Int64, W.qtd_colors),
			zeros(Int64, W.qtd_colors),
			[zeros(Int64, branch_size) for __ in 1:max_depth],
			zeros(Int64, W.lexicon_size), branch_size,
			caps,
			max_cap,
			[zeros(Int64, W.lexicon_size) for __ in 1:(max_depth)],
			[zeros(Int64, W.lexicon_size) for __ in 1:(max_depth)]
		)
	end
end

T_MinMax4(max_depth::Int64, W::T_Wordle) = T_MinMax4(max_depth, W, W.lexicon_size)

function get_lb(solver::T_MinMax4, len_S::Int64)
	if len_S == 1
		return 1
	elseif len_S-1 <= solver.max_cap
		return 2
	else
		return 3
	end
end

##################################
######### Moves & Bounds #########
##################################

function get_moves_and_bounds!(solver::T_MinMax4, colors::T_Colors,
	P::T_Ids, S::T_Layer, alpha::Int64, beta::Int64, depth::Int64)
	UBs = solver.UBs
	sizes = solver.sizes
	seens = solver.seens
	new_P = solver.new_P[depth]
	curr_seen_id = solver.curr_seen_id
	ix = solver.ix
	LBs = solver.LBs[depth]
	cumLBs = solver.cumLBs[depth]
	min_lb = _INF_SOLVER_MINMAX
	best_i = _NULL_SOL_MINMAX
	beta_in = beta
	alpha = max(alpha, get_lb(solver, length(S)))

	for i in P
		(beta <= alpha) && break
		
		UBs[i] = 0
		LBs[i] = _get_lb(solver, length(S), i)
		curr_seen_id += 1
		
		for j in S
			(j == i) && continue
			color = colors[i][j]

			if seens[color] != curr_seen_id
				sizes[color] = 0
				seens[color] = curr_seen_id
			end

			sizes[color] += 1
			UBs[i] = max(UBs[i], 1 + sizes[color])
			LBs[i] = max(LBs[i], 1 + get_lb(solver, sizes[color]))

			if LBs[i] >= beta
				UBs[i] = _INF_SOLVER_MINMAX
				break
			end
		end

		min_lb = min(min_lb, LBs[i])
		beta = min(beta, UBs[i])

		if (best_i == _NULL_SOL_MINMAX) || (UBs[i] < UBs[best_i])
			best_i = i
		end
	end

	# case 1: we are sure we are not going to improve beta
	if (beta_in <= alpha) || (min_lb >= beta_in)
		new_P[1] = 1
		cumLBs[new_P[1]] = _INF_SOLVER_MINMAX
	# case 2: found a solution which is for sure the best one
	elseif UBs[best_i] <= min_lb
		new_P[1] = best_i
		new_P[2] = (best_i == 1 ? 2 : 1) # anything different from best_i
		cumLBs[new_P[1]] = LBs[new_P[1]]
		cumLBs[new_P[2]] = _INF_SOLVER_MINMAX
		LBs[new_P[2]] = _INF_SOLVER_MINMAX
	else # case 3: move on (standard case)
		sortperm!(ix, UBs)
		new_P[solver.branch_size] = P[ix[solver.branch_size]]
		prev = new_P[solver.branch_size]
		cumLBs[prev] = LBs[prev]
		for i in (solver.branch_size-1):-1:1
			new_P[i] = P[ix[i]]
			curr = new_P[i]
			cumLBs[curr] = min(LBs[curr], cumLBs[prev])
			prev = curr
		end
	end

	solver.curr_seen_id = curr_seen_id

	return new_P, LBs, cumLBs
end

function _get_lb(solver::T_MinMax4, len_S::Int64, i::Int64)
	if len_S == 1
		return 1
	elseif len_S-1 <= solver.caps[i]
		return 2
	else
		return 3
	end
end

#############################
######## Utilities ##########
#############################

function get_capacities(W::T_Wordle)
	# pre computes max cuts for each guess i
	## which is the number of different colors in row i of matrix W.colors
	caps = zeros(Int64, W.lexicon_size)
		
	_v = Vector{Int64}(undef, W.qtd_colors)

	for i in W.ids
		_v .= 0
		
		for j in W.G_ids
			(i == j) && continue
			color = W.colors[i][j]
			_v[color] = 1
		end

		caps[i] = sum(_v)
	end

	return caps
end