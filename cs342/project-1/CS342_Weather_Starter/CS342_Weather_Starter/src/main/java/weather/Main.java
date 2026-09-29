package weather;

import weather.cli.WeatherCLI;
import weather.provider.OpenMeteoWeatherProvider;
import weather.service.WeatherService;

/** Application composition root. */
public final class Main {
    private Main() { }

    public static void main(String[] args) {
        var provider = new OpenMeteoWeatherProvider();
        var service = new WeatherService(provider);
        var cli = new WeatherCLI(service);
        cli.run();
    }
}
