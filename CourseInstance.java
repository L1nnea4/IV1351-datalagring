package se.kth.iv1351.coursejdbc.model;

public class CourseInstance {
    private final int id;
    private final int studyYear;
    private final String studyPeriod;
    private int numStudents;

    public CourseInstance(int id, int studyYear, String studyPeriod, int numStudents) {
        this.id = id;
        this.studyYear = studyYear;
        this.studyPeriod = studyPeriod;
        this.numStudents = numStudents;
    }

    public int getId() {
        return id;
    }

    public int getStudyYear() {
        return studyYear;
    }

    public String getStudyPeriod() {
        return studyPeriod;
    }

    public int getNumStudents() {
        return numStudents;
    }

    public void setNumStudents(int numStudents) {
        this.numStudents = numStudents;
    }
}
