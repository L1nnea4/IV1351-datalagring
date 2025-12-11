package se.kth.iv1351.coursejdbc.model;

public class TeachingActivity {
    private int id;
    private final String name;
    private final double factor;

    public TeachingActivity(int id, String name, double factor) {
        this.id = id;
        this.name = name;
        this.factor = factor;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public double getFactor() {
        return factor;
    }
}
