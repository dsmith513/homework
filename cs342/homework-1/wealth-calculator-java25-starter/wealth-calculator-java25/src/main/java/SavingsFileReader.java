import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

/**
 * PROVIDED CLASS - DO NOT MODIFY.
 *
 * Reads annual savings contributions from a text file containing
 * one contribution per line.
 */
public class SavingsFileReader {
    private final Path path;

    public SavingsFileReader(String filename) {
        this.path = Path.of(filename);
    }

    public List<Double> readSavings() {
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
