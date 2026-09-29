import math


def evaluate_a(x):
    return x**5 + x - 1, 5 * x**4 + 1


def evaluate_b(x):
    return math.sin(x) - 6 * x - 5, math.cos(x) - 6


def evaluate_c(x):
    if x <= 0:
        raise ValueError('Part (c) requires x > 0.')
    return math.log(x) + x**2 - 3, 1 / x + 2 * x


def newton(evaluate, x0, tol=1e-12, maxiter=100):
    x = float(x0)

    for iteration in range(1, maxiter + 1):
        f, derivative = evaluate(x)
        if derivative == 0:
            raise ArithmeticError('Newton method encountered a zero derivative.')
        next_x = x - f / derivative
        if not math.isfinite(next_x):
            raise ArithmeticError('Nonfinite iterate.')
        if abs(next_x - x) < tol:
            return next_x, iteration
        x = next_x

    raise RuntimeError('Iteration limit reached.')


def main():
    print("Newton's method: roots to eight decimal places.\n")

    for label, equation, evaluate, x0 in (
        ('a', 'x^5 + x = 1', evaluate_a, 1.0),
        ('b', 'sin(x) = 6x + 5', evaluate_b, -1.0),
        ('c', 'ln(x) + x^2 = 3', evaluate_c, 1.5),
    ):
        root, iterations = newton(evaluate, x0)
        print(f'({label}) {equation}')
        print(f'    x = {root:.8f} (x0 = {x0}, iterations = {iterations})')


if __name__ == '__main__':
    main()
