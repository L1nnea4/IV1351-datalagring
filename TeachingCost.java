package se.kth.iv1351.coursejdbc.model;

public class TeachingCost {
    private final int instanceId;
    private final String period;
    private final int year;
    private final double plannedKSEK;
    private final double actualKSEK;

    public TeachingCost(int instanceId, String period, int year, double plannedKSEK, double actualKSEK) {
        this.instanceId = instanceId;
        this.period = period;
        this.year = year;
        this.plannedKSEK = plannedKSEK;
        this.actualKSEK = actualKSEK;
    }

    @Override
    public String toString() {
        return String.format(
            "Instance %d | Period %s | Year %d | Planned %.2f KSEK | Actual %.2f KSEK",
            instanceId, period, year, plannedKSEK, actualKSEK
        );
    }
}
