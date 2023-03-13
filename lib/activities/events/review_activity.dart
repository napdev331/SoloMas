import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/blocs/event_details/event_review_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/event_review_response.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';

class ReviewActivity extends StatefulWidget {
  final String? eventId;

  final String? publicCommentId;

  final bool showKeyBoard;

  bool? scrollMessage;

  ReviewActivity(
      {this.eventId,
      this.showKeyBoard = false,
      this.scrollMessage,
      this.publicCommentId});

  @override
  _ReviewActivityState createState() => _ReviewActivityState();
}

class _ReviewActivityState extends State<ReviewActivity> {
  CommonHelper? _commonHelper;
  EventReviewBloc? _evenyReviewBloc;

  String? authToken, replyId = "", mineUserId;
  List<ReviewList>? _aList;

  ScrollController? _scrollController;

  bool _progressShow = false, refreshData = false;

  var _sendCommentController = TextEditingController();

  var _sendCommentFocusNode = FocusNode();

  var pos = -1;

  bool isEditReview = false;

  String? currentReviewId;

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

  Future<bool> _willPopCallback() async {
    Navigator.pop(context, refreshData);

    return false;
  }

  @override
  void initState() {
    super.initState();

    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });

    _scrollController = ScrollController();

    _evenyReviewBloc = EventReviewBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getEventCommentList());
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

  void _getEventCommentList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _evenyReviewBloc
              ?.getEventReviewList(token.toString(), widget.eventId.toString())
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

  Widget userDetails1(int index) {
    return _aList?[index].userId == mineUserId
        ? Container(
            color: SoloColor.blueWhite,
            padding: EdgeInsets.only(
                left: DimensHelper.sidesMargin, top: DimensHelper.sidesMargin),
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding:
                                EdgeInsets.only(right: DimensHelper.halfSides),
                            child: profileImage(index),
                          ),
                        ),
                        Container(
                          width: _commonHelper?.screenWidth * .7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_aList![index].userName.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.black,
                                      fontSize: Constants.FONT_TOP)),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: DimensHelper.smallSides),
                                child: RichText(
                                    text: TextSpan(
                                  text:
                                      '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.spanishGray,
                                      fontSize: Constants.FONT_LOW),
                                  children: [],
                                )),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: DimensHelper.smallSides),
                                child: Text(_aList![index].review.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: SoloColor.spanishGray,
                                        fontSize: Constants.FONT_MEDIUM)),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
                GestureDetector(
                  onTap: () {
                    _hideKeyBoard();
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
          )
        : Container(
            color: SoloColor.blueWhite,
            padding: EdgeInsets.only(
                left: DimensHelper.sidesMargin, top: DimensHelper.sidesMargin),
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding:
                                EdgeInsets.only(right: DimensHelper.halfSides),
                            child: profileImage(index),
                          ),
                        ),
                        Container(
                          width: _commonHelper?.screenWidth * .7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_aList![index].userName.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.black,
                                      fontSize: Constants.FONT_TOP)),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: DimensHelper.smallSides),
                                child: RichText(
                                    text: TextSpan(
                                  text:
                                      '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.spanishGray,
                                      fontSize: Constants.FONT_LOW),
                                  children: [],
                                )),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: DimensHelper.smallSides),
                                child: Text(_aList![index].review.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: SoloColor.spanishGray,
                                        fontSize: Constants.FONT_MEDIUM)),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ],
            ),
          );
  }

  Future<bool>? dialogCommentDel(
      BuildContext context, String commentId, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(DimensHelper.sidesMargin))),
        title: Text(StringHelper.deleteComment),
        titleTextStyle: TextStyle(
            fontSize: DimensHelper.sidesMargin, color: SoloColor.black),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(StringHelper.no,
                style: TextStyle(
                    color: SoloColor.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: DimensHelper.sidesMargin)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              // _deleteComment(commentId, index);
            },
            child: Text(StringHelper.yes,
                style: TextStyle(
                    color: SoloColor.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: DimensHelper.sidesMargin)),
          ),
        ],
      ),
    );
    //  ??
    // false;
    return null;
  }

  Widget userDetails(int index) {
    return _aList?[index].userId == mineUserId
        ? Container(
            padding: EdgeInsets.only(
                left: DimensHelper.sidesMargin, top: DimensHelper.sidesMargin),
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding:
                                EdgeInsets.only(right: DimensHelper.halfSides),
                            child: profileImage(index),
                          ),
                        ),
                        Container(
                          width: _commonHelper?.screenWidth * .7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_aList![index].userName.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.black,
                                      fontSize: Constants.FONT_TOP)),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: DimensHelper.smallSides),
                                child: RichText(
                                    text: TextSpan(
                                  text:
                                      '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.spanishGray,
                                      fontSize: Constants.FONT_LOW),
                                  children: [],
                                )),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: DimensHelper.smallSides),
                                child: Text(_aList![index].review.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: SoloColor.spanishGray,
                                        fontSize: Constants.FONT_MEDIUM)),
                              ),
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
                              _aList![index].reviewId.toString(),
                              _aList![index],
                              index);
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
          )
        : Container(
            padding: EdgeInsets.only(
                left: DimensHelper.sidesMargin, top: DimensHelper.sidesMargin),
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding:
                                EdgeInsets.only(right: DimensHelper.halfSides),
                            child: profileImage(index),
                          ),
                        ),
                        Container(
                          width: _commonHelper?.screenWidth * .7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_aList![index].userName.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.black,
                                      fontSize: Constants.FONT_TOP)),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: DimensHelper.smallSides),
                                child: RichText(
                                    text: TextSpan(
                                  text:
                                      '${_commonHelper?.getTimeDifference(_aList![index].insertDate ?? 0)}          ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.spanishGray,
                                      fontSize: Constants.FONT_LOW),
                                  children: [],
                                )),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: DimensHelper.smallSides),
                                child: Text(_aList![index].review.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: SoloColor.spanishGray,
                                        fontSize: Constants.FONT_MEDIUM)),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ],
            ),
          );
  }

  void _onSendCommentTap(String publicCommentId) {
    widget.scrollMessage = false;

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

        if (publicCommentId.isEmpty) {
          body = json.encode({
            "eventId": widget.eventId,
            "review": _sendCommentController.text.toString()
          });
        } else {
          body = json.encode({
            "eventId": widget.eventId,
            "review": _sendCommentController.text.toString(),
            "eventCommentId": publicCommentId
          });
        }

        _sendCommentController.text = "";

        _evenyReviewBloc
            ?.submitFeedReview(authToken.toString(), body)
            .then((onValue) {
          if (onValue.statusCode == 200) {
            _hideKeyBoard();

            refreshData = true;

            _hideKeyBoard();

            _aList?.clear();

            _getEventCommentList();
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

  void _animateScrolling() {
    Timer(
        Duration(milliseconds: 500),
        () => _scrollController
            ?.jumpTo(_scrollController!.position.maxScrollExtent));
  }

  void _hideKeyBoard() {
    replyId = "";

    FocusScope.of(context).unfocus();
  }

  void _animateScrollingMessage(int pos) {
    var position = pos + 1;
    Timer(Duration(milliseconds: 500),
        () => _scrollController?.jumpTo(position.toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    Widget sendCommentField() {
      return Row(
        children: [
          Expanded(
              child: Container(
            width: _commonHelper?.screenWidth * .78,
            padding: EdgeInsets.only(
                top: DimensHelper.halfSides, bottom: DimensHelper.halfSides),
            margin: EdgeInsets.only(
                left: DimensHelper.sidesMargin,
                right: DimensHelper.sidesMargin),
            child: TextFormField(
              style: TextStyle(
                  fontSize: Constants.FONT_MEDIUM,
                  color: SoloColor.spanishGray),
              autofocus: widget.showKeyBoard,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 4,
              focusNode: _sendCommentFocusNode,
              onTap: () {
                replyId = "";

                _animateScrolling();
              },
              controller: _sendCommentController,
              cursorColor: SoloColor.blue,
              decoration: InputDecoration(
                  hintText: replyId!.isEmpty
                      ? StringHelper.writeAReview
                      : StringHelper.writeAReply,
                  hintStyle: TextStyle(color: SoloColor.spanishGray),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.send, color: SoloColor.blue),
                      onPressed: () {
                        if (isEditReview) {
                          _onEditTap(currentReviewId.toString());
                        } else {
                          _onSendCommentTap(replyId.toString());
                        }
                      }),
                  fillColor: SoloColor.white,
                  contentPadding: EdgeInsets.only(
                      top: DimensHelper.sidesMargin,
                      bottom: DimensHelper.sidesMargin,
                      left: DimensHelper.sidesMargin,
                      right: DimensHelper.sidesMargin),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(DimensHelper.sidesMarginDouble)),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(DimensHelper.sidesMarginDouble)),
                      borderSide:
                          BorderSide(color: SoloColor.blue, width: 0.0)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(DimensHelper.sidesMarginDouble)),
                      borderSide:
                          BorderSide(color: SoloColor.blue, width: 0.0))),
            ),
          )),
        ],
      );
    }

    Widget _reviewListData(int pos) {
      return Container(
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
                  controller: _scrollController,
                  itemCount: _aList?.length,
                  padding: EdgeInsets.only(bottom: 56),
                  itemBuilder: (context, index) {
                    return userDetails(index);
                  },
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  color: Colors.white,
                  child: sendCommentField(),
                ),
              ],
            ),
            Visibility(
              visible: _aList!.isEmpty,
              child: Container(
                height: _commonHelper?.screenHeight * .8,
                child: Center(
                  child: Text(StringHelper.noReviewEvent,
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
      );
    }

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SoloScaffold(
        appBar: AppBar(
          backgroundColor: SoloColor.blue,
          automaticallyImplyLeading: false,
          title: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context, refreshData);
                },
                child: Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.centerLeft,
                  child: Image.asset('images/back_arrow.png'),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(StringHelper.reviews.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Constants.FONT_APP_TITLE)),
              )
            ],
          ),
        ),
        body: StreamBuilder(
            stream: _evenyReviewBloc?.reviewList,
            builder: (context, AsyncSnapshot<ReviewResponse> snapshot) {
              if (snapshot.hasData) {
                if (_aList == null || _aList!.isEmpty) {
                  _aList = snapshot.data?.data?.reviewList;
                  if (widget.scrollMessage == true) {
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
                return _reviewListData(pos);
              } else if (snapshot.hasError) {
                return Container();
              }

              return Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(SoloColor.blue)));
            }),
      ),
    );
  }

  Widget _showBottomSheetEditDel(
    String id,
    ReviewList aList,
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

  Widget _showDeleteBottomSheet(String delId, ReviewList aList, int index) {
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

  Widget _showEditBottomSheet(String edit, ReviewList reviewList, int index) {
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
            // editCarnivalFeedId = carnivalFeedId;
            isEditReview = true;

            currentReviewId = reviewList.reviewId;

            _sendCommentController.text = reviewList.review.toString();

            _sendCommentController.selection = TextSelection.fromPosition(
                TextPosition(offset: _sendCommentController.text.length));

            FocusScope.of(context).requestFocus(_sendCommentFocusNode);
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

  void _deleteComment(var commentId, int index) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();

          _evenyReviewBloc
              ?.deleteEventReview(token.toString(), commentId)
              .then((onValue) {
            if (onValue.statusCode == 200) {
              refreshData = true;
              _aList?.removeAt(index);
              _aList?.clear();
              _hideProgress();
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

  void _onEditTap(String currentReviewId) {
    widget.scrollMessage = false;

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

        _evenyReviewBloc
            ?.updateEventReview(authToken.toString(), body)
            .then((onValue) {
          refreshData = true;
          isEditReview = false;

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
}
