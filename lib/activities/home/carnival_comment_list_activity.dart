import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/blocs/group/group_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/carnival_comment_list_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/space.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';

class CarnivalCommentListActivity extends StatefulWidget {
  final String carnivalFeedId;
  final String? carnivalCommentId;
  bool? scrollMessage;
  CarnivalCommentListActivity(this.carnivalFeedId,
      {this.scrollMessage, this.carnivalCommentId});

  @override
  State<StatefulWidget> createState() {
    return _CarnivalCommentListState();
  }
}

class _CarnivalCommentListState extends State<CarnivalCommentListActivity> {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  String? authToken, mineProfilePic, replyId = "", mineUserId;
  GroupBloc? _groupBloc;
  ScrollController? _scrollController;
  ScrollController? _scrollController1;
  ScrollController? _scrollController2;
  List<CarnivalCommentsList>? _aList;
  bool refreshData = false;
  var _sendCommentController = TextEditingController();
  var _sendCommentFocusNode = FocusNode();
  var _progressShow = false;
  var pos = -1;
  bool isEditComment = false;
  String? editFeedID;
  ApiHelper? _apiHelper;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _apiHelper = ApiHelper();

    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });

    PrefHelper.getUserProfilePic().then((onValue) {
      mineProfilePic = onValue;
    });

    _scrollController = ScrollController();
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();

    _groupBloc = GroupBloc();

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

    WidgetsBinding.instance.addPostFrameCallback((_) => _getFeedCommentList());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: _appBar(context),
        ),
      ),
      body: _mainBody(_commentListData),
    );
  }

  @override
  void dispose() {
    _groupBloc?.dispose();

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

  Widget _mainBody(Widget _commentListData(int pos)) {
    return StreamBuilder(
        stream: _groupBloc?.carnivalCommentList,
        builder: (context, AsyncSnapshot<CarnivalCommentListModel> snapshot) {
          if (snapshot.hasData) {
            if (_aList == null || _aList!.isEmpty) {
              _aList = snapshot.data?.data?.carnivalCommentsList;

              if (widget.scrollMessage == true) {
                pos = _aList!.indexWhere((innerElement) =>
                    innerElement.carnivalCommentId == widget.carnivalCommentId);
                print(_aList!.indexWhere((innerElement) =>
                    innerElement.carnivalCommentId ==
                    widget.carnivalCommentId));

                if (pos == _aList!.length - 1) {
                  Future.delayed(Duration.zero, () => _animateScrolling());
                } else {
                  Future.delayed(
                      Duration.zero, () => _animateScrollingMessage(pos));
                }

                // return _commentListData(pos);
              } else {
                //return _commentListData(-1);
                Future.delayed(Duration.zero, () => _animateScrolling());
              }

              //Future.delayed(Duration.zero, () => _animateScrolling());
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

  //============================================================
// ** Helper Widgets **
//============================================================

  Widget _showBottomSheetEditDel(String editFeedId, int index, String comment) {
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

            editFeedID = editFeedId;

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
                  _showDeleteBottomSheet(editFeedId, index));
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

  Widget sendCommentField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _commonHelper?.startActivity(ProfileTab(isFromHome: true));
            },
            child: ClipOval(
                child: CachedNetworkImage(
                    imageUrl:
                        mineProfilePic == null ? "" : mineProfilePic.toString(),
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => imagePlaceHolder(),
                    errorWidget: (context, url, error) => imagePlaceHolder())),
          ),
          space(width: 5),
          Expanded(
              child: Container(
            width: _commonHelper?.screenWidth * .78,
            padding: EdgeInsets.only(
                top: DimensHelper.halfSides, bottom: DimensHelper.halfSides),
            child: TextFormField(
              style: TextStyle(
                  fontSize: Constants.FONT_MEDIUM,
                  color: SoloColor.spanishGray),
              autofocus: false,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 4,
              onTap: () {
                replyId = "";

                _animateScrolling();
              },
              controller: _sendCommentController,
              focusNode: _sendCommentFocusNode,
              cursorColor: SoloColor.blue,
              decoration: InputDecoration(
                  hintText:
                      replyId!.isEmpty ? StringHelper.writeComment : StringHelper.writeComment,
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
      ),
    );
  }

  Widget profileImage(int index) {
    return GestureDetector(
      onTap: () {
        if (_aList?[index].userId == mineUserId) {
          _commonHelper?.startActivity(ProfileTab(isFromHome: true));
        } else {
          _commonHelper?.startActivity(
              UserProfileActivity(userId: _aList![index].userId.toString()));
        }
      },
      child: ClipOval(
          child: CachedNetworkImage(
              imageUrl: _aList![index].userProfilePic.toString(),
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => imagePlaceHolder(),
              errorWidget: (context, url, error) => imagePlaceHolder())),
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
            visible: _aList?[listIndex].showReplies == true && replyIndex == 0,
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
            visible: _aList?[listIndex].showReplies == true,
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
                              _commonHelper?.startActivity(UserProfileActivity(
                                  userId: replyData.userId.toString()));
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                  right: DimensHelper.halfSides),
                              child: ClipOval(
                                  child: CachedNetworkImage(
                                      imageUrl:
                                          replyData.userProfilePic.toString(),
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          imagePlaceHolder(),
                                      errorWidget: (context, url, error) =>
                                          imagePlaceHolder())),
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
                                        bottom: DimensHelper.smallSides,
                                        top: DimensHelper.smallSides),
                                    child: Text(replyData.comment.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: SoloColor.spanishGray,
                                        )),
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
                                                      .carnivalCommentId
                                                      .toString(),
                                                  index,
                                                  _aList![index]
                                                      .comment
                                                      .toString());
                                            });
                                      },
                                      child: Image.asset(
                                        IconsHelper.comment_doted,
                                        width: 15,
                                        height: 15,
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
                                            replyId = _aList?[index]
                                                .carnivalCommentId;

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
                                  // GestureDetector(
                                  //   onTap: () {},
                                  //   child: Image.asset(
                                  //     IconsHelper.comment_doted,
                                  //     width: 15,
                                  //     height: 15,
                                  //   ),
                                  // )
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
                                            replyId = _aList?[index]
                                                .carnivalCommentId;

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
                          onTap: () {
                            _commonHelper?.startActivity(UserProfileActivity(
                                userId: _aList![index].userId.toString()));
                          },
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
                                                      .carnivalCommentId
                                                      .toString(),
                                                  index,
                                                  _aList![index]
                                                      .comment
                                                      .toString());
                                            });
                                      },
                                      child: Image.asset(
                                        IconsHelper.comment_doted,
                                        width: 15,
                                        height: 15,
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
                                            replyId = _aList?[index]
                                                .carnivalCommentId;
                                            FocusScope.of(context).requestFocus(
                                                _sendCommentFocusNode);
                                          },
                                          child: Text(
                                            StringHelper.reply,
                                            style:
                                                SoloStyle.taupeGrayW600MediumXs,
                                          ))
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
                          onTap: () {
                            _commonHelper?.startActivity(UserProfileActivity(
                                userId: _aList![index].userId.toString()));
                          },
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
                                  // GestureDetector(
                                  //   onTap: () {},
                                  //   child: Image.asset(
                                  //     IconsHelper.comment_doted,
                                  //     width: 15,
                                  //     height: 15,
                                  //   ),
                                  // )
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
                                            replyId = _aList?[index]
                                                .carnivalCommentId;

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
      color: SoloColor.white,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              _hideKeyBoard();
            },
            child: Container(
              color: Colors.white,
              height: _commonHelper?.screenHeight * .825,
              padding: EdgeInsets.only(
                  bottom: DimensHelper.halfSides, top: DimensHelper.halfSides),
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

                  // return userDetails(index);
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

  void _getFeedCommentList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _showProgress();

          _groupBloc
              ?.getCommentList(token.toString(), widget.carnivalFeedId)
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
          builder: (BuildContext context) => _commonHelper!
              .successBottomSheet(StringHelper.error, StringHelper.writeSomethingMsg, false));

      return;
    }

    var body = json.encode({
      "commentId": editFeedID,
      "comment": _sendCommentController.text.toString()
    });

    _sendCommentController.text = "";

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _apiHelper
            ?.updateGroupComment(body, authToken.toString())
            .then((onValue) {
          setState(() {
            isEditComment = false;
          });
          _aList?.clear();

          _getFeedCommentList();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onSendCommentTap(String carnivalCommentId) {
    FocusScope.of(context).unfocus();

    if (_sendCommentController.text.toString().trim().isEmpty) {
      if (replyId!.isEmpty) {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _commonHelper!
                .successBottomSheet(
                StringHelper.invalidComment,  StringHelper.emptyComment, false));
      } else {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _commonHelper!
                .successBottomSheet(
                StringHelper.invalidReply,  StringHelper.emptyReply, false));
      }

      return;
    }

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body;

        if (carnivalCommentId.isEmpty) {
          body = json.encode({
            "carnivalFeedId": widget.carnivalFeedId,
            "comment": _sendCommentController.text.toString()
          });
        } else {
          body = json.encode({
            "carnivalFeedId": widget.carnivalFeedId,
            "comment": _sendCommentController.text.toString(),
            "carnivalCommentId": carnivalCommentId
          });
        }

        _sendCommentController.text = "";

        _groupBloc
            ?.submitCarnivalFeedComment(authToken.toString(), body)
            .then((onValue) {
          _hideKeyBoard();

          refreshData = true;

          _aList?.clear();

          _getFeedCommentList();
        }).catchError((onError) {
          _hideKeyBoard();

          _hideProgress();
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

  void _deleteComment(var commentId, int index) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();

          _groupBloc
              ?.deleteCommentCarnival(token.toString(), commentId)
              .then((onValue) {
            if (onValue) {
              refreshData = true;
              // _aList.removeAt(index);
              _aList?.clear();
              _hideProgress();
              _getFeedCommentList();
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

  void _hideKeyBoard() {
    replyId = "";

    FocusScope.of(context).unfocus();
  }
}
