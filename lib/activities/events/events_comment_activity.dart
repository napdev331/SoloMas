import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
// import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:solomas/blocs/event_details/event_comment_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/events_comment_response.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/comment_helper.dart';
import '../../helpers/space.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';

class EventsCommentActivity extends StatefulWidget {
  final String? eventId;

  final String? publicCommentId;

  final bool showKeyBoard;

  bool? scrollMessage;

  EventsCommentActivity(
      {this.eventId,
      this.showKeyBoard = false,
      this.scrollMessage,
      this.publicCommentId});

  @override
  _EventsCommentActivityState createState() => _EventsCommentActivityState();
}

class _EventsCommentActivityState extends State<EventsCommentActivity> {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  EventCommentListBloc? _eventCommentListBloc;
  String? authToken, replyId = "", mineUserId;
  List<EventCommentsList>? _aList;
  ScrollController? _scrollController;
  bool _progressShow = false, refreshData = false;
  var _sendCommentController = TextEditingController();
  var _sendCommentFocusNode = FocusNode();
  var pos = -1;
  bool isEditComment = false;
  String? editNewEventID;
  ApiHelper? _apiHelper;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    Constants.isNavigated = false;
    _apiHelper = ApiHelper();
    _aList = [];

    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });

    _scrollController = ScrollController();
    _eventCommentListBloc = EventCommentListBloc();
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (!visible) {
        replyId = "";
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _getEventCommentList());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SoloScaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: _appBar(context),
          ),
        ),
        body: _mainBody(_commentListData),
      ),
    );
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _mainBody(Widget _commentListData(int pos)) {
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

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.comments,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget _showBottomSheetEditDel(
      String editNewEventId, int index, String comment) {
    return CupertinoActionSheet(actions: [
      CupertinoActionSheetAction(
        child: Text(StringHelper.edit, style: SoloStyle.blackW500FontTop),
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
        child: Text(StringHelper.delete, style: SoloStyle.blackW500FontTop),
        onPressed: () {
          Navigator.pop(context);

          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) =>
                  _showDeleteBottomSheet(editNewEventId, index));
        },
      ),
    ]);
  }

  Widget _showDeleteBottomSheet(String editBlogId, int index) {
    return CupertinoActionSheet(
      title:
          Text(StringHelper.deleteComments, style: SoloStyle.blackW500FontTop),
      message: Text(StringHelper.deleteCommentsMsg,
          style: SoloStyle.spanishGrayW400FontMedium),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes, style: SoloStyle.blackW500FontTop),
          onPressed: () {
            Navigator.pop(context);
            _deleteComment(editBlogId, index);
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _aList![index].userName.toString(),
                                    style: TextStyle(
                                        color: SoloColor.lightGrey200,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 35),
                                    child: GestureDetector(
                                      onTap: () {
                                        showCupertinoModalPopup(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return _showBottomSheetEditDel(
                                                  _aList![index]
                                                      .eventCommentId
                                                      .toString(),
                                                  index,
                                                  _aList![index]
                                                      .comment
                                                      .toString());
                                            });
                                      },
                                      child: Container(
                                        height:
                                            _commonHelper?.screenHeight * 0.025,
                                        width:
                                            _commonHelper?.screenWidth * 0.050,
                                        child: Image.asset(
                                          IconsHelper.comment_doted,
                                          //width: 17,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              space(height: 3),
                              Text(
                                _aList![index].comment.toString(),
                              ),
                              space(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            replyId =
                                                _aList?[index].eventCommentId;

                                            FocusScope.of(context).requestFocus(
                                                _sendCommentFocusNode);
                                          },
                                          child: Text(StringHelper.reply))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                                        style:
                                            SoloStyle.lightGrey200W600MediumXs,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _aList![index].userName.toString(),
                                    style: TextStyle(
                                        color: SoloColor.lightGrey200,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              space(height: 3),
                              Text(
                                _aList![index].comment.toString(),
                              ),
                              space(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            replyId =
                                                _aList?[index].eventCommentId;

                                            FocusScope.of(context).requestFocus(
                                                _sendCommentFocusNode);
                                          },
                                          child: Text(StringHelper.reply))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                                        style:
                                            SoloStyle.lightGrey200W600MediumXs,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          );
  }

  Widget _commentListData(int pos) {
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
                  bottom: DimensHelper.halfSides, top: DimensHelper.halfSides),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _aList?.length,
                padding: EdgeInsets.only(bottom: 56),
                itemBuilder: (context, index) {
                  return CommentHelper.userDetails(
                    context,
                    index,
                    userName: _aList![index].userName.toString(),
                    threeDotTap: () {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
                            return _showBottomSheetEditDel(
                                _aList![index].eventCommentId.toString(),
                                index,
                                _aList![index].comment.toString());
                          });
                    },
                    content: _aList![index].comment.toString(),
                    replyTap: () {
                      replyId = _aList?[index].eventCommentId;

                      FocusScope.of(context)
                          .requestFocus(_sendCommentFocusNode);
                    },
                    commentTime:
                        "${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}",
                    replyCount: _aList![index].replyData!.length,
                    replyBuilder: (context, replyDataIndex) {
                      return CommentHelper.replyItem(context,
                          listIndex: index,
                          replyData: _aList![index].replyData![replyDataIndex],
                          replyIndex: replyDataIndex,
                          viewAllTap: () {
                            setState(() {
                              _aList?[index].showReplies = true;
                            });
                          },
                          viewAllReply:
                              _aList?[index].replyData?.isNotEmpty == true &&
                                  replyDataIndex == 0 &&
                                  _aList?[index].showReplies == false,
                          viewAllReplyLength:
                              '${_aList?[index].replyData?.length.toString()}',
                          viewAllReplyComment:
                              _aList?[index].showReplies == true,
                          replyProfileImage: _aList![index]
                              .replyData![replyDataIndex]
                              .userProfilePic
                              .toString(),
                          replyUserName: _aList![index]
                              .replyData![replyDataIndex]
                              .userName
                              .toString(),
                          replyCommentThreeDotTap: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) {
                                  return _showBottomSheetEditDel(
                                      _aList![index]
                                          .replyData![replyDataIndex]
                                          .replyCommentId
                                          .toString(),
                                      index,
                                      _aList![index]
                                          .replyData![replyDataIndex]
                                          .comment
                                          .toString());
                                });
                          },
                          visibilityCommentThreeDot: _aList![index]
                                  .replyData![replyDataIndex]
                                  .userId ==
                              mineUserId,
                          replyCommentData: _aList![index]
                              .replyData![replyDataIndex]
                              .comment
                              .toString(),
                          replyCommentTime: _commonHelper!.getTimeDifference(
                              _aList![index]
                                      .replyData![replyDataIndex]
                                      .insertDate ??
                                  0));
                    },
                    idCheck: _aList?[index].userId == mineUserId ? true : false,
                    profilePic: _aList![index].userProfilePic.toString(),
                  );
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
                child: CommentHelper.sendCommentField(context, onSend: () {
                  isEditComment
                      ? _onEditCommentTap(replyId.toString())
                      : _onSendCommentTap(replyId.toString());
                },
                    controller: _sendCommentController,
                    autofocus: widget.showKeyBoard!,
                    focusNode: _sendCommentFocusNode,
                    id: replyId!),
              ),
            ],
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
            child:
                ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
            alignment: FractionalOffset.center,
          )
        ],
      ),
    );
  }

//============================================================
// ** Helper Function **
//============================================================

  Future<bool> _willPopCallback() async {
    Navigator.pop(context, refreshData);

    return false;
  }

  void _getEventCommentList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

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

  void _deleteComment(var commentId, int index) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _showProgress();
          _eventCommentListBloc
              ?.deleteComment(token.toString(), commentId)
              .then((onValue) {
            if (onValue) {
              refreshData = true;
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
              _deleteComment(commentId, index);
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

  void _hideKeyBoard() {
    replyId = "";

    FocusScope.of(context).unfocus();
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
}
