# WordleSolver
**WordleSolver** is a julia package to solve Wordle games. Some examples of this game, along with rules description, are [Wordle](https://www.nytimes.com/games/wordle/index.html), [Termo](https://term.ooo/) and [Le Mot](https://wordle.louan.me/).

## How it works

A Wordle game is a triplet (G, H, limit), where...

* **G** is the set of all possible guesses (words)
* **H** (a subset of G) is the set all possible hiddenwords
* **limit** is the maximum number of guesses alowed

... and you goal is guess the hiddenword.

There are at least two meanings for "solve": find the strategy with the best worst-case and find the strategy with the best average-case (provided that the words from **H** are sampled with equal propability).

## The algorithm

In a nutshell, **WordleSolver** finds the best strategy with a min-max search enhanced with alpha-beta pruning and other stuff. The search, when run in standard mode, always finds the optimal solution. You can also set the algorithm to work as an heuristic, therefore increasing its speed by a very large factor, but with no garanteed best solution.

#### Modeling

When your objective is to find the best worst-case strategy, wordle can be viewed as finite, zero-sum, two-player games with perfect information. One player chooses the word (the testword) and another player paints the testword, assigning colors to each letter. More about that will be described in another page (to do!).

## Explicit solutions

The package comes with explicit solutions for the **Wordle** and **Termo** versions (inside the /scrips/explicit) package.

* The best average-case strategy for Wordle ([link](https://github.com/pedrolazera/WordleSolver/blob/main/scripts/explicit/out_Wordle_AVG_1648601816.txt)) starts with the word *Salet* and uses 3.42 guesses per game.
* The best worst-case strategy for Wordle ([link](https://github.com/pedrolazera/WordleSolver/blob/main/scripts/explicit/out_Wordle_MAX_1648601916.txt)) uses at most 5 words. There many ways to achive that, one starting with the word 'aesir'. Since you asked, 'aesir' refers to the gods of the principal pantheon in Norse religion [Wiki](https://en.wikipedia.org/wiki/%C3%86sir).
* * The best average-case strategy for Termo ([link](https://github.com/pedrolazera/WordleSolver/blob/main/scripts/explicit/out_Termo_AVG_1648600950.txt)) starts with the word *coras* and uses 3.42 guesses per game.
* The best worst-case strategy for Termo ([link](https://github.com/pedrolazera/WordleSolver/blob/main/scripts/explicit/out_Wordle_MAX_1648601916.txt)) uses at most 4 words. here many ways to achive that, one starting with the word 'tarol'.