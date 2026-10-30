package weather;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import weather.cli.WeatherCLI;
import weather.model.Location;
import weather.model.WeatherData;
import weather.provider.WeatherDataProvider;
import weather.service.WeatherService;

import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class WeatherCLITest {
    private StubWeatherProvider provider;
    private WeatherService service;
    private WeatherCLI cli;

    @BeforeEach
    void setUp() {
        provider = new StubWeatherProvider();
        service = new WeatherService(provider);
        cli = new WeatherCLI(service);
    }

    @Test
    void helpDisplaysAvailableCommandSyntax() {
        var output = run("help\nquit\n");

        assertTrue(output.contains("current <location>"));
        assertTrue(output.contains("compare <location1> <location2>"));
        assertTrue(output.contains("warmest"));
    }

    @Test
    void locationsDisplaysConfiguredPlaces() {
        var output = run("locations\nquit\n");

        assertTrue(output.contains("Chicago"));
        assertTrue(output.contains("Los Angeles"));
        assertTrue(output.contains("New York"));
        assertTrue(provider.requests.isEmpty());
    }

    @Test
    void currentCommandPrintsCurrentMeasurements() {
        addWeather("Chicago", 72);

        var output = run("current Chicago\nquit\n");

        assertTrue(output.contains("Chicago: 72.0°F"));
        assertTrue(output.contains("humidity 45%"));
        assertTrue(output.contains("wind 8.5 mph"));
        assertEquals(1, provider.requests.size());
    }

    @Test
    void compareAcceptsQuotedMultiwordLocation() {
        addWeather("Chicago", 68);
        addWeather("New York", 75);

        var output = run("compare Chicago \"New York\"\nquit\n");

        assertTrue(output.contains("Current weather comparison"));
        assertTrue(output.contains("Chicago: 68.0°F"));
        assertTrue(output.contains("New York: 75.0°F"));
    }

    @Test
    void summaryAndWarmestCommandsDisplayServiceResults() {
        addWeather("Chicago", 81);
        addWeather("Los Angeles", 84);
        addWeather("New York", 65);

        var output = run("summary Chicago\nwarmest\nquit\n");

        assertTrue(output.contains("Chicago is clear sky"));
        assertTrue(output.contains("Warmest location: Los Angeles at 84.0°F"));
    }

    @Test
    void invalidCommandAndMissingArgumentsGetUsefulFeedback() {
        var output = run("forecast\ncurrent\nquit\n");

        assertTrue(output.contains("Unknown command: forecast"));
        assertTrue(output.contains("Usage: current <location>"));
        assertTrue(provider.requests.isEmpty());
    }

    @Test
    void quitStopsProcessingFurtherCommands() {
        var output = run("quit\nlocations\n");

        assertTrue(output.contains("Goodbye."));
        assertFalse(output.contains("Chicago"));
        assertTrue(provider.requests.isEmpty());
    }

    @Test
    void unknownLocationAndUnclosedQuotesAreReported() {
        var output = run("current Boston\ncompare Chicago \"New York\nquit\n");

        assertTrue(output.contains("Error: Unknown location: Boston"));
        assertTrue(output.contains("Invalid command: Unclosed quote"));
        assertTrue(provider.requests.isEmpty());
    }

    private void addWeather(String locationName, double temperature) {
        var location = service.getKnownLocations().stream()
                .filter(candidate -> candidate.name().equals(locationName))
                .findFirst().orElseThrow();
        provider.weatherByLocation.put(locationName, sample(location, temperature));
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

    private static final class StubWeatherProvider implements WeatherDataProvider {
        private final Map<String, WeatherData> weatherByLocation = new HashMap<>();
        private final List<Location> requests = new ArrayList<>();

        @Override
        public WeatherData getCurrentWeather(Location location) {
            requests.add(location);
            var weather = weatherByLocation.get(location.name());
            if (weather == null) throw new IllegalStateException("No stub weather for " + location.name());
            return weather;
        }
    }
}
