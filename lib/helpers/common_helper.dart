import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:solomas/activities/blogs/blogs_comment_activity.dart';
import 'package:solomas/activities/bottom_tabs/explore/carnivals_continets/carnival_photos_comment_activity.dart';
import 'package:solomas/activities/bottom_tabs/explore/contest/contest_detail_activity.dart';
import 'package:solomas/activities/bottom_tabs/explore/group/group_detail_activity.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/chat/chat_activity.dart';
import 'package:solomas/activities/events/events_comment_activity.dart';
import 'package:solomas/activities/events/view_events_details.dart';
import 'package:solomas/activities/home/carnival_comment_list_activity.dart';
import 'package:solomas/activities/home/carnival_detail_activity.dart';
import 'package:solomas/activities/home/carnival_like_list_activity.dart';
import 'package:solomas/activities/home/feed_comments_activity.dart';
import 'package:solomas/activities/home/feed_likes_activity.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/activities/home_activity.dart';
import 'package:solomas/activities/registration/login_activity.dart';
import 'package:solomas/activities/services/service_comment_activity.dart';
import 'package:solomas/activities/services/services_likes_activity.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../activities/common_helpers/app_button.dart';
import '../activities/services/view_service_detail.dart';
import '../resources_helper/dimens.dart';
import '../resources_helper/images.dart';
import '../resources_helper/text_styles.dart';
import 'constants.dart';

class CommonHelper {
  var context, mediaQuery, orientation, screenSize, screenWidth, screenHeight;
  CommonHelper? _commonHelper;
  static BuildContext? _cContext;



  CommonHelper(this.context) {
    _cContext = context;

    init();
  }

  void init() {
    mediaQuery = MediaQuery.of(context);

    orientation = mediaQuery.orientation;

    screenSize = mediaQuery.size;

    screenHeight = screenSize.height;

    screenWidth = screenSize.width;
  }

  Future<bool> isInternetAvailable() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
  }

  startActivity(child) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => child));
  }

  startActivityWithReplacement(child) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => child));
  }

  startActivityAndCloseOther(child) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => child),
        ModalRoute.withName("/Home"));
  }

  closeActivity() {
    Navigator.pop(context!);
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;

    var c = cos;

    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;

    return 12742 * asin(sqrt(a));
  }

  showAlert(String title, content) {
    Widget alert = Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Oops!",
                          style: SoloStyle.blackBoldMax,
                        ),
                        Text(title, style: SoloStyle.blackBoldMax)
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SvgPicture.asset(IconsHelper.closeAlertIcon,
                                width: 30)
                          ]),
                    )
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      child: Divider(
                          height: 2,
                          thickness: 2.5,
                          color: SoloColor.batteryChargedBlue),
                    ),
                  ],
                ),
                // Container(
                //    height: 1,
                //     width: 1,
                //     color: SoloColor.batteryChargedBlue,
                //     decoration:
                //         BoxDecoration(borderRadius: BorderRadius.circular(18)),
                //   ),
                SizedBox(
                  height: 18,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 295,
                      child: Text(
                        content,
                        style: SoloStyle.blackMediumRoboto,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          height: 160,
          width: 335,
        ),
      ),
    );

    // var alert = AlertDialog(
    //   alignment: Alignment.bottomCenter,
    //   title: Text(title),
    //   content: Text(content),
    //   actions: [
    //     TextButton(
    //       child: Text("Ok", style: TextStyle(color: SoloColor.blue)),
    //       onPressed: () {
    //         Navigator.of(context).pop();
    //       },
    //     ),
    //   ],
    // );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {

          return alert;
        });
  }



  showAlertIntent(String title, content) {
    var alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: Text("Ok", style: TextStyle(color: SoloColor.blue)),
          onPressed: () {
            Navigator.of(context).pop();

            closeActivity();
          },
        ),
      ],
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return alert;
        });
  }

  noInternetAlert(String title, content) {
    var alert = AlertDialog(
      title: Text(StringHelper.noInternetMsg),
      content: Text(StringHelper.noInternetTitle),
      actions: [
        TextButton(
          child: Text("SETTINGS", style: TextStyle(color: SoloColor.blue)),
          onPressed: () {
            AppSettings.openWIFISettings();

            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("OK", style: TextStyle(color: SoloColor.blue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return alert;
        });
  }

  bool checkPlatform() {
    if (Platform.isAndroid) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> getIosVersion() async {
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;

      var version = iosInfo.systemVersion;

      if (version!.contains('13')) {
        return true;
      } else {
        return false;
      }
    }

    return false;
  }

  static alertOk(title, msg) {
    var alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        TextButton(
          child: Text("Ok", style: TextStyle(color: SoloColor.blue)),
          onPressed: () {
            Navigator.of(_cContext!).pop();
          },
        ),
      ],
    );

    showDialog(
        context: _cContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return alert;
        });
  }

  static sessionError(title, msg) {
    var alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        // usually buttons at the bottom of the dialog
        TextButton(
          child: Text("Ok", style: TextStyle(color: SoloColor.blue)),
          onPressed: () {
            Navigator.of(_cContext!).pop();
            Navigator.pushAndRemoveUntil(
                _cContext!,
                MaterialPageRoute(builder: (context) => LoginActivity()),
                ModalRoute.withName("/Login"));
          },
        ),
      ],
    );

    showDialog(
        context: _cContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return alert;
        });
  }

  bool checkEvent(String previousDate, String selectedDate1) {
    final format = DateFormat('MM/dd/yyyy');
    final dt = format.parse(previousDate, true);
    print("prev1" + dt.millisecondsSinceEpoch.toString());

    final format1 = DateFormat('MM/dd/yyyy');
    final dt1 = format1.parse(selectedDate1, true);
    print("prev22" + dt1.millisecondsSinceEpoch.toString());

    if (dt1.millisecondsSinceEpoch > dt.millisecondsSinceEpoch) {
      return false;
    }

    return true;

/*
    var inputFormat = DateFormat('MM/dd/yyyy');
    var previous = inputFormat.parse(previousDate);
    var selectedDate = inputFormat.parse(selectedDate1);

    if (selectedDate.year < previous.year) {
      return false;
    } else if (selectedDate.month < previous.month) {
      return false;
    } else if (selectedDate.day < previous.day) {
      return false;
    }

    return true;*/
  }

  int calculateAge(DateTime selectedDate) {
    DateTime currentDate = DateTime.now();

    int age = currentDate.year - selectedDate.year;

    int month1 = currentDate.month;

    int month2 = selectedDate.month;

    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;

      int day2 = selectedDate.day;

      if (day2 > day1) {
        age--;
      }
    }

    return age;
  }

  Widget successBottomSheet(String title, String msg, bool closePage) {
    return CupertinoActionSheet(
      title: Text(title,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(msg,
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Ok",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            if (closePage) {
              closeActivity();
            }
          },
        ),
      ],
    );
  }

  static checkStatusCode(int statusCode, title, msg) {
    switch (statusCode) {
      case 400:
        alertOk(title, msg);

        break;

      case 401:
        var isIntroShown;

        PrefHelper.contains(Constants.PREF_INTRODUCTION).then((onValue) {
          isIntroShown = onValue;
        });

        PrefHelper.clear().then((onSuccess) {
          PrefHelper.setIntroScreenValue(isIntroShown);

          sessionError('Session Expired',
              'Your session has expired. Please login again to continue.');
        });

        break;

      case 404:
        alertOk(title, msg);

        break;

      case 403:
        var isIntroShown;

        PrefHelper.contains(Constants.PREF_INTRODUCTION).then((onValue) {
          isIntroShown = onValue;
        });

        PrefHelper.clear().then((onSuccess) {
          PrefHelper.setIntroScreenValue(isIntroShown);

          sessionError('Session Expired',
              'Your session has expired. Please login again to continue.');
        });

        break;

      default:
        alertOk(title, msg);

        break;
    }
  }

  showToast(String title) {
    Fluttertoast.showToast(
        msg: title,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: SoloColor.blue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  String getCarnivalDate(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    return "${date.day} ${getMonthName(date.month)} ${date.year}";
  }

  String getFormetedDate(String startDate, bool isStartDate) {
    var inputFormat = DateFormat('dd/MM/yyyy');
    var inputDate = inputFormat.parse(startDate); // <-- dd/MM 24H format

    var outputFormat = DateFormat(isStartDate ? 'dd MMM' : 'dd MMM yyyy');
    var outputDate = outputFormat.format(inputDate);
    print(outputDate); // 12/31/2000 11:59 PM <-- MM/dd 12H format
    return outputDate;
  }

  String getMonthName(int month) {
    switch (month) {
      case 1:
        return "Jan";

      case 2:
        return "Feb";

      case 3:
        return "Mar";

      case 4:
        return "April";

      case 5:
        return "May";

      case 6:
        return "June";

      case 7:
        return "July";

      case 8:
        return "Aug";

      case 9:
        return "Sep";

      case 10:
        return "Oct";

      case 11:
        return "Nov";

      case 12:
        return "Dec";

      default:
        return "";
    }
  }

  String convertEpochTime(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    return "${date.month}/${date.day}/${date.year}";
  }

  String getTimeDifference(int timestamp) {
    var now = DateTime.now();
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds < 0 || diff.inSeconds == 0) {
      return "just now";
    } else if (diff.inSeconds < 60) {
      time = diff.inSeconds.toString() + ' sec ago';
    } else if (diff.inMinutes >= 1 && diff.inMinutes < 60) {
      time = diff.inMinutes == 1
          ? '${diff.inMinutes.toString()} min ago'
          : '${diff.inMinutes.toString()} mins ago';
    } else if (diff.inHours >= 1 && diff.inHours < 24) {
      time = diff.inHours == 1
          ? '${diff.inHours.toString()} hour ago'
          : '${diff.inHours.toString()} hours ago';
    } else {
      time = diff.inDays == 1
          ? '${diff.inDays.toString()} day ago'
          : '${diff.inDays.toString()} days ago';
    }
    return time;
  }

  initIntent(String type, msgMap) {
    print("MESSAGE MAP: " + msgMap.toString());

    if (Constants.isNavigated) return;

    PrefHelper.getAuthToken().then((onValue) {
      if (onValue != null && onValue != "") {
        switch (type) {
          case "commentReply":
            startActivity(PublicFeedCommentActivity(
              publicFeedId: msgMap['id'],
              showKeyBoard: false,
              scrollMessage: true,
              publicCommentId: msgMap['publicCommentId'],
            ));
            break;

          case "eventCommentReply":
            startActivity(EventsCommentActivity(
              eventId: msgMap['id'],
              showKeyBoard: false,
              scrollMessage: true,
              publicCommentId: msgMap['eventCommentId'],
            ));

            break;
          case "eventComment":
            startActivity(EventsCommentActivity(
              eventId: msgMap['id'],
              showKeyBoard: false,
              scrollMessage: true,
              publicCommentId: msgMap['eventCommentId'],
            ));

            break;

          case "blogCommentReply":
            startActivity(BlogCommentActivity(
              blogId: msgMap['id'],
              showKeyBoard: false,
              scrollMessage: true,
              publicCommentId: msgMap['blogCommentId'],
            ));
            break;

          case "serviceCommentReply":
            startActivity(ServiceCommentActivity(
              serviceId: msgMap['id'],
              showKeyBoard: false,
              scrollMessage: true,
              publicCommentId: msgMap['serviceCommentId'],
            ));
            break;

          case "serviceComment":
            startActivity(ServiceCommentActivity(
              serviceId: msgMap['id'],
              showKeyBoard: false,
              scrollMessage: true,
              publicCommentId: msgMap['serviceCommentId'],
            ));

            break;

          case "likeService":
            startActivity(ServiceLikeActivity(msgMap['id']));
            break;

          case "likeFeed":
            startActivity(CarnivalLikeListActivity(msgMap['id']));
            break;

          case "commentFeed":
            startActivity(CarnivalCommentListActivity(msgMap['id'],
                scrollMessage: true,
                carnivalCommentId: msgMap['carnivalCommentId']));
            break;

          case "feedCommentReply":
            startActivity(CarnivalCommentListActivity(msgMap['id'],
                scrollMessage: true,
                carnivalCommentId: msgMap['carnivalCommentId']));
            break;

          case "likePhoto":
            startActivity(FeedLikeActivity(msgMap['id']));

            break;

          case "commentPhoto":
            startActivity(PublicFeedCommentActivity(
                publicFeedId: msgMap['id'],
                showKeyBoard: false,
                scrollMessage: true,
                publicCommentId: msgMap['publicCommentId']));

            break;

          case "newMessage":
            startActivity(ChatActivity(
              msgMap['userName'],
              msgMap['senderId'],
              msgMap['profilePic'],
            ));

            break;

          case "sameDaysCarnivalReminder":
            startActivity(CarnivalDetailActivity(carnivalId: msgMap['id']));

            break;

          case "3DaysCarnivalReminder":
            startActivity(CarnivalDetailActivity(carnivalId: msgMap['id']));

            break;

          case "1DaysCarnivalReminder":
            startActivity(CarnivalDetailActivity(carnivalId: msgMap['id']));

            break;

          case "contestCommencement":
            startActivity(ContestDetailActivity(
                contestId: msgMap['id'], contestTitle: msgMap['contestTitle']));

            break;

          case "carnivalAttendees":
            startActivity(CarnivalDetailActivity(carnivalId: msgMap['id']));
            break;

          case "voteReminder":
            startActivity(ContestDetailActivity(
                contestId: msgMap['id'], contestTitle: msgMap['contestTitle']));

            break;

          case "winnerRoadKing":
            startActivity(ProfileTab());

            break;

          case "winnerRoadQueen":
            startActivity(ProfileTab());

            break;

          case "winnerVoter":
            startActivity(UserProfileActivity(userId: msgMap['id']));

            break;

          case "home":
            startActivity(HomeActivity(
              currentIndex: 0,
              publicFeedId: msgMap['id'],
              scrollMessage: true,
            ));

            /* if (msgMap['publicFeedUserId'] == '') {
              startActivity(HomeActivity(currentIndex: 0));
            } else {
              startActivity(
                  UserProfileActivity(id: msgMap['publicFeedUserId']));
            }*/
            break;

          case "carnivals":
            if (msgMap['id'] == '') {
              startActivity(HomeActivity(currentIndex: 1));
            } else {
              startActivity(CarnivalDetailActivity(
                carnivalId: msgMap['id'],
              ));
            }
            break;

          case "groups":
            if (msgMap['id'] == '') {
              startActivity(HomeActivity(currentIndex: 1, exploreIndex: 2));
            } else {
              startActivity(GroupDetailsActivity(
                groupId: msgMap['id'],
                groupTitle: msgMap['groupTitle'],
              ));
            }
            break;

          case "contests":
            if (msgMap['id'] == '') {
              startActivity(HomeActivity(currentIndex: 1, exploreIndex: 1));
            } else {
              startActivity(ContestDetailActivity(
                  contestId: msgMap['id'],
                  contestTitle: msgMap['contestTitle']));
            }
            break;

          case "people":
            if (msgMap['id'] == '') {
              startActivity(HomeActivity(currentIndex: 1, exploreIndex: 3));
            } else {
              startActivity(UserProfileActivity(
                userId: msgMap['id'],
              ));
            }
            break;

          case "events":
            if (msgMap['id'] == '') {
              startActivity(HomeActivity(currentIndex: 2));
            } else {
              startActivity(EventsDetailsActivity(eventId: msgMap['id']));
            }

            break;

          case "services":
            if (msgMap['id'] == '') {
              startActivity(HomeActivity(currentIndex: 3));
            } else {
              startActivity(ServiceDetail(serviceId: msgMap['id']));
            }
            break;

          case "blogs":
            Constants.isNavigated = true;
            startActivity(HomeActivity(
              currentIndex: 4,
              blogId: msgMap['id'],
              scrollMessage: true,
            ));
            break;

          case "carnivalPhotoComment":
            startActivity(CarnivalPhotosComment(
              carnivalPhotoId: msgMap['id'],
              scrollMessage: true,
              showKeyBoard: false,
              publicCommentId: msgMap['carnivalPhotoCommentId'],
            ));
            break;

          case "carnivalPhotoCommentReply":
            startActivity(CarnivalPhotosComment(
              carnivalPhotoId: msgMap['id'],
              scrollMessage: true,
              showKeyBoard: false,
              publicCommentId: msgMap['carnivalPhotoCommentId'],
            ));
            break;
        }
      }
    });
  }
}
