@testset "small partition" begin
	colors = [
		#  1   2   3   4   5   6   7   8   9  10  11  12  13
		[242,  1,  1,  1,  1,  1,  6,  6,  7,  7,  8,  8,  9], # A (1)
		[  6,242,  1,  2,  3,  4,  6,  6,  6,  7,  7,  7,  7], # B (2)
		[  6,  1,242,  2,  3,  4,  6,  6,  6,  7,  7,  7,  7], # C (3)
		[  6,  1,  2,242,  3,  4,  6,  6,  6,  7,  7,  7,  7], # D (4)
		[  6,  1,  2,  3,242,  4,  6,  6,  6,  7,  7,  7,  7], # E (5)
		[  6,  1,  2,  3,  4,242,  6,  6,  6,  7,  7,  7,  7], # F (6)
		[  6,  1,  2,  3,  4,  5,242,  6,  6,  7,  7,  7,  7], # G (7)
		[  6,  1,  2,  3,  4,  5,  6,242,  6,  7,  7,  7,  7], # H (8)
		[  6,  1,  2,  3,  4,  5,  6,  6,242,  7,  7,  7,  7], # I (9)
		[  6,  1,  2,  3,  4,  5,  6,  6,  6,242,  7,  7,  7], # J (10)
		[  6,  1,  2,  3,  4,  5,  6,  6,  6,  7,242,  7,  7], # K (11)
		[  6,  1,  2,  3,  4,  5,  6,  6,  6,  7,  7,242,  7], # L (12)
		[  6,  1,  2,  3,  4,  5,  6,  6,  6,  7,  7,  7,242]  # M (13)
	]

	W = WordleSolver.T_Wordle(colors)
	len_lexicon = length(W.lexicon)
	qtd_colors = 243
	L_1 = WordleSolver.T_Layer(len_lexicon, qtd_colors)
	L_2 = WordleSolver.T_Layer(len_lexicon, qtd_colors)
	L_3 = WordleSolver.T_Layer(len_lexicon, qtd_colors)

	partition = WordleSolver.create_partition!(L_1, L_2, W.colors, 1)
	@test length(partition) == 5
	@test L_2.p_sizes[[1, 6, 7, 8, 9]] == [5, 2, 2, 2, 1]
	@test L_2.p_heads[[1, 6, 7, 8, 9]] == [6, 8, 10, 12, 13]

	cor = partition[1]
	WordleSolver.update_layer!(L_2, cor)
	@test length(L_2) == 5
	@test all([j for j in L_2] .== [6, 5, 4, 3, 2])

	cor = partition[2]
	WordleSolver.update_layer!(L_2, cor)
	@test length(L_2) == 2
	@test all([j for j in L_2] .== [8, 7])

	WordleSolver.update_layer!(L_2, partition[1])
	partition = WordleSolver.create_partition!(L_2, L_3, W.colors, 1)
	@test length(partition) == 1

	partition = WordleSolver.create_partition!(L_2, L_3, W.colors, 2)
	@test length(partition) == 4
	cor = partition[3]
	WordleSolver.update_layer!(L_3, cor)
	@test all([j for j in L_3] .== [4])

	partition = WordleSolver.create_partition!(L_2, L_3, W.colors, 8)
	@test length(partition) == 5
end

@testset "change parition with a vector" begin
	v = [6,1,2,7,5]
	layer = WordleSolver.T_Layer(10, maximum(v))
	WordleSolver.update_layer!(layer, v)

	@test layer.head == v[1]
	@test length(layer) == length(v)
	@test all([j for j in layer] .== v)
end

@testset "test p_ids" begin
	colors = [
		#  1   2   3   4   5   6   7   8   9  10  11  12  13
		[242,  1,  1,  1,  1,  1,  6,  6,  7,  7,  8,  8,  9], # A (1)
		[  6,242,  1,  2,  3,  4,  6,  6,  6,  7,  7,  7,  7], # B (2)
		[  6,  1,242,  2,  3,  4,  6,  6,  6,  7,  7,  7,  7], # C (3)
		[  6,  1,  2,242,  3,  4,  6,  6,  6,  7,  7,  7,  7], # D (4)
		[  6,  1,  2,  3,242,  4,  6,  6,  6,  7,  7,  7,  7], # E (5)
		[  6,  1,  2,  3,  4,242,  6,  6,  6,  7,  7,  7,  7], # F (6)
		[  6,  1,  2,  3,  4,  5,242,  6,  6,  7,  7,  7,  7], # G (7)
		[  6,  1,  2,  3,  4,  5,  6,242,  6,  7,  7,  7,  7], # H (8)
		[  6,  1,  2,  3,  4,  5,  6,  6,242,  7,  7,  7,  7], # I (9)
		[  6,  1,  2,  3,  4,  5,  6,  6,  6,242,  7,  7,  7], # J (10)
		[  6,  1,  2,  3,  4,  5,  6,  6,  6,  7,242,  7,  7], # K (11)
		[  6,  1,  2,  3,  4,  5,  6,  6,  6,  7,  7,242,  7], # L (12)
		[  6,  1,  2,  3,  4,  5,  6,  6,  6,  7,  7,  7,242]  # M (13)
	]

	W = WordleSolver.T_Wordle(colors)
	len_lexicon = length(W.lexicon)
	qtd_colors = 243
	qtd_layers = 2

	c1, c2 = WordleSolver.create_layers(len_lexicon, qtd_colors, qtd_layers)

	# create partition from guess i=2
	i = 2
	WordleSolver.create_partition!(c1, c2, W.colors, i)
	@test length(c2.partition) == 6
	@test c2.p_ids[2] != c2.p_ids[3]
	@test c2.p_ids[7] == c2.p_ids[9]

	# test "Base.in"
	color = 6
	WordleSolver.update_layer!(c2, color)
	@test !(2 in c2)
	@test (7 in c2)
end