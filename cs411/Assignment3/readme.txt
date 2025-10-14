Dylan Smith Assignment 5
A-Star Search

Language used: C++
Compiler used: g++
OS used: Windows
IDE used: VSCode

Run these commands in VSCode terminal to run code:
g++ astar.cpp -o astar -lpsapi
.\astar.exe

The A-Star algorithm supports both the Manhattan distance and misplaced tiles heuristic functions.
The user is prompted to choose with heuristic function to use when running the algorithm.

Output:
Enter 1 for misplaced tiles heuristic or 2 for Manhattan Distance heuristic:
1
Moves taken: RDLDDRR
Nodes expanded: 12
Time taken: 0.002599 seconds
Memory used: 48kb

Enter 1 for misplaced tiles heuristic or 2 for Manhattan Distance heuristic: 
2
Moves taken: RDLDDRR
Nodes expanded: 12
Time taken: 0.0022033 seconds
Memory used: 48kb

This output is using the test solution in the Assignment 3 instructions with this initial state:
{1, 0, 2, 4, 5, 7, 3, 8, 9, 6, 11, 12, 13, 10, 14, 15}

To test different states change the values on the test_solution variable in astar.cpp.
The value 0 represents the blank square in the 15-puzzle.
The code will only work on Windows machines because I used the GetProcessMemoryInfo() function to calculate memory usage.