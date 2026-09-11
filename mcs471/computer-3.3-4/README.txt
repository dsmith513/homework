Dylan Smith
Computer Problem 3.3-4

Command to run program:
python proglem_3.3-4.py

Output:
Empirical errors on [-1, 1], sampled every 0.01
  n  Nodes            Max absolute error   Location
 10  Evenly spaced      6.6071375508e-01      -0.94
 10  Chebyshev          5.4428276445e-02      -0.12
 20  Evenly spaced      9.3164500012e+01      -0.97
 20  Chebyshev          2.8458109953e-02      -0.06

Yes, the Runge phenomenon is observed. The graph showing evenly spaced interpolation
has large oscillations near the endpoints that worsen from degree 10 to 20, while the 
Chebyshev interpolation avoids this endpoint growth and has smaller errors.

Saved interpolation_comparison.png and interpolation_comparison.pdf