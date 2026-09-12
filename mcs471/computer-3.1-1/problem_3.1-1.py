import numpy as np


YEARS = np.array([1960, 1970, 1990, 2000], dtype=float)
POPULATIONS = np.array(
    [3039585530, 3707475887, 5281653820, 6079603571], dtype=float
)
YEAR_TO_ESTIMATE = 1980.0
ACTUAL_1980 = 4452584592.0


def estimate(years, populations, year=YEAR_TO_ESTIMATE):
    coefficients = np.polyfit(years, populations, deg=len(years) - 1)
    return float(np.polyval(coefficients, year))


def report(name, value):
    signed_error = value - ACTUAL_1980
    percent_error = 100.0 * signed_error / ACTUAL_1980

    print(f"{name}:")
    print(f"  estimated population: {value:,.0f}")
    print(f"  percent error:        {percent_error:.6f}%")


def main():
    line = estimate(YEARS[[1, 2]], POPULATIONS[[1, 2]])
    parabola = estimate(YEARS[[0, 1, 2]], POPULATIONS[[0, 1, 2]])
    cubic = estimate(YEARS, POPULATIONS)

    print(f"Given 1980 estimate: {ACTUAL_1980:,.0f}\n")
    report("(a) Straight line through 1970 and 1990", line)
    report("(b) Parabola through 1960, 1970, and 1990", parabola)
    report("(c) Cubic through all four data points", cubic)


if __name__ == "__main__":
    main()
