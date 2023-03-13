import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:solomas/blocs/explore/carnival_photos_like_list_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/carnival_comment_photos.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../../../resources_helper/common_widget.dart';
import '../../../../resources_helper/screen_area/scaffold.dart';

class CarnivalPhotosComment extends StatefulWidget {
  final String? carnivalPhotoId;

  final String? publicCommentId;
  final bool showKeyBoard;

  bool? scrollMessage;

  CarnivalPhotosComment(
      {this.carnivalPhotoId,
      this.showKeyBoard = false,
      this.scrollMessage,
      this.publicCommentId});

  @override
  CarnivalPhotosCommentState createState() => CarnivalPhotosCommentState();
}

class CarnivalPhotosCommentState extends State<CarnivalPhotosComment> {
  CommonHelper? _commonHelper;

  CarnivalPhotosLikeBloc? _carnivalPhotosLikeBloc;

  String? authToken, replyId = "", mineUserId;
  List<CarnivalPhotoCommentsList>? _aList;

  ScrollController? _scrollController;

  bool _progressShow = false, refreshData = false;

  var _sendCommentController = TextEditingController();

  var _sendCommentFocusNode = FocusNode();

  var pos = -1;

  bool isEditComment = false;

  String? editCarnicalPhotoID;

  ApiHelper? _apiHelper;

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
  void initState() {
    super.initState();
    _apiHelper = ApiHelper();

    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });

    _scrollController = ScrollController();

    _carnivalPhotosLikeBloc = CarnivalPhotosLikeBloc();

    // KeyboardVisibilityNotification().addNewListener(
    //   onChange: (bool visible) {
    //     if (!visible) {
    //       replyId = "";
    //     }
    //   },
    // );

    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (!visible) {
        replyId = "";
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _getBlogCommentList());
  }

  void _getBlogCommentList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();
          _carnivalPhotosLikeBloc
              ?.getPhotosCommentList(
                  token.toString(), widget.carnivalPhotoId.toString())
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

          _carnivalPhotosLikeBloc
              ?.deletePhotoComment(token.toString(), commentId)
              .then((onValue) {
            if (onValue) {
              refreshData = true;
              // _aList.removeAt(index);
              _hideProgress();
              _aList?.clear();
              _getBlogCommentList();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  StringHelper.deleteSuccess,
                ),
              ));
            } else {
              _hideProgress();

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  StringHelper.deleteUnSuccess,
                ),
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
    // ??
    //    false;
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
              StringHelper.error, StringHelper.pleaseWrite, false));

      return;
    }

    var body = json.encode({
      "commentId": editCarnicalPhotoID,
      "comment": _sendCommentController.text.toString()
    });

    _sendCommentController.text = "";

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _apiHelper
            ?.updateCarnivalPhotoCommentBlog(body, authToken.toString())
            .then((onValue) {
          setState(() {
            isEditComment = false;
          });
          _aList?.clear();

          _getBlogCommentList();
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
            "carnivalPhotoId": widget.carnivalPhotoId,
            "comment": _sendCommentController.text.toString()
          });
        } else {
          body = json.encode({
            "carnivalPhotoId": widget.carnivalPhotoId,
            "comment": _sendCommentController.text.toString(),
            "carnivalPhotoCommentId": publicCommentId
          });
        }

        _sendCommentController.text = "";

        _carnivalPhotosLikeBloc
            ?.submitPhotoComment(authToken.toString(), body)
            .then((onValue) {
          refreshData = true;

          _hideKeyBoard();

          _aList?.clear();

          _getBlogCommentList();
        }).catchError((onError) {
          _hideKeyBoard();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
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
                      ? StringHelper.writeComment
                      : StringHelper.writeReply,
                  hintStyle: TextStyle(color: SoloColor.spanishGray),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.send, color: SoloColor.blue),
                      onPressed: () {
                        isEditComment
                            ? _onEditCommentTap(replyId.toString())
                            : _onSendCommentTap(replyId.toString());
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

    Widget profileImage(int index) {
      return GestureDetector(
        onTap: () {
          /*   if (_aList[index].userId == mineUserId) {
            _commonHelper.startActivity(ProfileTab(isFromHome: true));
          } else {
            _commonHelper.startActivity(
                UserProfileActivity(userId: _aList[index].userId));
          }*/
        },
        child: ClipOval(
            child: CachedNetworkImage(
          imageUrl: _aList![index].userProfilePic.toString(),
          height: 40,
          width: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => imagePlaceHolder(),
          errorWidget: (context, url, error) => imagePlaceHolder(),
        )),
      );
    }

    Widget replyItem(int listIndex, ReplyData replyData, int replyIndex) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _aList?[listIndex].showReplies = true;
              });
            },
            child: Visibility(
              visible: _aList?[listIndex].replyData?.isNotEmpty == true &&
                  replyIndex == 0 &&
                  _aList?[listIndex].showReplies == false,
              child: Padding(
                padding: EdgeInsets.only(top: DimensHelper.sidesMargin),
                child: Text(
                    '-------View all replies (${_aList?[listIndex].replyData?.length.toString()})',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: SoloColor.spanishGray,
                        fontSize: Constants.FONT_LOW)),
              ),
            ),
          ),
          Visibility(
              visible: _aList![listIndex].showReplies!,
              child: Container(
                padding: EdgeInsets.only(
                    top: DimensHelper.sidesMargin,
                    bottom: DimensHelper.halfSides),
                child: Stack(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                /*_commonHelper.startActivity(UserProfileActivity(
                                    userId: replyData.userId));*/
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    right: DimensHelper.halfSides),
                                child: ClipOval(
                                    child: CachedNetworkImage(
                                  imageUrl: replyData.userProfilePic.toString(),
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      imagePlaceHolder(),
                                  errorWidget: (context, url, error) =>
                                      imagePlaceHolder(),
                                )),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: _commonHelper?.screenWidth * .55,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(replyData.userName.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: SoloColor.black,
                                            fontSize: Constants.FONT_TOP)),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: DimensHelper.smallSides),
                                      child: Text(
                                          _commonHelper!.getTimeDifference(
                                              replyData.insertDate ?? 0),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: SoloColor.spanishGray,
                                              fontSize: Constants.FONT_LOW)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: DimensHelper.smallSides),
                                      child: Text(replyData.comment.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: SoloColor.spanishGray,
                                              fontSize: Constants.FONT_MEDIUM)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showCupertinoModalPopup(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return _showBottomSheetEditDel(
                                          replyData.replyCommentId.toString(),
                                          listIndex,
                                          replyData.comment.toString());
                                    });
                              },
                              child: Visibility(
                                visible: replyData.userId == mineUserId,
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      child: Icon(
                                        Icons.more_vert,
                                        color: SoloColor.spanishGray,
                                      ),
                                    )),
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ))
        ],
      );
    }

    Widget userDetails1(int index) {
      return _aList?[index].userId == mineUserId
          ? Dismissible(
              direction: DismissDirection.endToStart,
              resizeDuration: Duration(milliseconds: 200),
              confirmDismiss: (DismissDirection direction) async {
                return dialogCommentDel(context,
                    _aList![index].carnivalPhotoCommentId.toString(), index);
              },
              key: ObjectKey(_aList?.elementAt(index)),
              onDismissed: (direction) {
                // removeMessage(index, _chatList);
              },
              background: Container(
                padding: EdgeInsets.only(right: 28.0),
                alignment: AlignmentDirectional.centerEnd,
                color: SoloColor.blueWhite,
                child: Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                ),
              ),
              child: Container(
                color: SoloColor.blueWhite,
                padding: EdgeInsets.only(
                    left: DimensHelper.sidesMargin,
                    top: DimensHelper.sidesMargin),
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
                                padding: EdgeInsets.only(
                                    right: DimensHelper.halfSides),
                                child: profileImage(index),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: _commonHelper?.screenWidth * .7,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width:
                                              _commonHelper?.screenWidth - 100,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  _aList![index]
                                                      .userName
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: SoloColor.black,
                                                      fontSize:
                                                          Constants.FONT_TOP)),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: DimensHelper
                                                        .smallSides),
                                                child: RichText(
                                                    text: TextSpan(
                                                  text:
                                                      '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          SoloColor.spanishGray,
                                                      fontSize:
                                                          Constants.FONT_LOW),
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            StringHelper.reply,
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap = () {
                                                                replyId = _aList?[
                                                                        index]
                                                                    .carnivalPhotoCommentId;
                                                                FocusScope.of(
                                                                        context)
                                                                    .requestFocus(
                                                                        _sendCommentFocusNode);
                                                              }),
                                                  ],
                                                )),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: DimensHelper
                                                        .smallSides),
                                                child: Text(
                                                    _aList![index]
                                                        .comment
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: SoloColor
                                                            .spanishGray,
                                                        fontSize: Constants
                                                            .FONT_MEDIUM)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            showCupertinoModalPopup(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return _showBottomSheetEditDel(
                                                      _aList![index]
                                                          .carnivalPhotoCommentId
                                                          .toString(),
                                                      index,
                                                      _aList![index]
                                                          .comment
                                                          .toString());
                                                });
                                          },
                                          child: Container(
                                            child: Icon(
                                              Icons.more_vert,
                                              color: SoloColor.spanishGray,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      itemCount:
                                          _aList?[index].replyData?.length,
                                      itemBuilder: (context, replyDataIndex) {
                                        return replyItem(
                                            index,
                                            _aList![index]
                                                .replyData![replyDataIndex],
                                            replyDataIndex);
                                      },
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
            )
          : Container(
              color: SoloColor.blueWhite,
              padding: EdgeInsets.only(
                  left: DimensHelper.sidesMargin,
                  top: DimensHelper.sidesMargin),
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
                              padding: EdgeInsets.only(
                                  right: DimensHelper.halfSides),
                              child: profileImage(index),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: _commonHelper?.screenWidth - 100,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                _aList![index]
                                                    .userName
                                                    .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: SoloColor.black,
                                                    fontSize:
                                                        Constants.FONT_TOP)),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: DimensHelper.smallSides),
                                              child: RichText(
                                                  text: TextSpan(
                                                text:
                                                    '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        SoloColor.spanishGray,
                                                    fontSize:
                                                        Constants.FONT_LOW),
                                                children: [
                                                  TextSpan(
                                                      text: StringHelper.reply,
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              replyId = _aList?[
                                                                      index]
                                                                  .carnivalPhotoCommentId;
                                                              FocusScope.of(
                                                                      context)
                                                                  .requestFocus(
                                                                      _sendCommentFocusNode);
                                                            }),
                                                ],
                                              )),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: DimensHelper.smallSides),
                                              child: Text(
                                                  _aList![index]
                                                      .comment
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color:
                                                          SoloColor.spanishGray,
                                                      fontSize: Constants
                                                          .FONT_MEDIUM)),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: ScrollPhysics(),
                                    itemCount: _aList?[index].replyData?.length,
                                    itemBuilder: (context, replyDataIndex) {
                                      return replyItem(
                                          index,
                                          _aList![index]
                                              .replyData![replyDataIndex],
                                          replyDataIndex);
                                    },
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      )),
                ],
              ),
            );
    }

    Widget userDetails(int index) {
      return _aList?[index].userId == mineUserId
          ? Dismissible(
              direction: DismissDirection.endToStart,
              resizeDuration: Duration(milliseconds: 200),
              confirmDismiss: (DismissDirection direction) async {
                return dialogCommentDel(context,
                    _aList![index].carnivalPhotoCommentId.toString(), index);
              },
              key: ObjectKey(_aList?.elementAt(index)),
              onDismissed: (direction) {
                // removeMessage(index, _chatList);
              },
              background: Container(
                padding: EdgeInsets.only(right: 28.0),
                alignment: AlignmentDirectional.centerEnd,
                color: SoloColor.blueWhite,
                child: Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                ),
              ),
              child: Container(
                padding: EdgeInsets.only(
                    left: DimensHelper.sidesMargin,
                    top: DimensHelper.sidesMargin),
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
                                padding: EdgeInsets.only(
                                    right: DimensHelper.halfSides),
                                child: profileImage(index),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width:
                                              _commonHelper?.screenWidth - 100,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  _aList![index]
                                                      .userName
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: SoloColor.black,
                                                      fontSize:
                                                          Constants.FONT_TOP)),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: DimensHelper
                                                        .smallSides),
                                                child: RichText(
                                                    text: TextSpan(
                                                  text:
                                                      '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          SoloColor.spanishGray,
                                                      fontSize:
                                                          Constants.FONT_LOW),
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            StringHelper.reply,
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap = () {
                                                                replyId = _aList?[
                                                                        index]
                                                                    .carnivalPhotoCommentId;
                                                                FocusScope.of(
                                                                        context)
                                                                    .requestFocus(
                                                                        _sendCommentFocusNode);
                                                              }),
                                                  ],
                                                )),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: DimensHelper
                                                        .smallSides),
                                                child: Text(
                                                    _aList![index]
                                                        .comment
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: SoloColor
                                                            .spanishGray,
                                                        fontSize: Constants
                                                            .FONT_MEDIUM)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            showCupertinoModalPopup(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return _showBottomSheetEditDel(
                                                      _aList![index]
                                                          .carnivalPhotoCommentId
                                                          .toString(),
                                                      index,
                                                      _aList![index]
                                                          .comment
                                                          .toString());
                                                });
                                          },
                                          child: Container(
                                            child: Icon(
                                              Icons.more_vert,
                                              color: SoloColor.spanishGray,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      itemCount:
                                          _aList?[index].replyData?.length,
                                      itemBuilder: (context, replyDataIndex) {
                                        return replyItem(
                                            index,
                                            _aList![index]
                                                .replyData![replyDataIndex],
                                            replyDataIndex);
                                      },
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.only(
                  left: DimensHelper.sidesMargin,
                  top: DimensHelper.sidesMargin),
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
                              padding: EdgeInsets.only(
                                  right: DimensHelper.halfSides),
                              child: profileImage(index),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: _commonHelper?.screenWidth - 100,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                _aList![index]
                                                    .userName
                                                    .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: SoloColor.black,
                                                    fontSize:
                                                        Constants.FONT_TOP)),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: DimensHelper.smallSides),
                                              child: RichText(
                                                  text: TextSpan(
                                                text:
                                                    '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}          ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        SoloColor.spanishGray,
                                                    fontSize:
                                                        Constants.FONT_LOW),
                                                children: [
                                                  TextSpan(
                                                      text: StringHelper.reply,
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              replyId = _aList?[
                                                                      index]
                                                                  .carnivalPhotoCommentId;

                                                              FocusScope.of(
                                                                      context)
                                                                  .requestFocus(
                                                                      _sendCommentFocusNode);
                                                            }),
                                                ],
                                              )),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: DimensHelper.smallSides),
                                              child: Text(
                                                  _aList![index]
                                                      .comment
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color:
                                                          SoloColor.spanishGray,
                                                      fontSize: Constants
                                                          .FONT_MEDIUM)),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: ScrollPhysics(),
                                    itemCount: _aList?[index].replyData?.length,
                                    itemBuilder: (context, replyDataIndex) {
                                      return replyItem(
                                          index,
                                          _aList![index]
                                              .replyData![replyDataIndex],
                                          replyDataIndex);
                                    },
                                  )
                                ],
                              ),
                            ),
                          )
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
                    bottom: DimensHelper.halfSides,
                    top: DimensHelper.halfSides),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _aList?.length,
                  padding: EdgeInsets.only(bottom: 56),
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
                  child: Text(StringHelper.noCommentOnPost,
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

    Future<bool> _willPopCallback() async {
      Navigator.pop(context, refreshData);

      return false;
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
                child: Text(StringHelper.comments,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Constants.FONT_APP_TITLE)),
              )
            ],
          ),
        ),
        body: StreamBuilder(
            stream: _carnivalPhotosLikeBloc?.commentList,
            builder:
                (context, AsyncSnapshot<CarnivalCommentPhotosModel> snapshot) {
              if (snapshot.hasData) {
                if (_aList == null || _aList!.isEmpty) {
                  _aList = snapshot.data?.data?.carnivalPhotoCommentsList;
                  if (widget.scrollMessage!) {
                    pos = _aList!.indexWhere((innerElement) =>
                        innerElement.carnivalPhotoCommentId ==
                        widget.publicCommentId);
                    print(_aList!.indexWhere((innerElement) =>
                        innerElement.carnivalPhotoCommentId ==
                        widget.publicCommentId));

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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(SoloColor.blue)));
            }),
      ),
    );
  }

  Widget _showBottomSheetEditDel(
      String editCarnicalPhotoId, int index, String comment) {
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

            editCarnicalPhotoID = editCarnicalPhotoId;

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
                  _showDeleteBottomSheet(editCarnicalPhotoId, index));
        },
      ),
    ]);
  }

  Widget _showDeleteBottomSheet(String editBlogId, int index) {
    return CupertinoActionSheet(
      title: Text(StringHelper.delComment,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.delCommentMsg,
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
            _deleteComment(editBlogId, index);
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
}
