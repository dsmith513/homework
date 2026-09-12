# CS 342 Wealth Calculator — Java 25 Maven Starter

This starter project is configured for **Java 25**, **Maven**, and **JUnit 5**.

## Requirements

Install:

- JDK 25
- Apache Maven 3.6.3 or newer

Verify:

```bash
java -version
mvn -version
```

Both commands should report that Maven is running with JDK 25.

## Run the tests

```bash
mvn test
```

Before submission:

```bash
mvn clean test
```

The starter source files compile once built with JDK 25, but the calculator methods intentionally contain placeholder results. Therefore, the instructor calculation tests are expected to fail until the TODOs are implemented.

## Provided — do not modify

- `pom.xml`
- `RateFileReader.java`
- `SavingsFileReader.java`
- `rates.txt`
- `savings.txt`
- files under `src/test/java`

## Student implementation

Complete:

- `FixedWealthCalculator.java`
- `VariableWealthCalculator.java`
- `ConsoleReporter.java`
- `Main.java`

The following records are included as the required data API:

- `LumpSumInput`
- `SavingsInput`
- `PresentValueInput`
- `CalculationResult`

## Required calculations

### FixedWealthCalculator

1. Lump-sum future value
2. Fixed annual compound savings
3. Present value

### VariableWealthCalculator

4. Future value using annual rates from `rates.txt`
5. Compound savings using annual rates from `rates.txt` and annual contributions from `savings.txt`

Savings contributions occur at the **end of each year**.

For the variable savings calculation, the yearly update is:

```java
balance *= 1 + rate;
balance += contribution;
```

You may assume all input is correct.

## Dependency injection

`VariableWealthCalculator` must receive its readers through its constructor:

```java
new VariableWealthCalculator(rateReader, savingsReader)
```

Do not construct `RateFileReader` or `SavingsFileReader` inside `VariableWealthCalculator`.

## Java 25 compact source file

`Main.java` intentionally uses Java 25 compact-source-file syntax:

```java
void main() {
    // composition root
}
```

It does not declare an explicit `Main` class and does not use the traditional
`public static void main(String[] args)` form.

## Notes for IntelliJ

Set the project SDK and Maven runner JDK to **JDK 25**. Then reload the Maven project and run the tests from the Maven tool window or with `mvn test` in the terminal.
