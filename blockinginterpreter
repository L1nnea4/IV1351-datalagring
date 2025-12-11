package se.kth.iv1351.coursejdbc.view;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class BlockingInterpreter {
    private final BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

    public String readLine(String prompt) {
        System.out.print(prompt);
        try {
            return reader.readLine();
        } catch (IOException e) {
            return null;
        }
    }
}
