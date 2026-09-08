import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;

class VariableWealthCalculatorTest {
    private static final double TOLERANCE = 0.01;

    @TempDir
    Path tempDir;

    @Test
    void calculatesFutureValueUsingVariableRates() throws IOException {
        Path rates = tempDir.resolve("rates.txt");
        Path savings = tempDir.resolve("savings.txt");

        Files.writeString(rates, """
                0.05
                0.04
                0.06
                0.035
                0.055
                """);

        Files.writeString(savings, """
                5000.00
                5500.00
                6000.00
                6500.00
                7000.00
                """);

        var calculator = new VariableWealthCalculator(
                new RateFileReader(rates.toString()),
                new SavingsFileReader(savings.toString()));

        var result = calculator.futureValue(10_000.00);

        assertEquals(12_639.25, result.value(), TOLERANCE);
    }

    @Test
    void calculatesCompoundSavingsUsingVariableRatesAndSavings() throws IOException {
        Path rates = tempDir.resolve("rates.txt");
        Path savings = tempDir.resolve("savings.txt");

        Files.writeString(rates, """
                0.05
                0.04
                0.06
                0.035
                0.055
                """);

        Files.writeString(savings, """
                5000.00
                5500.00
                6000.00
                6500.00
                7000.00
                """);

        var calculator = new VariableWealthCalculator(
                new RateFileReader(rates.toString()),
                new SavingsFileReader(savings.toString()));

        var result = calculator.compoundSavings(0.0);

        // Each year:
        // balance = balance * (1 + rate)
        // balance = balance + contribution
        assertEquals(32_793.66, result.value(), TOLERANCE);
    }
}
