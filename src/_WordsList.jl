module _WordsList

export load_lexicon, load_hiddenwords

const _PATH_DIR_DATA = abspath(joinpath(Base.@__DIR__, "..", "data"))

const _PATH_LEXICON_WORDLE = abspath(joinpath(_PATH_DIR_DATA, "wordle_lexicon.txt"))
const _PATH_HIDDENWORDS_WORDLE = abspath(joinpath(_PATH_DIR_DATA, "wordle_hiddenwords.txt"))

const _PATH_LEXICON_TERMO = abspath(joinpath(_PATH_DIR_DATA, "termo_lexicon.txt"))
const _PATH_HIDDENWORDS_TERMO = abspath(joinpath(_PATH_DIR_DATA, "termo_hiddenwords.txt"))

function _load_words(path::String)::Vector{String}
	L = Vector{String}()
	open(path, "r") do fp
		for s in readlines(fp)
			if (length(strip(s)) > 0)
				push!(L, s)
			end
		end
	end

	return L
end

function load_lexicon(s::Symbol)::Vector{String}
	if s == :Wordle
		return _load_words(_PATH_LEXICON_WORDLE)
	elseif s == :Termo
		return _load_words(_PATH_LEXICON_TERMO)
	else
		throw("Unkown lexicon: <<$(s)>>")
	end
end

function load_hiddenwords(s::Symbol)::Vector{String}
	if s == :Wordle
		return _load_words(_PATH_HIDDENWORDS_WORDLE)
	elseif s == :Termo
		return _load_words(_PATH_HIDDENWORDS_TERMO)
	else
		throw("Unkown lexicon: <<$(s)>>")
	end
end

end # module _WordsList