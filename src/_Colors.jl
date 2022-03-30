module _Colors

const _ALPHABET_SIZE = 'z'-'a'+1
const _GREEN = 2
const _YELLOW = 1
const _RED = 0

export compute_color, compute_colors

function compute_colors(lexicon::Vector{String}, G_ids::Vector{Int64})::Vector{Vector{Int64}}
	@assert length(lexicon) >= 1

	N = length(lexicon)

	colors = Vector{Vector{Int64}}(undef, N)
	lexicon_rel::Vector{Vector{Int64}} = [ chars_to_nums(s) for s in lexicon ]
	frequencies::Vector{Vector{Int64}} = [ get_frequency(s_rel) for s_rel in lexicon_rel ]
	
	_word_size = length(lexicon[1])
	_freq_j = Vector{Int64}(undef, _ALPHABET_SIZE)
	_is_green = Vector{Bool}(undef, _word_size)

	for i in 1:N
		colors[i] = Vector{Int64}(undef, N)
		for j in G_ids
			_freq_j .= frequencies[j]
			colors[i][j] = _compute_color!(lexicon_rel[i], lexicon_rel[j], _freq_j, _is_green)
		end
	end
	
	return colors
end

compute_colors(lexicon::Vector{String}) = compute_colors(lexicon, collect(1:length(lexicon)))

"""
compute color (as a number) from testword=palpite and guessword = gabarito
"""
function _compute_color!(palpite::Vector{Int64}, gabarito::Vector{Int64},
	freq_gabarito::Vector{Int64}, is_green::Vector{Bool})::Int64
	tam = length(palpite)
	cor = 0

	is_green .= false

	# GREEN
	for i in 1:tam
		if palpite[i] == gabarito[i]
			cor += _GREEN * (3^(tam-i))
			freq_gabarito[gabarito[i]] -= 1
			is_green[i] = true
		end
	end

	# YELLOW, RED
	for i in 1:tam
		is_green[i] && continue

		if freq_gabarito[palpite[i]] > 0
			freq_gabarito[palpite[i]] -= 1
			cor += _YELLOW * (3^(tam-i))
		else
			cor += _RED * (3^(tam-i))
		end
	end

	return cor+1 # evita cor zero, por conta da indexação de Julia
end

chars_to_nums(s::String)::Vector{Int64} = [si-'a'+1 for si in s]

function get_frequency(s_rel::Vector{Int64})::Vector{Int64}
	frequencia = zeros(Int64, 26)
	for letra in s_rel
		frequencia[letra] += 1
	end

	return frequencia
end

function compute_color(palpite::String, gabarito::String)
	palpite_rel = chars_to_nums(palpite)
	gabarito_rel = chars_to_nums(gabarito)
	_freq_gabarito = get_frequency(gabarito_rel)
	_is_green = Vector{Bool}(undef, length(palpite))
	_compute_color!(palpite_rel, gabarito_rel, _freq_gabarito, _is_green)
end

end # module _Colors