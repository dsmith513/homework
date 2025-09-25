Dylan Smith Assignment 3
Breadth-First-Search

Language used: C++
Compiler used: g++
OS used: Windows
IDE used: VSCode

Run these commands in VSCode terminal to run code:
g++ main.cpp -o bfs -lpsapi
.\bfs.exe

Output:
Moves taken: RDLDDRR
Nodes expanded: 229
Time taken: 0.0016454 seconds
Memory used: 60kb

This output is using the test solution in the Assignment 3 instructions with this initial state:
{1, 0, 2, 4, 5, 7, 3, 8, 9, 6, 11, 12, 13, 10, 14, 15}

To test different states change the values on the test_solution variable in main.cpp.
The value 0 represents the blank square in the 15-puzzle.
The code will only work on Windows machines because I used the GetProcessMemoryInfo() function to calculate memory usage.