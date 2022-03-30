abstract type Abs_MinMaxSolver2 <: Abs_MinMaxSolver end

mutable struct T_MinMax2 <: Abs_MinMaxSolver2
	max_depth::Int64
	best_i::Int64

	T_MinMax2(max_depth::Int64) = new(max_depth, _NULL_SOL_MINMAX)
end

function f_min_terminal(solver::Abs_MinMaxSolver2, W::T_Wordle,
	S::T_Layer, depth::Int64)
	if length(S) == 1
		if (depth == 1) solver.best_i = S.head end
		return 1
	elseif length(S) == 2
		if (depth == 1) solver.best_i = S.head end
		return 2
	else
		return _NULL_SOL_MINMAX
	end
end

function get_lb(solver::Abs_MinMaxSolver2, len_S::Int64)
	if len_S == 1
		return 1
	else
		return 2
	end
end

##################################
######### Special Cases ##########
##################################

function f_min_special(solver::Abs_MinMaxSolver2, W::T_Wordle,
	P::T_Ids, S::T_Layer, alpha::Int64, beta::Int64, depth::Int64)
	if length(S) == 3
		return _F_3(solver, W.colors, P, S, depth)
	else
		return _NULL_SOL_MINMAX
	end
end

function _F_3(solver::Abs_MinMaxSolver2, colors::T_Colors,
	P::T_Ids, S::T_Layer, depth::Int64)::Int64
	@assert length(S) == 3
	j1, j2, j3 = S

	# look for i in S that splits S set into singletons
	## assumes color[i][i] != color[i][j] for any j != i
	if (colors[j1][j2] != colors[j1][j3])
		if (depth == 1) solver.best_i = j1 end
		return 2
	elseif (colors[j2][j1] != colors[j2][j3])
		if (depth == 1) solver.best_i = j2 end
		return 2
	elseif (colors[j3][j1] != colors[j3][j2])
		if (depth == 1) solver.best_i = j3 end
		return 2
	end

	# look for i in the set (P-S) that splits set into singletons
	for i in P
		(i == j1 || i == j2 || i==j3) && continue

		if ((colors[i][j1] != colors[i][j2])
			&& (colors[i][j1] != colors[i][j3])
			&& (colors[i][j2] != colors[i][j3]))
			if (depth == 1) solver.best_i = i end
			return 2
		end
	end

	# no good. let's stick with j1
	if (depth == 1) solver.best_i = j1 end
	return 3
end

