import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class FixedWealthCalculatorTest {
    private static final double TOLERANCE = 0.01;

    @Test
    void calculatesFutureValueOfLumpSum() {
        var calculator = new FixedWealthCalculator();
        var input = new LumpSumInput(10_000.00, 0.05, 10);

        var result = calculator.futureValue(input);

        assertEquals(16_288.95, result.value(), TOLERANCE);
    }

    @Test
    void calculatesCompoundSavingsWithFixedContribution() {
        var calculator = new FixedWealthCalculator();
        var input = new SavingsInput(0.0, 5_000.00, 0.06, 20);

        var result = calculator.compoundSavings(input);

        // End-of-year contributions (ordinary annuity).
        assertEquals(183_927.96, result.value(), TOLERANCE);
    }

    @Test
    void calculatesPresentValue() {
        var calculator = new FixedWealthCalculator();
        var input = new PresentValueInput(100_000.00, 0.06, 20);

        var result = calculator.presentValue(input);

        assertEquals(31_180.47, result.value(), TOLERANCE);
    }
}
