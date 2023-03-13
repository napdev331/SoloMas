// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:solomas/blocs/blogs/blog_comment_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/blog_comment_blog.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/comment_helper.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../common_helpers/app_bar.dart';

class BlogCommentActivity extends StatefulWidget {
  final String? blogId;
  final String? publicCommentId;
  final bool? showKeyBoard;
  bool? scrollMessage;
  BlogCommentActivity(
      {this.blogId,
      this.showKeyBoard = false,
      this.scrollMessage,
      this.publicCommentId});

  @override
  _BlogCommentActivityState createState() => _BlogCommentActivityState();
}

class _BlogCommentActivityState extends State<BlogCommentActivity> {
//============================================================
// ** Properties **
//============================================================

  String? authToken, replyId = "", mineUserId;
  var _sendCommentController = TextEditingController();
  var _sendCommentFocusNode = FocusNode();
  var pos = -1;
  bool _progressShow = false, refreshData = false;
  bool isEditComment = false;
  String? editBlogID;

  List<BlogCommentsList>? _aList;

  CommonHelper? _commonHelper;
  BlogCommentBloc? _blogCommentBloc;
  ScrollController? _scrollController;
  ApiHelper? _apiHelper;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    Constants.isNavigated = false;
    _apiHelper = ApiHelper();

    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });

    _scrollController = ScrollController();
    _blogCommentBloc = BlogCommentBloc();
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

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    Future<bool> _willPopCallback() async {
      Navigator.pop(context, refreshData);

      return false;
    }

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SoloScaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: _appBar(context),
          ),
        ),
        body: StreamBuilder(
            stream: _blogCommentBloc?.commentList,
            builder: (context, AsyncSnapshot<BlogCommentResponse> snapshot) {
              if (snapshot.hasData) {
                if (_aList == null || _aList!.isEmpty) {
                  _aList = snapshot.data?.data?.blogCommentsList;
                  if (widget.scrollMessage!) {
                    pos = _aList!.indexWhere((innerElement) =>
                        innerElement.blogCommentId == widget.publicCommentId);
                    print(_aList?.indexWhere((innerElement) =>
                        innerElement.blogCommentId == widget.publicCommentId));

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

  @override
  void dispose() {
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.comments,
      backOnTap: () {
        Navigator.pop(context);
      },
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
              child: ListView.separated(
                controller: _scrollController,
                itemCount: _aList!.length,
                padding: EdgeInsets.only(bottom: 56),
                itemBuilder: (context, index) {
                  //userDetails
                  // if (index == pos) {
                  //   return userDetails1(index);
                  // } else {}
                  return CommentHelper.userDetails(
                    context,
                    index,
                    userName: _aList![index].userName.toString(),
                    threeDotTap: () {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
                            return _showBottomSheetEditDel(
                                _aList![index].blogCommentId.toString(),
                                index,
                                _aList![index].comment.toString());
                          });
                    },
                    content: _aList![index].comment.toString(),
                    replyTap: () {
                      replyId = _aList?[index].blogCommentId;

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
                          viewAllReplyComment: _aList![index].showReplies!,
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
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    color: SoloColor.spanishGray,
                    thickness: 0.3,
                    endIndent: 15,
                    indent: 15,
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
              CommentHelper.sendCommentField(context, onSend: () {
                isEditComment
                    ? _onEditCommentTap(replyId.toString())
                    : _onSendCommentTap(replyId.toString());
              },
                  controller: _sendCommentController,
                  autofocus: widget.showKeyBoard!,
                  focusNode: _sendCommentFocusNode,
                  id: replyId!),
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
            child:
                ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
            alignment: FractionalOffset.center,
          )
        ],
      ),
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                                  '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: SoloColor.spanishGray,
                                                  fontSize: Constants.FONT_LOW),
                                              children: [
                                                TextSpan(
                                                    text: StringHelper.reply,
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () {
                                                            replyId = _aList?[
                                                                    index]
                                                                .blogCommentId;

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
                                                    fontSize:
                                                        Constants.FONT_MEDIUM)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        showCupertinoModalPopup(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return _showBottomSheetEditDel(
                                                  _aList![index]
                                                      .blogCommentId
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
                                  itemCount: _aList?[index].replyData?.length,
                                  itemBuilder: (context, replyDataIndex) {
                                    return CommentHelper.replyItem(context,
                                        listIndex: index,
                                        replyData: _aList![index]
                                            .replyData![replyDataIndex],
                                        replyIndex: replyDataIndex,
                                        viewAllTap: () {
                                          setState(() {
                                            _aList?[index].showReplies = true;
                                          });
                                        },
                                        viewAllReply: _aList?[index]
                                                    .replyData
                                                    ?.isNotEmpty ==
                                                true &&
                                            replyDataIndex == 0 &&
                                            _aList?[index].showReplies == false,
                                        viewAllReplyLength:
                                            '${_aList?[index].replyData?.length.toString()}',
                                        viewAllReplyComment:
                                            _aList![index].showReplies!,
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
                                                        .replyData![
                                                            replyDataIndex]
                                                        .replyCommentId
                                                        .toString(),
                                                    index,
                                                    _aList![index]
                                                        .replyData![
                                                            replyDataIndex]
                                                        .comment
                                                        .toString());
                                              });
                                        },
                                        visibilityCommentThreeDot:
                                            _aList![index]
                                                    .replyData![replyDataIndex]
                                                    .userId ==
                                                mineUserId,
                                        replyCommentData: _aList![index]
                                            .replyData![replyDataIndex]
                                            .comment
                                            .toString(),
                                        replyCommentTime: _commonHelper!
                                            .getTimeDifference(_aList![index]
                                                    .replyData![replyDataIndex]
                                                    .insertDate ??
                                                0));
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                                  '${_commonHelper?.getTimeDifference(_aList?[index].insertDate ?? 0)}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: SoloColor.spanishGray,
                                                  fontSize: Constants.FONT_LOW),
                                              children: [
                                                TextSpan(
                                                    text: StringHelper.reply,
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () {
                                                            replyId = _aList?[
                                                                    index]
                                                                .blogCommentId;

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
                                                    fontSize:
                                                        Constants.FONT_MEDIUM)),
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
                                    return CommentHelper.replyItem(context,
                                        listIndex: index,
                                        replyData: _aList![index]
                                            .replyData![replyDataIndex],
                                        replyIndex: replyDataIndex,
                                        viewAllTap: () {
                                          setState(() {
                                            _aList?[index].showReplies = true;
                                          });
                                        },
                                        viewAllReply: _aList?[index]
                                                    .replyData
                                                    ?.isNotEmpty ==
                                                true &&
                                            replyDataIndex == 0 &&
                                            _aList?[index].showReplies == false,
                                        viewAllReplyLength:
                                            '${_aList?[index].replyData?.length.toString()}',
                                        viewAllReplyComment:
                                            _aList![index].showReplies!,
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
                                                        .replyData![
                                                            replyDataIndex]
                                                        .replyCommentId
                                                        .toString(),
                                                    index,
                                                    _aList![index]
                                                        .replyData![
                                                            replyDataIndex]
                                                        .comment
                                                        .toString());
                                              });
                                        },
                                        visibilityCommentThreeDot:
                                            _aList![index]
                                                    .replyData![replyDataIndex]
                                                    .userId ==
                                                mineUserId,
                                        replyCommentData: _aList![index]
                                            .replyData![replyDataIndex]
                                            .comment
                                            .toString(),
                                        replyCommentTime: _commonHelper!
                                            .getTimeDifference(_aList![index]
                                                    .replyData![replyDataIndex]
                                                    .insertDate ??
                                                0));
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

  Widget _showBottomSheetEditDel(String editBlogId, int index, String comment) {
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

            editBlogID = editBlogId;

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
                  _showDeleteBottomSheet(editBlogId, index));
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

  void _getBlogCommentList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _showProgress();

          _blogCommentBloc
              ?.getBlogCommentList(token.toString(), widget.blogId.toString())
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

          _blogCommentBloc
              ?.deleteBlog(token.toString(), commentId)
              .then((onValue) {
            if (onValue) {
              refreshData = true;
              // _aList.removeAt(index);
              _aList?.clear();
              _hideProgress();
              _getBlogCommentList();

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(StringHelper.deleteSucMsg),
              ));
            } else {
              _hideProgress();

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(StringHelper.deleteUnSucMsg),
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

  void _onEditCommentTap(String publicCommentId) {
    FocusScope.of(context).unfocus();

    if (_sendCommentController.text.toString().isEmpty) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _commonHelper!.successBottomSheet(
              StringHelper.error, StringHelper.writeSomethingMsg, false));

      return;
    }

    var body = json.encode({
      "commentId": editBlogID,
      "comment": _sendCommentController.text.toString()
    });

    _sendCommentController.text = "";

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _apiHelper
            ?.updateCommentBlog(body, authToken.toString())
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
            "blogId": widget.blogId,
            "comment": _sendCommentController.text.toString()
          });
        } else {
          body = json.encode({
            "blogId": widget.blogId,
            "comment": _sendCommentController.text.toString(),
            "blogCommentId": publicCommentId
          });
        }

        _sendCommentController.text = "";

        _blogCommentBloc
            ?.submitFeedComment(authToken.toString(), body)
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
}
