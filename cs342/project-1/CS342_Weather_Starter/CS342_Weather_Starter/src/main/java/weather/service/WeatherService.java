package weather.service;

import weather.model.Location;
import weather.model.WeatherComparison;
import weather.model.WeatherData;
import weather.provider.WeatherDataProvider;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/** Weather use cases independent of the concrete data source and console. */
public final class WeatherService {
    private static final List<Location> LOCATIONS = List.of(
            new Location("Chicago", 41.8781, -87.6298),
            new Location("Los Angeles", 34.0522, -118.2437),
            new Location("New York", 40.7128, -74.0060));
    private static final Map<String, Location> LOCATIONS_BY_NAME = LOCATIONS.stream()
            .collect(Collectors.toUnmodifiableMap(location -> key(location.name()), Function.identity()));

    private final WeatherDataProvider provider;

    public WeatherService(WeatherDataProvider provider) {
        this.provider = java.util.Objects.requireNonNull(provider, "provider");
    }

    public List<Location> getKnownLocations() {
        return LOCATIONS;
    }

    public WeatherData getCurrent(String locationName) {
        return provider.getCurrentWeather(findLocation(locationName));
    }

    public WeatherComparison compareCurrent(String firstName, String secondName) {
        var first = findLocation(firstName);
        var second = findLocation(secondName);
        return new WeatherComparison(provider.getCurrentWeather(first), provider.getCurrentWeather(second));
    }

    public String summarize(String locationName) {
        var weather = getCurrent(locationName);
        return "%s is %s at %.1f°F (feels like %.1f°F), with %d%% humidity, %.1f mph wind, and %.2f in. precipitation."
                .formatted(weather.location().name(), weather.conditions(), weather.temperatureFahrenheit(),
                        weather.apparentTemperatureFahrenheit(), weather.relativeHumidityPercent(),
                        weather.windSpeedMph(), weather.precipitationInches());
    }

    /** Additional feature: return the warmest currently observed configured location. */
    public WeatherData getWarmestLocation() {
        return LOCATIONS.stream().map(location -> provider.getCurrentWeather(location))
                .max(java.util.Comparator.comparingDouble(WeatherData::temperatureFahrenheit))
                .orElseThrow(() -> new IllegalStateException("No configured locations"));
    }

    private static Location findLocation(String locationName) {
        if (locationName == null || locationName.isBlank()) {
            throw new IllegalArgumentException("Location name cannot be blank");
        }
        var location = LOCATIONS_BY_NAME.get(key(locationName));
        if (location == null) throw new IllegalArgumentException("Unknown location: " + locationName);
        return location;
    }

    private static String key(String value) {
        return value.trim().toLowerCase(Locale.ROOT);
    }
}
