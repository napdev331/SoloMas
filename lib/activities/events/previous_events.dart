import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/events/add_event.dart';
import 'package:solomas/activities/events/events_comment_activity.dart';
import 'package:solomas/activities/events/review_activity.dart';
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

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';

class PreviousEvents extends StatefulWidget {
  final String? eventContinent;

  const PreviousEvents({key, this.eventContinent}) : super(key: key);

  @override
  PreviousEventsState createState() => PreviousEventsState();
}

class PreviousEventsState extends State<PreviousEvents> {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  ApiHelper? _apiHelper;
  EventBloc? _eventBloc;
  List<EventList> aList = [];
  List<EventList> searchList = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Timer? debounce;
  var lastInputValue = "";
  var lat, lng;
  var _progressShow = false;
  String? authToken, mineUserId = "", mineProfilePic = "";

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SoloScaffold(
      body: _mainBody(),
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

  Widget _mainBody() {
    return StreamBuilder(
        stream: _eventBloc?.eventList,
        builder: (context, AsyncSnapshot<EventResponse> snapshot) {
          if (snapshot.hasData) {
            if (aList.isEmpty) {
              aList = snapshot.data?.data?.eventList ?? [];
              searchList.addAll(aList);
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
                searchList.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: searchList.length,
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
    var reviews;

    if (searchList[index].totalComments == 0) {
      comments = "";
    } else {
      var titleComment = searchList[index].totalComments == 1 ? "" : "";

      comments = '${searchList[index].totalComments.toString()} $titleComment';
    }

    if (searchList[index].reviewCount == 0) {
      reviews = "";
    } else {
      var titleReview = searchList[index].reviewCount == 1 ? "" : "";

      reviews = '${searchList[index].reviewCount.toString()} $titleReview';
    }

    return Card(
      elevation: DimensHelper.tinySides,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DimensHelper.sidesMargin),
      ),
      margin: EdgeInsets.only(
          left: DimensHelper.sidesMargin,
          right: DimensHelper.sidesMargin,
          top: DimensHelper.halfSides,
          bottom: DimensHelper.halfSides),
      child: Column(
        children: [
          Column(
            children: [
              userDetails(index),
              Container(
                height: 335,
                margin: EdgeInsets.only(
                    bottom: DimensHelper.sidesMargin,
                    left: DimensHelper.halfSides,
                    right: DimensHelper.halfSides),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _hideKeyBoard();

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EventsDetailsActivity(
                                      eventId:
                                          searchList[index].eventId.toString(),
                                      refresh: false,
                                      context: this,
                                    ))).then((value) {
                          if (value) {
                            _showProgress();

                            aList.clear();
                            searchList.clear();

                            getEvents(
                                "", "", "", widget.eventContinent.toString());
                          }
                        });
                      },
                      child: Container(
                        height: 335,
                        width: _commonHelper?.screenWidth * .9,
                        child: ClipRRect(
                            child: CachedNetworkImage(
                                imageUrl: searchList[index].image.toString(),
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    imagePlaceHolder(),
                                errorWidget: (context, url, error) =>
                                    imagePlaceHolder())),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 40,
                        alignment: Alignment.bottomCenter,
                        color: SoloColor.blue,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                _hideKeyBoard();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReviewActivity(
                                          eventId: searchList[index]
                                              .eventId
                                              .toString(),
                                          showKeyBoard: true,
                                          scrollMessage: false)),
                                ).then((value) {
                                  Constants.printValue(
                                      "VALUE: " + value.toString());

                                  if (value != null && value) {
                                    _showProgress();

                                    aList.clear();
                                    searchList.clear();

                                    getEvents("", "", "",
                                        widget.eventContinent.toString());
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: DimensHelper.halfSides,
                                    bottom: DimensHelper.halfSides),
                                width: _commonHelper?.screenWidth * .43,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(
                                        left: DimensHelper.halfSides),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                              child: Image.asset(
                                            'assets/images/ic_review_black.png',
                                            width: 15,
                                            height: 15,
                                            fit: BoxFit.cover,
                                            color: SoloColor.white,
                                          )),
                                          TextSpan(
                                              text: " " + reviews,
                                              style: TextStyle(
                                                  fontSize: Constants.FONT_LOW,
                                                  color: SoloColor.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _hideKeyBoard();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EventsCommentActivity(
                                              eventId:
                                                  searchList[index].eventId,
                                              showKeyBoard: false,
                                              scrollMessage: false)),
                                ).then((value) {
                                  if (value != null && value) {
                                    _showProgress();

                                    aList.clear();
                                    searchList.clear();

                                    getEvents("", "", "",
                                        widget.eventContinent.toString());
                                  }
                                });
                              },
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(
                                    top: DimensHelper.halfSides,
                                    bottom: DimensHelper.halfSides),
                                width: _commonHelper?.screenWidth * .43,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset(
                                        'images/comment.png',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.cover,
                                        color: SoloColor.white,
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(
                                              left: DimensHelper.halfSides,
                                              right: DimensHelper.halfSides),
                                          child: Text(comments,
                                              style: TextStyle(
                                                  fontSize: Constants.FONT_LOW,
                                                  color: SoloColor.white))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
/*
              Container(
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        */
/*   Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PublicFeedCommentActivity(
                                    publicFeedId: aList[index].publicFeedId,
                                    showKeyBoard: true,
                                    scrollMessage: false)),
                          ).then((value) {
                            Constants.printValue("VALUE: " + value.toString());

                            if (value != null && value) {
                              _showProgress();

                              aList.clear();

                              _getPublicFeeds();
                            }
                          });*/ /*

                      },
                      child: GestureDetector(
                        onTap: () {
                          _hideKeyBoard();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReviewActivity(
                                    eventId: searchList[index].eventId,
                                    showKeyBoard: true,
                                    scrollMessage: false)),
                          ).then((value) {
                            Constants.printValue("VALUE: " + value.toString());

                            if (value != null && value) {
                              _showProgress();

                              aList.clear();
                              searchList.clear();

                              getEvents("", "", "",widget.eventContinent);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              top: DimensHelper.sidesMargin,
                              bottom: DimensHelper.sidesMargin),
                          width: _commonHelper.screenWidth * .45,
                          child: Material(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/ic_review_black.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.cover,
                                ),

                                Container(
                                    margin: EdgeInsets.only(
                                        left: DimensHelper.halfSides),
                                    child: Text("Review")), // text
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    */
/*  aList[index].isLike
                          ? unLikeButton(index)
                          : likeButton(index),*/ /*

                    InkWell(
                      onTap: () {
                        _hideKeyBoard();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventsCommentActivity(
                                  eventId: searchList[index].eventId,
                                  showKeyBoard: true,
                                  scrollMessage: false)),
                        ).then((value) {
                          Constants.printValue("VALUE: " + value.toString());

                          if (value != null && value) {
                            _showProgress();

                            aList.clear();
                            searchList.clear();

                            getEvents("", "", "",widget.eventContinent);
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            top: DimensHelper.sidesMargin,
                            bottom: DimensHelper.sidesMargin),
                        width: _commonHelper.screenWidth * .45,
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/comment.png',
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                              ),

                              Container(
                                  margin: EdgeInsets.only(
                                      left: DimensHelper.halfSides),
                                  child: Text("Comment")), // text
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
*/
            ],
          )
        ],
      ),
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

  Widget _showBottomSheetEditDel(String id, EventList eventList) {
    return CupertinoActionSheet(actions: [
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

//============================================================
// ** Helper Function **
//============================================================
  /*_onSearchTextChanged(String text) async {
    if (text.isNotEmpty) {
      aList.clear();
      _getSearchedEvent(text);
    } else {
      aList.clear();

      getEvents();
    }

    //searchData(text);
  }*/

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

  @override
  void updateData() {
    _refresh();
  }

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }

  Future<Null> _refresh() async {
    _showProgress();

    aList.clear();
    searchList.clear();

    getEvents("", "", "", widget.eventContinent.toString());
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

  void getEvents(String text, String lat, String lng, String eventContinent) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();
          _eventBloc
              ?.getEventPrevious(
                  token.toString(), text, lat, lng, eventContinent)
              .then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              aList.clear();
              searchList.clear();
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
}
