Dylan Smith Assignment 10
Decision Tree

Language used: C++
Compiler used: g++
OS used: Windows
IDE used: VSCode

Run these commands in VSCode terminal to run code:
g++ decision_tree.cpp -o decision_tree 
./decision_tree

Make sure restaurant.csv is in the same folder as decision_tree.cpp.

Output generated from restaurant.csv:

Some ?
  [Full] ->
    Yes ?
      [No] -> Leaf: No
      [Yes] ->
        French ?
          [Burger] -> Leaf: Yes
          [Italian] -> Leaf: No
          [Thai] ->
            No ?
              [No] -> Leaf: No
              [Yes] -> Leaf: Yes
  [None] -> Leaf: No
  [Some] -> Leaf: Yes