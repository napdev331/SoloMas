import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:solomas/activities/bottom_tabs/events_tab.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/events/add_event.dart';
import 'package:solomas/activities/events/view_events_details.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/blocs/event_details/event_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/events_response.dart';
import 'package:solomas/model/report_feed_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/space.dart';
import '../../model/get_events_category.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';
import '../services/search_autocomplete.dart';
import 'events_likes_activity.dart';

class NewEvents extends StatefulWidget {
  final String? eventContinent;

  const NewEvents({
    key,
    this.eventContinent,
  }) : super(key: key);

  @override
  NewEventsState createState() => NewEventsState();
}

class NewEventsState extends State<NewEvents> implements RefreshData {
//============================================================
// ** Properties **
//============================================================

  int isSelected = 0;

  _isSelected(int index) {
    setState(() {
      isSelected = index;
    });
  }

  late List<Widget> _randomChildren;
  CommonHelper? _commonHelper;
  ApiHelper? _apiHelper;
  EventBloc? _eventBloc;
  List<EventList> aList = [];
  List<EventList> searchList = [];
  List<EventCategoryList>? eventCategory;
  final CarouselController _controller = CarouselController();
  String locationValue = "";
  var _addressController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Timer? debounce;
  bool showLocation = false;
  bool isLocation = false;
  var lastInputValue = "";
  var selectedValue = 'Band Launch';
  var lat, lng;
  var _progressShow = false;
  String? authToken, mineUserId = "", mineProfilePic = "";
  Future<Null> _refresh() async {
    _showProgress();
    aList.clear();
    searchList.clear();
    getEvents("", "", "", widget.eventContinent.toString());
  }

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    eventCategory = [];
    _apiHelper = ApiHelper();
    _eventBloc = EventBloc();
    PrefHelper.getUserId().then((token) {
      setState(() {
        mineUserId = token;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getEvents("", "", "", widget.eventContinent.toString());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getEventCategory();
    });
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SafeArea(
      child: SoloScaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            child: _appBar(context),
          ),
        ),
        body: _mainBody(),
      ),
    );
  }

  @override
  void dispose() {
    _eventBloc?.dispose();

    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================
  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.addNavigationAppBar,
      addOnTap: () {
        _addressController.text = "";
        _commonHelper?.startActivity(AddEvent(
          isFrom: false,
          context: this,
        ));
      },
      navigationOnTap: () {
        _hideKeyBoard();
        Navigator.push(context,
                MaterialPageRoute(builder: (context) => SearchPlaces()))
            .then((value) {
          _hideKeyBoard();

          if (value != null) {
            isLocation = true;
            lat = value.lat;
            lng = value.lng;
            _addressController.text = value.placeName.toString();
            showLocation = true;
            locationValue = value.placeName.toString();
            print(value);
            aList.clear();
            searchList.clear();
            getEvents(
              lastInputValue == null ? "" : lastInputValue,
              lat.toString(),
              lng.toString(),
              widget.eventContinent.toString(),
            );
            // locationDetail = value;

            //         _addressController.text = locationDetail['locationName'];
          }
        });
      },
      onSearchBarTextChanged: _onSearchTextChanged,
    );
  }

  Widget _mainBody() {
    return StreamBuilder(
        stream: _eventBloc?.eventList,
        builder: (context, AsyncSnapshot<EventResponse> snapshot) {
          if (snapshot.hasData) {
            if (aList.isEmpty) {
              aList = snapshot.data?.data?.eventList ?? [];
              var listValue =
                  aList.where((element) => element.category == selectedValue);
              searchList.addAll(listValue);
              // searchList.addAll(aList);
            } else if (aList.length != snapshot.data?.data?.eventList?.length) {
              aList.clear();
              searchList.clear();
              aList = snapshot.data?.data?.eventList ?? [];
              var listValue =
                  aList.where((element) => element.category == selectedValue);
              searchList.addAll(listValue);
            }
            return mainListing();
          } else if (snapshot.hasError) {
            return mainListing();
          }

          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
        });
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget announcement() {
    return SizedBox(
      height: 140,
      width: _commonHelper?.screenWidth,
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          // padding: EdgeInsets.only(left: 4),
          itemCount: 4,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.all(6),
              width: 200,
              decoration: BoxDecoration(
                color: index % 2 == 0
                    ? SoloColor.electricPink
                    : SoloColor.batteryChargedBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(StringHelper.eventDate,
                      style: TextStyle(
                          color: SoloColor.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                  SizedBox(
                    width: _commonHelper?.screenWidth * 0.7,
                    child: Text(StringHelper.announcementMsg,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: SoloColor.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: _commonHelper?.screenWidth * 0.3,
                        child: Text(StringHelper.announcementLocation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: SoloColor.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 12)),
                      ),
                      Image.asset(
                        IconsHelper.announcement_icon,
                        width: _commonHelper?.screenWidth * 0.04,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget listData() {
    return SizedBox(
      height: 45,
      width: _commonHelper?.screenWidth,
      child: ListView.builder(
          // padding: EdgeInsets.only(left: 15),
          itemCount: eventCategory?.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  isSelected = index;
                  selectedValue = eventCategory?[index].eventCategoryId ?? "";
                  var listValue = aList
                      .where((element) => element.category == selectedValue);
                  searchList.clear();
                  searchList.addAll(listValue);
                });
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    margin: EdgeInsets.all(4),
                    height: 30,
                    child: Center(
                      child: Text(
                        eventCategory![index]
                            .eventCategoryId
                            .toString()
                            .toUpperCase(),
                        style: TextStyle(
                            fontSize: 13,
                            color: isSelected != null && isSelected == index
                                ? SoloColor.black
                                : SoloColor.lightGrey200,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  isSelected != null && isSelected == index
                      ? Container(
                          height: 6,
                          width: 6,
                          decoration: BoxDecoration(
                            color: SoloColor.electricPink,
                            shape: BoxShape.circle,
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            );
          }),
    );
  }

  List<Widget> _sliverWidgets(BuildContext context) {
    _randomChildren = [
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 2),
            child: Visibility(
              visible: showLocation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Container(
                          height: _commonHelper?.screenWidth * 0.08,
                          width: _commonHelper?.screenWidth * 0.08,
                          child: SvgPicture.asset(
                            IconsHelper.internetNavigation,
                          ),
                        ),
                        Container(
                            width: _commonHelper?.screenWidth * 0.4,
                            child: isLocation
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        locationValue,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )
                                : Container(
                                    child: Center(
                                        child: Text(
                                      StringHelper.map,
                                      style: SoloStyle.blackW600medium,
                                    )),
                                  )),
                      ],
                    ),
                  ),
                  Container(
                    height: _commonHelper?.screenWidth * 0.08,
                    width: _commonHelper?.screenWidth * 0.08,
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              getEvents(
                                  "", "", "", widget.eventContinent.toString());
                            });
                            showLocation = false;
                          });
                        },
                        child: Icon(Icons.close)),
                  ),
                ],
              ),
            ),
          ),
          // Row(
          //   children: [
          //     announcement(),
          //   ],
          // ),
        ],
      ),
    ];
    return _randomChildren;
  }

  Widget mainListing() {
    return Stack(
      children: [
        RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) {
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
                Row(
                  children: [
                    listData(),
                  ],
                ),
                searchList.isNotEmpty ? _eventsPost() : _noCarnivalWarning(),
              ],
            ),
          ),
        ),
        Align(
          child: ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
          alignment: FractionalOffset.center,
        )
      ],
    );
  }

  Widget _eventsPost() {
    var originalStartDate = searchList[0].endEpoch;

    var finalDate =
        DateTime.fromMillisecondsSinceEpoch(originalStartDate! * 1000);
    final dateFormat = new DateFormat('dd-MMM-yyyy-hh-mm-a-EEEE');
    var formatDate = dateFormat.format(finalDate);

    var splitDate = formatDate.split(RegExp('-'));
    var startDate = splitDate[0].toString();
    var startMonth = splitDate[1].toString();
    var startHours = splitDate[3].toString();
    var pm = splitDate[5].toString();
    var day = splitDate[6].toString();

    return Expanded(
      child: SizedBox(
        height: _commonHelper?.screenHeight * 0.9,
        width: _commonHelper?.screenWidth,
        child: ListView.builder(
            itemCount: aList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (aList[index].userId == mineUserId) {
                              _commonHelper
                                  ?.startActivity(ProfileTab(isFromHome: true));
                            } else {
                              _commonHelper?.startActivity(UserProfileActivity(
                                  userId: aList[index].userId.toString()));
                            }
                          },
                          child: Container(
                            width: _commonHelper?.screenWidth * 0.25,
                            height: _commonHelper?.screenWidth * 0.25,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: SoloColor.trans,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(19),
                                child: CachedNetworkImage(
                                  imageUrl: searchList[index].image.toString(),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      imagePlaceHolder(),
                                  errorWidget: (context, url, error) =>
                                      imagePlaceHolder(),
                                )),
                          ),
                        ),
                        space(width: _commonHelper?.screenWidth * 0.01),
                        GestureDetector(
                          onTap: () {
                            _hideKeyBoard();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EventsDetailsActivity(
                                          deleteTap: () {
                                            _hideKeyBoard();
                                            showCupertinoModalPopup(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return searchList[index]
                                                              .userId ==
                                                          mineUserId
                                                      ? _showBottomSheetEditDel(
                                                          searchList[index]
                                                              .eventId
                                                              .toString(),
                                                          searchList[index])
                                                      : _showBottomSheet(
                                                          searchList[index]
                                                              .userId
                                                              .toString(),
                                                          searchList[index]
                                                              .eventId
                                                              .toString());
                                                });
                                          },
                                          title: searchList[index]
                                              .title
                                              .toString(),
                                          likeOnTap: () {
                                            _commonHelper?.startActivity(
                                                EventsLikeActivity(
                                                    searchList[index]
                                                        .eventId
                                                        .toString()));
                                          },
                                          eventId: searchList[index]
                                              .eventId
                                              .toString(),
                                          refresh: false,
                                          context: this,
                                        ))).then((value) {
                              if (value) {
                                _showProgress();

                                aList.clear();
                                searchList.clear();

                                getEvents("", "", "",
                                    widget.eventContinent.toString());
                              }
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: SizedBox(
                                  width: _commonHelper?.screenWidth * 0.6,
                                  child: Text(
                                    searchList[index].title.toString(),
                                    maxLines: 2,
                                    style: SoloStyle.blackW500Top,
                                  ),
                                ),
                              ),
                              space(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("$day",
                                        style: TextStyle(
                                            color: SoloColor.lightGrey200,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400)),
                                    Text(" • ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color:
                                                SoloColor.batteryChargedBlue)),
                                    Text("$startDate $startMonth",
                                        style: TextStyle(
                                            color: SoloColor.lightGrey200,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400)),
                                    Text(" • ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color:
                                                SoloColor.batteryChargedBlue)),
                                    Text("$startHours $pm",
                                        style: TextStyle(
                                            color: SoloColor.lightGrey200,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400)),
                                  ],
                                ),
                              ),
                              space(height: 5),
                              SizedBox(
                                width: _commonHelper?.screenWidth * 0.6,
                                child: Text(
                                  getCountryName(index),
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: SoloColor.lightGrey200,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  String getCountryName(int index) {
    try {
      var array = searchList[index].locationName.toString().split(',');
      var country = searchList[index].locationName.toString().split(',').last;
      print("country$country");
      //  var name = CountryPickerUtils.getCountryByName(country.toString());
      //  print("codeData${name.isoCode.toString()}");
      var indexData = array.indexOf(country);
      return '${searchList[index].locationName.toString().split(',')[indexData - 1]},${country}';
    } catch (e) {
      return searchList[index].locationName.toString();
    }
  }

  Widget _noCarnivalWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text(StringHelper.noEventsFound,
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishGray)));
  }

  Widget _showBottomSheetEditDel(String id, EventList eventList) {
    return CupertinoActionSheet(actions: [
      CupertinoActionSheetAction(
        child: Text(StringHelper.edit,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        onPressed: () {
          Navigator.pop(context);

          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) =>
                  _showEditBottomSheet(id, eventList));
        },
      ),
      CupertinoActionSheetAction(
        child: Text(StringHelper.delete,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        onPressed: () {
          Navigator.pop(context);

          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => _showDeleteBottomSheet(id));
        },
      ),
    ]);
  }

  Widget _showBottomSheet(String blockUserId, String eventId) {
    return CupertinoActionSheet(
      actions: [
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
                    _showReportBottomSheet(eventId));
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

  Widget _showReportBottomSheet(String eventId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.report,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.reportMsg,
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

            _onReportPostTap(eventId);
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

  Widget _profileImage(int index) {
    return ClipOval(
        child: CachedNetworkImage(
            imageUrl: searchList[index].userProfilePic.toString(),
            height: 40,
            width: 40,
            fit: BoxFit.cover,
            placeholder: (context, url) => imagePlaceHolder(),
            errorWidget: (context, url, error) => imagePlaceHolder()));
  }

  Widget _showDeleteBottomSheet(String delId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.deleteEvent,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.deleteEventMsg,
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

            _deleteButtonTap(delId);
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

  Widget _showEditBottomSheet(String edit, EventList eventList) {
    return CupertinoActionSheet(
      title: Text(StringHelper.editEvent,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.editEventMSg,
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

            _editButtonTap(edit, eventList);
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

  Widget userDetails(int index) {
    return Container(
      padding: EdgeInsets.all(DimensHelper.sidesMargin),
      child: Stack(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  if (searchList[index].userId == mineUserId) {
                    _hideKeyBoard();
                    Navigator.of(context)
                        .push(
                      new MaterialPageRoute(
                          builder: (_) => new ProfileTab(isFromHome: true)),
                    )
                        .then((mapData) {
                      if (mapData != null && mapData) {
                        aList.clear();
                        searchList.clear();
                        _showProgress();
                        getEvents("", "", "", widget.eventContinent.toString());
                      }
                    });
                  } else {
                    _hideKeyBoard();

                    _commonHelper?.startActivity(UserProfileActivity(
                        userId: aList[index].userId.toString()));
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: DimensHelper.halfSides),
                      child: _profileImage(index),
                    ),
                    Container(
                      width: _commonHelper?.screenWidth * .6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(searchList[index].title.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: SoloColor.black,
                                  fontSize: Constants.FONT_TOP)),
                          Padding(
                            padding:
                                EdgeInsets.only(top: DimensHelper.smallSides),
                            child: Text(
                                _commonHelper!.getTimeDifference(
                                    searchList[index].insertDate ?? 0),
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: SoloColor.spanishGray,
                                    fontSize: Constants.FONT_LOW)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )),
          GestureDetector(
            onTap: () {
              _hideKeyBoard();
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return searchList[index].userId == mineUserId
                        ? _showBottomSheetEditDel(
                            searchList[index].eventId.toString(),
                            searchList[index])
                        : _showBottomSheet(searchList[index].userId.toString(),
                            searchList[index].eventId.toString());
                  });
            },
            child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  child: Icon(
                    Icons.more_vert,
                    color: SoloColor.spanishGray,
                  ),
                )),
          )
        ],
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
          child: Text(StringHelper.ok,
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

//============================================================
// ** Helper Function **
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

  _onSearchTextChanged(String text) async {
    searchList.clear();

    if (text.isEmpty) {
      searchList.addAll(aList);

      setState(() {});

      return;
    }

    aList.forEach((carnivalDetail) {
      if (carnivalDetail.title!.toUpperCase().contains(text.toUpperCase())) {
        searchList.add(carnivalDetail);
      }
    });

    setState(() {});
  }

  void _onUnLikeButtonTap(String serviceId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var unLikeBody = json.encode({
          "eventId": serviceId,
        });

        _eventBloc?.eventUnLike(unLikeBody, authToken.toString());
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onLikeButtonTap(String serviceId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var likeBody = json.encode({
          "eventId": serviceId,
        });

        _eventBloc?.eventLike(likeBody, authToken.toString());
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void getEvents(String text, String lat, String lng, String eventContinent) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();
          _eventBloc
              ?.getEvent(token.toString(), text, lat, lng, eventContinent)
              .then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              /* if (onValue.data.eventList.isNotEmpty) {
                aList = onValue.data.eventList;
              } else {}*/
            } else {
              /*    _commonHelper.showAlert(
                  StringHelper.noInternetTitle, "Something Wrong");*/
            }
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

  void _onReportPostTap(String eventId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "feedId": eventId,
          "feedType": "event",
        });

        _apiHelper?.reportFeed(body, authToken.toString()).then((onValue) {
          _hideProgress();

          ReportFeedModel _reportModel = onValue;

          if (_reportModel.statusCode == 200)
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _successBottomSheet(
                    StringHelper.success, StringHelper.eventSuccessMsg));
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _deleteButtonTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _eventBloc?.deleteEvent(authToken.toString(), feedId).then((onValue) {
          aList.clear();
          searchList.clear();

          _commonHelper?.showToast(StringHelper.eventDeleteMsg);

          getEvents("", "", "", widget.eventContinent.toString());
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _editButtonTap(String id, EventList eventList) {
    _hideKeyBoard();

    _commonHelper
        ?.startActivity(
            AddEvent(eventList: eventList, isFrom: true, context: this))
        .then((value) {
      if (value) {
        _showProgress();

        // _getProfileData();
      }
    });
  }

  void searchData(String text) {
    if (lastInputValue != text) {
      lastInputValue = text;

      aList.clear();

      searchList.clear();

      if (text.isEmpty) {
        //searchList.addAll(aList);

        //setState(() {});
        getEvents(
            "",
            lat == null ? "" : lat.toString(),
            lng == null ? "" : lng.toString(),
            widget.eventContinent.toString());

        return;
      }
      // _getService(text);

      if (debounce != null) debounce?.cancel();
      setState(() {
        debounce = Timer(Duration(seconds: 2), () {
          getEvents(
              text,
              lat == null ? "" : lat.toString(),
              lng == null ? "" : lng.toString(),
              widget.eventContinent.toString());
        });
      });
    }

    setState(() {});
  }

  void _getEventCategory() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _eventBloc?.getEventCategory(token.toString()).then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              if (onValue.data!.eventCategoryList!.isNotEmpty) {
                eventCategory = onValue.data?.eventCategoryList;
              } else {}
            } else {
              _commonHelper?.showAlert(
                  StringHelper.noInternetTitle, StringHelper.somethingWrong);
            }
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

  @override
  void updateData() {
    _refresh();
  }

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }
}
