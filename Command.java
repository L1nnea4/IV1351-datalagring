package se.kth.iv1351.coursejdbc.view;

public enum Command {
    COMPUTE,
    INCREASE,
    ALLOCATE,
    DEALLOCATE,
    ADD,
    EXIT,
    UNKNOWN;

    public static Command fromString(String s) {
        if (s == null) return UNKNOWN;

        switch (s.trim().toLowerCase()) {
            case "1":
            case "compute":
                return COMPUTE;

            case "2":
            case "increase":
                return INCREASE;

            case "3":
            case "allocate":
                return ALLOCATE;

            case "4":
            case "deallocate":
                return DEALLOCATE;

            case "5":
            case "add":
                return ADD;

            case "exit":
            case "quit":
                return EXIT;

            default:
                return UNKNOWN;
        }
    }
}
