class ProblemFields {
    static const String roadMap = 'Road Map';
    static const String problemName = 'Problem Name';
    static const String problemCode = 'Problem Code';
    static const String problemSolution = 'Problem Solution';
    static const String status = 'Status';
    static const String submitCount = 'Submit Count';
    static const String readingTime = 'Reading Time(m)';
    static const String thinkingTime = 'Thinking Time(m)';
    static const String codingTime = 'Coding Time(m)';
    static const String debugTime = 'Debug Time(m)';
    static const String totalTime = 'Total Time(m)';
    static const String problemLevel = 'Problem Level/10';
    static const String byYourself = 'By Yourself?';
    static const String category = 'Category';
    static const String comment = 'Any Comments';
    static const String resources = 'Helpful Resources';
    static List<String> getFields() => [
        roadMap,
        problemName,
        problemCode,
        problemSolution,
        status,
        submitCount,
        readingTime,
        thinkingTime,
        codingTime,
        debugTime,
        totalTime,
        problemLevel,
        byYourself,
        category,
        comment,
        resources
    ];
}