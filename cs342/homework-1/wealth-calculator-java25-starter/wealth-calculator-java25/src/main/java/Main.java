/*
 * STUDENT IMPLEMENTATION / COMPOSITION ROOT.
 *
 * Java 25 compact source file:
 * no explicit class declaration and no "public static void main(String[] args)".
 *
 * Create the major objects here, inject dependencies, perform the five
 * calculations, and pass each CalculationResult to ConsoleReporter.
 */
void main() {
    var rateReader = new RateFileReader("rates.txt");
    var savingsReader = new SavingsFileReader("savings.txt");

    var fixedCalculator = new FixedWealthCalculator();

    var variableCalculator =
            new VariableWealthCalculator(rateReader, savingsReader);

    var reporter = new ConsoleReporter();

    // TODO: create input records, call all five calculations,
    // and report their results.
}
