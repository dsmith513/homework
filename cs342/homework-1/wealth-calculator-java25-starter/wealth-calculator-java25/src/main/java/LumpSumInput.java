/**
 * Represents the inputs for a fixed-rate future-value calculation.
 */
public record LumpSumInput(
        double amount,
        double rate,
        int years) {
}
