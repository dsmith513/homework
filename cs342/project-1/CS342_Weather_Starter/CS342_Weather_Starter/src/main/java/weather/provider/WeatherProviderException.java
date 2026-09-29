package weather.provider;

/** Signals a communication, response, or parsing failure from a weather provider. */
public class WeatherProviderException extends RuntimeException {
    public WeatherProviderException(String message) { super(message); }
    public WeatherProviderException(String message, Throwable cause) { super(message, cause); }
}
