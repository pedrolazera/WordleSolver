module _Partition

import Base.iterate, Base.length
export T_Layer, update_layer!, create_partition!, create_layers

const _NULL = -1

mutable struct T_Layer
	head::Int64
	len::Int64
	nexts::Vector{Int64} # [len]

	# some auxiliaries structures for partitions
	partition::Vector{Int64} # [len]
	seens::Vector{Int64} # [qtd_colors]
	p_heads::Vector{Int64} # [qtd_colors]
	p_sizes::Vector{Int64} # [qtd_colors]
	p_ids::Vector{Int64} # [len] (itens from the same set have the same color)
	curr_id::Int64

	function T_Layer(len::Int64, qtd_colors::Int64)
		head = 1

		nexts = Vector{Int64}(undef, len)
		for i in 1:(len-1)
			@inbounds nexts[i] = i+1
		end
		nexts[len] = _NULL 

		partition = Vector{Int64}()
		seens = zeros(Int64, qtd_colors)
		p_heads = zeros(Int64, qtd_colors)
		p_sizes = zeros(Int64, qtd_colors)
		p_ids = zeros(Int64, len)
		curr_id = 0

		return new(head, len, nexts, partition,
			seens, p_heads, p_sizes, p_ids, curr_id)
	end
end

#####################
###### Iterator #####
#####################

function Base.iterate(C::T_Layer, state::Int64)
	if state == _NULL
		return nothing
	else
		@inbounds return (state, C.nexts[state])
	end
end

@inline Base.iterate(C::T_Layer) = Base.iterate(C, C.head)
@inline Base.length(C::T_Layer) = C.len

update_layer!(C::T_Layer, color::Int64) = __update_layer!(C, C.p_heads[color], C.p_sizes[color])

function __update_layer!(C::T_Layer, new_head::Int64, new_len::Int64)
	C.head = new_head
	C.len = new_len
end

function update_layer!(C::T_Layer, v::Vector{Int64})
	@assert (minimum(v) >= 1) && (maximum(v) <= length(C.nexts))
	@assert length(v) >= 1

	# set pointers
	C.head = v[1]
	for i in 1:(length(v)-1)
		@inbounds C.nexts[v[i]] = v[i+1]
	end

	C.nexts[v[end]] = _NULL

	# set ids
	C.curr_id += 1
	for vi in v
		C.p_ids[vi] = C.curr_id
	end

	# set size
	C.len = length(v)
end

function create_partition!(C1::T_Layer, C2::T_Layer,
	colors::Vector{Vector{Int64}}, i::Int64)
	old_id = C2.curr_id
	curr_id = old_id
	empty!(C2.partition)

	for j in C1
		(j == i) && continue
		color = colors[i][j]
		if C2.seens[color] <= old_id # first time visiting this color
			curr_id += 1
			C2.nexts[j] = _NULL
			C2.seens[color] = curr_id
			C2.p_heads[color] = j
			C2.p_sizes[color] = 1
			C2.p_ids[j] = curr_id
			push!(C2.partition, color)
		else
			head_j = C2.p_heads[color]
			C2.nexts[j] = head_j
			C2.p_heads[color] = j
			C2.p_sizes[color] += 1
			C2.p_ids[j] = C2.p_ids[head_j]
		end
	end

	C2.curr_id = curr_id
	
	return C2.partition
end

@inline Base.in(i::Int64, C::T_Layer) = (C.p_ids[C.head] == C.p_ids[i])

function create_layers(lexicon_size::Int64, qtd_colors::Int64,
	guesses_limit::Int64)::Vector{T_Layer}
	layers = Vector{T_Layer}(undef, guesses_limit)

	for i in 1:guesses_limit
		layers[i] = T_Layer(lexicon_size, qtd_colors)
	end

	return layers
end

end # module _Partition
