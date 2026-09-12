package edu.uic.cs342;

public class Main {

    public static void main(String[] args) {
        Calculator calculator = new Calculator();

        System.out.println("Java version: " + System.getProperty("java.version"));
        System.out.println("8 + 4 = " + calculator.add(8, 4));
        System.out.println("8 / 4 = " + calculator.divide(8, 4));
    }
}





