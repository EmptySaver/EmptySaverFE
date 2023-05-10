class ScheduleList {
  String? startDate;
  String? endDate;
  List<dynamic>? bitListsPerDay;
  List<dynamic>? scheduleListPerDays;
  String? timeStringData;

  ScheduleList({
    this.startDate,
    this.endDate,
    this.bitListsPerDay,
    this.scheduleListPerDays,
    this.timeStringData,
  });

  factory ScheduleList.fromJson(Map<String, dynamic> parsedJson) {
    return ScheduleList(
      startDate: parsedJson['startDate'],
      endDate: parsedJson['endData'],
      bitListsPerDay: parsedJson['bitListsPerDay'],
      scheduleListPerDays: parsedJson['scheduleListPerDays'],
      timeStringData: parsedJson['timeStringData'],
    );
  }
}

class Category {
  List<dynamic>? data;

  Category({this.data});

  factory Category.fromJson(Map<String, dynamic> parsedJson) {
    // var data = parsedJson['result'];
    return Category(
      data: parsedJson['result'],
    );
  }
}

class Unwrap {
  List<dynamic>? data;

  Unwrap({this.data});

  factory Unwrap.fromJson(Map<String, dynamic> parsedJson) {
    return Unwrap(
      data: parsedJson['data'],
    );
  }
}

class Group {
  int? groupId;
  String? groupName;
  String? oneLineInfo;
  int? nowMember;
  int? maxMember;
  bool? isPublic;
  bool? isAnonymous;
  String? categoryLabel;

  Group(
      {this.groupId,
      this.groupName,
      this.oneLineInfo,
      this.nowMember,
      this.maxMember,
      this.isPublic,
      this.isAnonymous,
      this.categoryLabel});

  Group.fromJson(Map<String, dynamic> parsedJson)
      : groupId = parsedJson['groupId'],
        groupName = parsedJson['groupName'],
        oneLineInfo = parsedJson['oneLineInfo'],
        nowMember = parsedJson['nowMember'],
        maxMember = parsedJson['maxMember'],
        isPublic = parsedJson['isPublic'],
        isAnonymous = parsedJson['isAnonymous'],
        categoryLabel = parsedJson['categoryLabel'];
}
