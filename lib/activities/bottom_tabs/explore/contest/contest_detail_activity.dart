import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as gLocator;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solomas/activities/home/participant_list_activity.dart';
import 'package:solomas/blocs/explore/contest_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/contest_list_model.dart';
import 'package:solomas/model/participate_model.dart';
import 'package:solomas/model/upload_image_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../../../resources_helper/common_widget.dart';
import '../../../../resources_helper/images.dart';
import '../../../../resources_helper/screen_area/scaffold.dart';
import '../../../../resources_helper/text_styles.dart';
import '../../../common_helpers/app_bar.dart';

class ContestDetailActivity extends StatefulWidget {
  final String? contestId, contestTitle;

  ContestDetailActivity({this.contestId, this.contestTitle});

  @override
  State<StatefulWidget> createState() {
    return _ContestDetailState();
  }
}

class _ContestDetailState extends State<ContestDetailActivity> {
  CommonHelper? _commonHelper;

  ContestBloc? _contestBloc;

  // File _profileImage;

  bool _progressShow = false;

  ImagePicker _imagePicker = ImagePicker();

  ApiHelper? _apiHelper;

  List<ContestList> _aList = [];

  double latitude = 0.0;

  double longitude = 0.0;

  @override
  void initState() {
    super.initState();

    _apiHelper = ApiHelper();

    _contestBloc = ContestBloc();

    _checkPermission();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getContestList(""));
  }

  Future<PermissionStatus> _checkPermission() async {
    var requestPermission = await Permission.location.request();

    if (requestPermission.isGranted) {
      _getCurrentLocation();
    }

    return requestPermission;
  }

  Future<bool> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return true;
  }

  Future<gLocator.Position> locateUser() async {
    return gLocator.Geolocator.getCurrentPosition(
        desiredAccuracy: gLocator.LocationAccuracy.high);
  }

  void _getContestList(String distance) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _contestBloc
              ?.getContests(
                  token.toString(), distance, widget.contestId.toString())
              .then((onValue) {
            _hideProgress();
          }).catchError((onError) {
            _hideProgress();
          });
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _showProgress() {
    setState(() {
      _progressShow = true;
    });
  }

  void _hideProgress() {
    setState(() {
      _progressShow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    Widget _successBottomSheet(String title, String msg, String type) {
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

              _commonHelper?.startActivity(ParticipantListActivity(
                  type: type, contestId: widget.contestId.toString()));
            },
          ),
        ],
      );
    }

    Future<Null> _cropImage(imageFile, type) async {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: imageFile.path,
          compressQuality: 80,
          cropStyle: CropStyle.rectangle,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: '',
                toolbarColor: Colors.white,
                showCropGrid: false,
                hideBottomControls: true,
                cropFrameColor: Colors.transparent,
                toolbarWidgetColor: SoloColor.blue,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: true),
            IOSUiSettings(
              rotateButtonsHidden: true,
              minimumAspectRatio: 1.0,
            )
          ]);

      if (croppedFile != null) {
        imageFile = File(croppedFile.path);

        _showProgress();

        _apiHelper?.uploadFile(imageFile).then((onSuccess) {
          UploadImageModel imageModel = onSuccess;

          var body = json.encode({
            "contestId": widget.contestId,
            "type": type,
            "image": imageModel.data?.url,
            "lat": latitude,
            "lng": longitude
          });

          PrefHelper.getAuthToken().then((authToken) {
            _apiHelper
                ?.participateRoadKingQueen(authToken.toString(), body)
                .then((onValue) {
              _hideProgress();

              ParticipateModel participateModel = onValue;

              if (participateModel.statusCode == 200) {
                var contestType =
                    "${toBeginningOfSentenceCase(type == Constants.TYPE_ROAD_KING ? "Road King" : "Road Queen")}";

                showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => _successBottomSheet(
                        "$contestType",
                        "Thanks for participating in $contestType",
                        type));
              }
            }).catchError((onError) {
              _hideProgress();
            });
          });
        }).catchError((onError) {
          _hideProgress();
        });
      }
    }

    Future<Null> _pickImage(isCamera, type) async {
      /*    _profileImage = isCamera
          ? await ImagePicker.pickImage(source: ImageSource.camera)
          : await ImagePicker.pickImage(source: ImageSource.gallery);*/

      var pickedFile = isCamera
          ? await _imagePicker.pickImage(source: ImageSource.camera)
          : await _imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        _hideProgress();
      }

      if (pickedFile != null) {
        setState(() {
          _progressShow = false;

          _cropImage(pickedFile, type);
        });
      }
    }

    Future<String?> _asyncInputDialog(
        BuildContext context, bool isAndroid) async {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('App Permission'),
            content: Container(
                child: isAndroid
                    ? Text("Allow Solo Mas to take pictures and record video?")
                    : Text(
                        "Allow Solo Mas to access photos, media and files on your device?")),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Settings'),
                onPressed: () {
                  AppSettings.openAppSettings();

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> requestPermission(
        Permission pPermission, bool status, type) async {
      var requestPermission = await pPermission.request();

      if (requestPermission.isGranted) {
        _progressShow = true;

        _pickImage(status, type);
      } else if (requestPermission.isDenied) {
        _asyncInputDialog(context, status);
      } else if (requestPermission.isRestricted) {
        _asyncInputDialog(context, status);
      }
    }

    Widget _showParticipateBottomSheet(String type) {
      return CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text("Camera",
                style: TextStyle(
                    color: SoloColor.black,
                    fontSize: Constants.FONT_TOP,
                    fontWeight: FontWeight.w500)),
            onPressed: () {
              Navigator.pop(context);

              setState(() {
                requestPermission(Permission.camera, true, type);
              });
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "Gallery",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);

              setState(() {
                (Platform.isAndroid)
                    ? requestPermission(Permission.storage, false, type)
                    : requestPermission(Permission.photos, false, type);
              });
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text("Cancel",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    }

    Widget _showBottomSheet(String msg, String title, String type) {
      return CupertinoActionSheet(
        message: Text(title,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal)),
        title: Text(msg,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        actions: [
          CupertinoActionSheetAction(
            child: Text("Yes",
                style: TextStyle(
                    color: SoloColor.black,
                    fontSize: Constants.FONT_TOP,
                    fontWeight: FontWeight.w500)),
            onPressed: () {
              Navigator.pop(context);
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) =>
                      _showParticipateBottomSheet(type));
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text("Cancel",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    }

    void participateInContest(String contestName, bool isRoadKing) async {
      LocationPermission geolocationStatus =
          await gLocator.Geolocator.checkPermission();

      if (geolocationStatus == gLocator.LocationPermission.denied ||
          geolocationStatus == gLocator.LocationPermission.deniedForever) {
        _commonHelper
            ?.showToast("Please allow location permission to continue.");

        _hideProgress();

        return;
      }

      var currentLocation = await locateUser();

      _hideProgress();

      latitude = currentLocation.latitude;

      longitude = currentLocation.longitude;

      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _showBottomSheet(
              "${_aList[0].title} $contestName",
              "Ready to Compete?",
              isRoadKing
                  ? Constants.TYPE_ROAD_KING
                  : Constants.TYPE_ROAD_QUEEN));
    }

    void _onLetsCompeteTap(bool isRoadKing) {
      if (_aList[0].contestJoined!) {
        var contestName = _aList[0].type?.toLowerCase() == "roadking"
            ? "Road King Contest"
            : "Road Queen Contest";

        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) =>
                _commonHelper!.successBottomSheet(
                    "Already Participated",
                    "You are already participated in "
                        "${_aList[0].title} $contestName",
                    false));
      } else {
        var contestName =
            isRoadKing ? "Road King Contest" : "Road Queen Contest";

        _showProgress();

        participateInContest(contestName, isRoadKing);
      }
    }

    Widget _mainItem() {
      //for start date
      var startDate = _aList[0].startDateString.toString();
      var splitDate = startDate.split(RegExp('/'));

      var month = splitDate[0].toString();
      var startDay = splitDate[1].toString();
      var startYear = splitDate[2].toString();
      var startMonth = "";
      print("hellocontest" + startDate.toString());
      switch (month) {
        case "01":
          startMonth = "Jan";
          break;
        case "02":
          startMonth = "Feb";
          break;
        case "03":
          startMonth = "Mar";
          break;

        case "04":
          startMonth = "Apr";
          break;
        case "05":
          startMonth = "May";
          break;

        case "06":
          startMonth = "Jun";
          break;

        case "07":
          startMonth = "Jul";
          break;
        case "08":
          startMonth = "Aug ";
          break;

        case "09":
          startMonth = "Sep";
          break;

        case "10":
          startMonth = "Oct";
          break;

        case "11":
          startMonth = "Nov";
          break;

        case "12":
          startMonth = "Dec";
          break;
      }

      //for end date

      var endDate = _aList[0].endDateString.toString();
      var splitEndDate = endDate.split(RegExp('/'));
      print("hellocontest" + endDate.toString());
      var endM = splitEndDate[0].toString();
      var endYear = splitEndDate[2].toString();
      var endDay = splitEndDate[1].toString();
      var endMonth = "";
      switch (endM) {
        case "01":
          endMonth = "Jan";
          break;
        case "02":
          endMonth = "Feb";
          break;
        case "03":
          endMonth = "Mar";
          break;

        case "04":
          endMonth = "Apr";
          break;
        case "05":
          endMonth = "May";
          break;

        case "06":
          endMonth = "Jun";
          break;

        case "07":
          endMonth = "Jul";
          break;
        case "08":
          endMonth = "Aug ";
          break;

        case "09":
          endMonth = "Sep";
          break;

        case "10":
          endMonth = "Oct";
          break;

        case "11":
          endMonth = "Nov";
          break;

        case "12":
          endMonth = "Dec";
          break;
      }

      return Stack(
        children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DimensHelper.sidesMargin),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: const Offset(
                            5.0,
                            5.0,
                          ),
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                        ), //BoxShadow
                        // BoxShadow(
                        //   color: Colors.white,
                        //   offset: const Offset(0.0, 0.0),
                        //   blurRadius: 0.0,
                        //   spreadRadius: 0.0,
                        // ), //BoxShadow
                      ],
                    ),
                    height: _commonHelper?.screenHeight * .3,
                    child: CachedNetworkImage(
                        width: _commonHelper?.screenWidth,
                        imageUrl: _aList[0].coverImageUrl.toString(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => imagePlaceHolder(),
                        errorWidget: (context, url, error) =>
                            imagePlaceHolder()),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      IconsHelper.person_pin,
                      width: _commonHelper!.screenWidth * 0.07,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      width: _commonHelper!.screenWidth * 0.77,
                      margin: EdgeInsets.only(
                          left: DimensHelper.tinySides,
                          right: DimensHelper.tinySides),
                      child: Text(
                        _aList[0].title.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: SoloStyle.darkBlackW700TopRob,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: DimensHelper.halfSides,
                    left: DimensHelper.sidesMargin,
                    right: DimensHelper.sidesMargin),
                child: Text(
                  _aList[0].description.toString(),
                  style: SoloStyle.spanishGrayNormalMediumXsRob,
                ),
              ),
              // Container(
              //   margin: EdgeInsets.only(
              //       top: DimensHelper.sidesMargin,
              //       left: DimensHelper.sidesMargin,
              //       right: DimensHelper.sidesMargin),
              //   child: Stack(
              //     children: [
              //       Align(
              //         alignment: Alignment.centerLeft,
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               "Start Datefg",
              //               style: TextStyle(
              //                   fontWeight: FontWeight.bold,
              //                   fontSize: Constants.FONT_APP_TITLE,
              //                   color: SoloColor.blue),
              //             ),
              //             Container(
              //               margin: EdgeInsets.only(
              //                   top: DimensHelper.sidesMargin,
              //                   right: DimensHelper.sidesMargin),
              //               child: Text(
              //                 "$startDay"
              //                 " "
              //                 "$startMonth"
              //                 " - "
              //                 "$endDay"
              //                 " "
              //                 "$endMonth "
              //                 "$endyear",
              //                 //_aList[0].startDateString.toString(),
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.normal,
              //                     fontSize: Constants.FONT_MEDIUM,
              //                     color: SoloColor.spanishGray),
              //               ),
              //             ),
              //             Container(
              //               margin:
              //                   EdgeInsets.only(top: DimensHelper.halfSides),
              //               height: 0.3,
              //               width: _commonHelper?.screenWidth * .4,
              //               color: SoloColor.silverSand,
              //             )
              //           ],
              //         ),
              //       ),
              //       Align(
              //         alignment: Alignment.centerRight,
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               "End Date",
              //               style: TextStyle(
              //                   fontWeight: FontWeight.bold,
              //                   fontSize: Constants.FONT_APP_TITLE,
              //                   color: SoloColor.blue),
              //             ),
              //             Container(
              //               margin:
              //                   EdgeInsets.only(top: DimensHelper.sidesMargin),
              //               child: Text(
              //                 _aList[0].endDateString.toString(),
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.normal,
              //                     fontSize: Constants.FONT_MEDIUM,
              //                     color: SoloColor.spanishGray),
              //               ),
              //             ),
              //             Container(
              //               margin:
              //                   EdgeInsets.only(top: DimensHelper.halfSides),
              //               height: 0.3,
              //               width: _commonHelper?.screenWidth * .4,
              //               color: SoloColor.silverSand,
              //             )
              //           ],
              //         ),
              //       )
              //     ],
              //   ),
              // ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Image.asset(
                      IconsHelper.ic_calender,
                      width: _commonHelper!.screenWidth * 0.06,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: DimensHelper.mediumSides,
                          right: DimensHelper.mediumSides),
                      child: Text(
                        "$startDay"
                        " "
                        "$startMonth "
                        "$startYear"
                        " - "
                        "$endDay"
                        " "
                        "$endMonth "
                        "$endYear",
                        style: SoloStyle.darkBlackW700MediumRob,
                      ),
                    ),
                    // Image.asset(
                    //   IconsHelper.ic_time,
                    //   width: _commonHelper!.screenWidth * 0.07,
                    //   fit: BoxFit.cover,
                    // ),
                    // Container(
                    //   margin: EdgeInsets.only(
                    //       left: DimensHelper.mediumSides,
                    //       right: DimensHelper.mediumSides),
                    //   child: Text(
                    //     "huiii",
                    //
                    //     // "${starthours}"
                    //     // ":"
                    //     // "${startminute} - ${endhuors}"
                    //     // ":"
                    //     // "${endminute}"
                    //     // " "
                    //     // "${endAmPm}",
                    //     style: SoloStyle.darkBlackW70015Rob,
                    //   ),
                    // ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Divider(color: SoloColor.graniteGray),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: DimensHelper.sidesMargin,
                  right: DimensHelper.sidesMargin,
                ),
                child: Text(
                  StringHelper.letsCompete,
                  style: SoloStyle.darkBlackW70020Rob,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flex(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      direction: Axis.horizontal,
                      children: [
                        Container(
                          child: ElevatedButton(
                            onPressed: () {
                              _onLetsCompeteTap(true);
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: SoloColor.white,
                                backgroundColor: SoloColor.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      DimensHelper.textSize,
                                    ),
                                    side: BorderSide(color: SoloColor.pink))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(StringHelper.roadKing.toUpperCase(),
                                    style: SoloStyle.pinkNormalMediumRob),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: DimensHelper.halfSides),
                                  child: Image.asset(IconsHelper.ic_pinkCrown,
                                      width: 30, height: 30),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      direction: Axis.horizontal,
                      children: [
                        Container(
                          child: ElevatedButton(
                            onPressed: () {
                              _onLetsCompeteTap(false);
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: SoloColor.white,
                                backgroundColor: SoloColor.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      DimensHelper.textSize,
                                    ),
                                    side: BorderSide(color: SoloColor.blue))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(StringHelper.roadQueen.toUpperCase(),
                                    style: SoloStyle.blueNormalMediumRob),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: DimensHelper.halfSides),
                                  child: Image.asset(IconsHelper.crownBlue,
                                      width: 30, height: 30),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.all(DimensHelper.halfSides),
              //   child: Flex(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     direction: Axis.horizontal,
              //     children: [
              //       ElevatedButton(
              //         style: ElevatedButton.styleFrom(
              //             foregroundColor: SoloColor.white,
              //             backgroundColor: SoloColor.pastelOrange,
              //             shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(
              //                     DimensHelper.sidesMargin))),
              //         onPressed: () {
              //           _onLetsCompeteTap(true);
              //         },
              //         child: Padding(
              //           padding: EdgeInsets.only(left: DimensHelper.halfSides),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Text(
              //                 "Road King ".toUpperCase(),
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.normal,
              //                     color: Colors.white,
              //                     fontSize: Constants.FONT_MEDIUM),
              //               ),
              //               Padding(
              //                 padding: EdgeInsets.only(
              //                     left: DimensHelper.halfSides + 2),
              //                 child: Image.asset('assets/images/ic_king.png'),
              //               )
              //             ],
              //           ),
              //         ),
              //       ),
              //       Padding(
              //         padding: EdgeInsets.only(
              //             left: DimensHelper.halfSides,
              //             right: DimensHelper.halfSides),
              //         child: Image.asset('assets/images/ic_cross.png'),
              //       ),
              //       ElevatedButton(
              //         onPressed: () {
              //           _onLetsCompeteTap(false);
              //         },
              //         style: ElevatedButton.styleFrom(
              //             foregroundColor: SoloColor.white,
              //             backgroundColor: SoloColor.black,
              //             shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(
              //                     DimensHelper.sidesMargin))),
              //         child: Padding(
              //           padding: EdgeInsets.only(left: DimensHelper.halfSides),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Text("Road Queen".toUpperCase(),
              //                   style: TextStyle(
              //                       fontWeight: FontWeight.normal,
              //                       color: Colors.white,
              //                       fontSize: Constants.FONT_MEDIUM)),
              //               Padding(
              //                 padding:
              //                     EdgeInsets.only(left: DimensHelper.halfSides),
              //                 child: Image.asset('assets/images/ic_queen.png'),
              //               )
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Divider(color: SoloColor.graniteGray),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: DimensHelper.sidesMargin,
                  right: DimensHelper.sidesMargin,
                ),
                child: Text(
                  StringHelper.letsVote,
                  style: SoloStyle.darkBlackW70020Rob,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flex(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      direction: Axis.horizontal,
                      children: [
                        Container(
                          child: ElevatedButton(
                            onPressed: () {
                              _commonHelper?.startActivity(
                                  ParticipantListActivity(
                                      contestId: widget.contestId.toString(),
                                      type: Constants.TYPE_ROAD_KING));
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: SoloColor.white,
                                backgroundColor: SoloColor.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      DimensHelper.textSize,
                                    ),
                                    side: BorderSide(color: SoloColor.pink))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(StringHelper.roadKing.toUpperCase(),
                                    style: SoloStyle.pinkNormalMediumRob),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: DimensHelper.halfSides),
                                  child: Image.asset(IconsHelper.ic_pinkCrown,
                                      width: 30, height: 30),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      direction: Axis.horizontal,
                      children: [
                        Container(
                          child: ElevatedButton(
                            onPressed: () {
                              _commonHelper?.startActivity(
                                  ParticipantListActivity(
                                      contestId: widget.contestId.toString(),
                                      type: Constants.TYPE_ROAD_QUEEN));
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: SoloColor.white,
                                backgroundColor: SoloColor.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      DimensHelper.textSize,
                                    ),
                                    side: BorderSide(color: SoloColor.blue))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(StringHelper.roadQueen.toUpperCase(),
                                    style: SoloStyle.blueNormalMediumRob),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: DimensHelper.halfSides),
                                  child: Image.asset(IconsHelper.crownBlue,
                                      width: 30, height: 30),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              //// old code

              // Padding(
              //   padding: EdgeInsets.all(DimensHelper.halfSides),
              //   child: Flex(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     direction: Axis.horizontal,
              //     children: [
              //       ElevatedButton(
              //         onPressed: () {
              //           _commonHelper?.startActivity(ParticipantListActivity(
              //               contestId: widget.contestId.toString(),
              //               type: Constants.TYPE_ROAD_KING));
              //         },
              //         style: ElevatedButton.styleFrom(
              //             foregroundColor: SoloColor.white,
              //             backgroundColor: SoloColor.yellow,
              //             shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(
              //                     DimensHelper.sidesMargin))),
              //         child: Padding(
              //           padding: EdgeInsets.only(left: DimensHelper.halfSides),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Text(
              //                 "Road King ".toUpperCase(),
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.normal,
              //                     color: Colors.white,
              //                     fontSize: Constants.FONT_MEDIUM),
              //               ),
              //               Padding(
              //                 padding: EdgeInsets.only(
              //                     left: DimensHelper.halfSides + 2),
              //                 child: Image.asset('assets/images/ic_king.png'),
              //               )
              //             ],
              //           ),
              //         ),
              //       ),
              //       Padding(
              //         padding: EdgeInsets.only(
              //             left: DimensHelper.halfSides,
              //             right: DimensHelper.halfSides),
              //         child: Image.asset('assets/images/ic_cross.png'),
              //       ),
              //       ElevatedButton(
              //         onPressed: () {
              //           _commonHelper?.startActivity(ParticipantListActivity(
              //               contestId: widget.contestId.toString(),
              //               type: Constants.TYPE_ROAD_QUEEN));
              //         },
              //         style: ElevatedButton.styleFrom(
              //             foregroundColor: SoloColor.white,
              //             backgroundColor: SoloColor.black,
              //             shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(
              //                     DimensHelper.sidesMargin))),
              //         child: Padding(
              //           padding: EdgeInsets.only(left: DimensHelper.halfSides),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Text("Road Queen".toUpperCase(),
              //                   style: TextStyle(
              //                       fontWeight: FontWeight.normal,
              //                       color: Colors.white,
              //                       fontSize: Constants.FONT_MEDIUM)),
              //               Padding(
              //                 padding:
              //                     EdgeInsets.only(left: DimensHelper.halfSides),
              //                 child: Image.asset('assets/images/ic_queen.png'),
              //               )
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
          Align(
            child:
                ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
            alignment: FractionalOffset.center,
          ),
        ],
      );
    }

    Widget _appBar(BuildContext context) {
      return SoloAppBar(
        appBarType: StringHelper.backWithText,
        appbarTitle: widget.contestTitle,
        backOnTap: () {
          Navigator.pop(context);
        },
      );
    }

    return SoloScaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 10, bottom: 0, top: 15, right: 10),
            child: _appBar(context),
          ),
        ),
        body: StreamBuilder(
            stream: _contestBloc?.contestList,
            builder: (context, AsyncSnapshot<ContestListModel> snapshot) {
              if (snapshot.hasData) {
                if (_aList.isEmpty) {
                  _aList = snapshot.data?.data?.contestList ?? [];
                }

                return _mainItem();
              } else if (snapshot.hasError) {
                return Container();
              }

              return Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(SoloColor.blue)));
            }));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
