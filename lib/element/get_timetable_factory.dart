class ScheduleList {
  String? startDate;
  String? endDate;
  List<dynamic>? bitListsPerDay;
  List<dynamic>? scheduleListPerDays;

  ScheduleList({
    this.startDate,
    this.endDate,
    this.bitListsPerDay,
    this.scheduleListPerDays,
  });

  factory ScheduleList.fromJson(Map<String, dynamic> parsedJson) {
    return ScheduleList(
      startDate: parsedJson['startDate'],
      endDate: parsedJson['endData'],
      bitListsPerDay: parsedJson['bitListsPerDay'],
      scheduleListPerDays: parsedJson['scheduleListPerDays'],
    );
  }
}
