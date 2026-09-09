import numpy as np
import matplotlib.pyplot as plt


def f(x):
    return np.exp(np.abs(x))


def interpolate(nodes, values, x):
    """Evaluate the polynomial interpolant using the barycentric formula."""
    differences = nodes[:, None] - nodes[None, :]
    np.fill_diagonal(differences, 1.0)
    weights = 1.0 / np.prod(differences, axis=1)
    weights /= np.max(np.abs(weights))

    distances = x[:, None] - nodes[None, :]
    hits = distances == 0.0
    # Avoid division by zero; replace these rows by exact nodal values below.
    safe_distances = np.where(hits, 1.0, distances)
    terms = weights / safe_distances
    result = (terms @ values) / np.sum(terms, axis=1)
    rows, columns = np.nonzero(hits)
    result[rows] = values[columns]
    return result


def main():
    # 201 samples include both endpoints, with spacing 0.01.
    x = np.linspace(-1.0, 1.0, 201)
    exact = f(x)
    # A finer grid makes the polynomial curves easier to see; error statistics
    # and error plots use only the requested 0.01 grid.
    plot_x = np.linspace(-1.0, 1.0, 2001)
    fig, axes = plt.subplots(2, 2, figsize=(12, 8), constrained_layout=True)
    samples = [x, exact]
    headers = ["x", "f(x)"]

    print("Empirical errors on [-1, 1], sampled every 0.01")
    print(f"{'n':>3}  {'Nodes':<14} {'Max absolute error':>20} {'Location':>10} {'RMSE':>14}")
    for column, n in enumerate((10, 20)):
        # Degree n requires n+1 interpolation nodes.
        uniform = np.linspace(-1.0, 1.0, n + 1)
        # Chebyshev nodes: the roots of T_{n+1}, in increasing order.
        chebyshev = np.sort(np.cos((2 * np.arange(n + 1) + 1) * np.pi / (2 * (n + 1))))
        # Both even-degree node sets contain zero mathematically.
        uniform[n // 2] = 0.0
        chebyshev[n // 2] = 0.0
        axes[0, column].plot(plot_x, f(plot_x), "k--", label=r"$e^{|x|}$", linewidth=2)

        for name, nodes, color in (
            ("Evenly spaced", uniform, "tab:orange"),
            ("Chebyshev", chebyshev, "tab:blue"),
        ):
            values = f(nodes)
            prediction = interpolate(nodes, values, x)
            error = np.abs(exact - prediction)
            maximum = np.argmax(error)
            rmse = np.sqrt(np.mean(error**2))
            print(f"{n:3d}  {name:<14} {error[maximum]:20.10e} {x[maximum]:10.2f} {rmse:14.6e}")
            axes[0, column].plot(plot_x, interpolate(nodes, values, plot_x), color=color, label=name)
            axes[0, column].scatter(nodes, values, color=color, s=16, zorder=3)
            axes[1, column].plot(x, error, color=color, label=name)
            samples.extend((prediction, error))
            prefix = name.lower().replace(" ", "_") + f"_n{n}"
            headers.extend((prefix, prefix + "_absolute_error"))

        axes[0, column].set_title(f"Degree {n} interpolation ({n + 1} nodes)")
        axes[0, column].set_ylabel("Function / polynomial value")
        axes[1, column].set_title(f"Degree {n}: sampled absolute error")
        axes[1, column].set_ylabel(r"$|f(x)-p_n(x)|$")
        for row in range(2):
            axes[row, column].set_xlim(-1, 1)
            axes[row, column].set_xlabel("x")
            axes[row, column].grid(alpha=0.3)
            axes[row, column].legend()

    fig.savefig("interpolation_comparison.png", dpi=180)
    np.savetxt("interpolation_errors.csv", np.column_stack(samples),
               delimiter=",", header=",".join(headers), comments="")
    print("\nSaved interpolation_comparison.png and interpolation_errors.csv")
    plt.show()


if __name__ == "__main__":
    main()
