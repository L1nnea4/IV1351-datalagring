package se.kth.iv1351.coursejdbc.model;

public class Allocation {
    private final int workerId;
    private final int instanceId;
    private final int activityId;
    private final int allocatedHours;

    public Allocation(int workerId, int instanceId, int activityId, int allocatedHours) {
        this.workerId = workerId;
        this.instanceId = instanceId;
        this.activityId = activityId;
        this.allocatedHours = allocatedHours;
    }

    public int getWorkerId() {
        return workerId;
    }

    public int getInstanceId() {
        return instanceId;
    }

    public int getActivityId() {
        return activityId;
    }

    public int getAllocatedHours() {
        return allocatedHours;
    }
}
