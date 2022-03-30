abstract type Abs_MinAvgSolver2 <: Abs_MinAvgSolver end

mutable struct T_MinAvg2 <: Abs_MinAvgSolver2
	max_depth::Int64
	best_i::Int64

	T_MinAvg2(max_depth::Int64) = new(max_depth, _NULL_SOL_MINAVG)
end

"""
The minimum score for |S| examples is to have a testword (in S) that
splits S in |S|-1 sets of size 1. In that case, we pay a total
of 1 + (|S|-1)*2 = 2|S|-1
"""
@inline get_lb(solver::Abs_MinAvgSolver2, len_S::Int64) = 2*len_S - 1


"""
A big improvent over T_MinAvg: when |S|=2, there is no best or worst
strategy: one most simply select S[1] (or S[2]) and hope for the best,
always paying 3 in the end (1 if S[1] is the hidden word, 2 otherwise)
"""
function f_min_terminal(solver::Abs_MinAvgSolver2, W::T_Wordle,
	S::T_Layer, depth::Int64)
	if length(S) == 1
		if (depth == 1) solver.best_i = S.head end
		return 1
	elseif length(S) == 2
		if (depth == 1) solver.best_i = S.head end
		return 3
	elseif length(S) == 3
		return _F_3(solver, W.colors, S, depth)
	else
		return _NULL_SOL_MINAVG
	end
end

"""
The case where |S| = 3 could also be solved in constant time: if you pick
any member in S, the worst case is 6 (3+2+1). If you pick any member in P-S,
the best case is 6. That means we just have to test for members in S (provided
that we do not run out of guesses)
"""
function _F_3(solver::Abs_MinAvgSolver2, cores::T_Colors, S::T_Layer,
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