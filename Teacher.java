package se.kth.iv1351.coursejdbc.model;

public class Teacher {
    private final int workerId;
    private final String name;
    private final double salary; 

    public Teacher(int workerId, String name, double salary) {
        this.workerId = workerId;
        this.name = name;
        this.salary = salary;
    }

    public int getWorkerId() {
        return workerId;
    }

    public String getName() {
        return name;
    }

    public double getSalary() {
        return salary;
    }
}
