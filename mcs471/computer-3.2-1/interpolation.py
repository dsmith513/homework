"""Degree-four interpolation: NumPy calculations and Matplotlib plots."""

import numpy as np
import matplotlib.pyplot as plt


def divided_differences(nodes, values):
    table = np.zeros((nodes.size, nodes.size))
    table[:, 0] = values
    for order in range(1, nodes.size):
        count = nodes.size - order
        table[:count, order] = (
            table[1:count + 1, order - 1] - table[:count, order - 1]
        ) / (nodes[order:] - nodes[:count])
    return table


def newton_value(x, nodes, coefficients):
    x = np.asarray(x, dtype=float)
    result = np.full_like(x, coefficients[-1])
    for k in range(coefficients.size - 2, -1, -1):
        result = coefficients[k] + (x - nodes[k]) * result
    return result


def main():
    nodes = np.array([0.6, 0.7, 0.8, 0.9, 1.0])
    values = np.array([1.433329, 1.632316, 1.896481, 2.247908, 2.718282])
    table = divided_differences(nodes, values)
    coefficients = table[0]
    print("Divided differences (blank entries are unused):")
    for i, node in enumerate(nodes):
        entries = " ".join(f"{v:15.10f}" for v in table[i, :nodes.size - i])
        print(f"{node:.1f} {entries}")

    polynomial = np.polynomial.Polynomial([coefficients[-1]])
    for k in range(coefficients.size - 2, -1, -1):
        polynomial = coefficients[k] + np.polynomial.Polynomial(
            [-nodes[k], 1.0]
        ) * polynomial
    print("\nPower coefficients, constant term first:")
    print(polynomial.coef)
    print("Maximum residual at supplied nodes:",
          np.max(np.abs(newton_value(nodes, nodes, coefficients) - values)))

    # f^(5)(x) = (32*x**5 + 160*x**3 + 120*x)*exp(x**2).
    # This is increasing for x >= 0, so on [0.6, 1] its maximum
    # is M = 312*e. 5! = 120.
    derivative_max = 312.0 * np.exp(1.0)
    print(f"\nMaximum fifth derivative on [0.6, 1]: {derivative_max:.12f}")
    for x in [0.82, 0.98]:
        interpolated = float(newton_value(x, nodes, coefficients))
        exact = np.exp(x**2)
        remainder_bound = derivative_max / 120.0 * np.abs(np.prod(x - nodes))
        # A polynomial made from rounded samples also has data error:
        # |P(x)-Q(x)| <= 0.5e-6 * sum_i |L_i(x)|, with Q using exact samples.
        lagrange_weights = np.empty(nodes.size)
        for i in range(nodes.size):
            others = np.delete(nodes, i)
            lagrange_weights[i] = np.prod((x - others) / (nodes[i] - others))
        rounding_bound = 0.5e-6 * np.sum(np.abs(lagrange_weights))
        print(f"\nx = {x:.2f}")
        print(f"  P4(x)                     = {interpolated:.12f}")
        print(f"  exp(x**2)                 = {exact:.12f}")
        print(f"  signed error P4-f         = {interpolated - exact:.12e}")
        print(f"  absolute error            = {abs(interpolated - exact):.12e}")
        print(f"  interpolation bound       = {remainder_bound:.12e}")
        print(f"  rounding contribution     = {rounding_bound:.12e}")
        print(f"  bound including rounding  = {remainder_bound + rounding_bound:.12e}")

    fig, axes = plt.subplots(1, 2, figsize=(12, 4.5), layout="constrained")
    for ax, (left, right) in zip(axes, [(0.5, 1.0), (0.0, 2.0)]):
        x = np.linspace(left, right, 2001)
        error = newton_value(x, nodes, coefficients) - np.exp(x**2)
        ax.plot(x, error, label=r"$P_4(x)-e^{x^2}$")
        ax.scatter(nodes, values - np.exp(nodes**2), s=22,
                   color="tab:orange", zorder=3, label="Supplied nodes")
        ax.axhline(0, color="black", linewidth=0.7)
        ax.set(xlabel="x", ylabel="Signed error", title=f"Error on [{left:g}, {right:g}]",
               xlim=(left, right))
        ax.grid(alpha=0.3)
        ax.ticklabel_format(axis="y", style="sci", scilimits=(-3, 3))
        ax.legend()
    fig.savefig("interpolation_error.png", dpi=200)
    fig.savefig("interpolation_error.pdf")
    plt.close(fig)
    print("\nSaved interpolation_error.png and interpolation_error.pdf")


if __name__ == "__main__":
    main()
