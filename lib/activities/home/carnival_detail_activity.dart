import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart' as gLocator;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solomas/activities/home/members_list_activity.dart';
import 'package:solomas/activities/home/participant_list_activity.dart';
import 'package:solomas/blocs/explore/carnival_list_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/carnival_list_model.dart';
import 'package:solomas/model/participate_model.dart';
import 'package:solomas/model/upload_image_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:solomas/widgets/btn_widget.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';

class CarnivalDetailActivity extends StatefulWidget {
  final String? carnivalId;

  CarnivalDetailActivity({this.carnivalId});

  @override
  State<StatefulWidget> createState() {
    return _EventDetailScreen();
  }
}

class _EventDetailScreen extends State<CarnivalDetailActivity> {
//============================================================
// ** Properties **
//============================================================
  CommonHelper? _commonHelper;
  double latitude = 0.0;
  double longitude = 0.0;
  bool _progressShow = false,
      _isCarnivalJoined = false,
      _isCheckInAvailable = false,
      _isCheckInAvailableApi = false,
      _isSkipDate = false;

  String? _authToken,
      mineProfilePic = "",
      mineUserName = "",
      _selectBand = StringHelper.selectBand,
      selectBandForApi = "",
      mineUserId = "";

  ApiHelper? _apiHelper;
  CarnivalListBloc? _carnivalListBloc;
  Data? _carnivalData;
  List<CarnivalList>? _carnivalList;
  File? _profileImage;
  ImagePicker _imagePicker = ImagePicker();

//============================================================
// ** Helper Functions **
//============================================================

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

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _carnivalList = [];
    PrefHelper.getUserProfilePic().then((onValue) {
      setState(() {
        mineProfilePic = onValue;
      });
    });

    PrefHelper.getUserName().then((onValue) {
      setState(() {
        mineUserName = onValue;
      });
    });

    PrefHelper.getUserId().then((onValue) {
      setState(() {
        mineUserId = onValue;
      });
    });

    _carnivalListBloc = CarnivalListBloc();

    _apiHelper = ApiHelper();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getPublicFeeds());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
        body: StreamBuilder(
            stream: _carnivalListBloc?.carnivalList,
            builder: (context, AsyncSnapshot<CarnivalListModel> snapshot) {
              if (snapshot.hasData) {
                if (_carnivalData == null || _carnivalList!.isEmpty) {
                  _carnivalData = snapshot.data?.data;

                  _carnivalList = _carnivalData?.carnivalList;

                  if (_carnivalList!.isNotEmpty) {
                    for (var items in _carnivalData!.membersList!) {
                      if (items.userId == mineUserId) {
                        _selectBand = items.userBand;

                        break;
                      }
                    }
                    _isCarnivalJoined = _carnivalList?[0].isJoined == true;

                    _isSkipDate =
                        _carnivalList?[0].isCarnivalDateSkipped == true;

                    if (_isCarnivalJoined &&
                        _carnivalList?[0].isJoined == true) {
                      _getCurrentLocation(
                          _carnivalList?[0].location as Location);
                    }
                  }
                }

                // Timestamp stamp = Timestamp.now();
                // DateTime date = stamp.toDate();
                return mainItem();
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
    _carnivalListBloc?.dispose();

    super.dispose();
  }

//============================================================
// ** Main Widget **
//============================================================
  Widget _appBar(BuildContext context, String? carnivalContinent) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: carnivalContinent!,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget bottomRow() {
    return GestureDetector(
      onTap: () {},
      child: Container(
          child: Row(
        children: [
          Image.asset(
            IconsHelper.ic_locationPin,
            width: _commonHelper!.screenWidth * 0.07,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 20,
              ),
            ]),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                _carnivalList![0].locationName.toString(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: SoloColor.white,
                    fontWeight: FontWeight.normal,
                    fontSize: Constants.FONT_TOP),
              ),
            ),
          )
        ],
      )),
    );
  }

  //============================================================
// ** Helper Widget **
//============================================================
  Widget _showCarnivalBottomSheet(String msg, String sheetTitle) {
    return CupertinoActionSheet(
      message: Text(msg,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.normal)),
      title: Text(sheetTitle,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes,
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            if (_isCarnivalJoined) {
              _disJoinCarnivalTap();
            } else {
              _joinCarnivalTap();
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(StringHelper.cancel,
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

  Widget _joinedCarnivalUi() {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _showCarnivalBottomSheet(
                StringHelper.do_you_Want_to_remove,
                StringHelper.remove_Carnival));
      },
      child: Container(
          height: 30,
          width: 70,
          decoration: BoxDecoration(
            border: Border.all(
              color: SoloColor.white,
            ),
            color: SoloColor.lightGrey200,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(right: DimensHelper.sidesMargin, top: 10),
          child: Center(
            child: Text(
              "✔ GOING",
              style: TextStyle(color: SoloColor.white, fontSize: 13),
            ),
          )),
    );
  }

  Widget _disJoinedCarnivalUi() {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _showCarnivalBottomSheet(
                StringHelper.areYouSureYouWantToAttend,
                StringHelper.addCarnival));
      },
      child: Container(
          height: 30,
          width: 70,
          decoration: BoxDecoration(
            border: Border.all(
              color: SoloColor.white,
            ),
            color: SoloColor.batteryChargedBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(right: DimensHelper.sidesMargin, top: 10),
          child: Center(
            child: Text(
              "${StringHelper.going}",
              style: TextStyle(color: SoloColor.white, fontSize: 13),
            ),
          )),
    );
  }

  Widget carnivalImages(String imageUrl) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: SoloColor.white)),
      child: CachedNetworkImage(
        width: 120,
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => imagePlaceHolder(),
        errorWidget: (context, url, error) => imagePlaceHolder(),
      ),
    );
  }

  Widget memberList() {
    return Expanded(
      child: Stack(
        children: [
          _carnivalData!.membersList!.length > 0
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(55.0)),
                    boxShadow: [
                      BoxShadow(blurRadius: 3.0),
                    ],
                  ),
                  height: _commonHelper?.screenHeight * .045,
                  width: _commonHelper?.screenHeight * .045,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                        child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            height: _commonHelper?.screenHeight * .018,
                            width: _commonHelper?.screenHeight * .018,
                            imageUrl: _carnivalData!
                                .membersList![0].userProfilePic
                                .toString(),
                            placeholder: (context, url) => imagePlaceHolder(),
                            errorWidget: (context, url, error) =>
                                imagePlaceHolder())),
                  ),
                )

              // Container(
              //         margin: EdgeInsets.only(
              //           left: _commonHelper!.screenWidth * 0.02,
              //         ),
              //         child: ClipOval(
              //             child: CachedNetworkImage(
              //           imageUrl: _carnivalData!.membersList![0].userProfilePic
              //               .toString(),
              //           height: 50,
              //           width: 50,
              //           fit: BoxFit.cover,
              //           placeholder: (context, url) => imagePlaceHolder(),
              //                         errorWidget: (context, url, error) =>
              //                             imagePlaceHolder()
              //         )),
              //       )
              : SizedBox(),
          _carnivalData!.membersList!.length > 1
              ? Positioned(
                  left: _commonHelper!.screenWidth * 0.06,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(55.0)),
                      boxShadow: [
                        BoxShadow(blurRadius: 3.0),
                      ],
                    ),
                    height: _commonHelper?.screenHeight * .045,
                    width: _commonHelper?.screenHeight * .045,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                          child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        height: _commonHelper?.screenHeight * .018,
                        width: _commonHelper?.screenHeight * .018,
                        imageUrl: _carnivalData!.membersList![1].userProfilePic
                            .toString(),
                        placeholder: (context, url) => imagePlaceHolder(),
                        errorWidget: (context, url, error) =>
                            imagePlaceHolder(),
                      )),
                    ),
                  ))
              : SizedBox(),
          _carnivalData!.membersList!.length > 2
              ? Positioned(
                  left: _commonHelper!.screenWidth * 0.12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(55.0)),
                      boxShadow: [
                        BoxShadow(blurRadius: 3.0),
                      ],
                    ),
                    height: _commonHelper?.screenHeight * .045,
                    width: _commonHelper?.screenHeight * .045,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              height: _commonHelper?.screenHeight * .018,
                              width: _commonHelper?.screenHeight * .018,
                              imageUrl: _carnivalData!
                                  .membersList![2].userProfilePic
                                  .toString(),
                              placeholder: (context, url) => imagePlaceHolder(),
                              errorWidget: (context, url, error) =>
                                  imagePlaceHolder())),
                    ),
                  ),
                )
              : SizedBox(),
          _carnivalData!.membersList!.length > 3
              ? Positioned(
                  left: _commonHelper!.screenWidth * 0.18,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(55.0)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3.0,
                        ),
                      ],
                    ),
                    height: _commonHelper?.screenHeight * .045,
                    width: _commonHelper?.screenHeight * .045,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(40)),
                        child: Text(
                          '+${_carnivalData!.membersList!.length - 3}',
                          style: SoloStyle.smokeWhiteW70010Rob
                              .copyWith(fontSize: 11),
                        ),
                      ),
                    ),
                  )

                  // Container(
                  //   height: _commonHelper?.screenHeight * .065,
                  //   width: _commonHelper?.screenHeight * .060,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius:
                  //         new BorderRadius.all(new Radius.circular(55.0)),
                  //   ),
                  //   child: Container(
                  //     alignment: Alignment.center,
                  //     decoration: BoxDecoration(
                  //         color: Colors.black,
                  //         borderRadius: BorderRadius.circular(40)),
                  //     child: Text(
                  //       '+${_carnivalData!.membersList!.length - 3}',
                  //       style: SoloStyle.smokeWhiteW70010Rob
                  //           .copyWith(fontSize: 15),
                  //     ),
                  //   ),
                  // ),
                  )
              : SizedBox(),
        ],
      ),
    );
    // return Visibility(
    //   visible: _carnivalData!.membersList!.isNotEmpty,
    //   child: Container(
    //     height: 120,
    //     child: ListView.builder(
    //         itemCount: _carnivalData?.membersList?.length,
    //         scrollDirection: Axis.horizontal,
    //         itemBuilder: (BuildContext context, int index) {
    //           return peopleDetailCard(_carnivalData!.membersList![index]);
    //         }),
    //   ),
    // );
  }

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
          child: Text(StringHelper.Ok,
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _commonHelper?.startActivity(ParticipantListActivity(
                type: type,
                contestId: _carnivalData?.carnivalList?[0].contestId));
          },
        ),
      ],
    );
  }

  Widget _showParticipateBottomSheet(String type) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.camera,
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
            StringHelper.gallery,
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
        child: Text(StringHelper.cancel,
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
          child: Text(StringHelper.yes,
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
        child: Text(StringHelper.cancel,
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

  String capitalizeAllWord(String? value) {
    var result = value![0].toUpperCase();
    for (int i = 1; i < value!.length; i++) {
      if (value[i - 1] == " ") {
        result = result + value[i].toUpperCase();
      } else {
        result = result + value[i];
      }
    }
    print(result);
    return result;
  }

  Widget mainItem() {
    // getting Start date
    var originalStartDate = _carnivalList![0].startDate;

    var finalDate =
        DateTime.fromMillisecondsSinceEpoch(originalStartDate! * 1000);
    final dateFormat = new DateFormat('dd-MMM-yyyy-hh-mm-a');
    var formatDate = dateFormat.format(finalDate);

    var splitDate = formatDate.split(RegExp('-'));
    var startDate = splitDate[0].toString();
    var startMonth = splitDate[1].toString();
    var startYear = splitDate[2].toString();
    var startHours = splitDate[3].toString();
    var startMinute = splitDate[4].toString();
    var startPMAM = splitDate[5].toString();

    // getting end date
    var originalEndDate = _carnivalList![0].endDate;

    var finalEndDate =
        DateTime.fromMillisecondsSinceEpoch(originalEndDate! * 1000);

    var formatEndDate = dateFormat.format(finalEndDate);

    var splitEndDate = formatEndDate.split(RegExp('-'));
    var endDate = splitEndDate[0].toString();
    var endMonth = splitEndDate[1].toString();
    var endYear = splitEndDate[2].toString();
    var endHuors = splitEndDate[3].toString();
    var endMinute = splitEndDate[4].toString();
    var endAmPm = splitEndDate[5].toString();

    print("helloenddate" + originalEndDate.toString());

    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
                left: 10,
              ),
              child: _appBar(context, _carnivalList![0].title.toString()),
            ),
            Container(
              height: _commonHelper?.screenHeight * .35,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(DimensHelper.sidesMargin),
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
                          ],
                        ),
                        height: _commonHelper?.screenHeight * .35,
                        child: CachedNetworkImage(
                          width: _commonHelper?.screenWidth,
                          imageUrl: _carnivalList![0].coverImageUrl.toString(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => imagePlaceHolder(),
                          errorWidget: (context, url, error) =>
                              imagePlaceHolder(),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 80,
                      width: _carnivalList?[0].images?.length == 1 ? 125 : 250,
                      margin: EdgeInsets.only(
                          top: _commonHelper?.screenHeight * .35),
                      child: ListView.builder(
                          itemCount: _carnivalList?[0].images?.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return carnivalImages(
                                _carnivalList![0].images![index]);
                          }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: _commonHelper?.screenHeight * .35,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(DimensHelper.sidesMargin),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.7),
                            ],
                          )),
                    ),
                  ),
                  Container(
                    height: _commonHelper?.screenHeight * .07,
                    width: _commonHelper?.screenWidth,
                    child: Visibility(
                      visible: !_isSkipDate,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _isCarnivalJoined
                            ? _joinedCarnivalUi()
                            : _disJoinedCarnivalUi(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 18, left: 20),
                    child: Align(
                        alignment: Alignment.bottomLeft, child: bottomRow()),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Image.asset(
                    IconsHelper.person_pin,
                    width: _commonHelper!.screenWidth * 0.07,
                    fit: BoxFit.cover,
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                          left: DimensHelper.smallSides,
                          right: DimensHelper.sidesMargin),
                      child: Text(
                        _carnivalList![0].title.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: SoloStyle.darkBlackW70020Rob,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: DimensHelper.halfSides,
                  left: DimensHelper.sidesMargin,
                  right: DimensHelper.sidesMargin,
                  bottom: DimensHelper.smallSides),
              child: Text(
                _carnivalList![0].description.toString(),
                style: SoloStyle.spanishGrayNormalMediumRob,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
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
                      // _carnivalList![0].startDate.toString(),

                      "$startDate"
                      " "
                      "$startMonth"
                      " "
                      "$startYear"
                      " - $endDate"
                      " $endMonth"
                      " "
                      "$endYear",
                      style: SoloStyle.darkBlackW70015Rob,
                    ),
                  ),
                  Image.asset(
                    IconsHelper.ic_time,
                    width: _commonHelper!.screenWidth * 0.06,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: DimensHelper.mediumSides,
                        right: DimensHelper.mediumSides),
                    child: Text(
                      "${startHours}"
                      ":"
                      "${startMinute} "
                      "$startPMAM"
                      "- ${endHuors}"
                      ":"
                      "${endMinute}"
                      " "
                      "${endAmPm}",
                      style: SoloStyle.darkBlackW70015Rob,
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _carnivalList?[0].isCarnivalDateSkipped == true,
              child: Container(
                margin: EdgeInsets.only(
                    top: DimensHelper.sidesMargin,
                    left: DimensHelper.sidesMargin,
                    right: DimensHelper.sidesMargin),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            StringHelper.eventStartDate,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Constants.FONT_APP_TITLE,
                                color: SoloColor.blue),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: DimensHelper.halfSides,
                                right: DimensHelper.sidesMargin),
                            child: Text(
                              _carnivalList?[0].isCarnivalDateSkipped == true
                                  ? ""
                                  : _commonHelper!.convertEpochTime(
                                      _carnivalList?[0].startDate ?? 0),
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: Constants.FONT_MEDIUM,
                                  color: SoloColor.spanishGray),
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: DimensHelper.halfSides),
                            height: 0.3,
                            width: _commonHelper?.screenWidth * .4,
                            color: SoloColor.silverSand,
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            StringHelper.eventEndDate,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Constants.FONT_APP_TITLE,
                                color: SoloColor.blue),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: DimensHelper.halfSides),
                            child: Text(
                              _carnivalList?[0].isCarnivalDateSkipped == true
                                  ? ""
                                  : _commonHelper!.convertEpochTime(
                                      _carnivalList?[0].endDate ?? 0),
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: Constants.FONT_MEDIUM,
                                  color: SoloColor.spanishGray),
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: DimensHelper.halfSides),
                            height: 0.3,
                            width: _commonHelper?.screenWidth * .4,
                            color: SoloColor.silverSand,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Visibility(
              visible: _carnivalList?[0].isCarnivalDateSkipped == true,
              child: Container(
                margin: EdgeInsets.only(
                    top: DimensHelper.sidesMargin,
                    left: DimensHelper.sidesMargin,
                    right: DimensHelper.sidesMargin),
                child: Text(
                  "DATE: TBD",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Constants.FONT_TOP,
                      color: SoloColor.blue),
                ),
              ),
            ),
            // Container(
            //   margin: EdgeInsets.only(
            //       top: DimensHelper.sidesMargin,
            //       left: DimensHelper.sidesMargin,
            //       right: DimensHelper.sidesMargin),
            //   child: Text(
            //     "Location",
            //     style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //         fontSize: Constants.FONT_APP_TITLE,
            //         color: SoloColor.blue),
            //   ),
            // ),
            // Container(
            //   margin: EdgeInsets.only(
            //       top: DimensHelper.halfSides,
            //       left: DimensHelper.sidesMargin,
            //       right: DimensHelper.sidesMargin),
            //   child: Text(
            //     _carnivalList![0].locationName.toString(),
            //     style: TextStyle(
            //         fontWeight: FontWeight.normal,
            //         fontSize: Constants.FONT_MEDIUM,
            //         color: SoloColor.spanishGray),
            //   ),
            // ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Divider(
                  color: SoloColor.silverSand.withOpacity(0.2), thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      StringHelper.whoAreYouPlayingWith,
                      style: SoloStyle.darkBlackW70020Rob,
                    ),
                  ),
                  Container(
                    width: _commonHelper!.screenWidth * 0.3,
                    height: _commonHelper!.screenWidth * 0.10,
                    decoration: BoxDecoration(
                      color: SoloColor.cultured,
                      borderRadius: BorderRadius.all(
                          Radius.circular(DimensHelper.halfSides)),
                      border: Border.all(color: SoloColor.gainsBoro),
                    ),
                    padding: EdgeInsets.only(
                        right: DimensHelper.halfSides,
                        left: DimensHelper.halfSides + 4),
                    child: DropdownButton<Bands>(
                      icon: Icon(Icons.arrow_drop_down, color: SoloColor.black),
                      iconSize: 25,
                      hint: Text(
                          capitalizeAllWord(
                              _selectBand.toString().toLowerCase()),
                          style: TextStyle(
                              color: SoloColor.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              fontFamily: 'Roboto')),
                      isExpanded: true,
                      items: _carnivalList?[0].bands?.map((Bands bands) {
                        return DropdownMenuItem<Bands>(
                          value: bands,
                          child: Text(
                              capitalizeAllWord(bands.name?.toLowerCase()) ??
                                  ''),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectBand = val?.name;
                          selectBandForApi = val?.name;
                          print(
                              "value of selectBandForAPi is ${capitalizeAllWord(_selectBand!.toLowerCase())}");
                        });
                      },
                      underline: Container(
                        height: 0,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_carnivalData!.membersList!.length > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Divider(
                    color: SoloColor.silverSand.withOpacity(0.2), thickness: 1),
              ),
            if (_carnivalData!.membersList!.length > 0)
              Visibility(
                visible: _carnivalData!.membersList!.isNotEmpty,
                child: Container(
                    width: _commonHelper?.screenWidth,
                    margin: EdgeInsets.only(right: DimensHelper.sidesMargin),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(
                              left: DimensHelper.sidesMargin,
                              right: DimensHelper.sidesMargin),
                          child: Text(
                            StringHelper.Masqueraders,
                            style: SoloStyle.darkBlackW70020Rob,
                          ),
                        ),
                        // Spacer(),
                        memberList(),

                        GestureDetector(
                          onTap: () {
                            _commonHelper?.startActivity(MembersListActivity(
                                membersList: _carnivalData?.membersList));
                          },
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              StringHelper.seeAll.toUpperCase(),
                              style: TextStyle(
                                shadows: [
                                  Shadow(
                                      color: Colors.black,
                                      offset: Offset(0, -5))
                                ],
                                fontSize: 12,
                                color: Colors.transparent,
                                decoration: TextDecoration.underline,
                                decorationColor: SoloColor.pink,
                                decorationThickness: 2,
                                decorationStyle: TextDecorationStyle.solid,
                              ),
                            ),
                          ),
                        )
                      ],
                    )),
              ),

            Visibility(
              visible: _carnivalData!.membersList!.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Divider(
                    color: SoloColor.silverSand.withOpacity(0.2), thickness: 1),
              ),
            ),

            Visibility(
              visible: _carnivalData?.carnivalList?[0].hasContest == true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    padding: EdgeInsets.symmetric(horizontal: 12),
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
                                        side:
                                            BorderSide(color: SoloColor.pink))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(StringHelper.roadKing.toUpperCase(),
                                        style: SoloStyle.pinkNormalMediumRob),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: DimensHelper.halfSides),
                                      child: Image.asset(
                                          IconsHelper.ic_pinkCrown,
                                          width: 25,
                                          height: 25),
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
                                        side:
                                            BorderSide(color: SoloColor.blue))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(StringHelper.roadQueen.toUpperCase(),
                                        style: SoloStyle.blueNormalMediumRob),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: DimensHelper.halfSides),
                                      child: Image.asset(IconsHelper.crownBlue,
                                          width: 25, height: 25),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Divider(
                        color: SoloColor.silverSand.withOpacity(0.2),
                        thickness: 1),
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
                    padding: EdgeInsets.symmetric(horizontal: 12),
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
                                          contestId: _carnivalData
                                              ?.carnivalList?[0].contestId,
                                          type: Constants.TYPE_ROAD_KING));
                                },
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: SoloColor.white,
                                    backgroundColor: SoloColor.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          DimensHelper.textSize,
                                        ),
                                        side:
                                            BorderSide(color: SoloColor.pink))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(StringHelper.roadKing.toUpperCase(),
                                        style: SoloStyle.pinkNormalMediumRob),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: DimensHelper.halfSides),
                                      child: Image.asset(
                                          IconsHelper.ic_pinkCrown,
                                          width: 30,
                                          height: 30),
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
                                          contestId: _carnivalData
                                              ?.carnivalList?[0].contestId,
                                          type: Constants.TYPE_ROAD_QUEEN));
                                },
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: SoloColor.white,
                                    backgroundColor: SoloColor.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          DimensHelper.textSize,
                                        ),
                                        side:
                                            BorderSide(color: SoloColor.blue))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                ],
              ),
            ),

            Visibility(
              visible:
                  _isCheckInAvailable && _carnivalList![0].isCheckIn == false,
              child: Container(
                margin: EdgeInsets.only(bottom: DimensHelper.sidesMargin),
                alignment: Alignment.center,
                child: ButtonWidget(
                  height: _commonHelper?.screenHeight,
                  width: _commonHelper?.screenWidth * .7,
                  onPressed: () {
                    _onCheckInTap();
                  },
                  btnText: StringHelper.checkIn,
                ),
              ),
            )
          ],
        ),
        Align(
          child: ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
          alignment: FractionalOffset.center,
        ),
      ],
    );
  }

  //============================================================
// ** Helper Functions **
//============================================================
  void _joinCarnivalTap() {
    if (_selectBand == StringHelper.selectBand) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _commonHelper!.successBottomSheet(
              StringHelper.chooseBand, StringHelper.chooseOneBand, false));

      return;
    }

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "carnivalId": widget.carnivalId,
          "band": selectBandForApi /*_selectBand*/
        });

        _apiHelper
            ?.joinCarnival(body.toString(), _authToken.toString())
            .then((onSuccess) {
          _hideProgress();

          setState(() {
            _isCarnivalJoined = true;
          });

          _getCurrentLocation(_carnivalList?[0].location as Location);
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _getPublicFeeds() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _authToken = token;

          _carnivalListBloc?.getCarnivalList(
              token.toString(), widget.carnivalId.toString(), "", "");
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  Future<gLocator.Position> locateUser() async {
    return gLocator.Geolocator.getCurrentPosition(
        desiredAccuracy: gLocator.LocationAccuracy.high);
  }

  void _getCurrentLocation(Location location) async {
    gLocator.LocationPermission geolocationStatus =
        await gLocator.Geolocator.checkPermission();

    if (geolocationStatus == gLocator.LocationPermission.denied ||
        geolocationStatus == gLocator.LocationPermission.deniedForever) {
      if (Platform.isAndroid) {
        _asyncInputDialog(context, true);
      } else {
        _asyncInputDialog(context, false);
      }

      _commonHelper?.showToast(StringHelper.allowPerCheckIn);
      return;
    }

    var currentLocation = await locateUser();

    latitude = currentLocation.latitude;

    longitude = currentLocation.longitude;

    print("AVI PRINT: " + currentLocation.latitude.toString());
    var distance = _commonHelper?.calculateDistance(currentLocation.latitude,
        currentLocation.longitude, location.lat, location.lng);

    print("DISTANCE: " + distance!.toInt().toString());

    if (distance.toInt() <= 5) {
      setState(() {
        _isCheckInAvailable = true;
      });
    }
    return null;
  }

  void _onLetsCompeteTap(bool isRoadKing) {
    if (_carnivalData?.carnivalList?[0].contestJoined == true) {
      var contestName =
          _carnivalData?.carnivalList?[0].type?.toLowerCase() == "roadking"
              ? StringHelper.RoadKingContest
              : StringHelper.RoadQueenContest;

      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _commonHelper!.successBottomSheet(
              StringHelper.AlreadyParticipated,
              "You are already participated in "
              "${_carnivalData?.carnivalList?[0].title} $contestName",
              false));
    } else {
      var contestName = isRoadKing
          ? StringHelper.RoadKingContest
          : StringHelper.RoadQueenContest;

      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _showBottomSheet(
              "${_carnivalData?.carnivalList?[0].title} $contestName",
              StringHelper.ReadyToCompete,
              isRoadKing
                  ? Constants.TYPE_ROAD_KING
                  : Constants.TYPE_ROAD_QUEEN));
    }
  }

  void _disJoinCarnivalTap() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "carnivalId": widget.carnivalId,
        });

        _apiHelper
            ?.disJoinCarnival(body.toString(), _authToken.toString())
            .then((onSuccess) {
          _hideProgress();

          setState(() {
            _isCarnivalJoined = false;

            _isCheckInAvailable = false;
          });
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onCheckInTap() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "carnivalId": widget.carnivalId,
        });

        _carnivalListBloc
            ?.checkInOnCarnival(_authToken.toString(), body.toString())
            .then((onSuccess) {
          _hideProgress();

          setState(() {
            _isCheckInAvailable = false;
          });
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  Future<Null> _cropImage(imageFile, type) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressQuality: 80,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        cropStyle: CropStyle.rectangle,
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
          "contestId": _carnivalData?.carnivalList?[0].contestId,
          "type": type,
          "image": imageModel.data?.url,
          "lat": latitude,
          "lng": longitude
        });

        _apiHelper
            ?.participateRoadKingQueen(_authToken.toString(), body)
            .then((onValue) {
          _hideProgress();

          ParticipateModel participateModel = onValue;

          if (participateModel.statusCode == 200) {
            var contestType =
                "${toBeginningOfSentenceCase(type == Constants.TYPE_ROAD_KING ? StringHelper.roadKing : StringHelper.roadQueen)}";

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
      }).catchError((onError) {
        _hideProgress();
      });
    }
  }

  Future<Null> _pickImage(isCamera, type) async {
    var pickedImage = isCamera
        ? await _imagePicker.pickImage(source: ImageSource.camera)
        : await _imagePicker.pickImage(source: ImageSource.gallery);

    _profileImage = File(pickedImage!.path);

    if (_profileImage == null) {
      _hideProgress();
    }

    if (_profileImage != null) {
      setState(() {
        _progressShow = false;

        _cropImage(_profileImage, type);
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
          title: Text(StringHelper.appPermission),
          content: Container(
              child: isAndroid
                  ? Text(StringHelper.AllowSoloMassToAddPermission)
                  : Text(StringHelper.AllowSoloMassToAddMedia)),
          actions: [
            TextButton(
              child: Text(StringHelper.Cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(StringHelper.Settings),
              onPressed: () {
                openAppSettings();

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
      // _progressShow = true;

      _pickImage(status, type);
    } else if (requestPermission.isDenied) {
      _asyncInputDialog(context, status);
    } else if (requestPermission.isRestricted) {
      _asyncInputDialog(context, status);
    } else if (requestPermission.isPermanentlyDenied) {
      _asyncInputDialog(context, status);
    } else if (requestPermission.isLimited) {
      _asyncInputDialog(context, status);
    }
  }
}
