import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/events/add_event.dart';
import 'package:solomas/activities/events/new_events.dart';
import 'package:solomas/activities/events/previous_events.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/blocs/event_details/event_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/events_response.dart';
import 'package:solomas/model/report_feed_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/common_helper.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';
import '../common_helpers/feed_card_events.dart';

abstract class RefreshData {
  void updateData();
}

class EventsTab extends StatefulWidget {
  final String? eventContinent;

  const EventsTab({Key? key, this.eventContinent}) : super(key: key);

  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab>
    with SingleTickerProviderStateMixin
    implements RefreshData {
  CommonHelper? _commonHelper;
  ApiHelper? _apiHelper;
  EventBloc? _eventBloc;
  List<EventList> _aList = [];
  List<EventList> _searchList = [];

  TabController? tabController;
  int _currentTabIndex = 0;
  GlobalKey<NewEventsState> _newEventState = GlobalKey();
  var _addressController = TextEditingController();

  GlobalKey<PreviousEventsState> _previousEventState = GlobalKey();
  final CarouselController _controller = CarouselController();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  var _progressShow = false;
  String? authToken, mineUserId = "", mineProfilePic = "";

  Future<Null> _refresh() async {
    _showProgress();

    _aList.clear();
    _searchList.clear();

    //_getEvent();
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

  _onSearchTextChanged1(String text) async {
    _searchList.clear();

    if (text.isEmpty) {
      _searchList.addAll(_aList);

      setState(() {});

      return;
    }

    _aList.forEach((carnivalDetail) {
      if (carnivalDetail.title!.toUpperCase().contains(text.toUpperCase())) {
        _searchList.add(carnivalDetail);
      }
    });

    setState(() {});
  }

  _onSearchTextChanged(String text) async {
    if (_currentTabIndex == 0) {
      _newEventState.currentState?.searchData(text);
    } else if (_currentTabIndex == 1) {
      _previousEventState.currentState?.searchData(text);
    }
  }

  Widget _noCarnivalWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text(StringHelper.noEvent,
            style: SoloStyle.spanishGrayNormalFontMedium));
  }

/*
  void _getEvent() {
    _commonHelper.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();
          _eventBloc.getEvent(token).then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              */
/* if (onValue.data.eventList.isNotEmpty) {
                _aList = onValue.data.eventList;
              } else {}*/ /*

            } else {
              */
/*    _commonHelper.showAlert(
                  StringHelper.noInternetTitle, "Something Wrong");*/ /*

            }
          }).catchError((onError) {
            _hideProgress();
          });
        });
      } else {
        _commonHelper.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }
*/

  Widget _showDeleteBottomSheet(String delId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.deleteEvent, style: SoloStyle.blackW500FontTop),
      message: Text(StringHelper.deleteEventWarring,
          style: SoloStyle.spanishGrayW400FontMedium),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes, style: SoloStyle.blackW500FontTop),
          onPressed: () {
            Navigator.pop(context);

            _deleteButtonTap(delId);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            StringHelper.no,
            style: SoloStyle.blackW500FontTop,
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
      title: Text(StringHelper.editEvent, style: SoloStyle.blackW500FontTop),
      message: Text(StringHelper.deleteEventWarring,
          style: SoloStyle.spanishGrayW400FontMedium),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes, style: SoloStyle.blackW500FontTop),
          onPressed: () {
            Navigator.pop(context);

            _editButtonTap(edit, eventList);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            StringHelper.no,
            style: SoloStyle.blackW500FontTop,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
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
          _aList.clear();
          _searchList.clear();

          _commonHelper?.showToast(StringHelper.eventDeleteMsg);

          //_getEvent();
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
    _addressController.text = "";
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

  Widget _showBottomSheetEditDel(String id, EventList eventList) {
    return CupertinoActionSheet(actions: [
      CupertinoActionSheetAction(
        child: Text(StringHelper.edit, style: SoloStyle.blackW500FontTop),
        onPressed: () {
          Navigator.pop(context);

          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) =>
                  _showEditBottomSheet(id, eventList));
        },
      ),
      CupertinoActionSheetAction(
        child: Text(StringHelper.delete, style: SoloStyle.blackW500FontTop),
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
        /* CupertinoActionSheetAction(
          child: Text("Block",
              style: TextStyle(
                  color: ColorsHelper.colorBlack,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) =>
                    _showBlockBottomSheet(blockUserId));
          },
        ),*/
        CupertinoActionSheetAction(
          child: Text(
            StringHelper.report,
            style: SoloStyle.blackW500FontTop,
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
        child: Text(StringHelper.cancel, style: SoloStyle.blackW500FontTop),
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _showReportBottomSheet(String eventId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.report, style: SoloStyle.blackW500FontTop),
      message: Text(StringHelper.deleteEventWarring,
          style: SoloStyle.spanishGrayW400FontMedium),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes, style: SoloStyle.blackW500FontTop),
          onPressed: () {
            Navigator.pop(context);

            _onReportPostTap(eventId);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            StringHelper.no,
            style: SoloStyle.blackW500FontTop,
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
      imageUrl: _searchList[index].userProfilePic.toString(),
      height: 40,
      width: 40,
      fit: BoxFit.cover,
      placeholder: (context, url) => imagePlaceHolder(),
      errorWidget: (context, url, error) => imagePlaceHolder(),
    ));
  }

  void _getCurrentTab() {
    setState(() {
      _addressController.text = "";
      /*_previousEventState.currentState.lat="";
      _previousEventState.currentState.lng="";
      _newEventState.currentState.lat="";
      _newEventState.currentState.lng="";*/
      _currentTabIndex = tabController!.index;
    });
  }

  @override
  void initState() {
    super.initState();
    _apiHelper = ApiHelper();

    _eventBloc = EventBloc();

    tabController = TabController(vsync: this, length: 2);

    tabController?.addListener(_getCurrentTab);

    PrefHelper.getUserId().then((token) {
      setState(() {
        mineUserId = token;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //_getEvent();
    });
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
                  if (_searchList[index].userId == mineUserId) {
                    Navigator.of(context)
                        .push(
                      new MaterialPageRoute(
                          builder: (_) => new ProfileTab(isFromHome: true)),
                    )
                        .then((mapData) {
                      if (mapData != null && mapData) {
                        _aList.clear();
                        _searchList.clear();
                        _showProgress();
                        //_getEvent();
                      }
                    });
                  } else {
                    _commonHelper?.startActivity(UserProfileActivity(
                        userId: _aList[index].userId.toString()));
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
                          Text(_searchList[index].userName.toString(),
                              style: SoloStyle.blackW500FontTop),
                          Padding(
                            padding:
                                EdgeInsets.only(top: DimensHelper.smallSides),
                            child: Text(
                                _commonHelper!.getTimeDifference(
                                    _searchList[index].insertDate ?? 0),
                                style: SoloStyle.spanishGrayW500FontLow),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )),
          GestureDetector(
            onTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return _searchList[index].userId == mineUserId
                        ? _showBottomSheetEditDel(
                            _searchList[index].eventId.toString(),
                            _searchList[index])
                        : _showBottomSheet(_searchList[index].userId.toString(),
                            _searchList[index].eventId.toString());
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
      title: Text(title, style: SoloStyle.blackW500FontTop),
      message: Text(msg, style: SoloStyle.spanishGrayW400FontMedium),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.ok, style: SoloStyle.blackW500FontTop),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  /*_onSearchTextChanged(String text) async {
    if (text.isNotEmpty) {
      _aList.clear();
      _getSearchedEvent(text);
    } else {
      _aList.clear();

      _getEvent();
    }

    //searchData(text);
  }*/

  void searchData(String searchQuery) {
    _searchList.clear();

    if (searchQuery.isEmpty) {
      _searchList.addAll(_aList);

      setState(() {});

      return;
    }

    _aList.forEach((carnivalDetail) {
      if (carnivalDetail.title!
          .toUpperCase()
          .contains(searchQuery.toUpperCase())) {
        _searchList.add(carnivalDetail);
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return Stack(
      children: [
        SoloScaffold(
          body: _mainBody(),

          /*StreamBuilder(
              stream: _eventBloc.eventList,
              builder: (context, AsyncSnapshot<EventResponse> snapshot) {
                if (snapshot.hasData) {
                  if (_aList.isEmpty) {
                    _aList = snapshot.data.data.eventList;
                    _searchList.addAll(_aList);
                  }

                  return mainListing();
                } else if (snapshot.hasError) {
                  return mainListing();
                }

                return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            ColorsHelper.colorBlue)));
              })*/
        )
      ],
    );
  }

  Widget _mainBody() {
    return NewEvents(
        key: _newEventState, eventContinent: widget.eventContinent.toString());
    // Column(
    //   children: [
    //     Container(
    //       color: Colors.transparent, // Tab Bar color change
    //       child: TabBar(
    //         // TabBar
    //         labelPadding: EdgeInsets.zero,
    //         controller: tabController,
    //         onTap: (index) {},
    //         unselectedLabelColor: SoloColor.spanishGray,
    //         labelColor: SoloColor.pink,
    //         indicatorWeight: 2,
    //         indicatorColor: SoloColor.pink,
    //         tabs: [
    //           Tab(text: "Events"),
    //           Tab(text: "Previous Events"),
    //         ],
    //       ),
    //     ),
    //     Expanded(
    //       flex: 2,
    //       child: TabBarView(
    //         // Tab Bar View
    //         physics: BouncingScrollPhysics(),
    //         controller: tabController,
    //         children: [
    //           NewEvents(
    //               key: _newEventState,
    //               eventContinent: widget.eventContinent.toString()),
    //           PreviousEvents(
    //               key: _previousEventState,
    //               eventContinent: widget.eventContinent.toString()),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }

  Widget _appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: _commonHelper?.screenWidth * 0.15,
                width: _commonHelper?.screenWidth * 0.1,
                child: SvgPicture.asset(
                  IconsHelper.backwardBackArrow,
                ),
              ),
            ),
            SizedBox(
              width: _commonHelper?.screenWidth * 0.60,
              child: SoloAppBar(
                appBarType: StringHelper.searchBar,
                onSearchBarTextChanged: _onSearchTextChanged,
                hintText: StringHelper.searchNearEvents,
                leadingTap: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                _addressController.text = "";
                _commonHelper?.startActivity(AddEvent(
                  isFrom: false,
                  context: this,
                ));
              },
              child: SvgPicture.asset(IconsHelper.ic_plus,
                  width: CommonHelper(context).screenWidth * 0.08),
            ),
            SvgPicture.asset(IconsHelper.nevigation,
                width: CommonHelper(context).screenWidth * 0.09),
          ],
        ),
      ),
    );
  }

  Widget mainListing() {
    return Stack(
      children: [
        RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: Container(
            height: _commonHelper?.screenHeight,
            child: Column(
              children: [
                _searchList.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _searchList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _eventsPost(index);
                          },
                        ),
                      )
                    : _noCarnivalWarning()
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

  Widget _eventsPost(int index) {
    var comments;

    if (_searchList[index].totalComments == 0) {
      comments = "";
    } else {
      var titleComment = _searchList[index].totalComments == 1 ? "" : "";

      comments = '${_searchList[index].totalComments.toString()} $titleComment';
    }
    return FeedCardEvent(
      carnivalsText: _searchList[index].carnivalTitle.toString(),
      userProfile: _searchList[index].image.toString(),
      userName: _searchList[index].title.toString(),
      userLocation: StringHelper.userLocation,
      userDetailsOnTap: () {
        if (_aList[index].userId == mineUserId) {
          _commonHelper?.startActivity(ProfileTab(isFromHome: true));
        } else {
          _commonHelper?.startActivity(
              UserProfileActivity(userId: _aList[index].userId.toString()));
        }
      },
      moreTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return _showBottomSheet(_searchList[index].userId.toString(),
                  _searchList[index].eventId.toString());
            });
      },
      imagePath: _searchList[index].image ?? "",
      carouselController: _controller,
      likeImage: _searchList[index].isLike == true
          ? IconsHelper.unLike
          : IconsHelper.like,
      likeCount: StringHelper.likes.toLowerCase(),
      likeOnTap: () {},
      commentCount: comments,
      commentOnTap: () {},
      countDown:
          _commonHelper!.getTimeDifference(_searchList[index].insertDate ?? 0),
      content: _searchList[index].title.toString(),
      feedTap: () {},
    );
  }

  @override
  void updateData() {
    _refresh();
  }

  @override
  void dispose() {
    _eventBloc?.dispose();

    super.dispose();
  }

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }
}
