# Java 25 Maven and JUnit Example

A small classroom project demonstrating a Maven directory structure, a Java
class with basic methods, and JUnit unit tests.

## Requirements

- JDK 25
- Apache Maven 3.9 or newer

Confirm the tools from a terminal:

```shell
java -version
mvn -version
```

Both commands should report that Maven is using Java 25.

## Run the tests

```shell
mvn test
```

## Run the example application

First compile the project:

```shell
mvn compile
```

Then run `edu.uic.cs342.Main` from IntelliJ IDEA. The program prints the Java
runtime version and two calculator results.

## Open in IntelliJ IDEA

1. Choose **File > Open**.
2. Select this project's folder, which contains `pom.xml`.
3. If prompted, choose **Trust Project**.
4. Set the Project SDK to JDK 25.
5. Open the Maven tool window and select **Reload All Maven Projects**.
6. Run `CalculatorTest` or the Maven `test` lifecycle goal.
