Dylan Smith
Computer Problem 3.2-1

Command to run the program:
python problem_3.2-1.py

Output:
Divided differences:
0.6    1.4333290000    1.9898700000    3.2589000000    3.6806666667    4.0004166667
0.7    1.6323160000    2.6416500000    4.3631000000    5.2808333333
0.8    1.8964810000    3.5142700000    5.9473500000
0.9    2.2479080000    4.7037400000
1.0    2.7182820000

Degree 4 polynomial:
P4(x) = 4.0004166667x^4 -8.3205833333x^3 +8.9308958333x^2 -3.4736141667x +1.5811670000

x = 0.82
  P4(x)                     = 1.958909774400
  exp(x**2)                 = 1.958933122914
  interpolation bound       = 5.373586503516e-05
  signed error P4-f         = -2.334851421470e-05

x = 0.98
  P4(x)                     = 2.612847966400
  exp(x**2)                 = 2.612741360976
  interpolation bound       = 2.165718196872e-04
  signed error P4-f         = 1.066054239338e-04

Saved interpolation_error.png and interpolation_error.pdf