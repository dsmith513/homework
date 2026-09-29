package weather;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import weather.model.Location;
import weather.model.WeatherData;
import weather.provider.WeatherDataProvider;
import weather.provider.WeatherProviderException;
import weather.service.WeatherService;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class WeatherServiceTest {
    @Mock WeatherDataProvider provider;
    @InjectMocks WeatherService service;

    @Test
    void returnsCurrentWeatherFromInjectedProvider() {
        var expected = sample(service.getKnownLocations().getFirst(), 72);
        when(provider.getCurrentWeather(expected.location())).thenReturn(expected);
        assertEquals(expected, service.getCurrent("Chicago"));
        verify(provider).getCurrentWeather(expected.location());
    }

    @Test
    void knowsAllThreeRequiredLocations() {
        assertEquals(java.util.List.of("Chicago", "Los Angeles", "New York"),
                service.getKnownLocations().stream().map(Location::name).toList());
    }

    @Test
    void locationLookupIgnoresCaseAndSurroundingWhitespace() {
        var expected = sample(service.getKnownLocations().getFirst(), 70);
        when(provider.getCurrentWeather(expected.location())).thenReturn(expected);
        assertEquals(expected, service.getCurrent("  cHiCaGo "));
    }

    @Test
    void unknownLocationIsRejectedBeforeProviderIsCalled() {
        var error = assertThrows(IllegalArgumentException.class, () -> service.getCurrent("Boston"));
        assertTrue(error.getMessage().contains("Unknown location"));
        verifyNoInteractions(provider);
    }

    @Test
    void comparisonContainsCurrentConditionsForBothLocations() {
        var chicago = service.getKnownLocations().get(0);
        var la = service.getKnownLocations().get(1);
        when(provider.getCurrentWeather(chicago)).thenReturn(sample(chicago, 68));
        when(provider.getCurrentWeather(la)).thenReturn(sample(la, 82));
        var result = service.compareCurrent("Chicago", "Los Angeles");
        assertEquals(68, result.first().temperatureFahrenheit());
        assertEquals(82, result.second().temperatureFahrenheit());
    }

    @Test
    void summaryIncludesLocationConditionsAndMeasurements() {
        var chicago = service.getKnownLocations().getFirst();
        when(provider.getCurrentWeather(chicago)).thenReturn(sample(chicago, 72));
        var result = service.summarize("Chicago");
        assertTrue(result.contains("Chicago is partly cloudy"));
        assertTrue(result.contains("72.0°F"));
        assertTrue(result.contains("45% humidity"));
        assertTrue(result.contains("8.5 mph wind"));
    }

    @Test
    void warmestFeatureReturnsTheHighestCurrentTemperature() {
        when(provider.getCurrentWeather(any(Location.class))).thenAnswer(invocation -> {
            var location = invocation.getArgument(0, Location.class);
            var temp = switch (location.name()) {
                case "Chicago" -> 58;
                case "Los Angeles" -> 86;
                default -> 64;
            };
            return sample(location, temp);
        });
        var result = service.getWarmestLocation();
        assertEquals("Los Angeles", result.location().name());
        assertEquals(86, result.temperatureFahrenheit());
        verify(provider, times(3)).getCurrentWeather(any(Location.class));
    }

    @Test
    void providerFailureIsNotHiddenByTheService() {
        when(provider.getCurrentWeather(any(Location.class)))
                .thenThrow(new WeatherProviderException("service unavailable"));
        var error = assertThrows(WeatherProviderException.class, () -> service.getCurrent("Chicago"));
        assertEquals("service unavailable", error.getMessage());
    }

    @Test
    void blankLocationIsRejected() {
        assertThrows(IllegalArgumentException.class, () -> service.getCurrent("  "));
        verifyNoInteractions(provider);
    }

    private static WeatherData sample(Location location, double temperature) {
        return new WeatherData(location, "2026-09-29T10:00", temperature, temperature - 2,
                45, 8.5, 0.02, 2);
    }
}
