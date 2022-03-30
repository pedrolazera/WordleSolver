# WordleSolver
**WordleSolver** is a julia package to solve Wordle games. Some examples of this game, along with rules description, are [Wordle](https://www.nytimes.com/games/wordle/index.html), [Termo](https://term.ooo/) and [Le Mot](https://wordle.louan.me/)

## How it works

A Wordle game is a triplet (G, H, limit), where...

* **G** is the set of all possible guesses (words)
* **H** (a subset of G) is the set all possible hiddenwords
* **limit** is the maximum number of guesses alowed

... and you goal is guess the hiddenword.

There are at least two meanings for "solve": find the strategy with the best worst-case and find the strategy with the best average-case (provided that the words from **H** are sampled with equal propability).

## The algorithm

In a nutshell, **WordleSolver** finds the best word with a min-max search enhanced with alpha-beta pruning and other stuff.