Dylan Smith Assignment 6
MDP Value Iteration

Language used: C++
Compiler used: g++
OS used: Windows
IDE used: VSCode

Run these commands in VSCode terminal to run code:
g++ main.cpp mdp.cpp -o mdp
./mdp input.txt

The MDP parameters are read from the file input.txt. To change any of the parameters, change the appropriate value in input.txt and re-run the program.
The input.txt file format is the same as the sample format included with the assignment. The load_mdp() function in mdp.cpp handles reading input files formatted in the following style:

# size of the gridworld
size : 3 4
# list of locations of walls
walls : 2 2
# list of terminal states (row,column,reward)
terminal_states : 3 4 +1 , 2 4 -1
# reward in non-terminal states
reward : -0.04
# transition probabilities (intended, left, right, reverse)
transition_probabilities : 0.8 0.1 0.1 0
discount_rate : 1
epsilon : 0.001

The load_mdp() function ignores lines beginning with a '#' character and looks for key words "size", "walls", "terminal_states", "reward", "transition_probabilities", "discount_rate", and "epsilon".
The order that these key words appear in the input file does not matter. The load_mdp() function searches for these key words and extracts the appropriate values after them to initialize the MDP.

Output:
The program prints the utilities of each cell in the grid after each iteration as well as the final utilities and optimal policy grid when the algorithm finishes. Walls are represented with the '#' character.

Sample output using values given in the assignment:

Running value iteration:

Initial utilities (iteration 0):
   0.000   0.000   0.000   1.000
   0.000       #   0.000  -1.000
   0.000   0.000   0.000   0.000

Iteration 1 utilities:
  -0.040  -0.040   0.760   1.000
  -0.040       #  -0.040  -1.000
  -0.040  -0.040  -0.040  -0.040

Iteration 2 utilities:
  -0.080   0.560   0.832   1.000
  -0.080       #   0.464  -1.000
  -0.080  -0.080  -0.080  -0.080

Iteration 3 utilities:
   0.392   0.738   0.890   1.000
  -0.120       #   0.572  -1.000
  -0.120  -0.120   0.315  -0.120

Iteration 4 utilities:
   0.577   0.819   0.906   1.000
   0.250       #   0.629  -1.000
  -0.160   0.188   0.394   0.100

Iteration 5 utilities:
   0.698   0.849   0.914   1.000
   0.472       #   0.648  -1.000
   0.162   0.313   0.492   0.185

Iteration 6 utilities:
   0.756   0.861   0.916   1.000
   0.613       #   0.656  -1.000
   0.385   0.416   0.528   0.272

Iteration 7 utilities:
   0.785   0.865   0.917   1.000
   0.687       #   0.658  -1.000
   0.530   0.466   0.553   0.310

Iteration 8 utilities:
   0.799   0.867   0.918   1.000
   0.726       #   0.660  -1.000
   0.609   0.496   0.564   0.334

Iteration 9 utilities:
   0.806   0.867   0.918   1.000
   0.745       #   0.660  -1.000
   0.651   0.547   0.571   0.345

Iteration 10 utilities:
   0.809   0.868   0.918   1.000
   0.754       #   0.660  -1.000
   0.675   0.590   0.577   0.351

Iteration 11 utilities:
   0.810   0.868   0.918   1.000
   0.758       #   0.660  -1.000
   0.689   0.618   0.582   0.357

Iteration 12 utilities:
   0.811   0.868   0.918   1.000
   0.760       #   0.660  -1.000
   0.697   0.635   0.586   0.361

Iteration 13 utilities:
   0.811   0.868   0.918   1.000
   0.761       #   0.660  -1.000
   0.701   0.645   0.593   0.365

Iteration 14 utilities:
   0.811   0.868   0.918   1.000
   0.761       #   0.660  -1.000
   0.703   0.650   0.601   0.371

Iteration 15 utilities:
   0.812   0.868   0.918   1.000
   0.761       #   0.660  -1.000
   0.704   0.653   0.606   0.378

Iteration 16 utilities:
   0.812   0.868   0.918   1.000
   0.761       #   0.660  -1.000
   0.705   0.654   0.609   0.383

Iteration 17 utilities:
   0.812   0.868   0.918   1.000
   0.762       #   0.660  -1.000
   0.705   0.655   0.610   0.385

Iteration 18 utilities:
   0.812   0.868   0.918   1.000
   0.762       #   0.660  -1.000
   0.705   0.655   0.611   0.387

Iteration 19 utilities:
   0.812   0.868   0.918   1.000
   0.762       #   0.660  -1.000
   0.705   0.655   0.611   0.387

=============================================
Final utilities after 19 iterations:
   0.812   0.868   0.918   1.000
   0.762       #   0.660  -1.000
   0.705   0.655   0.611   0.387

Optimal policy:
  >    >    >    T
  v    #    v    T
  v    <    <    <  