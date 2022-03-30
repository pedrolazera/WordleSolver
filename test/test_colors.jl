@testset "compute color - palpite vs gabarito" begin
	@test WordleSolver.compute_color("aaiun", "aarao") == 216+1
	@test WordleSolver.compute_color("ababa", "aarao") == 172+1
	@test WordleSolver.compute_color("raiao", "patio") == 65+1
end

@testset "compute colors" begin
	lexicon = ["aaiun", "aarao", "ababa", "livro"]
	colors = [
		[242,216,189,9] .+ 1,
		[216,242,192,11] .+ 1,
		[171,172,242,0] .+ 1,
		[27,5,0,242] .+ 1
	]

	C = WordleSolver.compute_colors(lexicon)
	@test C == colors
end
