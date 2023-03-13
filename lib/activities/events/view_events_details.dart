import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:solomas/activities/bottom_tabs/events_tab.dart';
import 'package:solomas/blocs/event_details/event_bloc.dart';
import 'package:solomas/blocs/event_details/event_comment_bloc.dart';
import 'package:solomas/blocs/event_details/event_review_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/comment_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/carnival_list_model.dart';
import 'package:solomas/model/particular_event_detail.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/space.dart';
import '../../model/events_comment_response.dart';
import '../../model/report_feed_model.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';
import '../common_helpers/comment_card.dart';
import '../home/members_list_activity.dart';
import 'events_comment_activity.dart';

class EventsDetailsActivity extends StatefulWidget {
  final Function()? likeOnTap;
  final Function()? deleteTap;
  final String? title;
  final String? eventId;
  final bool? refresh;
  final context;
  final String? eventContinent;
  final String? publicCommentId;
  bool? scrollMessage;
  final EventList? eventList;
  final bool? isFrom;

  EventsDetailsActivity({
    this.eventId,
    this.refresh,
    this.context,
    this.eventContinent,
    this.scrollMessage,
    this.publicCommentId,
    this.eventList,
    this.isFrom,
    this.title,
    this.deleteTap,
    this.likeOnTap,
  });

  //const EventsDetailsActivity(Data data, {key}) : super(key: key);

  @override
  _EventsDetailsActivityState createState() => _EventsDetailsActivityState();
}

class _EventsDetailsActivityState extends State<EventsDetailsActivity> {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  ApiHelper? _apiHelper;
  EventBloc? _eventBloc;
  EventReviewBloc? _evenyReviewBloc;
  List<EventCommentsList>? _aList;
  List<EventList> aListData = [];
  var pos = -1;
  late List<Widget> _randomChildren;
  String? editNewEventID;
  ScrollController? _scrollController;
  List<EventList> searchList = [];
  bool isLike = false;
  bool isEditComment = false;
  bool _progressShow = false,
      refreshData = false,
      _isEventJoined = false,
      isCurrentUser = false;
  bool isEditReview = false;
  RefreshData? _refreshData;
  List<EventList>? _eventList;
  List<MembersList>? _eventMemberList;
  EventCommentListBloc? _eventCommentListBloc;
  String authToken = "",
      mineUserId = "",
      mineUserName = "",
      mineProfile = "",
      replyId = "";
  var _sendCommentController = TextEditingController();
  var _sendCommentFocusNode = FocusNode();
  var _sendReviewFocusNode = FocusNode();
  String? currentReviewId;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _apiHelper = ApiHelper();
    _eventCommentListBloc = EventCommentListBloc();
    _evenyReviewBloc = EventReviewBloc();
    _eventMemberList = [];
    PrefHelper.getUserId().then((token) {
      setState(() {
        mineUserId = token.toString();
      });
    });

    PrefHelper.getUserName().then((token) {
      setState(() {
        mineUserName = token.toString();
      });
    });

    PrefHelper.getUserProfilePic().then((token) {
      setState(() {
        mineProfile = token.toString();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getEventDetail();
      _getEventMembers();
      Future.delayed(Duration(seconds: 2), () {
        _getEventCommentList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SoloScaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: Container(
              color: SoloColor.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: _appBar(),
              ),
            ),
          ),
          body: _mainBody()),
    );
  }

  @override
  void dispose() {
    _eventCommentListBloc?.dispose();
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _mainBody() {
    return StreamBuilder(
      stream: _eventCommentListBloc?.eventDetail,
      builder: (context, AsyncSnapshot<ParticularEventDetails> snapshot) {
        if (snapshot.hasData) {
          if (_eventList == null || _eventList!.isEmpty) {
            _eventList = snapshot.data?.data?.eventList;
            if (_eventList?.length == 0) {
              return Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(SoloColor.blue)));
            } else {
              return mainList();
            }
          }
          return mainList();
        } else if (snapshot.hasError) {
          return Container();
        }
        return Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
      },
    );
  }

  Widget _appBar() {
    return SoloAppBar(
      backWithMore: true,
      iconUrl: IconsHelper.ic_more_with_border,
      appBarType: StringHelper.backWithText,
      appbarTitle: widget.title,
      backOnTap: () {
        Navigator.pop(context);
      },
      iconOnTap: widget.deleteTap,
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget _showDeleteBottomSheetValue(String delId) {
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

  Widget _showEditBottomSheetValue(String edit, EventList eventList) {
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

  Widget _showBottomSheetEditDelValue(String id, EventList eventList) {
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
                  _showEditBottomSheetValue(id, eventList));
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
              builder: (BuildContext context) =>
                  _showDeleteBottomSheetValue(id));
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

  Widget peopleDetailCard(int index) {
    return Container(
      width: _commonHelper?.screenWidth * .7,
      margin: EdgeInsets.only(
          left: DimensHelper.halfSides,
          right: DimensHelper.halfSides,
          top: DimensHelper.halfSides),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: DimensHelper.halfSides),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(DimensHelper.sidesMargin)),
              elevation: 3.0,
              child: Container(
                margin: EdgeInsets.only(left: 75),
                padding: EdgeInsets.all(DimensHelper.sidesMargin),
                child: Row(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: _commonHelper?.screenWidth * .35,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                        _eventList![0]
                                            .eventLatestFiveMembers![index]
                                            .userName!
                                            .toUpperCase(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: SoloColor.black,
                                            fontSize: Constants.FONT_TOP)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: DimensHelper.sidesMargin,
                right: DimensHelper.sidesMargin),
            child: profileImageData(index),
          ),
        ],
      ),
    );
  }

  Widget profileImage(int index) {
    return GestureDetector(
      onTap: () {},
      child: ClipOval(
          child: CachedNetworkImage(
              imageUrl: _aList![index].userProfilePic.toString(),
              height: 40,
              width: 40,
              fit: BoxFit.cover,
              placeholder: (context, url) => imagePlaceHolder(),
              errorWidget: (context, url, error) => imagePlaceHolder())),
    );
  }

  Widget profileImageData(int index) {
    return GestureDetector(
      onTap: () {},
      child: ClipOval(
          child: CachedNetworkImage(
              imageUrl: _eventList![0]
                  .eventLatestFiveMembers![index]
                  .userProfilePic!
                  .toUpperCase(),
              height: 70,
              width: 70,
              fit: BoxFit.cover,
              placeholder: (context, url) => imagePlaceHolder(),
              errorWidget: (context, url, error) => imagePlaceHolder())),
    );
  }

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

            if (_isEventJoined) {
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
                StringHelper.upComingEventMsg, StringHelper.removeEvent));
      },
      child: Container(
          height: 30,
          width: 70,
          decoration: BoxDecoration(
            border: Border.all(
              color: SoloColor.white,
            ),
            color: SoloColor.electricPink,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              StringHelper.goingAdd,
              style: TextStyle(color: SoloColor.white, fontSize: 12),
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
                StringHelper.attendingEventMsg, StringHelper.addEvent));
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
          child: Center(
            child: Text(
              StringHelper.going,
              style: TextStyle(color: SoloColor.white, fontSize: 12),
            ),
          )),
    );
  }

  Widget _commentListData(int pos) {
    return Expanded(
      child: Container(
        width: _commonHelper?.screenWidth,
        color: SoloColor.white,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                _hideKeyBoard();
              },
              child: Container(
                color: Colors.white,
                width: _commonHelper?.screenWidth,
                height: _commonHelper?.screenHeight * .825,
                padding: EdgeInsets.only(
                    bottom: DimensHelper.halfSides,
                    top: DimensHelper.halfSides),
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  controller: _scrollController,
                  itemCount: _aList?.length,
                  padding: EdgeInsets.only(bottom: 56, left: 16, right: 16),
                  itemBuilder: (context, index) {
                    if (index == pos) {
                      return userDetails1(index);
                    } else {
                      return userDetails(index);
                    }
                  },
                ),
              ),
            ),
            Visibility(
              visible: _aList!.isEmpty,
              child: Container(
                height: _commonHelper?.screenHeight * .8,
                child: Center(
                  child: Text(StringHelper.noCommentsEvent,
                      style: TextStyle(
                          color: SoloColor.black,
                          fontSize: Constants.FONT_MEDIUM,
                          fontWeight: FontWeight.normal)),
                ),
              ),
            ),
            Align(
              child: ProgressBarIndicator(
                  _commonHelper?.screenSize, _progressShow),
              alignment: FractionalOffset.center,
            )
          ],
        ),
      ),
    );
  }

  Widget userDetails1(int index) {
    return _aList?[index].userId == mineUserId
        ? CommentCard(
            moreOnTapIcon: true,
            userProfile: _aList![index].userProfilePic.toString(),
            username: _aList![index].userName.toString(),
            moreOnTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return _showBottomSheetEditDelValueData(
                        _aList![index].eventCommentId.toString(),
                        index,
                        _aList![index].comment.toString());
                  });
            },
            content: _aList![index].comment.toString(),
            likeImage: isLike == true ? IconsHelper.like : IconsHelper.unLike,
            likeOnTap: () {
              isLike = isLike;
              // goToLike(groupFeedList);
            },
            likeCount: "",
            likeTextOnTap: () {
              // _commonHelper?.startActivity(
              //     CarnivalLikeListActivity(groupFeedList.carnivalFeedId.toString()));
            },
            commentTextOnTap: () {
              // goToComment(groupFeedList);
            },
            commentCount: "",
            commentOnTap: () {
              // goToComment(groupFeedList);
            },
            countDown: _commonHelper!
                .getTimeDifference(_aList![index].insertDate ?? 0),
          )
        : CommentCard(
            moreOnTapIcon: false,
            userProfile: _aList![index].userProfilePic.toString(),
            username: _aList![index].userName.toString(),
            content: _aList![index].comment.toString(),
            likeImage: isLike == true ? IconsHelper.like : IconsHelper.unLike,
            likeOnTap: () {
              isLike = isLike;
              // goToLike(groupFeedList);
            },
            likeCount: "",
            likeTextOnTap: () {
              // _commonHelper?.startActivity(
              //     CarnivalLikeListActivity(groupFeedList.carnivalFeedId.toString()));
            },
            commentTextOnTap: () {
              // goToComment(groupFeedList);
            },
            commentCount: "",
            commentOnTap: () {
              // goToComment(groupFeedList);
            },
            countDown: _commonHelper!
                .getTimeDifference(_aList![index].insertDate ?? 0),
          );
  }

  Widget userDetails(int index) {
    return _aList?[index].userId == mineUserId
        ? CommentCard(
            moreOnTapIcon: true,
            userProfile: _aList![index].userProfilePic.toString(),
            username: _aList![index].userName.toString(),
            moreOnTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return _showBottomSheetEditDelValueData(
                        _aList![index].eventCommentId.toString(),
                        index,
                        _aList![index].comment.toString());
                  });
            },
            content: _aList![index].comment.toString(),
            likeImage: isLike == true ? IconsHelper.like : IconsHelper.unLike,
            likeOnTap: () {
              isLike = isLike;
              // goToLike(groupFeedList);
            },
            likeCount: "",
            likeTextOnTap: () {
              // _commonHelper?.startActivity(
              //     CarnivalLikeListActivity(groupFeedList.carnivalFeedId.toString()));
            },
            commentTextOnTap: () {
              // goToComment(groupFeedList);
            },
            commentCount: "",
            commentOnTap: () {
              // goToComment(groupFeedList);
            },
            countDown: _commonHelper!
                .getTimeDifference(_aList![index].insertDate ?? 0),
          )
        : CommentCard(
            moreOnTapIcon: false,
            userProfile: _aList![index].userProfilePic.toString(),
            username: _aList![index].userName.toString(),
            content: _aList![index].comment.toString(),
            likeImage: isLike == true ? IconsHelper.like : IconsHelper.unLike,
            likeOnTap: () {
              isLike = isLike;
              // goToLike(groupFeedList);
            },
            likeCount: "",
            likeTextOnTap: () {
              // _commonHelper?.startActivity(
              //     CarnivalLikeListActivity(groupFeedList.carnivalFeedId.toString()));
            },
            commentTextOnTap: () {
              // goToComment(groupFeedList);
            },
            commentCount: "",
            commentOnTap: () {
              // goToComment(groupFeedList);
            },
            countDown: _commonHelper!
                .getTimeDifference(_aList![index].insertDate ?? 0),
          );
  }

  Widget reviewList() {
    return Visibility(
      visible: _eventList![0].endEpoch! <
          DateTime.now().millisecondsSinceEpoch / 1000,
      child: Container(
        width: _commonHelper?.screenWidth * .7,
        margin: EdgeInsets.only(
            left: DimensHelper.halfSides,
            right: DimensHelper.halfSides,
            top: DimensHelper.halfSides),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: DimensHelper.halfSides),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DimensHelper.sidesMargin)),
                elevation: 3.0,
                child: Container(
                  padding: EdgeInsets.all(DimensHelper.sidesMargin),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipOval(
                              child: CachedNetworkImage(
                                  imageUrl: mineProfile,
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      imagePlaceHolder(),
                                  errorWidget: (context, url, error) =>
                                      imagePlaceHolder())),
                          Expanded(
                            child: Container(
                              width: _commonHelper?.screenWidth * .6,
                              margin:
                                  EdgeInsets.only(left: DimensHelper.halfSides),
                              child: Text(mineUserName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.black,
                                      fontSize: Constants.FONT_TOP)),
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              if (isEditReview) {
                                _onEditTap(currentReviewId.toString());
                              } else {
                                _onSendCommentTapReview();
                              }
                            },
                            child: Container(
                              child: Text(StringHelper.reviews,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.spanishGray,
                                      fontSize: Constants.FONT_MEDIUM)),
                            ),
                          )
                        ],
                      ),
                      TextFormField(
                        controller: _sendCommentController,
                        cursorColor: SoloColor.blue,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        focusNode: _sendReviewFocusNode,
                        minLines: 1,
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: Constants.FONT_TOP,
                          color: SoloColor.black,
                        ),
                        decoration: InputDecoration(
                            hintText: StringHelper.writeSomething,
                            hintStyle: TextStyle(
                                fontSize: Constants.FONT_TOP,
                                color: SoloColor.black)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget minePostedFeed() {
    return _eventList![0].latestFiveEventReviews!.isNotEmpty
        ? ListView.separated(
            shrinkWrap: true,
            reverse: true,
            padding: EdgeInsets.only(
                top: DimensHelper.sidesMargin,
                left: DimensHelper.sidesMargin,
                right: DimensHelper.sidesMargin),
            physics: ScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) {
              return Divider(color: SoloColor.silverSand, height: 1);
            },
            itemCount: _eventList![0].latestFiveEventReviews!.length,
            itemBuilder: (BuildContext context, int index) {
              return carnivalFeedItem(
                  _eventList![0].latestFiveEventReviews![index], index);
            })
        : Container();
  }

  Widget carnivalFeedItem(
      LatestFiveEventReviews latestFiveEventReview, int index) {
    return Container(
      margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
      child: Column(
        children: [
          Stack(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: ClipOval(
                            child: CachedNetworkImage(
                                imageUrl: latestFiveEventReview.userProfilePic
                                    .toString(),
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    imagePlaceHolder(),
                                errorWidget: (context, url, error) =>
                                    imagePlaceHolder())),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: DimensHelper.halfSides),
                        width: _commonHelper?.screenWidth * .6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(latestFiveEventReview.userName.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: SoloColor.black,
                                    fontSize: Constants.FONT_TOP)),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: DimensHelper.smallSides),
                              child: Text(
                                  _commonHelper!.getTimeDifference(
                                      latestFiveEventReview.insertDate ?? 0),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.spanishGray,
                                      fontSize: Constants.FONT_LOW)),
                            )
                          ],
                        ),
                      )
                    ],
                  )),
              GestureDetector(
                onTap: () {
                  _hideKeyBoard();
                  showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return _showBottomSheetEditDel(
                            latestFiveEventReview.reviewId.toString(),
                            latestFiveEventReview,
                            index);
                      });
                },
                child: Visibility(
                  visible: latestFiveEventReview.userId == mineUserId,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        child:
                            Icon(Icons.more_vert, color: SoloColor.spanishGray),
                      )),
                ),
              )
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
                top: DimensHelper.halfSides, bottom: DimensHelper.sidesMargin),
            child: Text(
              latestFiveEventReview.review.toString(),
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: Constants.FONT_MEDIUM,
                  color: SoloColor.spanishGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showBottomSheetEditDelValueData(
      String editNewEventId, int index, String comment) {
    return CupertinoActionSheet(actions: [
      CupertinoActionSheetAction(
        child: Text(StringHelper.edit,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        onPressed: () {
          Navigator.pop(context);

          setState(() {
            isEditComment = true;

            editNewEventID = editNewEventId;

            _sendCommentController.text = comment;

            _sendCommentController.selection = TextSelection.fromPosition(
                TextPosition(offset: _sendCommentController.text.length));

            FocusScope.of(context).requestFocus(_sendCommentFocusNode);
          });
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
              builder: (BuildContext context) =>
                  _showDeleteBottomSheetData(editNewEventId, index));
        },
      ),
    ]);
  }

  Widget _showDeleteBottomSheetData(String commentId, int index) {
    return CupertinoActionSheet(
      title: Text(StringHelper.deleteComments,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.deleteCommentsMsg,
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
            _deleteCommentValue(commentId, index);
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

  Widget _showBottomSheetEditDel(
    String id,
    LatestFiveEventReviews aList,
    int index,
  ) {
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
                  _showEditBottomSheet(id, aList, index));
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
              builder: (BuildContext context) =>
                  _showDeleteBottomSheet(id, aList, index));
        },
      ),
    ]);
  }

  Widget _showDeleteBottomSheet(
      String delId, LatestFiveEventReviews aList, int index) {
    return CupertinoActionSheet(
      title: Text(StringHelper.DeleteReviews,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.DeleteReviewsMsg,
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

            _deleteComment(delId, index);
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

  Widget _showEditBottomSheet(
      String edit, LatestFiveEventReviews reviewList, int index) {
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

            // editCarnivalFeedId = carnivalFeedId;
            isEditReview = true;

            currentReviewId = reviewList.reviewId;

            _sendCommentController.text = reviewList.review.toString();

            _sendCommentController.selection = TextSelection.fromPosition(
                TextPosition(offset: _sendCommentController.text.length));

            FocusScope.of(context).requestFocus(_sendReviewFocusNode);
            // Navigator.pop(context);

            // _editButtonTap(edit, eventList);
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
            isEditReview = false;

            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget topView() {
    return Container(
      height: _commonHelper?.screenHeight * .35,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DimensHelper.sidesMargin),
              child: Container(
                height: _commonHelper?.screenHeight * .35,
                child: CachedNetworkImage(
                  width: _commonHelper?.screenWidth,
                  imageUrl: _eventList![0].image.toString(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => imagePlaceHolder(),
                  errorWidget: (context, url, error) => imagePlaceHolder(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 80,
              width: _eventList?[0].image?.length == 1 ? 125 : 250,
              margin: EdgeInsets.only(top: _commonHelper?.screenHeight * .35),
              child: ListView.builder(
                  itemCount: _eventList?[0].image?.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return carnivalImages(_eventList![0].image![index]);
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: _commonHelper?.screenHeight * .35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DimensHelper.sidesMargin),
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
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: _commonHelper?.screenHeight * .35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DimensHelper.sidesMargin),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: !isCurrentUser,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _isEventJoined
                            ? _joinedCarnivalUi()
                            : _disJoinedCarnivalUi(),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          children: [
                            Image.asset(
                              IconsHelper.ic_locationPin,
                              width: _commonHelper!.screenWidth * 0.07,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              width: _commonHelper?.screenWidth * 0.8,
                              child: Text(
                                _eventList![0].locationName.toString(),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: SoloColor.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: Constants.FONT_TOP),
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomRow() {
    return GestureDetector(
      onTap: () {},
      child: Container(
          width: _commonHelper?.screenWidth,
          child: Row(
            children: [
              Image.asset(
                IconsHelper.ic_locationPin,
                width: _commonHelper!.screenWidth * 0.07,
                fit: BoxFit.cover,
              ),
              Container(
                width: _commonHelper?.screenWidth * 0.8,
                child: Text(
                  _eventList![0].locationName.toString(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: SoloColor.white,
                      fontWeight: FontWeight.normal,
                      fontSize: Constants.FONT_TOP),
                ),
              )
            ],
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
          _eventList![0].eventLatestFiveMembers!.length > 0
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(55.0)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 2.0,
                        color: SoloColor.spanishGray.withOpacity(0.7),
                      ),
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
                            imageUrl: _eventList![0]
                                .eventLatestFiveMembers![0]
                                .userProfilePic
                                .toString(),
                            placeholder: (context, url) => imagePlaceHolder(),
                            errorWidget: (context, url, error) =>
                                imagePlaceHolder())),
                  ),
                )
              : SizedBox(),
          _eventList![0].eventLatestFiveMembers!.length > 1
              ? Positioned(
                  left: _commonHelper!.screenWidth * 0.06,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(55.0)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 2.0,
                          color: SoloColor.spanishGray.withOpacity(0.7),
                        ),
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
                              imageUrl: _eventList![0]
                                  .eventLatestFiveMembers![1]
                                  .userProfilePic
                                  .toString(),
                              placeholder: (context, url) => imagePlaceHolder(),
                              errorWidget: (context, url, error) =>
                                  imagePlaceHolder())),
                    ),
                  ))
              : SizedBox(),
          _eventList![0].eventLatestFiveMembers!.length > 2
              ? Positioned(
                  left: _commonHelper!.screenWidth * 0.12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(55.0)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 2.0,
                          color: SoloColor.spanishGray.withOpacity(0.7),
                        ),
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
                              imageUrl: _eventList![0]
                                  .eventLatestFiveMembers![2]
                                  .userProfilePic
                                  .toString(),
                              placeholder: (context, url) => imagePlaceHolder(),
                              errorWidget: (context, url, error) =>
                                  imagePlaceHolder())),
                    ),
                  ),
                )
              : SizedBox(),
          _eventList![0].eventLatestFiveMembers!.length > 3
              ? Positioned(
                  left: _commonHelper!.screenWidth * 0.17,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(55.0)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 2.0,
                          color: SoloColor.spanishGray.withOpacity(0.7),
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
                          '+${_eventList![0].eventLatestFiveMembers!.length - 3}',
                          style: SoloStyle.smokeWhiteW70010Rob
                              .copyWith(fontSize: 11),
                        ),
                      ),
                    ),
                  ))
              : SizedBox(),
        ],
      ),
    );
  }

  Widget likeComment({
    required String text,
    required String icon,
    Function()? onTap,
    Function()? textTap,
  }) {
    return Row(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            child: SvgPicture.asset(
              icon,
              color: SoloColor.jet.withOpacity(0.9),
              width: 15,
            ),
          ),
        ),
        space(width: 5),
        text.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 5),
                child: InkWell(
                  onTap: textTap,
                  child: Text(
                    text,
                    style: SoloStyle.darkBlackW800SmallMax,
                  ),
                ),
              )
      ],
    );
  }

  Widget commentList() {
    return StreamBuilder(
        stream: _eventCommentListBloc?.commentFeedList,
        builder: (context, AsyncSnapshot<EventCommentResponse> snapshot) {
          if (snapshot.hasData) {
            if (_aList == null || _aList!.isEmpty) {
              _aList = snapshot.data?.data?.eventCommentsList;
              if (widget.scrollMessage == true) {
                pos = _aList!.indexWhere((innerElement) =>
                    innerElement.eventCommentId == widget.publicCommentId);
                print(_aList!.indexWhere((innerElement) =>
                    innerElement.eventCommentId == widget.publicCommentId));

                if (pos == _aList!.length - 1) {
                  Future.delayed(Duration.zero, () => _animateScrolling());
                } else {
                  Future.delayed(
                      Duration.zero, () => _animateScrollingMessage(pos));
                }

                // return _commentListData(pos);
              } else {
                Future.delayed(Duration.zero, () => _animateScrolling());

                //return _commentListData(-1);
              }
            }
            return _commentListData(pos);
          } else if (snapshot.hasError) {
            return Container();
          }
          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
        });
  }

  List<Widget> _sliverWidgets(BuildContext context) {
    if (_eventList?[0].userId == mineUserId) {
      isCurrentUser = true;
    } else {
      isCurrentUser = false;
    }
    _isEventJoined = _eventList?[0].isEventJoined == true;
    var originalStartDate = _eventList![0].startDate.toString();

    var comments;

    if (_eventList?[0].totalComments == 0) {
      comments = "";
    } else {
      var titleComment = _eventList?[0].totalComments == 1 ? "" : "";

      comments = '${_eventList?[0].totalComments.toString()} $titleComment';
    }

    var likes;
    if (_eventList?[0].totalLikes == 0) {
      likes = "";
    } else {
      var titleLikes = _eventList?[0].totalLikes == 1 ? "" : "";

      likes = '${_eventList?[0].totalLikes.toString()} $titleLikes';
    }
    _randomChildren = [
      Container(
        color: SoloColor.white,
        child: Column(
          children: [
            topView(),
            space(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        IconsHelper.person_pin,
                        width: _commonHelper!.screenWidth * 0.07,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        width: _commonHelper?.screenHeight * 0.22,
                        margin: EdgeInsets.only(
                            left: DimensHelper.borderRadius,
                            right: DimensHelper.smallSides),
                        child: Text(
                          _eventList![0].host.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: SoloStyle.darkBlackW70020Rob,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      likeComment(
                        text: likes,
                        onTap: () {
                          if (_eventList?[0].isLike == true) {
                            setState(() {
                              var totalLikes =
                                  _eventList?[0].totalLikes ?? 0 - 1;
                              _eventList?[0].totalLikes = totalLikes;
                              _eventList?[0].isLike = false;
                            });
                            _onUnLikeButtonTap(
                                _eventList![0].eventId.toString());
                          } else {
                            setState(() {
                              var totalLikes =
                                  _eventList?[0].totalLikes ?? 0 + 1;
                              _eventList?[0].totalLikes = totalLikes;
                              _eventList?[0].isLike = true;
                            });
                            _onLikeButtonTap(_eventList![0].eventId.toString());
                          }
                        },
                        icon: _eventList?[0].isLike == true
                            ? IconsHelper.unLike
                            : IconsHelper.like,
                        textTap: widget.likeOnTap,
                      ),
                      likeComment(
                          text: comments,
                          textTap: () {
                            _hideKeyBoard();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EventsCommentActivity(
                                      eventId: _eventList?[0].eventId,
                                      showKeyBoard: false,
                                      scrollMessage: false)),
                            ).then((value) {
                              if (value != null && value) {
                                _showProgress();

                                _aList?.clear();
                                _eventList?.clear();

                                getEvents("", "", "",
                                    widget.eventContinent.toString());
                              }
                            });
                          },
                          icon: IconsHelper.message),
                    ],
                  ),
                ],
              ),
            ),
            space(height: 5),
            Container(
              margin: EdgeInsets.only(
                  top: DimensHelper.halfSides,
                  left: DimensHelper.sidesMargin,
                  right: DimensHelper.sidesMargin),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  _eventList![0].description.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: Constants.FONT_MEDIUM,
                      color: SoloColor.spanishGray),
                ),
              ),
            ),
            space(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Image.asset(
                    IconsHelper.ic_calender,
                    width: _commonHelper!.screenWidth * 0.06,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: DimensHelper.tinySides,
                        right: DimensHelper.tinySides),
                    child: Text(
                      '${getFormattedDate(_eventList![0].startDate.toString(), true)} - ${getFormattedDate(_eventList![0].endDate.toString(), false)}',
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
                        left: DimensHelper.tinySides,
                        right: DimensHelper.tinySides),
                    child: Text(
                      "${_eventList![0].startTime.toString()} - ${_eventList![0].endTime.toString()}",
                      style: SoloStyle.darkBlackW70015Rob,
                    ),
                  ),
                ],
              ),
            ),
            if (_eventList![0].eventLatestFiveMembers!.length > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Divider(
                    color: SoloColor.silverSand.withOpacity(0.2), thickness: 1),
              ),
            if (_eventList![0].eventLatestFiveMembers!.length > 0)
              Visibility(
                child: Container(
                    width: _commonHelper?.screenWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: SoloColor.spanishGray.withOpacity(0.1),
                          blurRadius: 1,
                          spreadRadius: 0.10,
                          offset: Offset(
                            0.0, // Move to right 10  horizontally
                            3.0, // Move to bottom 10 Vertically
                          ),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 7,
                          right: 10,
                          top: 3,
                        ),
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(
                                  left: DimensHelper.sidesMargin,
                                  right: DimensHelper.sidesMargin),
                              child: Text(
                                StringHelper.attendees,
                                style: SoloStyle.darkBlackW70020Rob,
                              ),
                            ),
                            // Spacer(),
                            memberList(),

                            GestureDetector(
                              onTap: () {
                                _commonHelper?.startActivity(
                                    MembersListActivity(
                                        membersList: _eventMemberList ?? []));
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
                        ),
                      ),
                    )),
              ),
          ],
        ),
      )
    ];

    return _randomChildren;
  }

  Widget mainList() {
    return Column(
      children: [
        Expanded(
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
            // You tab view goes here
            body: Container(
              color: SoloColor.white,
              child: Column(
                children: <Widget>[
                  Container(
                      width: _commonHelper?.screenWidth,
                      margin: EdgeInsets.only(
                          top: DimensHelper.sidesMargin,
                          right: DimensHelper.sidesMargin),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(
                                left: DimensHelper.searchBarMargin,
                                right: DimensHelper.sidesMargin),
                            child: Text(
                              StringHelper.comments,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: SoloColor.black),
                            ),
                          ),
                        ],
                      )),
                  commentList(),
                ],
              ),
            ),
          ),
        ),
        CommentHelper.sendCommentField(
          context,
          onSend: () {
            isEditComment
                ? _onEditCommentTap(replyId.toString())
                : _onSendCommentTap(replyId.toString());
          },
          controller: _sendCommentController,
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

  void _joinCarnivalTap() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "eventId": widget.eventId,
        });

        _apiHelper?.joinEvent(body.toString(), authToken).then((onSuccess) {
          _hideProgress();

          setState(() {
            _isEventJoined = true;
          });
          _eventList?.clear();
          _getEventDetail();

          //_getCurrentLocation(_carnivalList[0].location);
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _disJoinCarnivalTap() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "eventId": widget.eventId,
        });

        _apiHelper?.disJoinEvent(body.toString(), authToken).then((onSuccess) {
          _hideProgress();

          setState(() {
            _isEventJoined = false;

            // _isCheckInAvailable = false;
          });
          _eventList?.clear();

          _getEventDetail();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _deleteCommentValue(var commentId, int index) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token!;

          _showProgress();
          _eventCommentListBloc
              ?.deleteComment(token.toString(), commentId)
              .then((onValue) {
            if (onValue) {
              refreshData = true;
              // _aList.removeAt(index);
              _hideProgress();
              _aList?.clear();
              _getEventCommentList();

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(StringHelper.deleteSuccessfully),
              ));
            } else {
              _hideProgress();

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(StringHelper.deleteUnsuccessful),
              ));
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

  void _deleteComment(var commentId, int index) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token.toString();
          _showProgress();

          _evenyReviewBloc
              ?.deleteEventReview(token.toString(), commentId)
              .then((onValue) {
            if (onValue.statusCode == 200) {
              refreshData = true;
              _eventList?[0].latestFiveEventReviews?.removeAt(index);
              _eventList?.clear();

              _hideProgress();
              _getEventDetail();

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(StringHelper.deleteSuccessfully),
              ));
              _getEventCommentList();
            } else {
              _hideProgress();

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(StringHelper.deleteUnsuccessful),
              ));
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

  void _onEditTap(String currentReviewId) {
    //widget.scrollMessage = false;

    FocusScope.of(context).unfocus();

    if (_sendCommentController.text.toString().isEmpty) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _commonHelper!.successBottomSheet(
              StringHelper.error, StringHelper.writeSomethingMsg, false));

      return;
    }

    if (_sendCommentController.text.length > 100) {
      _commonHelper?.showAlert(StringHelper.alert, StringHelper.reviewAlertMsg);
      return;
    }

    var body = json.encode({
      "reviewId": currentReviewId,
      "review": _sendCommentController.text.toString()
    });

    _sendCommentController.text = "";

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _evenyReviewBloc?.updateEventReview(authToken, body).then((onValue) {
          _hideProgress();

          _eventList?.clear();
          isEditReview = false;
          // _eventList[0].latestFiveEventReviews.clear();
          _getEventDetail();
          //   _getEventCommentList();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  String getFormattedDate(String startDate, bool isStartDate) {
    var inputFormat = DateFormat('MM/dd/yyyy');
    var inputDate = inputFormat.parse(startDate); // <-- dd/MM 24H format

    var outputFormat = DateFormat(isStartDate ? 'dd MMM yyyy' : 'dd MMM yyyy');
    var outputDate = outputFormat.format(inputDate);
    print(outputDate); // 12/31/2000 11:59 PM <-- MM/dd 12H format
    return outputDate;
  }

  void getEvents(String text, String lat, String lng, String eventContinent) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token!;
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

  void _animateScrollingMessage(int pos) {
    var position = pos + 1;
    Timer(Duration(milliseconds: 500),
        () => _scrollController?.jumpTo(position.toDouble()));
  }

  void _animateScrolling() {
    Timer(
        Duration(milliseconds: 500),
        () => _scrollController
            ?.jumpTo(_scrollController!.position.maxScrollExtent));
  }

  void _onEditCommentTap(String editCommentId) {
    FocusScope.of(context).unfocus();

    if (_sendCommentController.text.toString().isEmpty) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _commonHelper!.successBottomSheet(
              StringHelper.error, StringHelper.writeSomethingMsg, false));

      return;
    }

    var body = json.encode({
      "commentId": editNewEventID,
      "comment": _sendCommentController.text.toString()
    });

    _sendCommentController.text = "";

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _apiHelper
            ?.updateNewEventCommentBlog(body, authToken.toString())
            .then((onValue) {
          setState(() {
            isEditComment = false;
          });
          _aList?.clear();

          _getEventCommentList();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onSendCommentTap(String publicCommentId) {
    widget.scrollMessage = false;

    if (_sendCommentController.text.toString().trim().isEmpty) {
      if (replyId!.isEmpty) {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _commonHelper!
                .successBottomSheet(StringHelper.invalidComment,
                    StringHelper.emptyComment, false));
      } else {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _commonHelper!
                .successBottomSheet(
                    StringHelper.invalidReply, StringHelper.emptyReply, false));
      }

      return;
    }

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body;

        if (publicCommentId.isEmpty) {
          body = json.encode({
            "eventId": widget.eventId,
            "comment": _sendCommentController.text.toString()
          });
        } else {
          body = json.encode({
            "eventId": widget.eventId,
            "comment": _sendCommentController.text.toString(),
            "eventCommentId": publicCommentId
          });
        }

        _sendCommentController.text = "";

        _eventCommentListBloc
            ?.submitFeedComment(authToken.toString(), body)
            .then((onValue) {
          refreshData = true;

          _hideKeyBoard();

          _aList?.clear();

          _getEventCommentList();
        }).catchError((onError) {
          _hideKeyBoard();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
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

  void _getEventCommentList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token!;

          _showProgress();

          _eventCommentListBloc
              ?.getEventCommentList(token.toString(), widget.eventId.toString())
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

  void _getEventDetail() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token.toString();
          _showProgress();
          _eventCommentListBloc
              ?.getEventDetail(authToken, widget.eventId.toString())
              .then((onValue) {
            _hideProgress();
            if (onValue!.statusCode == 200) {
              if (onValue.data!.eventList!.isNotEmpty) {
                // _eventList = onValue.data?.eventList;
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

  void _getEventMembers() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token.toString();
          _showProgress();
          _eventCommentListBloc
              ?.getEventMembersList(authToken, widget.eventId.toString())
              .then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              if (onValue.data!.eventMemberList!.isNotEmpty) {
                _eventMemberList = onValue.data?.eventMemberList;
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

  Future<bool> _willPopCallback() async {
    if (widget.refresh == true) {
      _refreshData = widget.context;
      _refreshData?.updateData();
      Navigator.pop(context, refreshData);
    } else {
      Navigator.pop(context, refreshData);
    }

    // }
    return false;
  }

  void _onSendCommentTapReview() {
    //widget.scrollMessage = false;

    if (_sendCommentController.text.toString().trim().isEmpty) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _commonHelper!.successBottomSheet(
              StringHelper.invalidReview,
              StringHelper.invalidReviewMsg,
              false));

      return;
    }

    if (_sendCommentController.text.length > 100) {
      _commonHelper?.showAlert(StringHelper.alert, StringHelper.reviewAlertMsg);
      return;
    }

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body;

        body = json.encode({
          "eventId": widget.eventId,
          "review": _sendCommentController.text.toString()
        });

        _sendCommentController.text = "";

        _evenyReviewBloc?.submitFeedReview(authToken, body).then((onValue) {
          if (onValue.statusCode == 200) {
            _hideProgress();

            refreshData = true;

            _hideKeyBoard();

            _eventList?.clear();

            _getEventDetail();
          } else {
            _commonHelper?.showAlert(StringHelper.alert, onValue.data?.message);
            refreshData = true;
            _hideProgress();

            _hideKeyBoard();
          }
        }).catchError((onError) {
          _hideKeyBoard();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }

  void _onFeedChanged(String value) {
    if (value.isEmpty) {
      setState(() {});

      return;
    }
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

  void _editButtonTap(String id, EventList eventList) {
    _hideKeyBoard();

    _commonHelper
        ?.startActivity(EventsDetailsActivity(
            eventList: eventList, isFrom: true, context: this))
        .then((value) {
      if (value) {
        _showProgress();

        // _getProfileData();
      }
    });
  }

  void _deleteButtonTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _eventBloc?.deleteEvent(authToken.toString(), feedId).then((onValue) {
          aListData.clear();
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
}
