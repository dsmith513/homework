package weather.model;

import java.util.Objects;

/** Current observations for a pair of locations. */
public record WeatherComparison(WeatherData first, WeatherData second) {
    public WeatherComparison {
        Objects.requireNonNull(first, "first");
        Objects.requireNonNull(second, "second");
    }
}
