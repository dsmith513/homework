import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ProvidedFileReaderTest {

    @TempDir
    Path tempDir;

    @Test
    void rateFileReaderReadsRates() throws IOException {
        Path file = tempDir.resolve("rates.txt");
        Files.writeString(file, """
                0.05
                0.04
                0.06
                """);

        var reader = new RateFileReader(file.toString());

        assertEquals(List.of(0.05, 0.04, 0.06), reader.readRates());
    }

    @Test
    void savingsFileReaderReadsSavings() throws IOException {
        Path file = tempDir.resolve("savings.txt");
        Files.writeString(file, """
                5000.00
                5500.00
                6000.00
                """);

        var reader = new SavingsFileReader(file.toString());

        assertEquals(List.of(5000.00, 5500.00, 6000.00), reader.readSavings());
    }
}
