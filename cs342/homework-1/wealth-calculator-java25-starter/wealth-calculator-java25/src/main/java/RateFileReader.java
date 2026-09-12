import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

/**
 * PROVIDED CLASS - DO NOT MODIFY.
 *
 * Reads annual interest rates from a text file containing one rate per line.
 */
public class RateFileReader {
    private final Path path;

    public RateFileReader(String filename) {
        this.path = Path.of(filename);
    }

    public List<Double> readRates() {
        try {
            return Files.readAllLines(path)
                    .stream()
                    .map(Double::parseDouble)
                    .toList();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }
}
