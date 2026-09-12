/**
 * Represents the inputs for a fixed annual-savings calculation.
 *
 * Contributions are assumed to be made at the end of each year.
 */
public record SavingsInput(
        double startingAmount,
        double contribution,
        double rate,
        int years) {
}
