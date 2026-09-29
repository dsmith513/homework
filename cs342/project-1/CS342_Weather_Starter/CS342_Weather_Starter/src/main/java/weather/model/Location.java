package weather.model;

import java.util.Objects;

/** A configured weather location. */
public record Location(String name, double latitude, double longitude) {
    public Location {
        Objects.requireNonNull(name, "name");
        name = name.trim();
        if (name.isEmpty()) throw new IllegalArgumentException("Location name cannot be blank");
        if (!Double.isFinite(latitude) || latitude < -90 || latitude > 90) {
            throw new IllegalArgumentException("Latitude must be between -90 and 90");
        }
        if (!Double.isFinite(longitude) || longitude < -180 || longitude > 180) {
            throw new IllegalArgumentException("Longitude must be between -180 and 180");
        }
    }
}
