import 'package:solomas/helpers/common_helper.dart';

class CarnivalListModel {
  int? statusCode;

  String? message;

  Data? data;

  CarnivalListModel({this.statusCode, this.message, this.data});

  CarnivalListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    message = json['message'];

    if (statusCode == 200) {
      data = json['data'] != null ? Data.fromJson(json['data']) : null;
    } else {
      CommonHelper.checkStatusCode(statusCode ?? 0, json['message'], json['data']);
    }
  }
}

class Data {
  List<CarnivalList>? carnivalList;

  List<MembersList>? membersList;

  List<CarnivalFeedList>? carnivalFeedList;

  Data({this.carnivalList, this.membersList, this.carnivalFeedList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['carnivalList'] != null) {
      carnivalList = <CarnivalList>[];

      json['carnivalList'].forEach((v) {
        carnivalList?.add(CarnivalList.fromJson(v));
      });
    }

    if (json['membersList'] != null) {
      membersList = <MembersList>[];

      json['membersList'].forEach((v) {
        membersList?.add(MembersList.fromJson(v));
      });
    }

    if (json['carnivalFeedList'] != null) {
      carnivalFeedList = <CarnivalFeedList>[];

      json['carnivalFeedList'].forEach((v) {
        carnivalFeedList?.add(CarnivalFeedList.fromJson(v));
      });
    }
  }
}

class CarnivalList {
  Location? location;

  List<String>? images;

  List<Bands>? bands;

  int? totalMembers, startDate, endDate, insertDate;

  String? locationName,
      title,
      description,
      coverImageUrl,
      creationDate,
      carnivalId,
      contestId,
      type;

  bool? isJoined, hasContest, contestJoined, isCheckIn, isCarnivalDateSkipped;

  CarnivalList(
      {this.location,
      this.images,
      this.totalMembers,
      this.locationName,
      this.title,
      this.description,
      this.bands,
      this.coverImageUrl,
      this.startDate,
      this.endDate,
      this.creationDate,
      this.insertDate,
      this.carnivalId,
      this.isJoined,
      this.hasContest,
      this.contestId,
      this.contestJoined,
      this.type,
      this.isCheckIn,
      this.isCarnivalDateSkipped});

  CarnivalList.fromJson(Map<String, dynamic> json) {
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;

    images = json['images'].cast<String>();

    totalMembers = json['totalMembers'];

    locationName = json['locationName'];

    title = json['title'];

    description = json['description'];

    if (json['bands'] != null) {
      bands = <Bands>[];

      json['bands'].forEach((v) {
        bands?.add(Bands.fromJson(v));
      });
    }

    coverImageUrl = json['coverImageUrl'] ?? "";

    startDate = json['startDate'];

    endDate = json['endDate'];

    creationDate = json['creationDate'];

    insertDate = json['insertDate'];

    isJoined = json['isJoined'];

    hasContest = json['hasContest'];

    contestId = json['contestId'];

    carnivalId = json['carnivalId'];

    contestJoined = json['contestJoined'];

    isCheckIn = json['isCheckIn'];

    type = json['type'];

    isCarnivalDateSkipped = json['isCarnivalDateSkipped'] ?? false;
  }
}

class Location {
  double? lat, lng;

  Location({this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];

    lng = json['lng'];
  }
}

class MembersList {
  String? memberId, userName, userProfilePic, userId, userBand;

  MembersList(
      {this.memberId,
      this.userName,
      this.userProfilePic,
      this.userId,
      this.userBand});

  MembersList.fromJson(Map<String, dynamic> json) {
    memberId = json['memberId'];

    userName = json['userName'];

    userProfilePic = json['userProfilePic'];

    userId = json['userId'];

    userBand = json['userBand'];
  }
}

class CarnivalFeedList {
  int? totalLikes, totalComments, insertDate;

  bool? isReported, isLike;

  String? userId, carnivalId, comment, carnivalFeedId, userName, userProfilePic;

  CarnivalFeedList(
      {this.totalLikes,
      this.totalComments,
      this.isReported,
      this.userId,
      this.carnivalId,
      this.comment,
      this.insertDate,
      this.carnivalFeedId,
      this.userName,
      this.userProfilePic,
      this.isLike});

  CarnivalFeedList.fromJson(Map<String, dynamic> json) {
    totalLikes = json['totalLikes'];

    totalComments = json['totalComments'];

    isReported = json['isReported'];

    userId = json['userId'];

    carnivalId = json['carnivalId'];

    comment = json['comment'];

    insertDate = json['insertDate'];

    carnivalFeedId = json['carnivalFeedId'];

    userName = json['userName'];

    userProfilePic = json['userProfilePic'];

    isLike = json['isLike'];
  }
}

class Bands {
  String? sId, name;

  Bands({this.sId, this.name});

  Bands.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    name = json['name'];
  }
}
