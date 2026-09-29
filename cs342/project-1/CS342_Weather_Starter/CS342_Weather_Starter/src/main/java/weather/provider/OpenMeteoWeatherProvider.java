package weather.provider;

import weather.model.Location;
import weather.model.WeatherData;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** Production provider backed by the Open-Meteo Forecast API. */
public final class OpenMeteoWeatherProvider implements WeatherDataProvider {
    private static final String ENDPOINT = "https://api.open-meteo.com/v1/forecast";
    private static final Pattern NUMBER_TEMPLATE = Pattern.compile(
            "\\\"%s\\\"\\s*:\\s*(-?(?:\\d+(?:\\.\\d*)?|\\.\\d+)(?:[eE][+-]?\\d+)?)");
    private static final Pattern TIME_PATTERN = Pattern.compile("\\\"time\\\"\\s*:\\s*\\\"([^\\\"]+)\\\"");
    private final HttpClient httpClient;

    public OpenMeteoWeatherProvider() {
        this(HttpClient.newHttpClient());
    }

    /** Constructor supports supplying a configured client while keeping HTTP behind the provider. */
    public OpenMeteoWeatherProvider(HttpClient httpClient) {
        this.httpClient = java.util.Objects.requireNonNull(httpClient, "httpClient");
    }

    @Override
    public WeatherData getCurrentWeather(Location location) {
        var query = "latitude=" + location.latitude()
                + "&longitude=" + location.longitude()
                + "&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,precipitation,weather_code"
                + "&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=auto";
        var uri = URI.create(ENDPOINT + "?" + query);
        var request = HttpRequest.newBuilder(uri).timeout(Duration.ofSeconds(15)).GET().build();
        try {
            var response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                throw new WeatherProviderException("Open-Meteo returned HTTP " + response.statusCode());
            }
            var json = response.body();
            return new WeatherData(location, extractTime(json),
                    number(json, "temperature_2m"), number(json, "apparent_temperature"),
                    integer(json, "relative_humidity_2m"), number(json, "wind_speed_10m"),
                    number(json, "precipitation"), integer(json, "weather_code"));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new WeatherProviderException("Request to Open-Meteo was interrupted", e);
        } catch (IOException e) {
            throw new WeatherProviderException("Could not retrieve weather from Open-Meteo: " + e.getMessage(), e);
        } catch (IllegalArgumentException e) {
            throw new WeatherProviderException("Open-Meteo returned invalid weather data: " + e.getMessage(), e);
        }
    }

    private static double number(String json, String key) {
        var pattern = Pattern.compile(NUMBER_TEMPLATE.pattern().formatted(Pattern.quote(key)));
        Matcher matcher = pattern.matcher(json);
        if (!matcher.find()) throw new WeatherProviderException("Open-Meteo response is missing '" + key + "'");
        try {
            var value = Double.parseDouble(matcher.group(1));
            if (!Double.isFinite(value)) throw new NumberFormatException("not finite");
            return value;
        } catch (NumberFormatException e) {
            throw new WeatherProviderException("Open-Meteo returned invalid '" + key + "'", e);
        }
    }

    private static int integer(String json, String key) {
        var value = number(json, key);
        if (value != Math.rint(value) || value < Integer.MIN_VALUE || value > Integer.MAX_VALUE) {
            throw new WeatherProviderException("Open-Meteo returned invalid integer '" + key + "'");
        }
        return (int) value;
    }

    private static String extractTime(String json) {
        var matcher = TIME_PATTERN.matcher(json);
        if (!matcher.find()) throw new WeatherProviderException("Open-Meteo response is missing current observation time");
        return matcher.group(1);
    }
}
