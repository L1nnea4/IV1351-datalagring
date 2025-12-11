package se.kth.iv1351.coursejdbc.integration;

import se.kth.iv1351.coursejdbc.model.*;
import java.sql.Connection;
import java.util.List;

public interface CourseDAO {
    Connection getConnection() throws DAOException;

    CourseInstance readInstance(Connection conn, int id) throws DAOException;
    CourseInstance readInstanceForUpdate(Connection conn, int id) throws DAOException;
    void updateInstanceStudents(Connection conn, int id, int newCount) throws DAOException;

    int readPlannedHours(Connection conn, int instanceId) throws DAOException;

    List<Allocation> readAllocationsForInstance(Connection conn, int instanceId) throws DAOException;
    List<Allocation> readAllocationsForTeacherPeriod(Connection conn, int workerId, String period, int year) throws DAOException;

    Teacher readTeacher(Connection conn, int workerId) throws DAOException;

    double readAverageSalary(Connection conn) throws DAOException;

    void createTeachingActivity(Connection conn, TeachingActivity activity) throws DAOException;
    void createAllocation(Connection conn, Allocation allocation) throws DAOException;
    void deleteAllocation(Connection conn, int workerId, int instanceId, int activityId) throws DAOException;
}
