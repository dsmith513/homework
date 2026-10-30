package weather.provider;

import weather.model.Location;
import weather.model.WeatherData;

@FunctionalInterface
public interface WeatherDataProvider {
    WeatherData getCurrentWeather(Location location);
}
