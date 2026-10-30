package weather;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import weather.model.Location;
import weather.model.WeatherData;
import weather.provider.WeatherDataProvider;
import weather.provider.WeatherProviderException;
import weather.service.WeatherService;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class WeatherServiceTest {
    private StubWeatherProvider provider;
    private WeatherService service;

    @BeforeEach
    void setUp() {
        provider = new StubWeatherProvider();
        service = new WeatherService(provider);
    }

    @Test
    void returnsCurrentWeatherFromInjectedProvider() {
        var chicago = service.getKnownLocations().getFirst();
        var expected = sample(chicago, 72);
        provider.add(expected);

        assertEquals(expected, service.getCurrent("Chicago"));
        assertEquals(List.of(chicago), provider.requests);
    }

    @Test
    void knowsAllThreeRequiredLocations() {
        assertEquals(List.of("Chicago", "Los Angeles", "New York"),
                service.getKnownLocations().stream().map(Location::name).toList());
    }

    @Test
    void locationLookupIgnoresCaseAndSurroundingWhitespace() {
        var chicago = service.getKnownLocations().getFirst();
        var expected = sample(chicago, 70);
        provider.add(expected);

        assertEquals(expected, service.getCurrent("  cHiCaGo "));
    }

    @Test
    void unknownLocationIsRejectedBeforeProviderIsCalled() {
        var error = assertThrows(IllegalArgumentException.class, () -> service.getCurrent("Boston"));

        assertTrue(error.getMessage().contains("Unknown location"));
        assertTrue(provider.requests.isEmpty());
    }

    @Test
    void comparisonContainsCurrentConditionsForBothLocations() {
        var chicago = service.getKnownLocations().get(0);
        var losAngeles = service.getKnownLocations().get(1);
        provider.add(sample(chicago, 68));
        provider.add(sample(losAngeles, 82));

        var result = service.compareCurrent("Chicago", "Los Angeles");

        assertEquals(68.0, result.first().temperatureFahrenheit(), 0.001);
        assertEquals(82.0, result.second().temperatureFahrenheit(), 0.001);
        assertEquals(List.of(chicago, losAngeles), provider.requests);
    }

    @Test
    void summaryIncludesLocationConditionsAndMeasurements() {
        var chicago = service.getKnownLocations().getFirst();
        provider.add(sample(chicago, 72));

        var result = service.summarize("Chicago");

        assertTrue(result.contains("Chicago is partly cloudy"));
        assertTrue(result.contains("72.0°F"));
        assertTrue(result.contains("45% humidity"));
        assertTrue(result.contains("8.5 mph wind"));
    }

    @Test
    void warmestFeatureReturnsTheHighestCurrentTemperature() {
        for (var location : service.getKnownLocations()) {
            var temperature = switch (location.name()) {
                case "Chicago" -> 58;
                case "Los Angeles" -> 86;
                default -> 64;
            };
            provider.add(sample(location, temperature));
        }

        var result = service.getWarmestLocation();

        assertEquals("Los Angeles", result.location().name());
        assertEquals(86.0, result.temperatureFahrenheit(), 0.001);
        assertEquals(3, provider.requests.size());
    }

    @Test
    void providerFailureIsNotHiddenByTheService() {
        provider.failure = new WeatherProviderException("service unavailable");

        var error = assertThrows(WeatherProviderException.class, () -> service.getCurrent("Chicago"));

        assertEquals("service unavailable", error.getMessage());
    }

    @Test
    void blankLocationIsRejectedBeforeProviderIsCalled() {
        assertThrows(IllegalArgumentException.class, () -> service.getCurrent("  "));
        assertTrue(provider.requests.isEmpty());
    }

    private static WeatherData sample(Location location, double temperature) {
        return new WeatherData(location, "2026-09-29T10:00", temperature, temperature - 2,
                45, 8.5, 0.02, 2);
    }

    private static final class StubWeatherProvider implements WeatherDataProvider {
        private final Map<String, WeatherData> weatherByLocation = new HashMap<>();
        private final List<Location> requests = new ArrayList<>();
        private RuntimeException failure;

        void add(WeatherData weather) {
            weatherByLocation.put(weather.location().name(), weather);
        }

        @Override
        public WeatherData getCurrentWeather(Location location) {
            requests.add(location);
            if (failure != null) throw failure;
            var weather = weatherByLocation.get(location.name());
            if (weather == null) throw new IllegalStateException("No stub weather for " + location.name());
            return weather;
        }
    }
}
