import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solomas/activities/events/view_events_details.dart';
import 'package:solomas/activities/services/view_service_detail.dart';
import 'package:solomas/blocs/home/update_user_bloc.dart';
import 'package:solomas/blocs/home/user_profile_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/show_dialog.dart';
import 'package:solomas/model/upload_image_model.dart';
import 'package:solomas/model/user_profile_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../blocs/home/home_bloc.dart';
import '../../helpers/progress_indicator.dart';
import '../../model/block_user_model.dart';
import '../../model/country.dart';
import '../../model/report_feed_model.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';
import '../common_helpers/common.dart';
import '../common_helpers/feed_card_events.dart';
import '../common_helpers/feed_card_profile.dart';
import '../common_helpers/festival_card.dart';
import '../common_helpers/profile_carnival_card.dart';
import '../home/feed_comments_activity.dart';
import '../home/feed_likes_activity.dart';
import 'edit_profile_activity.dart';
import 'explore/group/group_detail_activity.dart';
import 'group_info_activity.dart';

class ProfileTab extends StatefulWidget {
  final bool isFromHome;
  final String? id;

  ProfileTab({this.isFromHome = false, this.id});

  @override
  State<StatefulWidget> createState() {
    return _ProfileTabState();
  }
}

class _ProfileTabState extends State<ProfileTab> {
//============================================================
// ** Properties **
//============================================================

  var postList;
  var userProfileList;
  bool _progressShow = false,
      isCoverImage = false,
      isJoined = false,
      isSelectGenderShow = false;
  String? authToken, mineUserId;
  int _radioValue = 0;
  bool isRefresh = false;
  Country? code;

  late List<Widget> _randomChildren;

  Data? _aList;
  File? _profileImage;
  ApiHelper? _apiHelper;
  CommonHelper? _commonHelper;
  HomeBloc? _homeActivityBloc;
  UserProfileBloc? _userProfileBloc;
  UpdateUserBloc? _updateUserBloc;
  ImagePicker _imagePicker = ImagePicker();
  var _nameController = TextEditingController();
  final CarouselController _controller = CarouselController();
  final CarouselController _controller1 = CarouselController();

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    _getInitData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SoloScaffold(
        body: StreamBuilder(
            stream: _userProfileBloc?.userProfileList,
            builder: (context, AsyncSnapshot<UserProfileModel> snapshot) {
              if (snapshot.hasData) {
                if (_aList == null) {
                  _aList = snapshot.data?.data;

                  if (_aList!.response!.gender!.isEmpty) {
                    isSelectGenderShow = true;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (isSelectGenderShow)
                        ShowDialog.showChoiceGender(context,
                            backOnTap: () {
                              print("Hello");
                              setState(() {
                                isSelectGenderShow = false;
                                Navigator.pop(context);
                              });
                            },
                            groupValue: _radioValue,
                            nextOnTap: () {
                              setState(() {
                                var body = json.encode({
                                  "gender": _radioValue == 1 ? "female" : "male"
                                });
                                _onUpdateTap(body);
                              });
                            });
                    });
                  } else {
                    isSelectGenderShow = false;
                  }
                  _nameController.text =
                      toBeginningOfSentenceCase(_aList?.response?.fullName) ??
                          '';
                }
                return DefaultTabController(length: 6, child: _mainBody());
              } else if (snapshot.hasError) {
                return Container();
              }

              return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(SoloColor.red)),
              );
            }),
      ),
    );
  }

  @override
  void dispose() {
    _userProfileBloc?.dispose();
    _updateUserBloc?.dispose();
    _homeActivityBloc?.dispose();
    super.dispose();
  }

//============================================================
// ** Main Widget **
//============================================================

  Widget _appBar({void Function()? onTap}) {
    return SoloAppBar(
      appBarType: StringHelper.backWithEditAppBar,
      backOnTap: () {
        _commonHelper?.closeActivity();
      },
      iconUrl: IconsHelper.pencil,
      iconOnTap: () {
        isCoverImage = true;
        Navigator.of(context)
            .push(
          new MaterialPageRoute(
              builder: (_) =>
                  EditProfileActivity(userResponse: _aList?.response)),
        )
            .then((mapData) {
          if (mapData.containsKey("profilePic"))
            _aList?.response?.profilePic = mapData['profilePic'];

          if (mapData.containsKey("age"))
            _aList?.response?.age = mapData['age'];

          if (mapData.containsKey("fullName"))
            _aList?.response?.fullName = mapData['fullName'];

          if (mapData.containsKey("gender"))
            _aList?.response?.gender = mapData['gender'];

          if (mapData.containsKey("coverImage"))
            _aList?.response?.coverImage = mapData['coverImage'];

          if (mapData.containsKey("locationName"))
            _aList?.response?.locationName = mapData['locationName'];

          isRefresh = true;

          setState(() {});

          // _showProgress();
          //_getUserData();
        });
      },
    );
  }

  Widget _mainBody() {
    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: (context, _) {
          var country = _aList!.response!.locationName.toString().split(',').last;
          code = getisoCodeByName(country.toString().trim());
          return [
            SliverList(
              delegate: SliverChildListDelegate(
                _sliverWidgets(context),
              ),
            ),
          ];
        },
        // You tab view goes here
        body: Stack(
          children: [
            Column(
              children: <Widget>[
                TabBar(
                    isScrollable: true,
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    labelPadding: EdgeInsets.symmetric(horizontal: 7),
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: <Widget>[
                      _tabTitle(
                        StringHelper.posts_profile.toUpperCase(),
                      ),
                      _tabTitle(
                        StringHelper.carnivals.toUpperCase(),
                      ),
                      _tabTitle(
                        StringHelper.events.toUpperCase(),
                      ),
                      _tabTitle(
                        StringHelper.services.toUpperCase(),
                      ),
                      _tabTitle(
                        StringHelper.groups.toUpperCase(),
                      ),
                      _tabTitle(
                        StringHelper.competitions.toUpperCase(),
                      ),
                    ]),
                Expanded(
                  child: TabBarView(
                    children: [
                      _postTab(),
                      _carnivalsTab(),
                      _eventsTab(),
                      _serviceTab(),
                      _groupsTab(),
                      _competitionsTab()
                    ],
                  ),
                ),
              ],
            ),
            Align(
              child: ProgressBarIndicator(
                  _commonHelper?.screenSize, _progressShow),
              alignment: FractionalOffset.center,
            ),
          ],
        ),
      ),
    );
  }

//============================================================
// ** Tab Widget **
//============================================================

  Widget _postTab() {
    postList = _aList?.photo ?? [];
    userProfileList = _aList?.response as Response;

    return _aList!.photo!.isNotEmpty
        ? ListView.builder(
            itemCount: postList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: photosCardDetail(index),
              );
            })
        : _noPostWarning();
  }

  Widget _carnivalsTab() {
    var carnivalList = _aList?.upcomingCarnival ?? [];
    var userProfileList = _aList?.response as Response;
    if (_aList!.upcomingCarnival!.isEmpty ||
        _aList!.upcomingCarnival![0].carnivalData!.isEmpty) {
      return _noCarnivalWarning();
    } else {
      return Container(
        padding: EdgeInsets.only(top: 0),
        child: ListView.builder(
            itemCount: _aList?.upcomingCarnival?.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ProfileCarnivalCard(
                    index: index,
                    carnivalData: carnivalList[index].carnivalData?[0],
                    carnivalsInfo:
                        carnivalList[index].carnivalData?[0].userBand,
                  ));
            }),
      );
    }
  }

  Widget _eventsTab() {
    return _aList!.myEventListProfile!.isNotEmpty
        ? ListView.builder(
            itemCount: _aList?.myEventListProfile?.length,
            itemBuilder: (BuildContext context, int index) {
              return _eventsMainItem(index);
            })
        : _noEventsWarning();
  }

  Widget _serviceTab() {
    return _aList!.myServiceList!.isNotEmpty
        ? ListView.builder(
            itemCount: _aList?.myServiceList?.length,
            itemBuilder: (BuildContext context, int index) {
              return _servicesMainItem(index);
            })
        : _noServiceWarning();
  }

  Widget _groupsTab() {
    var _commonHelper = CommonHelper(context);
    return _aList!.groupList!.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              left: _commonHelper.screenWidth * 0.035,
              right: _commonHelper.screenWidth * 0.035,
              top: _commonHelper.screenHeight * 0.01,
              bottom: _commonHelper.screenHeight * 0.02,
            ),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: _commonHelper?.screenWidth * 0.5,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3 / 3,
                ),
                itemCount: _aList!.groupList!.length,
                itemBuilder: (BuildContext context, int index) {
                  return _groupsDetails(index);
                  // return _cardContinent(index);
                }),
          )
        : _noGroupWarning();
  }

  Widget _competitionsTab() {
    return _aList!.contestWon!.isNotEmpty
        ? ListView.builder(
            itemCount: _aList?.contestWon?.length,
            padding: EdgeInsets.only(top: DimensHelper.sidesMargin),
            itemBuilder: (BuildContext context, int index) {
              return contestWonCard(_aList!.contestWon![index]);
            })
        : _noDataWarning();
  }

//============================================================
// ** Helper Widget **
//============================================================

// ** Init Widget **//

  _getInitData() {
    _apiHelper = ApiHelper();
    _userProfileBloc = UserProfileBloc();
    _updateUserBloc = UpdateUserBloc();
    _homeActivityBloc = HomeBloc();
    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });
    PrefHelper.getAuthToken().then((onValue) {
      authToken = onValue;
    });
    _apiHelper = ApiHelper();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getUserData());
  }

// ** Profile Widgets **//

  List<Widget> _sliverWidgets(BuildContext context) {
    print("coverImage...${_aList!.response!.coverImage.toString()}");
    print("profileImage...${_aList!.response!.profilePic.toString()}");
    _randomChildren = [
      SizedBox(
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  Column(
                    children: [

                      Container(
                        height: _commonHelper?.screenHeight * .2,
                        child: CachedNetworkImage(
                          width: _commonHelper?.screenWidth,
                          imageUrl: _aList!.response!.coverImage.toString(),
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Container(color: SoloColor.waterBlue),
                        ),
                      ),
                      getCountryName() != 'null'
                          ? Padding(
                        padding: const EdgeInsets.only(top: 10, right: 5),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 110,
                               // color: Colors.red,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  IconsHelper.ic_locationPin,
                                  width:
                                  _commonHelper!.screenWidth * 0.06,
                                  fit: BoxFit.cover,
                                ),
                                Flexible(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      getCountryName(),
                                      textAlign: TextAlign.start,
                                      maxLines: 3,
                                      style: TextStyle(
                                          color: SoloColor.spanishGray,
                                          fontWeight: FontWeight.normal,
                                          fontSize: Constants.FONT_TOP),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          : Container(),
                    ],
                  ),
                  Container(
                    width: _commonHelper?.screenWidth,
                    padding: EdgeInsets.only(top: 2.5),
                    child: _appBar(),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: _commonHelper?.screenHeight * .14,
                        left: _commonHelper?.screenHeight * .013,
                        right: _commonHelper?.screenHeight * .013),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [profileImage(), profileInfoCard()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    ];

    return _randomChildren;
  }

  Widget profileInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_aList!.response!.fullName.toString(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: SoloStyle.darkBlackW700MaxTitle),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Visibility(
                  visible: _aList!.response!.statusTitle!.isNotEmpty,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${_aList?.response?.statusTitle?.toUpperCase()}",
                        style: TextStyle(
                            color: SoloColor.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: Constants.FONT_LOW),
                      ),
                      // Visibility(
                      //   visible: _aList!.response!.totalStatusPoint! > 100,
                      //   child: Container(
                      //     margin:
                      //         EdgeInsets.only(left: DimensHelper.halfSides),
                      //     child: Image.asset(
                      //         _aList!.response!.totalStatusPoint! > 200
                      //             ? "assets/images/ic_crown.png"
                      //             : _aList!.response!.totalStatusPoint! >
                      //                     100
                      //                 ? "assets/images/ic_cap.png"
                      //                 : "",
                      //         color: SoloColor.graniteGray,
                      //         height: 30),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            ],
          ),
          // getCountryName() != 'null'
          //     ? Row(
          //         mainAxisAlignment: MainAxisAlignment.end,
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Padding(
          //             padding: const EdgeInsets.symmetric(vertical: 2),
          //             child: Image.asset(
          //               IconsHelper.ic_locationPin,
          //               width: _commonHelper!.screenWidth * 0.05,
          //               fit: BoxFit.cover,
          //             ),
          //           ),
          //           Container(
          //             width: 100,
          //             child: Text(
          //               getCountryName(),
          //               textAlign: TextAlign.start,
          //               maxLines: 1,
          //               overflow: TextOverflow.ellipsis,
          //               style: TextStyle(
          //                   color: SoloColor.spanishGray,
          //                   fontWeight: FontWeight.normal,
          //                   fontSize: Constants.FONT_TOP),
          //             ),
          //           ),
          //         ],
          //       )
          //     : Container(),
        ],
      ),
    );
  }

  Country? getisoCodeByName(String name) {
    try {
      return countryDataList.firstWhere(
        (country) => country.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (error) {
      return null;
    }
  }

  Widget profileImage() {
    return Container(
      height: _commonHelper?.screenHeight * .12,
      width: _commonHelper?.screenHeight * .12,
      decoration:
          new BoxDecoration(shape: BoxShape.circle, color: SoloColor.white),
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: ClipOval(
            child: CachedNetworkImage(
                fit: BoxFit.cover,
                height: _commonHelper?.screenHeight * .1,
                width: _commonHelper?.screenHeight * .1,
                imageUrl: _aList!.response!.profilePic.toString(),
                placeholder: (context, url) => imagePlaceHolder(),
                errorWidget: (context, url, error) => imagePlaceHolder())),
      ),
    );
  }

  Widget selectGender() {
    return Container(
      width: _commonHelper?.screenWidth,
      height: _commonHelper?.screenHeight * 0.4,
      color: Colors.black.withOpacity(0.85),
      child: Container(
        alignment: Alignment.center,
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DimensHelper.sidesMargin)),
          elevation: 3.0,
          child: Container(
            width: _commonHelper?.screenWidth * .9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
                  height: 60,
                  width: 60,
                  child: Image.asset("images/ic_lg_bag.png"),
                ),
                Container(
                  margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
                  child: Text(
                    'Please choose your gender',
                    style: TextStyle(
                        color: SoloColor.spanishLightGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: Constants.FONT_TOP),
                  ),
                ),
                Container(
                  height: _commonHelper?.screenHeight * .06,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: maleCheckBox(),
                      ),
                      Expanded(
                        child: femaleCheckBox(),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSelectGenderShow = false;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(DimensHelper.sidesMargin),
                          width: _commonHelper?.screenWidth * .45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft:
                                    Radius.circular(DimensHelper.sidesMargin)),
                            color: SoloColor.pink,
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                                color: SoloColor.white,
                                fontWeight: FontWeight.normal,
                                fontSize: Constants.FONT_TOP),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            var body = json.encode({
                              "gender": _radioValue == 1 ? "female" : "male"
                            });

                            _onUpdateTap(body);
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(DimensHelper.sidesMargin),
                          width: _commonHelper?.screenWidth * .45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomRight:
                                    Radius.circular(DimensHelper.sidesMargin)),
                            color: SoloColor.blue,
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(
                                color: SoloColor.white,
                                fontWeight: FontWeight.normal,
                                fontSize: Constants.FONT_TOP),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget femaleCheckBox() {
    return RadioListTile<int>(
      title: Text('Female',
          style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.normal)),
      value: 1,
      activeColor: SoloColor.pink,
      groupValue: _radioValue,
      onChanged: _handleRadioValueChange,
    );
  }

  Widget maleCheckBox() {
    return RadioListTile<int>(
      title: Text('Male',
          style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.normal)),
      value: 0,
      activeColor: SoloColor.pink,
      groupValue: _radioValue,
      onChanged: _handleRadioValueChange,
    );
  }

// ** Post Widgets **//

  Widget photosCardDetail(int index) {
    return postList[index].type == Constants.PUBLIC_FEED_TYPE_IMAGE
        ? imageTypePublicFeed(index)
        : titleTypePublicFeed(index);
  }

  Widget imageTypePublicFeed(int index) {
    var likes = postList?[index].totalLikes == 0
        ? ""
        : " " + postList![index].totalLikes.toString();

    if (postList?[index].totalLikes == 0) {
      likes = "";
    } else if (postList?[index].totalLikes == 1) {
      likes = postList[index].totalLikes.toString();
      // + " Like";
    } else {
      likes = postList![index].totalLikes.toString();
      // + " Likes"
    }

    var comments;

    if (postList?[index].totalComments == 0) {
      comments = "";
    } else {
      var titleComment = postList?[index].totalComments == 1 ? "" : "";

      comments = '${postList![index].totalComments.toString()} ';
    }

    return FeedCardProfile(
      feedImageZoomOnTap: () async {
        print("images" + postList![index].image![0].toString());

        // ShowDialog.showFeedDialog(context,
        //     indexSearch: index, imgUrl: postList!, controller: _controller);
        //
        ShowDialog.showFeedDialog(
          context,
          indexPro: index,
          photoList: postList!,
          controller: _controller1,
          isHome: false,
        );

        // showDialog(
        //     barrierColor: SoloColor.black.withOpacity(0.9),
        //     context: context,
        //     builder: (_) =>
        //         imageDialog(context, imgUrl: postList!, indexSearch: index
        //             // _searchList![index].image![0].toString()
        //             ));
      },
      userProfile: userProfileList!.profilePic.toString(),
      userName: userProfileList.fullName.toString(),
      countDown:
          _commonHelper!.getTimeDifference(postList[index].insertDate ?? 0),
      moreTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return userProfileList?.userId == mineUserId
                  ? _showDeleteBottomSheet(
                      postList![index].publicFeedId.toString(), index)
                  : _showBottomSheet(userProfileList!.userId.toString(),
                      postList[index].publicFeedId.toString());
            });
      },
      feedImage: postList,
      indexForSearch: index,
      controller: _controller,
      likeImage: postList?[index].isLike == true
          ? IconsHelper.like
          : IconsHelper.unLike,
      likeCount: likes,
      likeOnTap: () {
        if (postList?[index].isLike == true) {
          setState(() {
            var totalLikes = postList?[index].totalLikes ?? 0 - 1;
            postList?[index].totalLikes = totalLikes;
            postList?[index].isLike = false;
          });

          _onUnLikeButtonTap(postList![index].publicFeedId.toString());
        } else {
          setState(() {
            var totalLikes = postList?[index].totalLikes ?? 0 + 1;
            postList?[index].totalLikes = totalLikes;
            postList?[index].isLike = true;
          });

          _onLikeButtonTap(postList![index].publicFeedId.toString());
        }
      },
      userLocation: "",
      showLikesOnTap: () {
        _commonHelper?.startActivity(
            FeedLikeActivity(postList![index].publicFeedId.toString()));
      },
      commentCount: comments,
      commentOnTap: () {
        _commonHelper?.startActivity(PublicFeedCommentActivity(
          publicFeedId: postList![index].publicFeedId.toString(),
          scrollMessage: false,
        ));
      },
      content: postList[index].title,
      feedTap: () {},
    );
  }

  Widget titleTypePublicFeed(int index) {
    var likes = postList?[index].totalLikes == 0
        ? ""
        : " " + postList![index].totalLikes.toString();

    if (postList?[index].totalLikes == 0) {
      likes = "";
    } else if (postList?[index].totalLikes == 1) {
      likes = postList![index].totalLikes.toString();
    } else {
      likes = postList![index].totalLikes.toString();
    }

    var comments;

    if (postList?[index].totalComments == 0) {
      comments = "Comment";
    } else {
      var titleComment = postList?[index].totalComments == 1 ? "Comment" : "";

      comments = '${postList![index].totalComments.toString()} $titleComment';
    }

    print(" api print:--- ${userProfileList.fullName.toString()}");
    return FeedCardProfile(
      reverseContent: true,
      userProfile: userProfileList!.profilePic.toString(),
      userName: userProfileList.fullName.toString(),
      userLocation: "",
      countDown:
          _commonHelper!.getTimeDifference(postList[index].insertDate ?? 0),
      moreTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return userProfileList?.userId == mineUserId
                  ? _showDeleteBottomSheet(
                      postList![index].publicFeedId.toString(), index)
                  : _showBottomSheet(userProfileList!.userId.toString(),
                      postList[index].publicFeedId.toString());
            });
      },
      indexForSearch: index,
      controller: _controller,
      likeImage: postList?[index].isLike == true
          ? IconsHelper.like
          : IconsHelper.unLike,
      likeCount: likes,
      likeOnTap: () {
        if (postList?[index].isLike == true) {
          setState(() {
            var totalLikes = postList?[index].totalLikes ?? 0 - 1;
            postList?[index].totalLikes = totalLikes;
            postList?[index].isLike = false;
          });

          _onUnLikeButtonTap(postList![index].publicFeedId.toString());
        } else {
          setState(() {
            var totalLikes = postList?[index].totalLikes ?? 0 + 1;
            postList?[index].totalLikes = totalLikes;
            postList?[index].isLike = true;
          });

          _onLikeButtonTap(postList![index].publicFeedId.toString());
        }
      },
      showLikesOnTap: () {
        _commonHelper?.startActivity(
            FeedLikeActivity(postList![index].publicFeedId.toString()));
      },
      commentCount: comments,
      commentOnTap: () {
        _commonHelper?.startActivity(PublicFeedCommentActivity(
          publicFeedId: postList![index].publicFeedId.toString(),
          scrollMessage: false,
        ));
      },
      content: postList[index].title,
      feedTap: () {},
    );
  }

  Widget _showDeleteBottomSheet(String publicFeedID, int index) {
    return CupertinoActionSheet(
      title: Text("Delete Post",
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("Are you sure you want to delete this post?",
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _deleteButtonTap(publicFeedID, index);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            "No",
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _showBottomSheet(String blockUserId, String publicFeedId) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text("Block",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) =>
                    _showBlockBottomSheet(blockUserId));
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            "Report",
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500),
          ),
          onPressed: () {
            Navigator.pop(context);

            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) =>
                    _showReportBottomSheet(publicFeedId));
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

  Widget _showBlockBottomSheet(String blockUserId) {
    return CupertinoActionSheet(
      title: Text("Block",
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("Are you sure you want to block this profile?",
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _onBlockUserTap(blockUserId);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            "No",
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _showReportBottomSheet(String publicFeedId) {
    return CupertinoActionSheet(
      title: Text("Report",
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("Are you sure you want to report this post?",
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _onReportPostTap(publicFeedId);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            "No",
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _successBottomSheet(String title, String msg) {
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
          },
        ),
      ],
    );
  }

  Widget _noPostWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text("No post Yet!",
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishLightGrey)));
  }

// ** Events Widgets **//

  Widget _eventsMainItem(int index) {
    var carnivalData = _aList?.myEventListProfile?[index];
    var _commonHelper = CommonHelper(context);
    return FeedCardEvent(
      padding: EdgeInsets.only(
        left: _commonHelper.screenWidth * 0.035,
        right: _commonHelper.screenWidth * 0.035,
        bottom: _commonHelper.screenHeight * 0.02,
        top: _commonHelper.screenHeight * 0.01,
      ),
      feedTap: () {
        _commonHelper.startActivity(EventsDetailsActivity(
          eventId: carnivalData?.eventId.toString(),
          refresh: false,
          context: this,
        ));
      },
      locationName: carnivalData?.locationName.toString() ?? "",
      carnivalsText: carnivalData?.title.toString() ?? "",
      userName: carnivalData?.title.toString() ?? "",
      userLocation: StringHelper.userLocation,
      imagePath: carnivalData?.image ?? "",
      carouselController: _controller,
      date:
          '${getFormattedDate(carnivalData?.startDate.toString() ?? "", false)} - ${getFormattedDate(carnivalData?.endDate.toString() ?? "", false)}',
      description: carnivalData?.carnivalTitle,
      countDown: _commonHelper.getTimeDifference(carnivalData?.insertDate ?? 0),
      content: carnivalData?.title ?? "",
    );
  }

  Widget _noEventsWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text("No Events Yet!",
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishLightGrey)));
  }

// ** Services Widgets **//

  Widget _servicesMainItem(int index) {
    var servicesData = _aList?.myServiceList?[index];
    var _commonHelper = CommonHelper(context);
    return FeedCardEvent(
      padding: EdgeInsets.only(
        left: _commonHelper.screenWidth * 0.035,
        right: _commonHelper.screenWidth * 0.035,
        top: _commonHelper.screenHeight * 0.01,
        bottom: _commonHelper.screenHeight * 0.02,
      ),
      feedTap: () {
        _commonHelper.startActivity(ServiceDetail(
          serviceId: servicesData?.serviceId.toString(),
          refresh: false,
          context: this,
        ));
      },
      carnivalsText: servicesData?.category.toString() ?? "",
      userProfile: servicesData?.image.toString() ?? "",
      userName: servicesData?.email ?? "",
      userLocation: StringHelper.userLocation,
      imagePath: servicesData?.image ?? "",
      carouselController: _controller,
      number: servicesData?.phoneNumber,
      countDown: _commonHelper.getTimeDifference(servicesData?.insertDate ?? 0),
      content: servicesData?.category.toString() ?? "",
    );
  }

  Widget _noServiceWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text("No Services Yet!",
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishLightGrey)));
  }

  // ** Groups Widgets **//

  Widget _groupsDetails(int index) {
    var groupData = _aList!.groupList?[index];
    var _commonHelper = CommonHelper(context);
    return listCard(context, index,
        countryTitle: groupData?.title!.toUpperCase() ?? "",
        image: groupData?.groupProfilePic.toString() ?? "", onAllTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GroupDetailsActivity(
                groupId: groupData?.groupId, groupTitle: groupData?.title)),
      );
    }, padding: EdgeInsets.only(top: 10.0), isWidth: true, isHeight: true);
  }

  Widget _noGroupWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text("No Groups joined Yet!",
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishLightGrey)));
  }

  Widget groupsHeader() {
    return Visibility(
      visible: _aList!.groupList!.isNotEmpty,
      child: Container(
        margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
        width: _commonHelper?.screenWidth,
        padding: EdgeInsets.all(DimensHelper.sidesMargin),
        color: SoloColor.waterBlue,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Groups",
                style: TextStyle(
                    fontSize: Constants.FONT_TOP, fontWeight: FontWeight.w700),
              ),
            ),
            Visibility(
              visible: _aList!.groupList!.isNotEmpty,
              child: GestureDetector(
                onTap: () => _commonHelper?.startActivity(
                    GroupInfoActivity(groupList: _aList?.groupList)),
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "See all",
                    style: TextStyle(
                        color: SoloColor.spanishLightGrey,
                        fontSize: Constants.FONT_MEDIUM,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget groupsDetailCard(GroupList groupList) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: DimensHelper.halfSides),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(DimensHelper.sidesMargin),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                GestureDetector(
                  onTap: () {
                    _commonHelper?.startActivity(GroupDetailsActivity(
                        groupId: groupList.groupId,
                        groupTitle: groupList.title));
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: DimensHelper.halfSides),
                    child: ClipOval(
                        child: CachedNetworkImage(
                      imageUrl: groupList.groupProfilePic.toString(),
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => imagePlaceHolder(),
                    )),
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: _commonHelper?.screenWidth * .5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(groupList.title.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.black,
                                      fontSize: Constants.FONT_TOP)),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: DimensHelper.smallSides),
                                  child: Text(
                                      "${groupList.totalSubscribers} subscribers",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: SoloColor.spanishLightGrey,
                                          fontSize: Constants.FONT_MEDIUM)))
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ** Competitions  Widgets **//

  Widget contestWonCard(ContestWon contestWon) {
    return Container(
      margin: EdgeInsets.only(
          left: DimensHelper.sidesMargin,
          right: DimensHelper.sidesMargin,
          bottom: DimensHelper.halfSides),
      decoration: BoxDecoration(
          color: SoloColor.lightYellow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SoloColor.graniteGray.withOpacity(0.2))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: SoloColor.white, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                        imageUrl: _aList!.response!.profilePic.toString(),
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => imagePlaceHolder(),
                        errorWidget: (context, url, error) =>
                            imagePlaceHolder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        padding: EdgeInsets.only(left: DimensHelper.halfSides),
                        child: Text(_aList!.response!.fullName!.toUpperCase(),
                            style: SoloStyle.blackBoldMediumRoboto),
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.all(DimensHelper.sidesMargin),
              child: RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Image.asset("assets/images/ic_queen.png",
                          height: 30, color: SoloColor.black),
                    ),
                    TextSpan(
                        text: contestWon.contestName == null
                            ? ""
                            : "  ${contestWon.contestName}",
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: SoloColor.spanishLightGrey,
                            fontSize: Constants.FONT_MEDIUM)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _noDataWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text("No Data Yet!",
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishLightGrey)));
  }

  // ** Other  Widgets **//

  Widget _noCarnivalWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text("No Upcoming Carnivals",
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishLightGrey)));
  }

  Tab _tabTitle(String content) {
    return Tab(
      child: Text(
        content,
        style: TextStyle(
          letterSpacing: 1,
        ),
      ),
    );
  }

//============================================================
// ** Helper Function **
//============================================================

  String getCountryName() {
    try {
      var array = _aList!.response!.locationName.toString().split(',');
      var country = _aList!.response!.locationName.toString().split(',').last;
      print("country$country");
      print("array$array");
      //  var name = CountryPickerUtils.getCountryByName(country.toString());
      //  print("codeData${name.isoCode.toString()}");
      var index = array.indexOf(country);
      return
        "${_aList!.response!.locationName.toString().split(',')[index - 1]}, ${code?.isoCode ?? country}";
    } catch (e) {
      return _aList!.response!.locationName.toString();
    }
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

  Future<void> requestPermission(Permission pPermission, bool status) async {
    var requestPermission = await pPermission.request();

    if (requestPermission.isGranted) {
      _progressShow = true;

      _pickImage(status);
    } else if (requestPermission.isDenied) {
      _asyncInputDialog(context, status);
    } else if (requestPermission.isRestricted) {
      _asyncInputDialog(context, status);
    }
  }

  Future<Null> _cropImage(imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressQuality: 30,
        cropStyle: isCoverImage ? CropStyle.rectangle : CropStyle.circle,
        aspectRatioPresets: Platform.isAndroid
            ? [CropAspectRatioPreset.square]
            : [CropAspectRatioPreset.square],
        aspectRatio: isCoverImage
            ? CropAspectRatio(ratioX: 1, ratioY: 1)
            : CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: isCoverImage ? 'Cover Pic' : 'Profile Pic',
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

        var imageKey = isCoverImage ? "coverImage" : "profilePic";

        var body = json.encode({imageKey: imageModel.data!.url});

        _onUpdateTap(body);
      }).catchError((onError) {
        _hideProgress();
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
                  ? Text("Allow Solomas to take pictures and record video?")
                  : Text(
                      "Allow Solomas to access photos, media and files on your device?")),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: SoloColor.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Settings', style: TextStyle(color: SoloColor.blue)),
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

  Future<Null> _pickImage(isCamera) async {
    var pickedFile = isCamera
        ? await _imagePicker.pickImage(source: ImageSource.camera)
        : await _imagePicker.pickImage(source: ImageSource.gallery);

    _profileImage = File(pickedFile!.path);

    if (_profileImage == null) {
      _hideProgress();
    }

    if (_profileImage != null) {
      setState(() {
        _progressShow = false;

        _cropImage(_profileImage);
      });
    }
  }

  void _onUpdateTap(String reqBody) {
    isCoverImage = true;

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _updateUserBloc
            ?.updateUser(authToken.toString(), reqBody)
            .then((onValue) {
          if (!isCoverImage) {
            Map mapData = json.decode(reqBody);

            PrefHelper.setUserProfilePic(mapData['profilePic']);
          }
          isRefresh = true;
          _aList = null;
          _getUserData();
          Navigator.pop(context);
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _getUserData() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          print("apihello" + authToken.toString());
          _userProfileBloc
              ?.getUserProfileData(token.toString(), "")
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

  void _deleteButtonTap(String feedId, int index) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _homeActivityBloc
            ?.deleteFeed(authToken.toString(), feedId)
            .then((onValue) {
          _hideProgress();

          postList?.removeAt(index);

          if (postList!.isEmpty) {
            _commonHelper?.closeActivity();
          }

          _commonHelper?.showToast("Public feed deleted successfully");
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onBlockUserTap(String blockUserId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "blockUserId": blockUserId,
        });

        _apiHelper?.blockUser(body, authToken.toString()).then((onValue) {
          _hideProgress();

          BlockUserModel _blockModel = onValue;

          if (_blockModel.statusCode == 200) {
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _commonHelper!
                    .successBottomSheet(
                        "Success", "User Blocked Successfully", true));
          }
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onUnLikeButtonTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var unLikeBody = json.encode({
          "publicFeedId": feedId,
        });

        _homeActivityBloc?.unLikeFeed(unLikeBody, authToken.toString());
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onLikeButtonTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var likeBody = json.encode({
          "publicFeedId": feedId,
        });

        _homeActivityBloc?.likeFeed(likeBody, authToken.toString());
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onReportPostTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "feedId": feedId,
          "feedType": "publicFeed",
        });

        _apiHelper?.reportFeed(body, authToken.toString()).then((onValue) {
          _hideProgress();

          ReportFeedModel _reportModel = onValue;

          if (_reportModel.statusCode == 200)
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _successBottomSheet(
                    "Success", "Post Reported Successfully"));
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _handleRadioValueChange(int? value) {
    setState(() {
      _radioValue = value ?? 0;
    });
  }

  Future<bool> _willPopCallback() async {
    Navigator.pop(context, isRefresh);
    return false;
  }

  String getFormattedDate(String startDate, bool isStartDate) {
    var inputFormat = DateFormat('MM/dd/yyyy');
    var inputDate = inputFormat.parse(startDate); // <-- dd/MM 24H format

    var outputFormat = DateFormat(isStartDate ? 'dd MMM yyyy' : 'dd MMM yyyy');
    var outputDate = outputFormat.format(inputDate);
    print(outputDate); // 12/31/2000 11:59 PM <-- MM/dd 12H format
    return outputDate;
  }

//============================================================
// ** Firebase Function **
//============================================================
}
