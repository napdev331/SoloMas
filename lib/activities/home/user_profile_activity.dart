import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:solomas/activities/bottom_tabs/explore/group/group_detail_activity.dart';
import 'package:solomas/activities/chat/chat_activity.dart';
import 'package:solomas/activities/events/my_event_details.dart';
import 'package:solomas/activities/events/view_events_details.dart';
import 'package:solomas/activities/home/carnival_detail_activity.dart';
import 'package:solomas/activities/services/my_services_details.dart';
import 'package:solomas/activities/services/view_service_detail.dart';
import 'package:solomas/blocs/home/user_profile_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/block_user_model.dart';
import 'package:solomas/model/report_feed_model.dart';
import 'package:solomas/model/user_profile_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../blocs/home/home_bloc.dart';
import '../../helpers/show_dialog.dart';
import '../../model/country.dart';
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
import '../common_helpers/read_more_text.dart';
import 'feed_comments_activity.dart';
import 'feed_likes_activity.dart';

class UserProfileActivity extends StatefulWidget {
  final String userId;
  final String id;

  UserProfileActivity({this.userId = "", this.id = ""});

  @override
  State<StatefulWidget> createState() {
    return _NewProfileState();
  }
}

class _NewProfileState extends State<UserProfileActivity> {
//============================================================
// ** Properties **
//============================================================

  UserProfileBloc? _userProfileBloc;

  CommonHelper? _commonHelper;
  Country? code;
  String? authToken, mineUserId;
  var userProfileList;
  Data? _aList;
  var postList;
  final CarouselController _controller = CarouselController();
  ApiHelper? _apiHelper;
  late List<Widget> _randomChildren;
  bool _isShowProgress = false;
  var carnival_list;
  HomeBloc? _homeActivityBloc;
  final CarouselController _controller1 = CarouselController();

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();

    _apiHelper = ApiHelper();
    _homeActivityBloc = HomeBloc();
    _userProfileBloc = UserProfileBloc();
    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _getUserData());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SoloScaffold(
        body: DefaultTabController(
          length: 6,
          child: StreamBuilder(
              stream: _userProfileBloc?.userProfileList,
              builder: (context, AsyncSnapshot<UserProfileModel> snapshot) {
                if (snapshot.hasData) {
                  if (_aList == null) {
                    _aList = snapshot.data?.data;
                  }
                  return _mainItem();
                } else if (snapshot.hasError) {
                  return _mainItem();
                }

                return Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(SoloColor.blue)));
              }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userProfileBloc?.dispose();

    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================
  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.backWithReportIcon,
      onTapMore: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => showBlockBottomSheet());
      },
    );
  }

  Widget _mainItem() {
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
        body: Column(
          children: [
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
                  _groupTab(),
                  _competitionsTab()
                ],
              ),
            ),
            // Stack(children: [
            //   ListView(
            //     children: [
            //       // topView(),
            // upcomingCarnival(),
            //       upcomingEvents(),
            //       services(),
            //       _aList!.myServiceList!.isEmpty
            //           ? _noServicesWarning()
            //           : servicesDetail(_aList?.myServiceList ?? []),
            //       myEvents(),
            //       _aList!.myEventList!.isEmpty
            //           ? _noEventsWarning()
            //           : myEventsDetail(_aList?.myEventList ?? []),
            //       photos(),
            //       _aList!.photo!.isEmpty
            //           ? _noPhotoAvailableWarning()
            //           : ListView.builder(
            //               shrinkWrap: true,
            //               physics: ScrollPhysics(),
            //               itemCount: 1,
            //               itemBuilder: (BuildContext context, int index) {
            //                 return photosCardDetail();
            //               }),
            //       groupsHeader(),
            //       groupListBuilder(),
            //       contestHeader(),
            //       _aList!.contestWon!.isNotEmpty
            //           ? Container(
            //               margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
            //               height: 100,
            //               child: ListView.builder(
            //                   itemCount: _aList?.contestWon?.length,
            //                   scrollDirection: Axis.horizontal,
            //                   itemBuilder: (BuildContext context, int index) {
            //                     return contestWonCard(_aList!.contestWon![index]);
            //                   }),
            //             )
            //           : _noContestWarning()
            //     ],
            //   ),
            //   Align(
            //     child: ProgressBarIndicator(
            //         _commonHelper?.screenSize, _isShowProgress),
            //     alignment: FractionalOffset.center,
            //   )
            // ]),
          ],
        ),
      ),
    );
  }
//============================================================
// ** Helper Widgets **
//============================================================

// ** Profile Widgets **//
  List<Widget> _sliverWidgets(BuildContext context) {
    _randomChildren = [
      SizedBox(
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
                                  alignment: Alignment.centerRight,
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
                  child: _appBar(context),
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
      )
    ];

    return _randomChildren;
  }

  Widget profileInfoCard() {
    var country = _aList!.response!.locationName.toString().split(',').last;
    print("country$country");
    code = getisoCodeByName(country.toString().trim());
    print("codeDaswddf$code");
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
      carnivalsText: carnivalData?.carnivalTitle.toString() ?? "",
      userName: carnivalData?.title.toString() ?? "",
      userLocation: StringHelper.userLocation,
      imagePath: carnivalData?.image ?? "",
      carouselController: _controller,
      date:
          '${getFormattedDate(carnivalData?.startDate.toString() ?? "", false)} - ${getFormattedDate(carnivalData?.endDate.toString() ?? "", false)}',
      description: carnivalData?.description,
      countDown: _commonHelper.getTimeDifference(carnivalData?.insertDate ?? 0),
      content: carnivalData?.title.toString() ?? "",
    );
  }

  Widget myEvents() {
    return Container(
      width: _commonHelper?.screenWidth,
      padding: EdgeInsets.all(DimensHelper.sidesMargin),
      color: SoloColor.waterBlue,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Events",
              style: TextStyle(
                  fontSize: Constants.FONT_TOP, fontWeight: FontWeight.w700),
            ),
          ),
          Visibility(
            visible: _aList!.myEventList!.isNotEmpty,
            child: GestureDetector(
              onTap: () => _commonHelper?.startActivity(MyEventActivity(
                  upcomingCarnival: _aList?.myEventList, isFrom: true)),
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  StringHelper.seeAll,
                  style: TextStyle(
                      color: SoloColor.spanishGray,
                      fontSize: Constants.FONT_MEDIUM,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget services() {
    return Container(
      width: _commonHelper?.screenWidth,
      padding: EdgeInsets.all(DimensHelper.sidesMargin),
      color: SoloColor.waterBlue,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Services",
              style: TextStyle(
                  fontSize: Constants.FONT_TOP, fontWeight: FontWeight.w700),
            ),
          ),
          Visibility(
            visible: _aList!.myServiceList!.isNotEmpty,
            child: GestureDetector(
              onTap: () => _commonHelper?.startActivity(
                  MyServicesActivity(upcomingCarnival: _aList?.myServiceList)),
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "See all",
                  style: TextStyle(
                      color: SoloColor.spanishGray,
                      fontSize: Constants.FONT_MEDIUM,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget servicesDetail(List<MyServiceList> myServiceList) {
    if (myServiceList.isEmpty) {
      return Container();
    }

    var carnivalData = myServiceList[0];

    return GestureDetector(
      onTap: () {
        _commonHelper?.startActivity(ServiceDetail(
          serviceId: carnivalData.serviceId,
          refresh: false,
          context: this,
        ));
      },
      child: Container(
        padding: EdgeInsets.only(
          left: DimensHelper.sidesMargin,
          right: DimensHelper.sidesMargin,
          top: DimensHelper.sidesMargin,
          bottom: DimensHelper.sidesMargin,
        ),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero)),
          elevation: DimensHelper.tinySides,
          child: Row(
            children: [
              Container(
                height: _commonHelper?.screenHeight * .188,
                width: _commonHelper?.screenWidth * .44,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: carnivalData.image.toString(),
                  placeholder: (context, url) => imagePlaceHolder(),
                  errorWidget: (context, url, error) => imagePlaceHolder(),
                ),
              ),
              Container(
                height: 150,
                padding: EdgeInsets.all(DimensHelper.halfSides),
                width: _commonHelper?.screenWidth * .44,
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Text(carnivalData.businessName.toString(),
                        style: TextStyle(
                            fontSize: Constants.FONT_TOP,
                            color: SoloColor.blue,
                            fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsets.only(top: DimensHelper.smallSides),
                      child: Text(
                          carnivalData.category.toString()
                          /* _commonHelper
                                    .getCarnivalDate(carnivalData.startDate) +
                                " to " +
                                _commonHelper
                                    .getCarnivalDate(carnivalData.endDate)*/
                          ,
                          style: TextStyle(
                              fontSize: Constants.FONT_LOW,
                              color: SoloColor.spanishGray,
                              fontWeight: FontWeight.w500)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: DimensHelper.smallSides),
                      child: Text(carnivalData.email.toString(),
                          style: TextStyle(
                              fontSize: Constants.FONT_MEDIUM,
                              color: SoloColor.spanishGray,
                              fontWeight: FontWeight.w500)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: DimensHelper.smallSides),
                      child: Text(carnivalData.phoneNumber.toString(),
                          style: TextStyle(
                              fontSize: Constants.FONT_MEDIUM,
                              color: SoloColor.spanishGray,
                              fontWeight: FontWeight.w500),
                          maxLines: 3),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget myEventsDetail(List<MyEventList> myEventList) {
    if (myEventList.isEmpty) {
      return Container();
    }

    var carnivalData = myEventList[0];

    return GestureDetector(
      onTap: () {
        _commonHelper?.startActivity(EventsDetailsActivity(
          eventId: carnivalData.eventId,
          refresh: false,
          context: this,
        ));
      },
      child: Container(
        padding: EdgeInsets.only(
            left: DimensHelper.sidesMargin,
            right: DimensHelper.sidesMargin,
            top: DimensHelper.sidesMargin,
            bottom: DimensHelper.sidesMargin),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero)),
          elevation: DimensHelper.tinySides,
          child: Row(
            children: [
              Container(
                height: _commonHelper?.screenHeight * .188,
                width: _commonHelper?.screenWidth * .44,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: carnivalData.image.toString(),
                  placeholder: (context, url) => imagePlaceHolder(),
                  errorWidget: (context, url, error) => imagePlaceHolder(),
                ),
              ),
              Container(
                height: 150,
                padding: EdgeInsets.all(DimensHelper.halfSides),
                width: _commonHelper?.screenWidth * .44,
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    /*  Text(carnivalData.title,
                        style: TextStyle(
                            fontSize: Constants.FONT_TOP,
                            color: ColorsHelper.colorBlue,
                            fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsets.only(top: DimensHelper.smallSides),
                      child: Text(
                          carnivalData.category
                          */ /*_commonHelper
                                    .getCarnivalDate(carnivalData.startDate) +
                                " to " +
                                _commonHelper
                                    .getCarnivalDate(carnivalData.endDate)*/ /*
                          ,
                          style: TextStyle(
                              fontSize: Constants.FONT_LOW,
                              color: ColorsHelper.colorGrey,
                              fontWeight: FontWeight.w500)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: DimensHelper.smallSides),
                      child: Text(carnivalData.description,
                          style: TextStyle(
                              fontSize: Constants.FONT_MEDIUM,
                              color: ColorsHelper.colorGrey,
                              fontWeight: FontWeight.w500)),
                    ),*/

                    Text(carnivalData.title.toString(),
                        style: TextStyle(
                            fontSize: Constants.FONT_TOP,
                            color: SoloColor.blue,
                            fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsets.only(top: DimensHelper.smallSides),
                      child: Text(
                          _commonHelper!.getCarnivalDate(
                                  carnivalData.startEpoch ?? 0) +
                              " to " +
                              _commonHelper!
                                  .getCarnivalDate(carnivalData.endEpoch ?? 0),
                          style: TextStyle(
                              fontSize: Constants.FONT_LOW,
                              color: SoloColor.spanishGray,
                              fontWeight: FontWeight.w500)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: DimensHelper.smallSides),
                      child: Text(
                          carnivalData.carnivalTitle == null
                              ? ""
                              : carnivalData.carnivalTitle.toString(),
                          style: TextStyle(
                              fontSize: Constants.FONT_MEDIUM,
                              color: SoloColor.spanishGray,
                              fontWeight: FontWeight.w500)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: DimensHelper.smallSides),
                      child: Text(carnivalData.locationName.toString(),
                          style: TextStyle(
                              fontSize: Constants.FONT_MEDIUM,
                              color: SoloColor.spanishGray,
                              fontWeight: FontWeight.w500),
                          maxLines: 3),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
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

//============================================================
// ** Tab Widget **

//============================================================
  Widget _postTab() {
    postList = _aList?.photo ?? [];
    var userProfileList = _aList?.response as Response;
    if (_aList!.photo!.isNotEmpty) {
      return Container(
        padding: EdgeInsets.only(top: 0),
        child: ListView.builder(
            itemCount: postList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: photosCardDetail(index),
              );
            }),
      );
    } else {
      return _noDataFoundWarning(StringHelper.NoPost);
    }
  }

  Widget _eventsTab() {
    return _aList!.myEventListProfile!.isNotEmpty
        ? ListView.builder(
            itemCount: _aList?.myEventListProfile?.length,
            itemBuilder: (BuildContext context, int index) {
              return _eventsMainItem(index);
            })
        : _noDataFoundWarning(StringHelper.noEventsYet);
  }

  Widget _carnivalsTab() {
    carnival_list = _aList?.upcomingCarnival ?? [];
    var userProfileList = _aList?.response as Response;
    if (_aList!.upcomingCarnival!.isEmpty ||
        _aList!.upcomingCarnival![0].carnivalData!.isEmpty) {
      return _noDataFoundWarning(StringHelper.noUpComingCarnivals);
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
                      carnivalData: carnival_list?[index].carnivalData?[0],
                      carnivalsInfo:
                          carnival_list?[index].carnivalData?[0].userBand));
            }),
      );
    }
  }

  Widget _serviceTab() {
    return _aList!.myServiceList!.isNotEmpty
        ? ListView.builder(
            itemCount: _aList?.myServiceList?.length,
            itemBuilder: (BuildContext context, int index) {
              return _servicesMainItem(index);
            })
        : _noDataFoundWarning(StringHelper.noServiceYet);
  }
  // ** Groups Widgets **//

  Widget _groupTab() {
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
                  maxCrossAxisExtent: _commonHelper.screenWidth * 0.5,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3 / 3,
                ),
                itemCount: _aList!.groupList!.length,
                itemBuilder: (BuildContext context, int index) {
                  return _groupsDetails(index);
                  // return _cardContinent(index);
                }),
          )
        : _noDataFoundWarning(StringHelper.noGroupYet);
  }

  Widget _groupsDetails(int index) {
    var groupData = _aList!.groupList?[index];
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
      carnivalsText: servicesData?.carnivalTitle.toString() ?? "",
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

  Widget _noDataFoundWarning(String msg) {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text(msg,
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishLightGrey)));
  }

  // ** Post Widgets **//
  Widget photosCardDetail(int index) {
    return postList[index].type == Constants.PUBLIC_FEED_TYPE_IMAGE
        ? imageTypePublicFeed(index)
        : titleTypePublicFeed(index);
  }

  Widget imageDialog(context, {imgUrl}) {
    return Dialog(
      child: Container(
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          height: _commonHelper?.screenHeight * .45,
          imageUrl: imgUrl,
          errorWidget: (context, url, error) => Image.asset(
            IconsHelper.profile_icon,
            width: _commonHelper?.screenHeight * .13,
            height: _commonHelper?.screenHeight * .13,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
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
      userProfile: _aList!.response!.profilePic.toString(),
      feedImageZoomOnTap: () async {
        print("images" + postList![index].image![0].toString());

        ShowDialog.showFeedDialog(
          context,
          indexPro: index,
          photoList: postList!,
          controller: _controller1,
          isHome: false,
        );

        // await showDialog(
        //     barrierColor: SoloColor.black.withOpacity(0.9),
        //     context: context,
        //     builder: (_) => imageDialog(context,
        //         imgUrl: postList![index].image![0].toString()));
      },
      userName: _aList!.response!.fullName.toString(),

      countDown:
          _commonHelper!.getTimeDifference(postList[index].insertDate ?? 0),
      // _commonHelper!.getTimeDifference(post_list[index].insertDate ?? 0),
      moreTap: () {
        print("tap on the more");
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return _aList!.response!.userId == mineUserId
                  ? _showDeleteBottomSheet(
                      postList![index].publicFeedId.toString(), index)
                  : _showBottomSheet(_aList!.response!.userId.toString(),
                      postList[index].publicFeedId.toString());
            });

        // showCupertinoModalPopup(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return userprofilelist?.userId == mineUserId
        //           ? _showDeleteBottomSheet(
        //           post_list![index].publicFeedId.toString(), index)
        //           : _showBottomSheet(userprofilelist!.userId.toString(),
        //           post_list[index].publicFeedId.toString());
        //     });
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

          // _onUnLikeButtonTap(post_list![index].publicFeedId.toString());
        } else {
          setState(() {
            var totalLikes = postList?[index].totalLikes ?? 0 + 1;
            postList?[index].totalLikes = totalLikes;
            postList?[index].isLike = true;
          });

          // _onLikeButtonTap(post_list![index].publicFeedId.toString());
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
      likes = postList![index].totalLikes.toString()
          // " +Like"
          ;
    } else {
      likes = postList![index].totalLikes.toString()

          // " Likes"
          ;
    }

    var comments;

    if (postList?[index].totalComments == 0) {
      comments = "Comment";
    } else {
      var titleComment = postList?[index].totalComments == 1 ? "Comment" : "";

      comments = '${postList![index].totalComments.toString()} $titleComment';
    }

    return FeedCardProfile(
      userProfile: _aList!.response!.profilePic.toString(),
      userName: _aList!.response!.fullName.toString(),
      countDown:
          _commonHelper!.getTimeDifference(postList[index].insertDate ?? 0),
      userLocation: "",
      reverseContent: true,
      moreTap: () {
        print("tap on the more");
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return _aList!.response!.userId == mineUserId
                  ? _showDeleteBottomSheet(
                      postList![index].publicFeedId.toString(), index)
                  : _showBottomSheet(_aList!.response!.userId.toString(),
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

          // _onUnLikeButtonTap(post_list![index].publicFeedId.toString());
        } else {
          setState(() {
            var totalLikes = postList?[index].totalLikes ?? 0 + 1;
            postList?[index].totalLikes = totalLikes;
            postList?[index].isLike = true;
          });
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
      title: Text(StringHelper.deletePost,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.areYouSureWantToDelete,
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes,
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
            StringHelper.no,
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

  Widget _showBlockBottomSheet(String blockUserId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.block,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.blockProfileMsg,
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
      title: Text(StringHelper.report,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.areYouSureWantToReport,
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes,
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
            StringHelper.no,
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
          child: Text(StringHelper.block,
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
            StringHelper.report,
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

  Widget carnivalDetail(UpcomingCarnival upcomingCarnival) {
    if (upcomingCarnival.carnivalData!.isEmpty) {
      return Container();
    }

    var carnivalData = upcomingCarnival.carnivalData?[0];

    return GestureDetector(
      onTap: () {
        _commonHelper?.startActivity(
            CarnivalDetailActivity(carnivalId: carnivalData?.sId));
      },
      child: Container(
        padding: EdgeInsets.only(
            left: DimensHelper.sidesMargin,
            right: DimensHelper.sidesMargin,
            bottom: DimensHelper.sidesMargin),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero)),
          elevation: DimensHelper.tinySides,
          child: Row(
            children: [
              Container(
                height: _commonHelper?.screenHeight * .188,
                width: _commonHelper?.screenWidth * .44,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: carnivalData!.coverImageUrl.toString(),
                  placeholder: (context, url) => imagePlaceHolder(),
                  errorWidget: (context, url, error) => imagePlaceHolder(),
                ),
              ),
              Container(
                height: 150,
                padding: EdgeInsets.all(DimensHelper.halfSides),
                width: _commonHelper?.screenWidth * .44,
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Text(carnivalData.title.toString(),
                        style: TextStyle(
                            fontSize: Constants.FONT_TOP,
                            color: SoloColor.blue,
                            fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsets.only(top: DimensHelper.smallSides),
                      child: Text(
                          _commonHelper!.getCarnivalDate(
                                  carnivalData.startDate ?? 0) +
                              " to " +
                              _commonHelper!
                                  .getCarnivalDate(carnivalData.endDate ?? 0),
                          style: TextStyle(
                              fontSize: Constants.FONT_LOW,
                              color: SoloColor.spanishGray,
                              fontWeight: FontWeight.w500)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: DimensHelper.smallSides),
                      child: Text(_aList?.response?.band ?? '',
                          style: TextStyle(
                              fontSize: Constants.FONT_MEDIUM,
                              color: SoloColor.spanishGray,
                              fontWeight: FontWeight.w500)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: DimensHelper.smallSides),
                      child: Text(carnivalData.locationName.toString(),
                          style: TextStyle(
                              fontSize: Constants.FONT_MEDIUM,
                              color: SoloColor.spanishGray,
                              fontWeight: FontWeight.w500),
                          maxLines: 3),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget carnivalItemCard(int index, carnivalData) {
    // var carnivalData = carnival_list?[index].carnivalData?[0];

    return InkWell(
      onTap: () {
        _commonHelper!.startActivity(
            CarnivalDetailActivity(carnivalId: carnivalData?.sId));
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: _commonHelper?.screenWidth * 0.035,
          right: _commonHelper?.screenWidth * 0.035,
          top: _commonHelper?.screenHeight * 0.02,
        ),
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: SoloColor.spanishGray.withOpacity(0.6),
              blurRadius: 3,
              spreadRadius: 0.5,
            ),
          ], color: SoloColor.white, borderRadius: BorderRadius.circular(20)),
          width: _commonHelper?.screenWidth,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    carnivalData.title.toString(),
                    style: SoloStyle.black54W500SmallMax,
                  ),
                  Text(
                    carnivalData.locationName.toString(),
                    style: SoloStyle.lightGrey200W600MediumXs,
                  )
                ],
              ),
            ),
            carnivalData!.coverImageUrl.toString() != null
                ? Stack(
                    children: [
                      Container(
                        height: _commonHelper!.screenHeight * 0.3,
                        width: _commonHelper!.screenWidth,
                        child: ClipRRect(
                          child: CachedNetworkImage(
                              imageUrl: carnivalData!.coverImageUrl.toString(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => imagePlaceHolder(),
                              errorWidget: (context, url, error) =>
                                  imagePlaceHolder()),
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.only(
                  right: 10, left: 15, bottom: 15, top: 10),
              child: Container(
                  width: _commonHelper!.screenWidth,
                  child: ReadMoreText(
                    carnivalData.description.toString() ?? " ",
                    //StringHelper.dummyHomeText,
                    trimLines: 2,
                    style: SoloStyle.lightGrey200W500SmallMax,
                    colorClickableText: SoloColor.black,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: StringHelper.readMore,
                    trimExpandedText: StringHelper.readLess,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Image.asset(
                    IconsHelper.ic_calender,
                    width: _commonHelper!.screenWidth * 0.05,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: DimensHelper.mediumSides,
                        right: DimensHelper.mediumSides),
                    child: Text(
                      _commonHelper!
                              .getCarnivalDate(carnivalData.startDate ?? 0) +
                          " to " +
                          _commonHelper!
                              .getCarnivalDate(carnivalData.endDate ?? 0),
                      style: SoloStyle.darkBlackW70015Rob,
                    ),
                  ),
                ],
              ),
            ),
            Column(children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [],
                    ),
                    // Text(
                    //   widget.countDown ?? "",
                    // )
                  ],
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget showBlockBottomSheet() {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text("Chat",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _commonHelper?.startActivity(ChatActivity(
              _aList!.response!.fullName.toString(),
              _aList!.response!.userId.toString(),
              _aList!.response!.profilePic.toString(),
            ));
          },
        ),
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
                    showBlockBottomSheetOtherUser());
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
                    _showReportBottomSheetForOtherUser());
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

  Widget showBlockBottomSheetOtherUser() {
    return CupertinoActionSheet(
      title: Text("Block",
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("Are you sure you want to block this profile?",
          style: TextStyle(
              color: SoloColor.brightGray,
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

            _onBlockUserTapMethod();
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
        child: Text("No Wins Yet!",
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishLightGrey)));
  }

  Widget _showReportBottomSheetForOtherUser() {
    return CupertinoActionSheet(
      title: Text("Report",
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("Are you sure you want to report this post?",
          style: TextStyle(
              color: SoloColor.graniteGray,
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

            _onReportPostTapForOtherUser();
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

  Tab _tabTitle(String content) {
    return Tab(
      child: Text(
        content,
        style: TextStyle(
          letterSpacing: 0,
        ),
      ),
    );
  }

//============================================================
// ** Helper Functions **
//============================================================
  String getCountryName() {
    try {
      var array = _aList!.response!.locationName.toString().split(',');
      var country = _aList!.response!.locationName.toString().split(',').last;
      var index = array.indexOf(country);
      return "${_aList!.response!.locationName.toString().split(',')[index - 1]}, ${code?.isoCode ?? country} ";
    } catch (e) {
      return _aList!.response!.locationName.toString();
    }
  }

  String getFormattedDate(String startDate, bool isStartDate) {
    var inputFormat = DateFormat('MM/dd/yyyy');
    var inputDate = inputFormat.parse(startDate); // <-- dd/MM 24H format

    var outputFormat = DateFormat(isStartDate ? 'dd MMM yyyy' : 'dd MMM yyyy');
    var outputDate = outputFormat.format(inputDate);
    print(outputDate); // 12/31/2000 11:59 PM <-- MM/dd 12H format
    return outputDate;
  }

  Future<bool> _willPopCallback() async {
    Navigator.pop(context);

    return false;
  }

  void _onReportPostTapForOtherUser() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "feedId": _aList?.response?.userId,
          "feedType": "profile",
        });

        _apiHelper?.reportFeed(body, authToken.toString()).then((onValue) {
          _hideProgress();

          ReportFeedModel _reportModel = onValue;

          if (_reportModel.statusCode == 200)
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _successBottomSheet(
                    "Success", "Profile Reported Successfully"));
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onBlockUserTapMethod() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "blockUserId": _aList?.response?.userId,
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

          _commonHelper?.showToast(StringHelper.publicFeedDeletedSuccessfully);
        }).catchError((onError) {
          _hideProgress();
        });
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
                    StringHelper.success, "Post Reported Successfully"));
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
          if (widget.id == '') {
            _userProfileBloc?.getUserProfileData(
                token.toString(), widget.userId);
          } else {
            _userProfileBloc?.getUserProfileData(token.toString(), widget.id);
          }
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _showProgress() {
    setState(() {
      _isShowProgress = true;
    });
  }

  void _hideProgress() {
    setState(() {
      _isShowProgress = false;
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
                    .successBottomSheet(StringHelper.success,
                        StringHelper.UserBlockedSuccessfully, true));
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
}

//============================================================
// ** Firebase Function **
//============================================================
