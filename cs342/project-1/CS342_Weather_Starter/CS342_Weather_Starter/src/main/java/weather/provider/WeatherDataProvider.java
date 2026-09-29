package weather.provider;

import weather.model.Location;
import weather.model.WeatherData;

/** Abstraction over a source of current weather data. */
@FunctionalInterface
public interface WeatherDataProvider {
    WeatherData getCurrentWeather(Location location);
}
