"""Python equivalent of Lab_1_Rcode.R.

The script follows the same exercises as the R version.  It expects
``zip.train.gz`` and ``zip.test.gz`` to be in the same directory as this file
(or in the directory supplied with ``--data-dir``).
"""

from __future__ import annotations

import argparse
import gzip
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.special import gammaln, expit


def negative_binomial_pmf(x: np.ndarray, r: int, p: float) -> np.ndarray:
    """P(X=x) when X is trials needed to obtain r successes."""
    x = np.asarray(x, dtype=float)
    log_choose = gammaln(x) - gammaln(r) - gammaln(x - r + 1)
    return np.exp(log_choose + r * np.log(p) + (x - r) * np.log1p(-p))


def load_zip_data(data_dir: Path) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Read the whitespace-separated, gzipped digit data."""
    train = pd.read_csv(data_dir / "zip.train.gz", sep=r"\s+", header=None,
                        compression="gzip", engine="python")
    test = pd.read_csv(data_dir / "zip.test.gz", sep=r"\s+", header=None,
                       compression="gzip", engine="python")
    # The R script retains the first 257 columns of the training data.
    return train.iloc[:, :257], test


def show_digit(ax: plt.Axes, row: pd.Series) -> None:
    """Display one digit using the same orientation as image() in the R code."""
    image = row.iloc[1:257].to_numpy(dtype=float).reshape((16, 16), order="F")
    ax.imshow(-np.flip(image, axis=0), cmap="gray", interpolation="nearest")
    ax.axis("off")


def log_likelihood(beta: float | np.ndarray, y: np.ndarray,
                   x: np.ndarray) -> np.ndarray:
    beta = np.atleast_1d(beta).astype(float)
    # log(1 + exp(z)) computed stably.
    values = y[:, None] * x[:, None] * beta - np.logaddexp(0, x[:, None] * beta)
    return values.sum(axis=0)


def log_likelihood_prime(beta: float | np.ndarray, y: np.ndarray,
                         x: np.ndarray) -> np.ndarray:
    beta = np.atleast_1d(beta).astype(float)
    return (x[:, None] * (y[:, None] - expit(x[:, None] * beta))).sum(axis=0)


def log_likelihood_second(beta: float | np.ndarray, y: np.ndarray,
                          x: np.ndarray) -> np.ndarray:
    beta = np.atleast_1d(beta).astype(float)
    probabilities = expit(x[:, None] * beta)
    return (-(x[:, None] ** 2) * probabilities * (1 - probabilities)).sum(axis=0)


def newton_raphson(beta0: float, y: np.ndarray, x: np.ndarray,
                   epsilon: float = 0.0001) -> dict[str, float | int]:
    counts = 0
    beta = float(beta0)
    while True:
        beta1 = beta - log_likelihood_prime(beta, y, x)[0] / log_likelihood_second(beta, y, x)[0]
        if abs(beta1 - beta) < epsilon:
            return {"betastar": beta1, "counts": counts}
        beta = beta1
        counts += 1


def steepest_ascent(beta0: float, y: np.ndarray, x: np.ndarray,
                    epsilon: float = 0.0001) -> dict[str, float | int]:
    counts = 0
    beta = float(beta0)
    while True:
        derivative = log_likelihood_prime(beta, y, x)[0]
        ratio = 1.0
        beta1 = beta + ratio * derivative
        inner_iterations = 0
        while log_likelihood(beta1, y, x)[0] < log_likelihood(beta, y, x)[0]:
            ratio /= 2
            inner_iterations += 1
            beta1 = beta + ratio * derivative
            print(inner_iterations, beta1)
        if abs(beta1 - beta) < epsilon or counts > 1000:
            return {"betastar": beta1, "iterations": counts}
        beta = beta1
        counts += 1


def gradient_ascent(beta0: float, y: np.ndarray, x: np.ndarray, alpha: float,
                    epsilon: float = 0.0001) -> dict[str, float | int]:
    counts = 0
    beta = float(beta0)
    while True:
        beta1 = beta + alpha * log_likelihood_prime(beta, y, x)[0]
        if abs(log_likelihood_prime(beta1, y, x)[0]) < epsilon or counts > 1000:
            return {"betastar": beta1, "iterations": counts}
        beta = beta1
        counts += 1


def main(data_dir: Path) -> None:
    # Q1(a), Q1(c): simulation from N(0, 4).
    rng = np.random.default_rng()
    X = rng.normal(0, 2, 100)
    meanX = X.mean()
    varX = X.var(ddof=1)  # R's var() uses the sample variance.
    prob1 = np.mean(X > 1)
    positiveX = X[X > 0]
    print(f"Q1: mean={meanX}, variance={varX}, P(X > 1)={prob1}")

    fig, ax = plt.subplots()
    ax.hist(X, density=True)
    grid = np.linspace(X.min(), X.max(), 400)
    ax.plot(grid, np.exp(-grid**2 / 8) / (2 * np.sqrt(2 * np.pi)), color="red")
    ax.set_title("Q1: N(0, 4) sample")

    # Q2(a): approximate E[X] for the negative-binomial distribution.
    rvec, pvec, N = [10, 20, 30], [0.2, 0.5], 1000
    expX = np.zeros((3, 2))
    for i, r in enumerate(rvec):
        for j, p in enumerate(pvec):
            k = np.arange(r, N + 1)
            expX[i, j] = np.sum(k * negative_binomial_pmf(k, r, p))
    print("Q2: approximate expectations")
    print(expX)

    # Q3: all negative-binomial probability mass functions.
    fig, ax = plt.subplots()
    for i, r in enumerate(rvec):
        for j, p in enumerate(pvec):
            xvec = np.arange(r, 200 + 1)
            ax.plot(xvec, negative_binomial_pmf(xvec, r, p),
                    linestyle="-" if j == 0 else "--", color=f"C{i}",
                    label=f"r={r},p={p}")
    ax.set(xlabel="x", ylabel="probability mass of NB(r,p)", ylim=(0, 0.1))
    ax.legend(loc="upper right")

    # Q4: clockwise 90-degree rotation.
    # R's matrix() fills by column, so this is matrix(c(1,1,-1,-1,-1,1,1,1,-1), 3, 3).
    A = np.array([[1, -1, 1], [1, -1, 1], [-1, 1, -1]])
    imA = np.flip(A, axis=0).T
    fig, axes = plt.subplots(1, 2)
    axes[0].imshow(-A, cmap="gray", interpolation="nearest")
    axes[1].imshow(-imA, cmap="gray", interpolation="nearest")
    for ax in axes:
        ax.axis("off")

    # Q5: digit data, frequency table, and visualizations.
    zip_train, zip_test = load_zip_data(data_dir)
    print(f"Q5: train shape={zip_train.shape}, test shape={zip_test.shape}")
    print(zip_train.iloc[:, 0].value_counts().sort_index())
    numbers = {digit: zip_train[zip_train.iloc[:, 0] == digit]
               for digit in range(10)}

    fig, axes = plt.subplots(1, 2)
    show_digit(axes[0], zip_train.iloc[3])
    show_digit(axes[1], zip_train.iloc[3])
    fig, axes = plt.subplots(5, 10, figsize=(10, 5))
    for digit, ax_column in enumerate(axes.T):
        for i, ax in enumerate(ax_column):
            show_digit(ax, numbers[digit].iloc[i])
    fig.tight_layout()

    # Q6: likelihood optimization.
    rng = np.random.default_rng(2025)
    x = rng.normal(size=100)
    beta = 2
    pi = expit(x * beta)
    y = rng.binomial(1, pi)
    betavec = np.linspace(1, 5, 1000)
    fig, axes = plt.subplots(1, 2)
    axes[0].plot(betavec, log_likelihood(betavec, y, x))
    axes[1].plot(betavec, log_likelihood_prime(betavec, y, x))
    axes[1].axhline(0, color="black")
    fig, axes = plt.subplots(1, 2)
    axes[0].plot(betavec, log_likelihood_prime(betavec, y, x))
    axes[1].plot(betavec, log_likelihood_second(betavec, y, x))

    print("Q6: Newton-Raphson from 1:", newton_raphson(1, y, x, 0.00001))
    print("Q6: Newton-Raphson from 3:", newton_raphson(3, y, x, 0.00001))
    print("Q6: steepest ascent:", steepest_ascent(2.5, y, x, 0.00001))
    print("Q6: gradient ascent alpha=0.01:", gradient_ascent(3.5, y, x, 0.01, 0.00001))
    print("Q6: gradient ascent alpha=0.05:", gradient_ascent(3.5, y, x, 0.05, 0.00001))
    plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-dir", type=Path, default=Path(__file__).parent)
    args = parser.parse_args()
    main(args.data_dir)
