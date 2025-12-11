package se.kth.iv1351.coursejdbc.integration;

public class DAOException extends Exception {
    public DAOException(String msg) { super(msg); }
    public DAOException(String msg, Throwable cause) { super(msg, cause); }
}
