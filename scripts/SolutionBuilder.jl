module SolutionBuilder

export build_solution, printa

import WordleSolver

const _NUM_TO_LETRA = Dict(
	0 => "R",
	1 => "Y",
	2 => "G"
)

const _GREEN_ID = 243

mutable struct Node
	S::Vector{Int64}
	i::Int64
	opt::Int64

	children_colors::Vector{Int64}
	children::Vector{Node}
end

Node(S) = Node(S, -1, -1, Vector{Int64}(), Vector{Node}())

function printa(lexicon::Vector{String}, node::Node)
	lines = Vector{String}()
	depth = 1
	_printa!(lines, lexicon, node, depth)
	return lines
end

function _printa!(lines::Vector{String}, lexicon::Vector{String}, node::Node, depth::Int64)
	(node.i == -1) && return nothing
	push!(lines, "\t"^(depth-1)*lexicon[node.i])
	for (color, child) in zip(node.children_colors, node.children)
		rgb_color = cor_id_to_cor_letra(color)
		push!(lines, "\t"^(depth) * rgb_color)
		_printa!(lines, lexicon, child, depth+2)
	end
end

function build_solution(solver, W)
	node = Node(copy(W.G_ids))
	_build_solution(solver, W, W.ids, node)
	return node
end

function _build_solution(solver, W, P, node)::Nothing
	(length(node.S) == 0) && return nothing

	(opt, i) = WordleSolver.f_min(solver, W, P, node.S)
	node.i = i
	node.opt = opt

	if i in node.S
		push!(node.children_colors, _GREEN_ID)
		push!(node.children, Node([]))
	end

	partes_color, partes = particiona(node.S, i, W.colors)
	for (color, Sj) in zip(partes_color, partes)
		push!(node.children_colors, color)
		child = Node(Sj)
		_build_solution(solver, W, P, child)
		push!(node.children, child)
	end

	return nothing
end

function particiona(S::Vector{Int64}, i::Int64, colors::Vector{Vector{Int64}})
	_d = Dict{Int64, Vector{Int64}}()
	partes_color = Vector{Int64}()
	partes = Vector{Vector{Int64}}()

	for j in S
		(j == i) && continue
		color = colors[i][j]
		if !haskey(_d, color)
			_d[color] = Vector{Int64}()
			push!(partes_color, color)
			push!(partes, _d[color])
		end

		push!(_d[color], j)
	end

	return (partes_color, partes)
end

function cor_id_to_cor_letra(cor::Int64)::String
	# assume que cor está incrementado em 1 para lidar com a indexação de Julia
	@assert 1 <= cor <= 243

	v = ["R" for __ in 1:5]
	
	cor = cor - 1
	
	for i in 1:5
		v[5-i+1] = _NUM_TO_LETRA[mod(cor, 3)]
		cor = div(cor, 3)
	end

	return join(v, "")
end

end # module SolutionBuilder