package edu.uic.cs342;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class CalculatorTest {

    private Calculator calculator;

    @BeforeEach
    void setUp() {
        calculator = new Calculator();
    }

    @Test
    @DisplayName("add returns the sum of two integers")
    void addsTwoNumbers() {
        assertEquals(7, calculator.add(3, 4));
    }

    @Test
    @DisplayName("subtract returns the difference of two integers")
    void subtractsTwoNumbers() {
        assertEquals(6, calculator.subtract(10, 4));
    }

    @Test
    @DisplayName("multiply handles a negative number")
    void multipliesNumbers() {
        assertEquals(-15, calculator.multiply(3, -5));
    }

    @Test
    @DisplayName("divide returns a decimal result")
    void dividesNumbers() {
        assertEquals(2.5, calculator.divide(5, 2), 0.0001);
    }

    @Test
    @DisplayName("divide rejects a zero divisor")
    void rejectsDivisionByZero() {
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> calculator.divide(10, 0)
        );

        assertEquals("Divisor cannot be zero", exception.getMessage());
    }

    @Test
    @DisplayName("isEven identifies even and odd numbers")
    void identifiesEvenNumbers() {
        assertTrue(calculator.isEven(8));
        assertFalse(calculator.isEven(7));
    }
}
