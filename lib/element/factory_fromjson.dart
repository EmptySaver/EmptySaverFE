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

class ScheduleText {
  int? id;
  String? name;
  String? body;
  bool? periodicType;
  String? timeData;

  ScheduleText(
      {this.id, this.name, this.body, this.periodicType, this.timeData});

  factory ScheduleText.fromJson(Map<String, dynamic> parsedJson) {
    return ScheduleText(
      id: parsedJson['id'],
      name: parsedJson['name'],
      body: parsedJson['body'],
      periodicType: parsedJson['periodicType'],
      timeData: parsedJson['timeData'],
    );
  }
}

class GroupScheduleList {
  int? groupId;
  ScheduleList? timeTableInfo;

  GroupScheduleList({this.groupId, this.timeTableInfo});

  factory GroupScheduleList.fromJson(Map<String, dynamic> parsedJson) {
    return GroupScheduleList(
      groupId: parsedJson['groupId'],
      timeTableInfo: parsedJson['timeTableInfo'],
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
  String? groupDescription;
  int? nowMember;
  int? maxMember;
  bool? isPublic;
  bool? isAnonymous;
  String? categoryLabel;
  List<dynamic>? commentList;

  Group(
      {this.groupId,
      this.groupName,
      this.oneLineInfo,
      this.groupDescription,
      this.nowMember,
      this.maxMember,
      this.isPublic,
      this.isAnonymous,
      this.categoryLabel,
      this.commentList});

  // Group.fromJson(Map<String, dynamic> parsedJson)
  //     : groupId = parsedJson['groupId'],
  //       groupName = parsedJson['groupName'],
  //       oneLineInfo = parsedJson['oneLineInfo'],
  //       nowMember = parsedJson['nowMember'],
  //       maxMember = parsedJson['maxMember'],
  //       isPublic = parsedJson['isPublic'],
  //       isAnonymous = parsedJson['isAnonymous'],
  //       categoryLabel = parsedJson['categoryLabel'];

  factory Group.fromJson(Map<String, dynamic> parsedJson) {
    return Group(
      groupId: parsedJson['groupId'],
      groupName: parsedJson['groupName'],
      oneLineInfo: parsedJson['oneLineInfo'],
      groupDescription: parsedJson['groupDescription'],
      nowMember: parsedJson['nowMember'],
      maxMember: parsedJson['maxMember'],
      isPublic: parsedJson['isPublic'],
      isAnonymous: parsedJson['isAnonymous'],
      categoryLabel: parsedJson['categoryLabel'],
      commentList: parsedJson['commentList'],
    );
  }
}

class Info {
  String? courseName;
  String? applyDate;
  String? runDate;
  String? targetDepartment;
  String? targetGrade;
  String? url;

  Info(
      {this.courseName,
      this.applyDate,
      this.runDate,
      this.targetDepartment,
      this.targetGrade,
      this.url});

  factory Info.fromJson(Map<String, dynamic> parsedJson) {
    return Info(
      courseName: parsedJson['courseName'],
      applyDate: parsedJson['applyDate'],
      runDate: parsedJson['runDate'],
      targetDepartment: parsedJson['targetDepartment'],
      targetGrade: parsedJson['targetGrade'],
      url: parsedJson['url'],
    );
  }
}

class Friend {
  String? friendName;
  int? friendId;
  int? friendMemberId;

  Friend.fromJson(Map<String, dynamic> parsedJson)
      : friendName = parsedJson['friendName'],
        friendId = parsedJson['friendId'],
        friendMemberId = parsedJson['friendMemberId'];
}

class Ticket {
  int? memberTeamId;
  int? memberId;
  int? groupId;
  String? groupName;
  String? memberName;
  String? inviteDate;

  Ticket(
      {this.memberTeamId,
      this.memberId,
      this.groupId,
      this.groupName,
      this.memberName,
      this.inviteDate});

  factory Ticket.fromJson(Map<String, dynamic> parsedJson) {
    return Ticket(
      memberTeamId: parsedJson['memberTeamId'],
      memberId: parsedJson['memberId'],
      groupId: parsedJson['groupId'],
      groupName: parsedJson['groupName'],
      memberName: parsedJson['memberName'],
      inviteDate: parsedJson['inviteDate'],
    );
  }
}

class MemberInfo {
  String? email;
  String? name;
  String? nickname;
  String? classOf;

  MemberInfo({this.email, this.name, this.nickname, this.classOf});

  factory MemberInfo.fromJson(Map<String, dynamic> parsedJson) {
    return MemberInfo(
      email: parsedJson['email'],
      name: parsedJson['name'],
      nickname: parsedJson['nickname'],
      classOf: parsedJson['classOf'],
    );
  }
}
