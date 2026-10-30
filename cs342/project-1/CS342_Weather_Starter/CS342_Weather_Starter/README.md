# CS 342 Weather Information Service

## Team Members

Dylan Smith

## Running the Application

```bash
mvn compile
java -cp target/classes weather.Main
```

## Running the Tests

```bash
mvn test
```

## Design

- `weather.model` contains records for locations, weather observations, and weather comparisons.

- `weather.provider` defines the weather-data interface and implements it with `OpenMeteoWeatherProvider`.

- `weather.service.WeatherService` defines supported locations, current-weather retrieval, comparisons, summaries, and finding the warmest location.

- `weather.cli.WeatherCLI` reads and validates interactive commands, calls the service, and formats results.

- `weather.Main` is the composition root.

## Interfaces

`WeatherDataProvider` represents any source of current weather. `WeatherService` depends on this interface rather than on `OpenMeteoWeatherProvider`, so another provider can be introduced without changing the CLI or the service's application logic.

## Dependency Injection

`WeatherService` receives a `WeatherDataProvider` through its constructor. `Main` supplies `OpenMeteoWeatherProvider` in the running application. Tests can supply a controlled provider that returns chosen observations or a chosen failure. This keeps application logic independent of the network provider and makes it testable in isolation.

## Testing

`WeatherServiceTest` contains 9 JUnit Jupiter tests for retrieving current conditions, configured and unknown locations, case-insensitive lookup, comparisons, summaries, the warmest-location feature, blank input, and provider failure.

`WeatherCLITest` contains 8 tests for help, locations, current conditions, quoted comparisons, summaries, the warmest command, invalid input, unknown locations, and quitting.

## Java 25

The project uses records for immutable model objects, switch statements for command dispatch and weather-code descriptions, and a text block for the CLI help screen. `var` is used for local variables where the assigned type is clear.

The use of records make location and weather results immutable data objects, meaning constructors and getters/setters are unnecessary. Switch statements improve readability. 'var' helps to reduce repeated type names.

## Additional Feature

The `warmest` command retrieves current conditions for Chicago, Los Angeles, and New York, then reports which configured location has the highest temperature. It uses `WeatherService` and the injected provider interface like the other weather commands.

## Design Reflection

1. What responsibilities were combined in the original starter code that you separated during refactoring?

The starter combined location configuration, HTTP communication, response parsing, error handling, application control, and output rendering in `Main`. Those responsibilities are now split across the model, provider, service, CLI, and 'Main'.

2. How does programming to WeatherDataProvider make the program easier to change?

Programming to `WeatherDataProvider` means the application uses a stable interface for weather data. If we wanted to modify the program in the future, a different source could be implemented instead of Open-Mateo without changing the service or CLI logic.

3. How does dependency injection make WeatherService easier to test?

Dependency injection lets each service test supply a provider stub with controlled responses. The service can be tested without constructing an HTTP client or contacting the remote API.

4. Why should unit tests avoid depending on the live weather API?

Tests should not depend on the live API because internet access and API service availability can vary. Real weather is also unpredictable. Controlled data makes the tests repeatable and usable offline.

5. If the current weather API were replaced with a completely different provider, which parts of your application would need to change? Which parts should not need to change?

Replacing Open-Meteo would require a new provider implementation and a change to the provider assembly in `Main`. The service, CLI, and their tests should not need changes assuming the replacement returns the same model data.
