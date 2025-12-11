package se.kth.iv1351.coursejdbc.integration;

import se.kth.iv1351.coursejdbc.model.*;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CourseDAOJdbc implements CourseDAO {

    private final String url = "jdbc:postgresql://localhost:5432/iv1351";
    private final String user = "postgres";
    private final String pass = "postgres";

    @Override
    public Connection getConnection() throws DAOException {
        try {
            return DriverManager.getConnection(url, user, pass);
        } catch (SQLException e) {
            throw new DAOException("Could not connect to DB", e);
        }
    }


    @Override
    public CourseInstance readInstance(Connection conn, int id) throws DAOException {
        String sql =
                "SELECT instance_id, num_students, study_period, study_year " +
                "FROM course_instance WHERE instance_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (!rs.next())
                throw new DAOException("Course instance not found");

            return new CourseInstance(
                    rs.getInt("instance_id"),
                    rs.getInt("study_year"),
                    rs.getString("study_period"),
                    rs.getInt("num_students")
            );

        } catch (SQLException e) {
            throw new DAOException("readInstance failed", e);
        }
    }


    @Override
    public CourseInstance readInstanceForUpdate(Connection conn, int id) throws DAOException {
        String sql =
                "SELECT instance_id, num_students, study_period, study_year " +
                "FROM course_instance WHERE instance_id = ? FOR UPDATE";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (!rs.next())
                throw new DAOException("Course instance not found");

            return new CourseInstance(
                    rs.getInt("instance_id"),
                    rs.getInt("study_year"),
                    rs.getString("study_period"),
                    rs.getInt("num_students")
            );

        } catch (SQLException e) {
            throw new DAOException("readInstanceForUpdate failed", e);
        }
    }

    @Override
    public void updateInstanceStudents(Connection conn, int id, int newCount) throws DAOException {
        String sql = "UPDATE course_instance SET num_students = ? WHERE instance_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newCount);
            ps.setInt(2, id);
            ps.executeUpdate();

        } catch (SQLException e) {
            throw new DAOException("updateInstanceStudents failed", e);
        }
    }


    @Override
    public int readPlannedHours(Connection conn, int instanceId) throws DAOException {
        String sql =
                "SELECT SUM(planned_hours) AS total_hours " +
                "FROM planned_activity WHERE instance_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, instanceId);
            ResultSet rs = ps.executeQuery();

            if (rs.next())
                return rs.getInt("total_hours");

            return 0;

        } catch (SQLException e) {
            throw new DAOException("readPlannedHours failed", e);
        }
    }


    @Override
    public List<Allocation> readAllocationsForInstance(Connection conn, int instanceId) throws DAOException {
        String sql =
                "SELECT activity_id, worker_id, instance_id, allocated_hours " +
                "FROM allocation WHERE instance_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, instanceId);
            ResultSet rs = ps.executeQuery();

            List<Allocation> list = new ArrayList<>();

            while (rs.next()) {
                list.add(new Allocation(
                        rs.getInt("worker_id"),
                        rs.getInt("instance_id"),
                        rs.getInt("activity_id"),
                        rs.getInt("allocated_hours")
                ));
            }
            return list;

        } catch (SQLException e) {
            throw new DAOException("readAllocationsForInstance failed", e);
        }
    }


    @Override
    public List<Allocation> readAllocationsForTeacherPeriod(
            Connection conn,
            int workerId,
            String period,
            int year
    ) throws DAOException {

        String sql =
                "SELECT a.worker_id, a.activity_id, a.instance_id, a.allocated_hours " +
                "FROM allocation a " +
                "JOIN course_instance ci ON a.instance_id = ci.instance_id " +
                "WHERE a.worker_id = ? AND ci.study_period = ? AND ci.study_year = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, workerId);
            ps.setString(2, period);
            ps.setInt(3, year);

            ResultSet rs = ps.executeQuery();

            List<Allocation> list = new ArrayList<>();

            while (rs.next()) {
                list.add(new Allocation(
                        rs.getInt("worker_id"),
                        rs.getInt("instance_id"),
                        rs.getInt("activity_id"),
                        rs.getInt("allocated_hours")
                ));
            }

            return list;

        } catch (SQLException e) {
            throw new DAOException("readAllocationsForTeacherPeriod failed", e);
        }
    }


    @Override
    public Teacher readTeacher(Connection conn, int workerId) throws DAOException {

        String sql =
                "SELECT e.worker_id, p.first_name, p.last_name " +
                "FROM employee e " +
                "JOIN person p ON e.person_id = p.person_id " +
                "WHERE e.worker_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, workerId);
            ResultSet rs = ps.executeQuery();

            if (!rs.next())
                throw new DAOException("Teacher not found");

            String fullName =
                    rs.getString("first_name").trim() + " " +
                    rs.getString("last_name").trim();

            double salary = readLatestSalary(conn, workerId);

            return new Teacher(workerId, fullName, salary);

        } catch (SQLException e) {
            throw new DAOException("readTeacher failed", e);
        }
    }

    private double readLatestSalary(Connection conn, int workerId) throws DAOException {
        String sql =
                "SELECT salary FROM salary " +
                "WHERE worker_id = ? ORDER BY start_date DESC LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, workerId);
            ResultSet rs = ps.executeQuery();

            if (rs.next())
                return rs.getDouble("salary");

            return 0;

        } catch (SQLException e) {
            throw new DAOException("readLatestSalary failed", e);
        }
    }

    @Override
    public double readAverageSalary(Connection conn) throws DAOException {
        String sql = "SELECT AVG(salary) AS avg_salary FROM salary";

        try (Statement stmt = conn.createStatement()) {
            ResultSet rs = stmt.executeQuery(sql);

            if (rs.next())
                return rs.getDouble("avg_salary");

            return 0;

        } catch (SQLException e) {
            throw new DAOException("readAverageSalary failed", e);
        }
    }


    @Override
    public void createTeachingActivity(Connection conn, TeachingActivity activity) throws DAOException {
        String sql =
                "INSERT INTO teaching_activity(activity_name, factor) " +
                "VALUES (?, ?) RETURNING activity_id";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, activity.getName());
            ps.setDouble(2, activity.getFactor());

            ResultSet rs = ps.executeQuery();
            if (rs.next())
                activity.setId(rs.getInt(1));

        } catch (SQLException e) {
            throw new DAOException("createTeachingActivity failed", e);
        }
    }

    @Override
    public void createAllocation(Connection conn, Allocation alloc) throws DAOException {
        String sql =
                "INSERT INTO allocation(activity_id, worker_id, instance_id, allocated_hours) " +
                "VALUES (?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, alloc.getActivityId());
            ps.setInt(2, alloc.getWorkerId());
            ps.setInt(3, alloc.getInstanceId());
            ps.setInt(4, alloc.getAllocatedHours());
            ps.executeUpdate();

        } catch (SQLException e) {
            throw new DAOException("createAllocation failed", e);
        }
    }

    @Override
    public void deleteAllocation(Connection conn, int workerId, int instanceId, int activityId)
            throws DAOException {

        String sql =
                "DELETE FROM allocation WHERE worker_id = ? AND instance_id = ? AND activity_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, workerId);
            ps.setInt(2, instanceId);
            ps.setInt(3, activityId);

            int rows = ps.executeUpdate();
            if (rows == 0)
                throw new DAOException("Allocation not found");

        } catch (SQLException e) {
            throw new DAOException("deleteAllocation failed", e);
        }
    }
}
