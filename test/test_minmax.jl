@testset "minmax - set 1" begin
	colors = [
		[0,2,2,2,2,2] .+ 1, # 5
		[1,0,2,2,2,2] .+ 1, # 1, 4
		[1,1,0,2,2,2] .+ 1, # 2, 3
		[1,1,1,0,2,2] .+ 1, # 3, 2
		[1,1,1,1,0,2] .+ 1, # 4, 1
		[1,2,2,3,3,0] .+ 1  # 1, 2, 2
	]

	W = WordleSolver.T_Wordle(colors)
	max_depth = 1
	solver = WordleSolver.T_MinMax(max_depth)

	@test WordleSolver.f_min(solver, W) == (3, 6)

end

@testset "minmax - set 2" begin
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
	
	##### depth = 1
	max_depth = 1
	solver = WordleSolver.T_MinMax(max_depth)
	@test WordleSolver.f_min(solver, W) == (5, 2)

	##### depth = 2
	max_depth = 2
	solver = WordleSolver.T_MinMax(max_depth)
	@test WordleSolver.f_min(solver, W) == (3, 1)
end

@testset "minmax - set 3" begin
	colors = [
		[242,1,1,1,1,1,2] .+ 1, # A
		[1,242,2,2,1,1,2] .+ 1, # B -> [A, E, F], [C, D, G]
		[1,1,242,2,2,2,2] .+ 1, # C -> [A, B], [D, E, F, G]
		[1,1,1,242,2,2,2] .+ 1, # D -> [A, B, C] [E, F, G]
		[1,1,1,1,242,1,2] .+ 1, # E
		[0,2,2,3,0,242,3] .+ 1, # F
		[0,1,1,1,1,1,242] .+ 1  # G
	]

	W = WordleSolver.T_Wordle(colors)
	max_depth = 2
	solver = WordleSolver.T_MinMax(max_depth)

	@test WordleSolver.f_min(solver, W) == (3, 4)
end