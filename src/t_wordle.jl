const _DEFAULT_WORD_SIZE = 5
const _DEFAULT_GUESSES_LIMIT = 6

struct T_Wordle
	lexicon::T_Lexicon
	colors::T_Colors
	ids::T_Ids # ids de todos os palpites possíveis
	G_ids::T_Ids # ids dos gabaritos
	guesses_limit::Int64
	word_size::Int64
	qtd_colors::Int64
	lexicon_size::Int64

	function T_Wordle(lexicon::T_Lexicon, colors::T_Colors, ids::T_Ids,
		G_ids::T_Ids, guesses_limit::Int64)
		# some checks...
		N = length(lexicon)

		@assert length(lexicon) >= 1 # at least one word
		@assert all( ids .== 1:N )
		@assert issubset(Set(G_ids), Set(ids))
		@assert length(unique(ids)) == length(ids)
		@assert length(unique(G_ids)) == length(G_ids)

		# colors's size is [N][N]
		@assert length(colors) == N
		@assert all(length(c) == N for c in colors)

		# every color is >= 1
		@assert all( all(c[G_ids] .> 0) for c in colors ) 

		# only lower case, from 'a' to 'z'
		@assert all( all('a' .<= Vector{Char}(s) .<= 'z') for s in lexicon )

		# every word is the same size
		word_size = length(lexicon[1])
		@assert all( (length(s) == word_size) for s in lexicon )

		qtd_colors = maximum(maximum(colors[i][j] for j in G_ids) for i in ids)

		return new(
			lexicon,
			colors,
			ids,
			G_ids,
			guesses_limit,
			word_size,
			qtd_colors,
			N,
		)
	end
end

T_Wordle(lexicon::T_Lexicon, colors::T_Colors, ids::T_Ids,
	guesses_limit::Int64=_DEFAULT_GUESSES_LIMIT) = T_Wordle(lexicon, colors, ids, copy(ids), guesses_limit)

T_Wordle(colors::T_Colors) = T_Wordle(
	["a"^_DEFAULT_WORD_SIZE for __ in 1:length(colors)],
	colors,
	collect(1:length(colors))
)

function T_Wordle(lexicon::T_Lexicon, guess_words::T_Lexicon,
	guesses_limit::Int64=_DEFAULT_GUESSES_LIMIT)
	# some checks...
	@assert length(guess_words) >= 1 # at least one word
	@assert issubset(Set(guess_words), Set(lexicon))

	ids = collect(1:length(lexicon))

	# G_ids (no need to optimize)
	G_ids = Vector{Int64}(undef, length(guess_words))
	for (i, s) in enumerate(guess_words)
		G_ids[i] = findfirst(i -> i==s, lexicon)
	end

	colors = _Colors.compute_colors(lexicon, G_ids)

	return T_Wordle(
		lexicon,
		colors,
		ids,
		G_ids,
		guesses_limit,
	)
end

T_Wordle(s::Symbol) = T_Wordle(
	load_lexicon(s),
	load_hiddenwords(s)
)