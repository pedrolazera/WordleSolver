abstract type Abs_MinAvgSolver5 <: Abs_MinAvgSolver4 end

"""
T_MinAvg5 has a branch size parameter, which limits the search to the
best branch_size candidates, according to the upperbound of each
candidate i in P
"""
mutable struct T_MinAvg5 <: Abs_MinAvgSolver5
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

	# arrays for _F_5
	Sj::Vector{Int64}
	_v4::Vector{Int64}
	_v5::Vector{Int64}
	

	function T_MinAvg5(max_depth::Int64, W::T_Wordle, branch_size::Int64)
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
			[zeros(Int64, W.lexicon_size) for __ in 1:(max_depth)],

			zeros(Int64, 3),
			zeros(Int64, 4),
			zeros(Int64, 5)
		)
	end
end

T_MinAvg5(max_depth::Int64, W::T_Wordle) = T_MinAvg5(max_depth, W, W.lexicon_size)

function f_min_special(solver::Abs_MinAvgSolver5, W::T_Wordle,
	P::T_Ids, S::T_Layer, beta::Int64, depth::Int64)
	if length(S) == 4
		return _F_4(solver, W.colors, P, S, beta, depth)
	elseif length(S) == 5
		return _F_5(solver, W.colors, P, S, beta, depth)
	else
		return _NULL_SOL_MINAVG
	end
end

"""
This functions solves (find the best guessword i) the case
where |5|=4. Debugging is a bit challenging...
"""
function _F_5(solver::Abs_MinAvgSolver5, colors::T_Colors, P::T_Ids,
	S::T_Layer, beta::Int64, depth::Int64)
	@assert length(S) == 5
	j1, j2, j3, j4, j5 = S
	subs = (
		(j1, [j2, j3, j4, j5]),
		(j2, [j1, j3, j4, j5]),
		(j3, [j1, j2, j4, j5]),
		(j4, [j1, j2, j3, j5]),
		(j5, [j1, j2, j3, j4])
	)

	# auxiliary vectors for colors[][]
	v = solver._v4
	Sj = solver.Sj

	# case 1: try guesses i in S
	for (i, sub) in subs
		v[1] = colors[i][sub[1]]
		v[2] = colors[i][sub[2]]
		v[3] = colors[i][sub[3]]
		v[4] = colors[i][sub[4]]

		sort_four!(v)
		@inbounds qtd_particoes = 1 + (v[1]<v[2]) + (v[2]<v[3]) + (v[3]<v[4]) 
		val_i = _INF_SOLVER_MINAVG

		if qtd_particoes == 4 # caso 1 1 1 1
			val_i = 9
		elseif qtd_particoes == 3 # caso 1 1 2
			val_i = 10
		elseif qtd_particoes == 2 && (beta>11)
			if v[2]!=v[3] # caso 2 2
				val_i = 11
			else # caso 1 3
				if colors[i][sub[1]] != colors[i][sub[2]]
					if colors[i][sub[1]] != colors[i][sub[3]]
						@inbounds Sj .= sub[[2,3,4]]
					else
						@inbounds Sj .= sub[[1,3,4]]
					end
				elseif colors[i][sub[1]] != colors[i][sub[3]]
					@inbounds Sj .= sub[[1,2,4]]
				else
					@inbounds Sj .= sub[[1,2,3]]
				end

				val_i = 6 + _F_3(solver, colors, Sj, depth+1)
			end
		end

		if val_i < beta
			beta = val_i
			if (depth == 1) solver.best_i = i end
		end

		(beta == 9) && return beta
	end

	(beta == 10) && return beta

	# case 2: try guesses in (P-S), but ignoring subsets of size 4
	v = solver._v5
	for i in P
		( i==j1 || i==j2 || i==j3 || i==j4 || i==j5 ) && continue

		v[1] = colors[i][j1]
		v[2] = colors[i][j2]
		v[3] = colors[i][j3]
		v[4] = colors[i][j4]
		v[5] = colors[i][j5]

		sort_five!(v)
		@inbounds qtd_particoes = 1 + (v[1]<v[2]) + (v[2]<v[3]) + (v[3]<v[4]) + (v[4]<v[5]) 
		val_i = _INF_SOLVER_MINAVG

		if qtd_particoes == 5 # splits into 1 1 1 1 1
			val_i = 10
		elseif qtd_particoes == 4 # splits into 1 1 1 2
			val_i = 11
		elseif (qtd_particoes == 3) && (beta > 12)
			@inbounds if v[1]==v[3] || v[2]==v[4] || v[3]==v[5] # splits into 1 1 3, with f(3) = 6
				val_i = 13
			else # splits into 1 2 2
				val_i = 12
			end
		elseif (qtd_particoes == 2) && (beta > 14)
			@inbounds if v[1]==v[2] && v[4]==v[5] # splits into 2 3, with f(3) = 6
				val_i = 14
			end
		end

		if val_i < beta
			beta = val_i
			if (depth == 1) solver.best_i = i end
		end

		(beta == 10) && return beta
	end

	if beta > 15
		beta = 15 # splits into 4 -> 3 -> 2
		if (depth == 1) solver.best_i = j1 end
	end

	return beta
end

"""
This is the same _F_3 defined in previous MinAvg files, but accepting an
array (T_Ids) as input
"""
function _F_3(solver::Abs_MinAvgSolver5, cores::T_Colors, S::T_Ids,
	depth::Int64)::Int64
	@assert length(S) == 3
	# picking a survivor is always at least as good
	j1, j2, j3 = S
	
	if (cores[j1][j2] != cores[j1][j3])
		if (depth == 1) solver.best_i = j1 end
		return 5 # 1 + 2 + 2
	elseif (cores[j2][j1] != cores[j2][j3])
		if (depth == 1) solver.best_i = j2 end
		return 5 # 1 + 2 + 2
	elseif (cores[j3][j1] != cores[j3][j2])
		if (depth == 1) solver.best_i = j3 end
		return 5 # 1 + 2 + 2
	else
		if (depth == 1) solver.best_i = j1 end
		return 6 # 1 + 2 + 3
	end
end

#############################
######## Utilities ##########
#############################

"""
Sort a vector of length 4 with 5 comparisons
"""
function sort_four!(v::Vector{Int64})
	if v[1] < v[2]
		low1 = v[1]
		high1 = v[2]
	else 
		low1 = v[2]
		high1 = v[1]
	end

	if v[3] < v[4]
		low2 = v[3]
		high2 = v[4]
	else
		low2 = v[4]
		high2 = v[3]
	end

	if low1 < low2
		lowest = low1
		middle1 = low2
	else
		lowest = low2
		middle1 = low1
	end

	if high1 > high2
		highest = high1
		middle2 = high2
	else
		highest = high2
		middle2 = high1
	end

	if middle1 < middle2
		v[1] = lowest
		v[2] = middle1
		v[3] = middle2
		v[4] = highest
	else
		v[1] = lowest
		v[2] = middle2
		v[3] = middle1
		v[4] = highest
	end
end

function sort_five!(v::Vector{Int64})
	i_max = argmax(v)
	if i_max != 5
		tmp = v[5]
		v[5] = v[i_max]
		v[i_max] = tmp
	end

	sort_four!(v)
end