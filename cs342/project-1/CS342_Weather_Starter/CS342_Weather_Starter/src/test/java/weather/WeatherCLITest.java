package weather;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import weather.cli.WeatherCLI;
import weather.model.Location;
import weather.model.WeatherComparison;
import weather.model.WeatherData;
import weather.service.WeatherService;

import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class WeatherCLITest {
    @Mock WeatherService service;
    private WeatherCLI cli;

    @BeforeEach
    void setUp() { cli = new WeatherCLI(service); }

    @Test
    void helpDisplaysAvailableCommandSyntax() {
        var output = run("help\nquit\n");
        assertTrue(output.contains("current <location>"));
        assertTrue(output.contains("compare <location1> <location2>"));
        assertTrue(output.contains("warmest"));
    }

    @Test
    void locationsDisplaysConfiguredPlaces() {
        when(service.getKnownLocations()).thenReturn(java.util.List.of(
                new Location("Chicago", 41.8, -87.6), new Location("Los Angeles", 34.0, -118.2),
                new Location("New York", 40.7, -74.0)));
        var output = run("locations\nquit\n");
        assertTrue(output.contains("Chicago"));
        assertTrue(output.contains("Los Angeles"));
        assertTrue(output.contains("New York"));
    }

    @Test
    void currentCommandPrintsCurrentMeasurements() {
        var chicago = new Location("Chicago", 41.8, -87.6);
        when(service.getCurrent("Chicago")).thenReturn(sample(chicago, 72));
        var output = run("current Chicago\nquit\n");
        assertTrue(output.contains("Chicago: 72.0°F"));
        assertTrue(output.contains("humidity 45%"));
        assertTrue(output.contains("wind 8.5 mph"));
    }

    @Test
    void compareAcceptsQuotedMultiwordLocation() {
        var chicago = new Location("Chicago", 41.8, -87.6);
        var newYork = new Location("New York", 40.7, -74.0);
        when(service.compareCurrent("Chicago", "New York"))
                .thenReturn(new WeatherComparison(sample(chicago, 68), sample(newYork, 75)));
        var output = run("compare Chicago \"New York\"\nquit\n");
        assertTrue(output.contains("Current weather comparison"));
        assertTrue(output.contains("Chicago: 68.0°F"));
        assertTrue(output.contains("New York: 75.0°F"));
    }

    @Test
    void summaryAndWarmestCommandsDisplayServiceResults() {
        var chicago = new Location("Chicago", 41.8, -87.6);
        when(service.summarize("Chicago")).thenReturn("Chicago is sunny today.");
        when(service.getWarmestLocation()).thenReturn(sample(chicago, 81));
        var output = run("summary Chicago\nwarmest\nquit\n");
        assertTrue(output.contains("Chicago is sunny today."));
        assertTrue(output.contains("Warmest location: Chicago at 81.0°F"));
    }

    @Test
    void invalidCommandAndMissingArgumentsGetUsefulFeedback() {
        var output = run("forecast\ncurrent\nquit\n");
        assertTrue(output.contains("Unknown command: forecast"));
        assertTrue(output.contains("Usage: current <location>"));
    }

    @Test
    void quitStopsProcessingFurtherCommands() {
        var output = run("quit\nlocations\n");
        assertTrue(output.contains("Goodbye."));
        assertFalse(output.contains("Chicago"));
        verifyNoInteractions(service);
    }

    @Test
    void unknownLocationAndUnclosedQuotesAreReported() {
        when(service.getCurrent("Boston")).thenThrow(new IllegalArgumentException("Unknown location: Boston"));
        var output = run("current Boston\ncompare Chicago \"New York\nquit\n");
        assertTrue(output.contains("Error: Unknown location: Boston"));
        assertTrue(output.contains("Invalid command: Unclosed quote"));
    }

    private String run(String commands) {
        var writer = new StringWriter();
        cli.run(new StringReader(commands), new PrintWriter(writer, true));
        return writer.toString();
    }

    private static WeatherData sample(Location location, double temperature) {
        return new WeatherData(location, "2026-09-29T10:00", temperature, temperature - 2,
                45, 8.5, 0.02, 0);
    }
}
