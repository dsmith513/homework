/**
 * STUDENT IMPLEMENTATION.
 *
 * Performs calculations using values supplied by the provided
 * RateFileReader and SavingsFileReader dependencies.
 *
 * The dependencies must be received through the constructor.
 * Do not create file readers inside this class.
 * Do not print from this class.
 */
public class VariableWealthCalculator {
    private final RateFileReader rateReader;
    private final SavingsFileReader savingsReader;

    public VariableWealthCalculator(
            RateFileReader rateReader,
            SavingsFileReader savingsReader) {
        this.rateReader = rateReader;
        this.savingsReader = savingsReader;
    }

    public CalculationResult futureValue(double startingAmount) {
        // TODO: use rateReader.readRates() and implement the calculation
        return new CalculationResult("Variable Future Value", 0.0);
    }

    public CalculationResult compoundSavings(double startingAmount) {
        // TODO: use both provided readers and implement the calculation
        // Savings contributions occur at the end of each year.
        return new CalculationResult("Variable Compound Savings", 0.0);
    }
}
