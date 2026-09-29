import numpy as np


def bisection(f, a, b, tol=1e-12):
    fa, fb = f(a), f(b)
    if fa == 0:
        return a
    if fb == 0:
        return b
    if np.signbit(fa) == np.signbit(fb):
        raise ValueError("The endpoints must bracket a root.")

    while (b - a) / 2 > tol:
        midpoint = (a + b) / 2
        fm = f(midpoint)
        if fm == 0:
            return midpoint
        if np.signbit(fa) == np.signbit(fm):
            a, fa = midpoint, fm
        else:
            b = midpoint

    return (a + b) / 2


if __name__ == "__main__":
    problems = [
        ("a", lambda x: x**5 + x - 1, 0.0, 1.0),
        ("b", lambda x: np.sin(x) - 6*x - 5, -1.0, 0.0),
        ("c", lambda x: np.log(x) + x**2 - 3, 1.0, 2.0),
    ]

    for label, f, a, b in problems:
        root = bisection(f, a, b)
        print(f"({label}) x = {root:.8f}")
