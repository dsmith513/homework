/**
 * Represents the inputs for a fixed-rate present-value calculation.
 */
public record PresentValueInput(
        double futureValue,
        double rate,
        int years) {
}
