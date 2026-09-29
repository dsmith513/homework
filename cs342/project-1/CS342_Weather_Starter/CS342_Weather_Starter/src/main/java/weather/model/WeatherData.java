package weather.model;

import java.util.Objects;

/** Current weather measurements using Fahrenheit, percent, mph, and inches. */
public record WeatherData(
        Location location,
        String observedAt,
        double temperatureFahrenheit,
        double apparentTemperatureFahrenheit,
        int relativeHumidityPercent,
        double windSpeedMph,
        double precipitationInches,
        int weatherCode) {

    public WeatherData {
        Objects.requireNonNull(location, "location");
        Objects.requireNonNull(observedAt, "observedAt");
        if (observedAt.isBlank()) throw new IllegalArgumentException("Observation time cannot be blank");
        requireFinite(temperatureFahrenheit, "temperature");
        requireFinite(apparentTemperatureFahrenheit, "apparent temperature");
        requireFinite(windSpeedMph, "wind speed");
        requireFinite(precipitationInches, "precipitation");
        if (relativeHumidityPercent < 0 || relativeHumidityPercent > 100) {
            throw new IllegalArgumentException("Relative humidity must be between 0 and 100 percent");
        }
        if (windSpeedMph < 0 || precipitationInches < 0) {
            throw new IllegalArgumentException("Wind speed and precipitation cannot be negative");
        }
    }

    private static void requireFinite(double value, String label) {
        if (!Double.isFinite(value)) throw new IllegalArgumentException(label + " must be a finite number");
    }

    /** Human-readable description for the WMO weather interpretation codes. */
    public String conditions() {
        return switch (weatherCode) {
            case 0 -> "clear sky";
            case 1 -> "mostly clear";
            case 2 -> "partly cloudy";
            case 3 -> "overcast";
            case 45, 48 -> "foggy";
            case 51, 53, 55 -> "drizzling";
            case 56, 57 -> "freezing drizzle";
            case 61, 63, 65 -> "rainy";
            case 66, 67 -> "freezing rain";
            case 71, 73, 75, 77 -> "snowy";
            case 80, 81, 82 -> "rain showers";
            case 85, 86 -> "snow showers";
            case 95, 96, 99 -> "thunderstorms";
            default -> "conditions unavailable";
        };
    }
}
