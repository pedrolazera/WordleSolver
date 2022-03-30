abstract type Abs_MinAvgSolver4 <: Abs_MinAvgSolver3 end

"""
T_MinAvg4 has a branch size parameter, which limits the search to the
best branch_size candidates, according to the upperbound of each
candidate i in P
"""
mutable struct T_MinAvg4 <: Abs_MinAvgSolver4
	max_depth::Int64
	best_i::Int64

	# guesses ordering
	curr_seen_id::Int64
	UBs::Vector{Int64} # [lexicon_size]
	sizes::Vector{Int64} # [qtd_colors]
	seens::Vector{Int64} # [qtd_colors]
	new_P::Vector{Vector{Int64}} # [max_depth][branch size]
	ix::Vector{Int64} # [lexicon_size]
	branch_size::Int64

	# lower bounds per depth
	LBs::Vector{Vector{Int64}} # [max_depth][lexicon_size]
	cumLBs::Vector{Vector{Int64}} # [max_depth][lexicon_size]

	function T_MinAvg4(max_depth::Int64, W::T_Wordle, branch_size::Int64)
		@assert 1 <= branch_size <= W.lexicon_size

		return new(
			max_depth,
			_NULL_SOL_MINAVG,
			0,
			zeros(Int64, W.lexicon_size),
			zeros(Int64, W.qtd_colors),
			zeros(Int64, W.qtd_colors),
			[zeros(Int64, branch_size) for __ in 1:(max_depth)],
			zeros(Int64, W.lexicon_size),
			branch_size,
			[zeros(Int64, W.lexicon_size) for __ in 1:(max_depth)],
			[zeros(Int64, W.lexicon_size) for __ in 1:(max_depth)]
		)
	end
end

T_MinAvg4(max_depth::Int64, W::T_Wordle) = T_MinAvg4(max_depth, W, W.lexicon_size)

@inline get_lb(solver::Abs_MinAvgSolver4, len_S::Int64) = 2*len_S-1

##################################
######### Special Cases ##########
##################################

function f_min_special(solver::Abs_MinAvgSolver4, W::T_Wordle,
	P::T_Ids, S::T_Layer, beta::Int64, depth::Int64)
	if length(S) == 4
		return _F_4(solver, W.colors, P, S, beta, depth)
	else
		return _NULL_SOL_MINAVG
	end
end


"""
This functions solves (find the best guessword i) the case
where |S|=4.
"""
function _F_4(solver::Abs_MinAvgSolver4, colors::T_Colors, P::T_Ids,
	S::T_Layer, beta::Int64, depth::Int64)::Int64
	@assert length(S) == 4
	j1, j2, j3, j4 = S

	subs = (
		(j1, colors[j1][j2], colors[j1][j3], colors[j1][j4]),
		(j2, colors[j2][j1], colors[j2][j3], colors[j2][j4]),
		(j3, colors[j3][j1], colors[j3][j2], colors[j3][j4]),
		(j4, colors[j4][j1], colors[j4][j2], colors[j4][j3]),
	)

	(beta <= 7) && return beta

	# testwords in S
	for (j, c1,c2,c3) in subs

		# case 1: splits into [b], [c], [d] 
		if (c1!=c2) && (c1!=c3) && (c2!=c3)
			if (depth == 1) solver.best_i = j end
			return 7 # 1+2+2+2
		end

		# case 2: splits into [b,c], [d] 
		if ( c1!=c2 || c1!=c3 ) && ( beta > 8  )
			if (depth == 1) solver.best_i = j end
			beta = 8 # 1+2+3+2
		end
	end

	(beta <= 8) && return beta

	# testwords not in S
	for i in P
		( i==j1 || i==j2 || i==j3 || i==j4 ) && continue

		c1,c2,c3,c4 = colors[i][j1], colors[i][j2], colors[i][j3], colors[i][j4]

		# splits into [a], [b], [c], [d]
		if (c1!=c2) && (c1!=c3) && (c1!=c4) &&
		   (c2!=c3) && (c2!=c4) && (c3!=c4)
			if (depth == 1) solver.best_i = i end
			return 8 # 2+2+2+2
		end

		# splits into [a,b], [c], [d]
		if (
			( (c1 != c2) && (c1 != c3) && (c2 != c3) ) ||
			( (c1 != c2) && (c1 != c4) && (c2 != c4) ) ||
			( (c1 != c3) && (c1 != c4) && (c3 != c4) )
		) && ( beta > 9 )
			if (depth == 1) solver.best_i = i end
			beta = 9 # 2+3+2+2
		end
	end

	if beta > 10 # case [a,b,c,d] -> [b,c,d] -> [c,d]
		if (depth == 1) solver.best_i = j1 end
		beta = 10 # 1+2+3+4
	end

	return beta
end

##################################
######### Moves & Bounds #########
##################################

function get_moves_and_bounds!(solver::Abs_MinAvgSolver4, colors::T_Colors,
	P::T_Ids, S::T_Layer, beta::Int64, depth::Int64)
	UBs = solver.UBs
	sizes = solver.sizes
	seens = solver.seens
	new_P = solver.new_P[depth]
	curr_seen_id = solver.curr_seen_id
	ix = solver.ix
	LBs = solver.LBs[depth]
	cumLBs = solver.cumLBs[depth]
	min_lb = _INF_SOLVER_MINAVG
	lb_S = 2*length(S)-1 # alpha
	best_i = _NULL_SOL_MINAVG
	beta_in = beta

	for i in P
		(beta <= lb_S) && break # no reason to keep searching for a better solution

		UBs[i] = length(S)

		if i in S
			LBs[i] = 2*length(S)-1
		else
			LBs[i] = 2*length(S)
		end
		
		curr_seen_id += 1
		
		for j in S
			(j == i) && continue
			color = colors[i][j]

			if seens[color] != curr_seen_id
				sizes[color] = 0
				seens[color] = curr_seen_id
			else
				LBs[i] += 1 # this is correct!
			end

			sizes[color] += 1
			UBs[i] += sizes[color] # this is correct!

			if LBs[i] >= beta
				UBs[i] = _INF_SOLVER_MINAVG
				LBs[i] = _INF_SOLVER_MINAVG
				break
			end
		end

		beta = min(beta, UBs[i])
		min_lb = min(min_lb, LBs[i])

		if (best_i == _NULL_SOL_MINAVG) || (UBs[i] < UBs[best_i])
			best_i = i
		end
	end

	solver.curr_seen_id = curr_seen_id

	# case 1: we are sure we are not going to improve beta
	if (beta_in <= lb_S) || (beta_in <= min_lb)
		new_P[1] = 1
		cumLBs[new_P[1]] = _INF_SOLVER_MINAVG
	# case 2: found a solution which is for sure the best one
	elseif UBs[best_i] <= min_lb
		new_P[1] = best_i
		new_P[2] = (best_i == 1 ? 2 : 1) # anything different from best_i
		cumLBs[new_P[1]] = LBs[new_P[1]]
		cumLBs[new_P[2]] = _INF_SOLVER_MINAVG
		LBs[new_P[2]] = _INF_SOLVER_MINAVG
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