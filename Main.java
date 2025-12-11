package se.kth.iv1351.coursejdbc.startup;

import se.kth.iv1351.coursejdbc.integration.CourseDAO;
import se.kth.iv1351.coursejdbc.integration.CourseDAOJdbc;
import se.kth.iv1351.coursejdbc.controller.Controller;
import se.kth.iv1351.coursejdbc.view.CmdLine;

public class Main {

    public static void main(String[] args) {

        try {
            CourseDAO dao = new CourseDAOJdbc();
            Controller controller = new Controller(dao);
            CmdLine cli = new CmdLine(controller);

            cli.start();

        } catch (Exception e) {
            System.out.println("Fatal error starting the application");
            System.out.println(e.getMessage());
        }
    }
}
