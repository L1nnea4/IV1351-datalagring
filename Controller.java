package se.kth.iv1351.coursejdbc.controller;

import se.kth.iv1351.coursejdbc.integration.*;
import se.kth.iv1351.coursejdbc.model.*;

import java.sql.Connection;
import java.util.*;

public class Controller {

    private final CourseDAO dao;

    public Controller(CourseDAO dao) {
        this.dao = dao;
    }

    public TeachingCost computeCost(int instanceId) throws Exception {
        try (Connection conn = dao.getConnection()) {
            conn.setAutoCommit(false);

            CourseInstance ci = dao.readInstance(conn, instanceId);

            int plannedHours = dao.readPlannedHours(conn, instanceId);

            List<Allocation> allocations = dao.readAllocationsForInstance(conn, instanceId);

            double actual = 0;

            for (Allocation a : allocations) {
                Teacher t = dao.readTeacher(conn, a.getWorkerId());
                double hourly = t.getSalary() / 1600.0;
                actual += hourly * a.getAllocatedHours();
            }

            double avgSalary = dao.readAverageSalary(conn);
            double planned = plannedHours * (avgSalary / 1600.0);

            conn.commit();

            return new TeachingCost(
                instanceId,
                ci.getStudyPeriod(),
                ci.getStudyYear(),
                planned / 1000.0,
                actual / 1000.0
            );
        }
    }


    public TeachingCost increaseStudents(int instanceId, int delta) throws Exception {
        try (Connection conn = dao.getConnection()) {
            conn.setAutoCommit(false);

            CourseInstance ci = dao.readInstanceForUpdate(conn, instanceId);
            int updated = ci.getNumStudents() + delta;

            dao.updateInstanceStudents(conn, instanceId, updated);

            TeachingCost cost = computeCostInside(conn, instanceId);

            conn.commit();

            return cost;
        }
    }

    private TeachingCost computeCostInside(Connection conn, int instanceId) throws Exception {
        CourseInstance ci = dao.readInstance(conn, instanceId);

        int plannedHours = dao.readPlannedHours(conn, instanceId);
        List<Allocation> allocations = dao.readAllocationsForInstance(conn, instanceId);

        double actual = 0;

        for (Allocation a : allocations)     {
            Teacher t = dao.readTeacher(conn, a.getWorkerId());
            actual += (t.getSalary() / 1600.0) * a.getAllocatedHours();
        }

        double avgSalary = dao.readAverageSalary(conn);
        double planned = plannedHours * (avgSalary / 1600.0);

        return new TeachingCost(
            instanceId,
            ci.getStudyPeriod(),
            ci.getStudyYear(),
            planned / 1000.0,
            actual / 1000.0
        );
    }


    public void allocate(int workerId, int instanceId, int activityId, int hours) throws Exception {
        try (Connection conn = dao.getConnection()) {
            conn.setAutoCommit(false);

            CourseInstance ci = dao.readInstance(conn, instanceId);

            List<Allocation> current = dao.readAllocationsForTeacherPeriod(
                conn, workerId, ci.getStudyPeriod(), ci.getStudyYear()
            );

            long distinctInstances = current.stream()
                                            .map(Allocation::getInstanceId)
                                            .distinct()
                                            .count();

            boolean alreadyTeachingThisInstance =
                current.stream().anyMatch(a -> a.getInstanceId() == instanceId);

            if (!alreadyTeachingThisInstance && distinctInstances >= 4)
                throw new Exception("Teacher exceeds allocation limit");

            dao.createAllocation(conn, new Allocation(workerId, instanceId, activityId, hours));

            conn.commit();
        }
    }

    public void deallocate(int workerId, int instanceId, int activityId) throws Exception {
        try (Connection conn = dao.getConnection()) {
            conn.setAutoCommit(false);

            dao.deleteAllocation(conn, workerId, instanceId, activityId);

            conn.commit();
        }
    }


    public void addActivityAndAllocate(String name, double factor, int instanceId,
                                       int workerId, int hours) throws Exception {

        try (Connection conn = dao.getConnection()) {
            conn.setAutoCommit(false);

            TeachingActivity activity = new TeachingActivity(0, name, factor);
            dao.createTeachingActivity(conn, activity);

            allocateInside(conn, workerId, instanceId, activity.getId(), hours);

            conn.commit();
        }
    }

    private void allocateInside(Connection conn,
                                int workerId,
                                int instanceId,
                                int activityId,
                                int hours) throws Exception {

        CourseInstance ci = dao.readInstance(conn, instanceId);

        List<Allocation> current = dao.readAllocationsForTeacherPeriod(
            conn, workerId, ci.getStudyPeriod(), ci.getStudyYear()
        );

        long distinctInstances = current.stream()
                                        .map(Allocation::getInstanceId)
                                        .distinct()
                                        .count();

        boolean alreadyTeaching = current.stream()
                                         .anyMatch(a -> a.getInstanceId() == instanceId);

        if (!alreadyTeaching && distinctInstances >= 4)
            throw new Exception("Teacher exceeds allocation limit");

        dao.createAllocation(conn, new Allocation(workerId, instanceId, activityId, hours));
    }
}
