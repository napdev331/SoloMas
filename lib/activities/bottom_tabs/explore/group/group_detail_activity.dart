import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/bottom_tabs/explore/group/group_feed_activity.dart';
import 'package:solomas/activities/home/carnival_comment_list_activity.dart';
import 'package:solomas/activities/home/carnival_like_list_activity.dart';
import 'package:solomas/blocs/group/group_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/block_user_model.dart';
import 'package:solomas/model/delete_carnival_feed_model.dart';
import 'package:solomas/model/get_groups_model.dart';
import 'package:solomas/model/group_feed_model.dart';
import 'package:solomas/model/report_feed_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../../../helpers/comment_helper.dart';
import '../../../../helpers/space.dart';
import '../../../../resources_helper/common_widget.dart';
import '../../../../resources_helper/images.dart';
import '../../../../resources_helper/screen_area/scaffold.dart';
import '../../../../resources_helper/text_styles.dart';
import '../../../common_helpers/app_bar.dart';
import '../../../common_helpers/app_button.dart';
import '../../../common_helpers/comment_card.dart';
import '../../../home/user_profile_activity.dart';

class GroupDetailsActivity extends StatefulWidget {
  final String? groupId, groupTitle;

  GroupDetailsActivity({this.groupId, this.groupTitle});

  @override
  State<StatefulWidget> createState() {
    return _GroupDetailState();
  }
}

class _GroupDetailState extends State<GroupDetailsActivity> {
//============================================================
// ** Properties **
//============================================================
  var _sendCommentFocusNode = FocusNode();
  GroupBloc? _groupBloc;
  CommonHelper? _commonHelper;
  bool _isShowProgress = false;
  String? authToken,
      mineProfilePic,
      mineUserName,
      mineUserId,
      postButton = "POST",
      editCarnivalFeedId;
  GroupData? _groupData;
  List<CarnivalFeedList> _groupFeedList = [];
  ApiHelper? _apiHelper;
  var _commentController = TextEditingController();
  var _commentFocusNode = FocusNode();
  late List<Widget> _randomChildren;

//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  void initState() {
    super.initState();

    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });

    PrefHelper.getUserProfilePic().then((onValue) {
      setState(() {
        mineProfilePic = onValue;
      });
    });

    PrefHelper.getUserName().then((onValue) {
      setState(() {
        Constants.printValue("value: " + onValue.toString());

        mineUserName = onValue;
      });
    });

    _apiHelper = ApiHelper();

    _groupBloc = GroupBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getGroupDetails());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      body: StreamBuilder(
          stream: _groupBloc?.groupsList,
          builder: (context, AsyncSnapshot<GetGroupsModel> snapshot) {
            if (snapshot.hasData) {
              if (_groupData == null) {
                _groupData = snapshot.data?.data;
              }
              return _mainItem();
            } else if (snapshot.hasError) {
              return Container();
            }

            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
          }),
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
      appBarType: StringHelper.backBar,
    );
  }

  Widget _mainItem() {
    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: (context, bool innerBoxIsScrolled) {
          return [
            SliverList(
              delegate: SliverChildListDelegate(
                _sliverWidgets(context),
              ),
            ),
          ];
        },
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: _groupBloc?.groupsFeedList,
                      builder:
                          (context, AsyncSnapshot<GroupFeedModel> snapshot) {
                        if (snapshot.hasData) {
                          if (_groupFeedList.isEmpty) {
                            _groupFeedList =
                                snapshot.data?.data?.carnivalFeedList ?? [];
                          }

                          return _feedMainItem();
                        } else {
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                    color:
                                        SoloColor.spanishGray.withOpacity(0.4),
                                    blurRadius: 2.5,
                                    spreadRadius: 0.7,
                                  )
                                ], color: SoloColor.white),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        width: 200,
                                        child: Text(
                                            widget.groupTitle!.toUpperCase(),
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                SoloStyle.darkBlackW700MaxRob),
                                      ),
                                      _groupData!.groupList![0].isJoined!
                                          ? joinedButton()
                                          : joinButton(),
                                    ],
                                  ),
                                ),
                              ),
                              _joinedGroupWarning(),
                            ],
                          );
                        }
                      }),
                ),
                if (_groupData?.groupList?[0].isJoined == true)
                  CommentHelper.sendCommentField(
                    context,
                    focusNode: _sendCommentFocusNode,
                    onSend: () {
                      postButton?.toLowerCase() == "post"
                          ? _onPostTap()
                          : _onEditTap();

                      postButton = StringHelper.post;

                      editCarnivalFeedId = "";
                    },
                    controller: _commentController,
                  )
              ],
            ),
            Align(
              child: ProgressBarIndicator(
                  _commonHelper?.screenSize, _isShowProgress),
              alignment: FractionalOffset.center,
            )
          ],
        ),
      ),
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  List<Widget> _sliverWidgets(BuildContext context) {
    _randomChildren = [
      Stack(
        children: [
          Container(
            height: _commonHelper?.screenHeight * .23,
            child: CachedNetworkImage(
              width: _commonHelper?.screenWidth,
              imageUrl: _groupData!.groupList![0].groupProfilePic.toString(),
              fit: BoxFit.cover,
              placeholder: (context, url) => imagePlaceHolder(),
              errorWidget: (context, url, error) => imagePlaceHolder(),
            ),
          ),
          Container(
            width: _commonHelper?.screenWidth,
            padding: EdgeInsets.only(top: 2.5),
            child: _appBar(context),
          ),
        ],
      )
    ];

    return _randomChildren;
  }

  Widget _feedMainItem() {
    return ListView(
      children: [detailsBar(), minePostedFeed()],
    );
  }

  Widget minePostedFeed() {
    return _groupFeedList.isNotEmpty
        ? ListView.separated(
            shrinkWrap: true,
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            physics: ScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) {
              return Container();
            },
            itemCount: _groupFeedList.length,
            itemBuilder: (BuildContext context, int index) {
              return carnivalFeedItem(_groupFeedList[index]);
            })
        : Container();
  }

  Widget detailsBar() {
    return Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: SoloColor.spanishGray.withOpacity(0.4),
            blurRadius: 2.5,
            spreadRadius: 0.7,
          )
        ], color: SoloColor.white),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 200,
                    child: Text(widget.groupTitle!.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: SoloStyle.darkBlackW700MaxRob),
                  ),
                  _groupData!.groupList![0].isJoined!
                      ? joinedButton()
                      : joinButton(),
                ],
              ),
            ),
            _groupData?.subscriberList?.length != 0
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Divider(
                            color: SoloColor.graniteGray.withOpacity(0.3),
                            height: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                    "${_groupData?.subscriberList?.length} ${StringHelper.members}:",
                                    style: SoloStyle.blackW900TopXs),
                                space(width: 10),
                                memberList(),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                _commonHelper?.startActivity(
                                    GroupMembersActivity(
                                        subsList:
                                            _groupData?.subscriberList ?? [],
                                        groupName:
                                            widget.groupTitle.toString()));
                              },
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  StringHelper.seeAll.toUpperCase(),
                                  style: SoloStyle.transparentW500MediumXs,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                : Container()
          ],
        ));
  }

  Widget memberList() {
    var len = _groupData?.subscriberList?.length;
    return Container(
      width: 150,
      child: Stack(
        children: [
          len! > 0
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(55.0)),
                    boxShadow: [
                      BoxShadow(blurRadius: 3.0),
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
                            imageUrl: _groupData!
                                .subscriberList![0].userProfilePic
                                .toString(),
                            placeholder: (context, url) => imagePlaceHolder(),
                            errorWidget: (context, url, error) =>
                                imagePlaceHolder())),
                  ),
                )
              : SizedBox(),
          len > 1
              ? Positioned(
                  left: _commonHelper!.screenWidth * 0.06,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(55.0)),
                      boxShadow: [
                        BoxShadow(blurRadius: 3.0),
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
                              imageUrl: _groupData!
                                  .subscriberList![1].userProfilePic
                                  .toString(),
                              placeholder: (context, url) => imagePlaceHolder(),
                              errorWidget: (context, url, error) =>
                                  imagePlaceHolder())),
                    ),
                  ))
              : SizedBox(),
          len > 2
              ? Positioned(
                  left: _commonHelper!.screenWidth * 0.12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(55.0)),
                      boxShadow: [
                        BoxShadow(blurRadius: 3.0),
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
                        imageUrl: _groupData!.subscriberList![2].userProfilePic
                            .toString(),
                        placeholder: (context, url) => imagePlaceHolder(),
                        errorWidget: (context, url, error) =>
                            imagePlaceHolder(),
                      )),
                    ),
                  ),
                )
              : SizedBox(),
          len > 3
              ? Positioned(
                  left: _commonHelper!.screenWidth * 0.18,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(55.0)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3.0,
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
                        child: Text('+${len - 3}',
                            style: SoloStyle.smokeWhiteW70010Rob),
                      ),
                    ),
                  ))
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _showBottomSheet(String msg, bool joinGroup, String groupId) {
    return CupertinoActionSheet(
      message: Text(msg, style: SoloStyle.blackNormalMedium),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes,
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);
            if (joinGroup) {
              _onJoinButtonTap(groupId);
            } else {
              _onDisJoinButtonTap(groupId);
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

  Widget joinedButton() {
    return AppButton(
      onTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _showBottomSheet(
                StringHelper.groupLeaveMsg,
                false,
                _groupData!.groupList![0].groupId.toString()));
      },
      text: '+ ${StringHelper.joined}'.toUpperCase(),
      color: SoloColor.pink,
      width: _commonHelper!.screenWidth * 0.2,
      height: _commonHelper!.screenHeight * 0.035,
    );
  }

  Widget joinButton() {
    return AppButton(
      onTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _showBottomSheet(
                "${StringHelper.groupJoinMsg}${_groupData?.groupList?[0].title?.trim()}?",
                true,
                _groupData!.groupList![0].groupId.toString()));
      },
      width: _commonHelper!.screenWidth * 0.2,
      height: _commonHelper!.screenHeight * 0.035,
      text: StringHelper.join.toUpperCase(),
      color: SoloColor.gainsBoro,
    );
  }

  Widget _showFeedBottomSheet(String carnivalFeedId, String comment) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.edit,
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              postButton = StringHelper.save;
              editCarnivalFeedId = carnivalFeedId;
              _commentController.text = comment;
              _commentController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _commentController.text.length));
              FocusScope.of(context).requestFocus(_commentFocusNode);
            });
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            StringHelper.delete,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500),
          ),
          onPressed: () {
            Navigator.pop(context);
            _onDeleteTap(carnivalFeedId);
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

  Widget _showReportBottomSheet(String feedId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.report,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.reportPostMsg,
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
            _onReportPostTap(feedId);
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

  Widget _showBlockConfirmationSheet(String blockUserId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.blockProfileMsg,
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
          child: Text(StringHelper.yes,
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

  Widget _showBlockBottomSheet(String blockUserId, String feedId) {
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
                    _showBlockConfirmationSheet(blockUserId));
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
                    _showReportBottomSheet(feedId));
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

  Widget carnivalFeedItem(CarnivalFeedList groupFeedList) {
    var likes;
    var comments;
    if (_groupFeedList.isNotEmpty) {
      likes = groupFeedList.totalLikes == 0
          ? ""
          : groupFeedList.totalLikes.toString();

      if (groupFeedList.totalComments == 0) {
        comments = "";
      } else {
        var titleComment = groupFeedList.totalComments == 1 ? "" : "";

        comments = '${groupFeedList.totalComments.toString()} $titleComment';
      }
    }

    return CommentCard(
      moreOnTapIcon: true,
      userProfileTap: () {
        _commonHelper?.startActivity(
            UserProfileActivity(userId: groupFeedList.userId.toString()));
      },
      userProfile: groupFeedList.userProfilePic.toString(),
      username: groupFeedList.userName.toString(),
      moreOnTap: () {
        goToMore(groupFeedList);
      },
      content: groupFeedList.comment.toString(),
      likeImage:
          groupFeedList.isLike == true ? IconsHelper.like : IconsHelper.unLike,
      likeOnTap: () {
        goToLike(groupFeedList);
      },
      likeCount: likes,
      likeTextOnTap: () {
        _commonHelper?.startActivity(
            CarnivalLikeListActivity(groupFeedList.carnivalFeedId.toString()));
      },
      commentTextOnTap: () {
        goToComment(groupFeedList);
      },
      commentCount: comments,
      commentOnTap: () {
        goToComment(groupFeedList);
      },
      countDown:
          _commonHelper!.getTimeDifference(groupFeedList.insertDate ?? 0),
    );
  }

  Widget _joinedGroupWarning() {
    return Container(
        alignment: Alignment.center,
        height: _commonHelper?.screenHeight * .5,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text(StringHelper.notGroupJoinMsg,
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishGray)));
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
          child: Text(StringHelper.Ok,
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
// ** Helper Functions **
//============================================================

  void goToLike(groupFeedList) {
    if (groupFeedList.isLike == true) {
      setState(() {
        groupFeedList.isLike = false;
        var totalLikes = groupFeedList.totalLikes ?? 0 - 1;
        groupFeedList.totalLikes = totalLikes;
      });
      _onUnLikeButtonTap(groupFeedList.carnivalFeedId.toString());
    } else {
      setState(() {
        groupFeedList.isLike = true;

        var totalLikes = groupFeedList.totalLikes ?? 0 + 1;
        groupFeedList.totalLikes = totalLikes;
      });
      _onLikeButtonTap(groupFeedList.carnivalFeedId.toString());
    }
  }

  void goToComment(groupFeedList) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CarnivalCommentListActivity(
                groupFeedList.carnivalFeedId.toString(),
                scrollMessage: false,
              )),
    ).then((value) {
      if (value) {
        _showProgress();
        _groupFeedList.clear();
        _getGroupFeeds();
      }
    });
  }

  void goToMore(groupFeedList) {
    if (groupFeedList.userId == mineUserId) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _showFeedBottomSheet(
              groupFeedList.carnivalFeedId.toString(),
              groupFeedList.comment.toString()));
    } else {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _showBlockBottomSheet(
              groupFeedList.userId.toString(),
              groupFeedList.carnivalFeedId.toString()));
    }
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

  void _onDisJoinButtonTap(String groupId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "groupId": groupId,
        });

        _groupBloc?.disJoinGroup(authToken.toString(), body).then((onValue) {
          setState(() {
            var totalSubscribers =
                _groupData?.groupList?[0].totalSubscribers ?? 0 - 1;
            _groupData?.groupList?[0].totalSubscribers = totalSubscribers;
            _groupData?.groupList?[0].isJoined = false;
          });

          _groupFeedList.clear();

          _getGroupFeeds();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onJoinButtonTap(String groupId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();
        var body = json.encode({
          "groupId": groupId,
        });
        _groupBloc?.joinGroup(authToken.toString(), body).then((onValue) {
          setState(() {
            var totalSubscribers =
                _groupData?.groupList?[0].totalSubscribers ?? 0 + 1;
            _groupData?.groupList?[0].totalSubscribers = totalSubscribers;
            _groupData?.groupList?[0].isJoined = true;
          });
          _groupFeedList.clear();
          _getGroupFeeds();
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
          "feedType": "carnivalFeed",
        });
        _apiHelper?.reportFeed(body, authToken.toString()).then((onValue) {
          _hideProgress();
          ReportFeedModel _reportModel = onValue;
          if (_reportModel.statusCode == 200)
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _successBottomSheet(
                    StringHelper.success, StringHelper.postSucMsg));
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
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
                        StringHelper.blocUserSucMsg, true));
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

  void _onFeedChanged(String value) {
    if (value.isEmpty) {
      editCarnivalFeedId = "";
      postButton = StringHelper.post.toUpperCase();
      setState(() {});
      return;
    }
  }

  void _getGroupDetails() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _groupBloc
              ?.getGroupList(token.toString(), widget.groupId.toString(), "")
              .then((onValue) {
            _showProgress();
            _getGroupFeeds();
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

  void _onLikeButtonTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var likeBody = json.encode({
          "carnivalFeedId": feedId,
        });
        _groupBloc?.likeFeed(authToken.toString(), likeBody);
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onUnLikeButtonTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var unLikeBody = json.encode({
          "carnivalFeedId": feedId,
        });
        _groupBloc?.unLikeFeed(authToken.toString(), unLikeBody);
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _getGroupFeeds() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _groupBloc
              ?.getGroupFeedList(token.toString(), widget.groupId.toString())
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

  void _onEditTap() {
    FocusScope.of(context).unfocus();

    if (_commentController.text.toString().isEmpty) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _commonHelper!.successBottomSheet(
              StringHelper.error, StringHelper.writeSomethingMsg, false));

      return;
    }

    var body = json.encode({
      "groupId": widget.groupId,
      "carnivalFeedId": editCarnivalFeedId,
      "comment": _commentController.text.toString()
    });

    _commentController.text = "";

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();
        _apiHelper
            ?.updateCarnivalFeed(body, authToken.toString())
            .then((onValue) {
          _groupFeedList.clear();

          _getGroupFeeds();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onPostTap() {
    FocusScope.of(context).unfocus();
    if (_commentController.text.toString().isEmpty) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _commonHelper!.successBottomSheet(
              StringHelper.error, StringHelper.writeSomethingMsg, false));
      return;
    }
    var body = json.encode({
      "groupId": widget.groupId,
      "comment": _commentController.text.toString()
    });
    _commentController.text = "";
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();
        _apiHelper
            ?.createCarnivalFeed(body, authToken.toString())
            .then((onValue) {
          _groupFeedList.clear();

          _getGroupFeeds();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onDeleteTap(String carnivalFeedId) {
    FocusScope.of(context).unfocus();

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _apiHelper
            ?.deleteCarnivalFeed(authToken.toString(), carnivalFeedId)
            .then((onValue) {
          DeleteCarnivalFeedModel _deleteModel = onValue;

          if (_deleteModel.statusCode == 200) {
            _groupFeedList.clear();

            _getGroupFeeds();

            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _commonHelper!
                    .successBottomSheet(
                        "Post Deleted", "Post Successfully Deleted", false));
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

//============================================================
// ** Firebase Function **
//============================================================

}
