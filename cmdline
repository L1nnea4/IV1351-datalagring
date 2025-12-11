package se.kth.iv1351.coursejdbc.view;

import se.kth.iv1351.coursejdbc.controller.Controller;
import se.kth.iv1351.coursejdbc.model.TeachingCost;

public class CmdLine {

    private final Controller controller;
    private final BlockingInterpreter in = new BlockingInterpreter();

    public CmdLine(Controller controller) {
        this.controller = controller;
    }

    public void start() {
        System.out.println("- Course Management CLI ");

        while (true) {
            printMenu();
            String raw = in.readLine("> ");
            Command cmd = Command.fromString(raw);

            try {
                switch (cmd) {
                    case COMPUTE:
                        computeCost();
                        break;

                    case INCREASE:
                        increaseStudents();
                        break;

                    case ALLOCATE:
                        allocateTeacher();
                        break;

                    case DEALLOCATE:
                        deallocate();
                        break;

                    case ADD:
                        addActivityAndAllocate();
                        break;

                    case EXIT:
                        System.out.println("Exiting");
                        return;

                    default:
                        System.out.println("Unknown command");
                }
            } catch (Exception e) {
                System.out.println("Error: " + e.getMessage());
            }
        }
    }

    private void printMenu() {
        System.out.println("\nCommands:");
        System.out.println("1 / compute, Compute teaching cost");
        System.out.println("2 / increase, Increase students and recompute");
        System.out.println("3 / allocate, Allocate teacher to an activity");
        System.out.println("4 / deallocate, Remove allocation");
        System.out.println("5 / add, Add activity + allocate teacher");
        System.out.println("exit, Quit");
    }


    private void computeCost() throws Exception {
        int instanceId = readInt("Course instance id: ");
        TeachingCost cost = controller.computeCost(instanceId);
        System.out.println(cost);
    }

    private void increaseStudents() throws Exception {
        int instanceId = readInt("Course instance id: ");
        int delta = readInt("Increase by how many students: ");
        TeachingCost cost = controller.increaseStudents(instanceId, delta);
        System.out.println("Updated teaching cost:");
        System.out.println(cost);
    }

    private void allocateTeacher() throws Exception {
        int workerId = readInt("Worker id (teacher): ");
        int instanceId = readInt("Course instance id: ");
        int activityId = readInt("Activity id: ");
        int hours = readInt("Allocated hours: ");

        controller.allocate(workerId, instanceId, activityId, hours);
        System.out.println("Teacher allocated successfully");
    }

    private void deallocate() throws Exception {
        System.out.println("Allocation is identified by (workerId, instanceId, activityId)");

        int workerId = readInt("Worker id: ");
        int instanceId = readInt("Course instance id: ");
        int activityId = readInt("Activity id: ");

        controller.deallocate(workerId, instanceId, activityId);
        System.out.println("Allocation removed");
    }

    private void addActivityAndAllocate() throws Exception {
        int instanceId = readInt("Course instance id: ");
        String name = in.readLine("Activity name: ");
        double factor = readDouble("Activity factor (example 1.5): ");

        int workerId = readInt("Worker id to allocate: ");
        int hours = readInt("Allocated hours for teacher: ");

        controller.addActivityAndAllocate(name, factor, instanceId, workerId, hours);

        System.out.println("Activity created and teacher allocated");
    }


    private int readInt(String prompt) {
        return Integer.parseInt(in.readLine(prompt));
    }

    private double readDouble(String prompt) {
        return Double.parseDouble(in.readLine(prompt));
    }
}
