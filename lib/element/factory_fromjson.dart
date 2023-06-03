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
  bool? read;

  ScheduleText({this.id, this.name, this.body, this.periodicType, this.timeData, this.read});

  factory ScheduleText.fromJson(Map<String, dynamic> parsedJson) {
    return ScheduleText(
      id: parsedJson['id'],
      name: parsedJson['name'],
      body: parsedJson['body'],
      periodicType: parsedJson['periodicType'],
      timeData: parsedJson['timeData'],
      read: parsedJson['read'],
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

// class Unwrap {
//   List<dynamic>? data;

//   Unwrap({this.data});

//   factory Unwrap.fromJson(Map<String, dynamic> parsedJson) {
//     return Unwrap(
//       data: parsedJson['data'],
//     );
//   }
// }

class ScheduleInfo {
  int? id;
  String? name;
  String? body;
  bool? periodicType;
  String? category;
  String? subCategory;
  Group? groupInfo;
  String? timeData;

  ScheduleInfo({this.id, this.name, this.body, this.periodicType, this.category, this.subCategory, this.groupInfo, this.timeData});

  ScheduleInfo.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    body = json["body"];
    periodicType = json["periodicType"];
    category = json["category"];
    subCategory = json["subCategory"];
    groupInfo = json["groupInfo"] == null ? null : Group.fromJson(json["groupInfo"]);
    timeData = json["timeData"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["name"] = name;
    data["body"] = body;
    data["periodicType"] = periodicType;
    data["category"] = category;
    data["subCategory"] = subCategory;
    if (groupInfo != null) {
      data["groupInfo"] = groupInfo?.toJson();
    }
    data["timeData"] = timeData;
    return data;
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
  bool? amIOwner;
  List<dynamic>? commentList;
  String? categoryName;

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
      this.amIOwner,
      this.commentList,
      this.categoryName});

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
        amIOwner: parsedJson['amIOwner'],
        commentList: parsedJson['commentList'] == null ? null : (parsedJson["commentList"] as List).map((e) => CommentList.fromJson(e)).toList(),
        categoryName: parsedJson['categoryName']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["groupId"] = groupId;
    data["groupName"] = groupName;
    data["oneLineInfo"] = oneLineInfo;
    data["groupDescription"] = groupDescription;
    data["nowMember"] = nowMember;
    data["maxMember"] = maxMember;
    data["isPublic"] = isPublic;
    data["isAnonymous"] = isAnonymous;
    data["categoryLabel"] = categoryLabel;
    if (commentList != null) {
      data["commentList"] = commentList?.map((e) => e.toJson()).toList();
    }
    data["amIOwner"] = amIOwner;
    return data;
  }
}

class CommentList {
  Parent? parent;
  List<ChildList>? childList;

  CommentList({this.parent, this.childList});

  CommentList.fromJson(Map<String, dynamic> json) {
    parent = json["parent"] == null ? null : Parent.fromJson(json["parent"]);
    childList = json["childList"] == null ? null : (json["childList"] as List).map((e) => ChildList.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (parent != null) {
      data["parent"] = parent?.toJson();
    }
    if (childList != null) {
      data["childList"] = childList?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class ChildList {
  int? commentId;
  String? text;
  String? dateTime;
  bool? isOwner;
  String? writerName;

  ChildList({this.commentId, this.text, this.dateTime, this.isOwner, this.writerName});

  ChildList.fromJson(Map<String, dynamic> json) {
    commentId = json["commentId"];
    text = json["text"];
    dateTime = json["dateTime"];
    isOwner = json["isOwner"];
    writerName = json["writerName"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["commentId"] = commentId;
    data["text"] = text;
    data["dateTime"] = dateTime;
    data["isOwner"] = isOwner;
    data["writerName"] = writerName;
    return data;
  }
}

class Parent {
  int? commentId;
  String? text;
  String? dateTime;
  bool? isOwner;
  String? writerName;

  Parent({this.commentId, this.text, this.dateTime, this.isOwner, this.writerName});

  Parent.fromJson(Map<String, dynamic> json) {
    commentId = json["commentId"];
    text = json["text"];
    dateTime = json["dateTime"];
    isOwner = json["isOwner"];
    writerName = json["writerName"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["commentId"] = commentId;
    data["text"] = text;
    data["dateTime"] = dateTime;
    data["isOwner"] = isOwner;
    data["writerName"] = writerName;
    return data;
  }
}

class Info {
  String? courseName;
  String? applyDate;
  String? runDate;
  String? targetDepartment;
  String? targetGrade;
  String? url;

  Info({this.courseName, this.applyDate, this.runDate, this.targetDepartment, this.targetGrade, this.url});

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
  String? friendEmail;
  int? friendId;
  int? friendMemberId;

  Friend.fromJson(Map<String, dynamic> parsedJson)
      : friendName = parsedJson['friendName'],
        friendEmail = parsedJson['friendEmail'],
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

  Ticket({this.memberTeamId, this.memberId, this.groupId, this.groupName, this.memberName, this.inviteDate});

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

class Lecture {
  int? id;
  String? dept;
  String? subject_div;
  String? subject_div2;
  String? class_div;
  String? subjectname;
  String? shyr;
  int? credit;
  String? prof_nm;
  String? class_type;
  String? class_nm;

  Lecture({this.id, this.dept, this.subject_div, this.subject_div2, this.class_div, this.subjectname, this.shyr, this.credit, this.prof_nm, this.class_type, this.class_nm});

  factory Lecture.fromJson(Map<String, dynamic> parsedJson) {
    return Lecture(
      id: parsedJson['id'],
      dept: parsedJson['dept'],
      subject_div: parsedJson['subject_div'],
      subject_div2: parsedJson['subject_div2'],
      class_div: parsedJson['class_div'],
      subjectname: parsedJson['subjectname'],
      shyr: parsedJson['shyr'],
      credit: parsedJson['credit'],
      prof_nm: parsedJson['prof_nm'],
      class_type: parsedJson['class_type'],
      class_nm: parsedJson['class_nm'],
    );
  }
}

class Dept {
  String? upperName;
  List<dynamic>? deptNameList;
  Dept({this.upperName, this.deptNameList});
  factory Dept.fromJson(Map<String, dynamic> parsedJson) {
    return Dept(upperName: parsedJson['upperDivName'], deptNameList: parsedJson['deptNameList']);
  }
}

class Noti {
  int? id;
  String? title;
  String? body;
  String? routeValue;
  String? idType;
  String? idType2;
  int? idValue;
  int? idValue2;
  String? receiveTime;
  bool? isRead;

  Noti({this.id, this.title, this.body, this.routeValue, this.idType, this.idValue, this.receiveTime, this.isRead});

  Noti.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    title = json["title"];
    body = json["body"];
    routeValue = json["routeValue"];
    idType = json["idType"];
    idType2 = json["idType2"];
    idValue = int.parse(json["idValue"]);
    idValue2 = int.parse(json["idValue2"]);
    receiveTime = json["receiveTime"];
    isRead = json["isRead"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["title"] = title;
    data["body"] = body;
    data["routeValue"] = routeValue;
    data["idType"] = idType;
    data["idValue"] = idValue;
    data["receiveTime"] = receiveTime;
    data["isRead"] = isRead;
    return data;
  }
}

class FullCategoryInfo {
  String? type;
  String? typeName;
  List<dynamic>? tagList;
  FullCategoryInfo({this.type, this.typeName, this.tagList});
  factory FullCategoryInfo.fromJson(Map<String, dynamic> parsedJson) {
    return FullCategoryInfo(type: parsedJson['type'], typeName: parsedJson['typeName'], tagList: parsedJson['result']);
  }
  Map<String, dynamic> toJson() => {'type': type, 'typeName': typeName, 'tagList': tagList};
}
