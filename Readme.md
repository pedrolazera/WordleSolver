# WordleSolver
**WordleSolver** is a julia package to solve Wordle games. Some examples of this game, along with rules description, are [Wordle](https://www.nytimes.com/games/wordle/index.html), [Termo](https://term.ooo/) and [Le Mot](https://wordle.louan.me/).

## How it works

A Wordle game is a triplet (G, H, limit), where...

* **P** is the set of all possible guesses (words)
* **S** (a subset of **P**) is the set all possible hidden words
* **limit** is the maximum number of guesses allowed

... and you goal is guess the hidden word.

There are at least two meanings for "solve": find the strategy with the best worst-case and find the strategy with the best average-case (provided that the words from **S** are sampled with equal probability).

## How to use

#### Simple usage with custom words and hidden words

```julia


using WordleSolver

max_depth = 5 # maximum search depth
W = WordleSolver.T_Wordle(P, S) # assumes G and H are vector of strings
solver = WordleSolver.MinAvg5(max_depth, W)
(opt, i) = WordleSolver.f_min(solver, W)
```

#### Simple usage with words from famous game versions

```julia


using WordleSolver

max_depth = 5 # maximum search depth
W = WordleSolver.T_Wordle(:Wordle) # this is the original Wordle game
solver = WordleSolver.MinAvg5(max_depth, W)
(opt, i) = WordleSolver.f_min(solver, W)
```

## The algorithm

In a nutshell, **WordleSolver** finds the best strategy with a min-max search enhanced with alpha-beta pruning and other stuff. The search, when run in standard mode, always finds the optimal solution. You can also set the algorithm to work as an heuristic, therefore increasing its speed by a very large factor, but with no guaranteed  best solution.

#### Modeling

When your objective is to find the best worst-case strategy, wordle can be modeled as finite, zero-sum, two-player games with perfect information. One player chooses the word (the testword) and another player paints the testword, assigning colors to each letter. More about that will be described in another page (to do!).

#### Usefulness of this package

This package aims to provide Wordle solutions with proof and clean code, for educational purposes. The solvers (MinAvg and MinMax) have several versions, one built on top of the other, increasing the complexity gradually.

## Explicit solutions

The package comes with explicit solutions for the **Wordle** and **Termo** versions, located at the the [scripts/explicit_solutions](https://github.com/pedrolazera/WordleSolver/tree/main/scripts/explicit_solutions) folder.

* The best average-case strategy for Wordle ([link](https://github.com/pedrolazera/WordleSolver/blob/main/scripts/explicit/out_Wordle_AVG_1648601816.txt)) starts with the word **Salet** and uses on average **3.42** guesses per game.
* The best worst-case strategy for Wordle ([link](https://github.com/pedrolazera/WordleSolver/blob/main/scripts/explicit/out_Wordle_MAX_1648601916.txt)) uses **at most 5 words**. There many ways to achieve that, one starting with the word 'aesir'. Since you asked, 'aesir' refers to the gods of the principal pantheon in Norse religion [Wiki](https://en.wikipedia.org/wiki/%C3%86sir).
* The best average-case strategy for Termo ([link](https://github.com/pedrolazera/WordleSolver/blob/main/scripts/explicit/out_Termo_AVG_1648600950.txt)) starts with the word **coras** and uses **3.23** guesses per game.
* The best worst-case strategy for Termo ([link](https://github.com/pedrolazera/WordleSolver/blob/main/scripts/explicit/out_Wordle_MAX_1648601916.txt)) uses **at most 4 words**. There many ways to achieve that, one starting with the word **Tarol**, which is a musical instrument.