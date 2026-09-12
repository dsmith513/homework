package edu.uic.cs342;

/**
 * A small class used to demonstrate methods and unit testing.
 */
public class Calculator {

    public int add(int first, int second) {
        return first + second;
    }

    public int subtract(int first, int second) {
        return first - second;
    }

    public int multiply(int first, int second) {
        return first * second;
    }

    public double divide(double dividend, double divisor) {
        if (divisor == 0.0) {
            throw new IllegalArgumentException("Divisor cannot be zero");
        }
        return dividend / divisor;
    }

    public boolean isEven(int number) {
        return number % 2 == 0;
    }
}
