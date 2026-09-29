package weather.cli;

import weather.model.WeatherData;
import weather.service.WeatherService;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

/** Interactive command line interface. It knows the service, never the HTTP provider. */
public final class WeatherCLI {
    private static final String HELP = """
            Commands:
              help                         Show this help
              locations                    List supported locations
              current <location>            Show current conditions
              compare <location1> <location2>  Compare two locations
              summary <location>            Summarize current conditions
              warmest                      Find the warmest configured location
              quit                         Exit the application
            Put quotes around a multi-word location, for example: compare Chicago \"New York\".
            """;

    private final WeatherService service;

    public WeatherCLI(WeatherService service) {
        this.service = Objects.requireNonNull(service, "service");
    }

    public void run() {
        run(new java.io.InputStreamReader(System.in), new PrintWriter(System.out, true));
    }

    /** Input/output overload keeps command behavior easy to test without changing global streams. */
    public void run(Reader input, PrintWriter output) {
        var reader = new BufferedReader(input);
        output.println("Weather Information Service. Type 'help' for commands.");
        while (true) {
            output.print("weather> ");
            output.flush();
            final String line;
            try {
                line = reader.readLine();
            } catch (IOException e) {
                output.println("Input error: " + e.getMessage());
                return;
            }
            if (line == null) {
                output.println();
                return;
            }
            if (execute(line, output)) return;
        }
    }

    /** Executes one line; returns true when the caller should exit. */
    public boolean execute(String line, PrintWriter output) {
        final List<String> args;
        try {
            args = tokenize(line);
        } catch (IllegalArgumentException e) {
            output.println("Invalid command: " + e.getMessage());
            return false;
        }
        if (args.isEmpty()) return false;
        var command = args.getFirst().toLowerCase(Locale.ROOT);
        try {
            switch (command) {
                case "help" -> {
                    requireCount(args, 1, "help");
                    output.print(HELP);
                }
                case "locations" -> {
                    requireCount(args, 1, "locations");
                    service.getKnownLocations().forEach(location -> output.println(location.name()));
                }
                case "current" -> {
                    requireAtLeast(args, 2, "current <location>");
                    output.println(format(service.getCurrent(joinLocation(args))));
                }
                case "compare" -> {
                    requireCount(args, 3, "compare <location1> <location2>");
                    var comparison = service.compareCurrent(args.get(1), args.get(2));
                    output.println("Current weather comparison:");
                    output.println(format(comparison.first()));
                    output.println(format(comparison.second()));
                }
                case "summary" -> {
                    requireAtLeast(args, 2, "summary <location>");
                    output.println(service.summarize(joinLocation(args)));
                }
                case "warmest" -> {
                    requireCount(args, 1, "warmest");
                    var warmest = service.getWarmestLocation();
                    output.println("Warmest location: " + warmest.location().name() + " at "
                            + "%.1f°F".formatted(warmest.temperatureFahrenheit()));
                }
                case "quit", "exit" -> {
                    requireCount(args, 1, "quit");
                    output.println("Goodbye.");
                    return true;
                }
                default -> output.println("Unknown command: " + args.getFirst() + ". Type 'help' for commands.");
            }
        } catch (RuntimeException e) {
            output.println("Error: " + e.getMessage());
        }
        return false;
    }

    private static String format(WeatherData weather) {
        return "%s: %.1f°F (feels like %.1f°F), %s, humidity %d%%, wind %.1f mph, precipitation %.2f in."
                .formatted(weather.location().name(), weather.temperatureFahrenheit(),
                        weather.apparentTemperatureFahrenheit(), weather.conditions(),
                        weather.relativeHumidityPercent(), weather.windSpeedMph(), weather.precipitationInches());
    }

    private static void requireCount(List<String> args, int expected, String syntax) {
        if (args.size() != expected) throw new IllegalArgumentException("Usage: " + syntax);
    }

    private static void requireAtLeast(List<String> args, int minimum, String syntax) {
        if (args.size() < minimum) throw new IllegalArgumentException("Usage: " + syntax);
    }

    private static String joinLocation(List<String> args) {
        return String.join(" ", args.subList(1, args.size()));
    }

    private static List<String> tokenize(String line) {
        var tokens = new ArrayList<String>();
        var token = new StringBuilder();
        boolean quoted = false;
        boolean started = false;
        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            if (c == '"') {
                quoted = !quoted;
                started = true;
            } else if (Character.isWhitespace(c) && !quoted) {
                if (started) {
                    tokens.add(token.toString());
                    token.setLength(0);
                    started = false;
                }
            } else {
                token.append(c);
                started = true;
            }
        }
        if (quoted) throw new IllegalArgumentException("Unclosed quote");
        if (started) tokens.add(token.toString());
        return tokens;
    }
}
