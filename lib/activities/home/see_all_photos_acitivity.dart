import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/blocs/home/home_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/block_user_model.dart';
import 'package:solomas/model/report_feed_model.dart';
import 'package:solomas/model/user_profile_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../common_helpers/feed_card_profile.dart';
import 'feed_comments_activity.dart';
import 'feed_likes_activity.dart';

class SeeAllPhotosActivity extends StatefulWidget {
  String? id;
  final Response? userProfile;

  final List<Photo>? publicFeedDetail;

  final bool isMineProfile;

  SeeAllPhotosActivity(
      {this.userProfile,
      this.publicFeedDetail,
      this.isMineProfile = false,
      this.id});

  @override
  State<StatefulWidget> createState() {
    return _SeeAllPhotosState();
  }
}

class _SeeAllPhotosState extends State<SeeAllPhotosActivity> {
  CommonHelper? _commonHelper;

  HomeBloc? _homeActivityBloc;

  String? authToken, mineUserId;

  bool _isShowProgress = false;

  ApiHelper? _apiHelper;

  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();

    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });

    PrefHelper.getAuthToken().then((onValue) {
      authToken = onValue;
    });

    _apiHelper = ApiHelper();

    _homeActivityBloc = HomeBloc();
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

  void _onLikeButtonTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var likeBody = json.encode({
          "publicFeedId": feedId,
        });

        _homeActivityBloc?.likeFeed(likeBody, authToken.toString());
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
          "publicFeedId": feedId,
        });

        _homeActivityBloc?.unLikeFeed(unLikeBody, authToken.toString());
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
                    .successBottomSheet(
                    StringHelper.success, StringHelper.blocUserSucMsg, true));
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

  void _onReportPostTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "feedId": feedId,
          "feedType": "publicFeed",
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

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    Widget userPhotosPic() {
      return ClipOval(
          child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: widget.userProfile!.profilePic.toString(),
              height: 40,
              width: 40,
              placeholder: (context, url) => imagePlaceHolder(),
              errorWidget: (context, url, error) => imagePlaceHolder()));
    }

    void _deleteButtonTap(String feedId, int index) {
      _commonHelper?.isInternetAvailable().then((available) {
        if (available) {
          _showProgress();

          _homeActivityBloc
              ?.deleteFeed(authToken.toString(), feedId)
              .then((onValue) {
            _hideProgress();

            widget.publicFeedDetail?.removeAt(index);

            if (widget.publicFeedDetail!.isEmpty) {
              _commonHelper?.closeActivity();
            }

            _commonHelper?.showToast(StringHelper.publicFeedDeletedSuccessfully);
          }).catchError((onError) {
            _hideProgress();
          });
        } else {
          _commonHelper?.showAlert(
              StringHelper.noInternetTitle, StringHelper.noInternetMsg);
        }
      });
    }

    Widget _showBlockBottomSheet(String blockUserId) {
      return CupertinoActionSheet(
        title: Text(StringHelper.block,
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

    Widget _showDeleteBottomSheet(String publicFeedID, int index) {
      return CupertinoActionSheet(
        title: Text(StringHelper.deletePost,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        message: Text(StringHelper.areYouSureWantToDelete,
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

              _deleteButtonTap(publicFeedID, index);
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

    Widget _showReportBottomSheet(String publicFeedId) {
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

              _onReportPostTap(publicFeedId);
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

    Widget _showBottomSheet(String blockUserId, String publicFeedId) {
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
                      _showBlockBottomSheet(blockUserId));
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
                      _showReportBottomSheet(publicFeedId));
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

    Widget userDetails(int index) {
      return Container(
        padding: EdgeInsets.all(DimensHelper.sidesMargin),
        child: Stack(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: DimensHelper.halfSides),
                      child: userPhotosPic(),
                    ),
                    Container(
                      width: _commonHelper?.screenWidth * .6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.userProfile!.fullName.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: SoloColor.black,
                                  fontSize: Constants.FONT_TOP)),
                          Padding(
                            padding:
                                EdgeInsets.only(top: DimensHelper.smallSides),
                            child: Text(
                                _commonHelper!.getTimeDifference(widget
                                        .publicFeedDetail?[index].insertDate ??
                                    0),
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
                showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) {
                      return widget.userProfile?.userId == mineUserId
                          ? _showDeleteBottomSheet(
                              widget.publicFeedDetail![index].publicFeedId
                                  .toString(),
                              index)
                          : _showBottomSheet(
                              widget.userProfile!.userId.toString(),
                              widget.publicFeedDetail![index].publicFeedId
                                  .toString());
                    });
              },
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      child:
                          Icon(Icons.more_vert, color: SoloColor.spanishGray))),
            )
          ],
        ),
      );
    }

    Widget likeButton(int index) {
      return InkWell(
        onTap: () {
          setState(() {
            var totalLikes =
                widget.publicFeedDetail?[index].totalLikes ?? 0 + 1;
            widget.publicFeedDetail?[index].totalLikes = totalLikes;
            widget.publicFeedDetail?[index].isLike = true;
          });

          _onLikeButtonTap(
              widget.publicFeedDetail![index].publicFeedId.toString());
        },
        child: Container(
          padding: EdgeInsets.only(
              top: DimensHelper.sidesMargin, bottom: DimensHelper.sidesMargin),
          width: _commonHelper?.screenWidth * .45,
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/ic_like_black.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  color: SoloColor.silverSand,
                ),

                Container(
                    margin: EdgeInsets.only(left: DimensHelper.halfSides),
                    child: Text(StringHelper.like)),
                // text
              ],
            ),
          ),
        ),
      );
    }

    Widget unLikeButton(int index) {
      return InkWell(
        onTap: () {
          setState(() {
            var totalLikes =
                widget.publicFeedDetail?[index].totalLikes ?? 0 - 1;
            widget.publicFeedDetail?[index].totalLikes = totalLikes;
            widget.publicFeedDetail?[index].isLike = false;
          });

          _onUnLikeButtonTap(
              widget.publicFeedDetail![index].publicFeedId.toString());
        },
        child: Container(
          padding: EdgeInsets.only(
              top: DimensHelper.sidesMargin, bottom: DimensHelper.sidesMargin),
          width: _commonHelper?.screenWidth * .45,
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/ic_like_black.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  color: SoloColor.blue,
                ),

                Container(
                    margin: EdgeInsets.only(left: DimensHelper.halfSides),
                    child: Text(StringHelper.like,
                        style: TextStyle(color: SoloColor.blue))), // text
              ],
            ),
          ),
        ),
      );
    }

    Widget titleTypePublicFeed(int index) {
      var likes = widget.publicFeedDetail?[index].totalLikes == 0
          ? ""
          : " " + widget.publicFeedDetail![index].totalLikes.toString();

      if (widget.publicFeedDetail?[index].totalLikes == 0) {
        likes = "";
      } else if (widget.publicFeedDetail?[index].totalLikes == 1) {
        likes = widget.publicFeedDetail![index].totalLikes.toString() +  StringHelper.likeS;
      } else {
        likes =
            widget.publicFeedDetail![index].totalLikes.toString() + StringHelper.likeS;
      }

      var comments;

      if (widget.publicFeedDetail?[index].totalComments == 0) {
        comments = "Comment";
      } else {
        var titleComment = widget.publicFeedDetail?[index].totalComments == 1
            ? "Comment"
            : "Comments";

        comments =
            '${widget.publicFeedDetail![index].totalComments.toString()} $titleComment';
      }

      Widget likeButton(int index) {
        return Container(
          width: _commonHelper?.screenWidth * .45,
          child: Material(
            color: Colors.transparent,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      var totalLikes =
                          widget.publicFeedDetail?[index].totalLikes ?? 0 + 1;
                      widget.publicFeedDetail?[index].totalLikes = totalLikes;
                      widget.publicFeedDetail?[index].isLike = true;
                    });

                    _onLikeButtonTap(widget
                        .publicFeedDetail![index].publicFeedId
                        .toString());
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: DimensHelper.halfSides),
                    child: Image.asset('images/ic_like_black.png',
                        width: 15,
                        height: 15,
                        fit: BoxFit.cover,
                        color: SoloColor.white),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    _commonHelper?.startActivity(FeedLikeActivity(widget
                        .publicFeedDetail![index].publicFeedId
                        .toString()));
                  },
                  child: Container(
                      margin: EdgeInsets.only(left: DimensHelper.halfSides),
                      child: Text(likes,
                          style: TextStyle(color: SoloColor.white))),
                ),
                // text
              ],
            ),
          ),
        );
      }

      Widget unLikeButton(int index) {
        return Container(
          width: _commonHelper?.screenWidth * .45,
          child: Material(
            color: Colors.transparent,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      var totalLikes =
                          widget.publicFeedDetail?[index].totalLikes ?? 0 - 1;
                      widget.publicFeedDetail?[index].totalLikes = totalLikes;
                      widget.publicFeedDetail?[index].isLike = false;
                    });

                    _onUnLikeButtonTap(widget
                        .publicFeedDetail![index].publicFeedId
                        .toString());
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: DimensHelper.halfSides),
                    child: Image.asset(
                      'images/ic_like_black.png',
                      width: 15,
                      height: 15,
                      fit: BoxFit.cover,
                      color: SoloColor.black,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    _commonHelper?.startActivity(FeedLikeActivity(widget
                        .publicFeedDetail![index].publicFeedId
                        .toString()));
                  },
                  child: Container(
                      margin: EdgeInsets.only(left: DimensHelper.halfSides),
                      child: Text(likes,
                          style: TextStyle(color: SoloColor.white))),
                ), // text
              ],
            ),
          ),
        );
      }

//       return Card(
//         elevation: DimensHelper.tinySides,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(DimensHelper.sidesMargin),
//         ),
//         margin: EdgeInsets.only(
//             left: DimensHelper.sidesMargin,
//             right: DimensHelper.sidesMargin,
//             top: DimensHelper.halfSides,
//             bottom: DimensHelper.halfSides),
//         child: Container(
//             child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             FeedCard(
//               userProfile: widget.userProfile!.profilePic.toString(),
//               userName: widget.userProfile!.fullName.toString(),
//               userLocation: _commonHelper!.getTimeDifference(
//                   widget.publicFeedDetail?[index].insertDate ?? 0),
//               userDetailsOnTap: () {},
//               moreTap: () {},
//
//               feedImage: widget.publicFeedDetail!,
//               // feedImage: _searchList![index].image,
//               controller: _controller,
//               likeImage: IconsHelper.like,
//               likeCount: "2.4K",
//               likeOnTap: () {},
//               commentCount: "658",
//               indexForSearch: index,
//               commentOnTap: () {},
//               countDown: "3h ago",
//               content: StringHelper.dummyHomeText,
//               feedTap: () {},
//             ),
//             userDetails(index),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   alignment: Alignment.centerLeft,
//                   margin: EdgeInsets.only(
//                       left: DimensHelper.sidesMargin,
//                       right: DimensHelper.sidesMargin),
//                   child: Text(
//                     widget.publicFeedDetail![index].title.toString(),
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: Constants.FONT_TOP,
//                         color: SoloColor.black),
//                   ),
//                 ),
//                 Container(
//                   alignment: Alignment.centerLeft,
//                   margin: EdgeInsets.only(
//                       top: DimensHelper.halfSides,
//                       left: DimensHelper.sidesMargin,
//                       right: DimensHelper.sidesMargin,
//                       bottom: DimensHelper.sidesMargin),
//                   child: Text(
//                     widget.publicFeedDetail![index].description.toString(),
//                     style: TextStyle(
//                         fontWeight: FontWeight.normal,
//                         fontSize: Constants.FONT_MEDIUM,
//                         color: SoloColor.spanishGray),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       bottom: 16.0, left: 8.0, right: 8.0),
//                   child: Container(
//                     height: 40,
//                     alignment: Alignment.bottomCenter,
//                     color: SoloColor.blue,
//                     child: Row(
//                       children: [
//                         widget.publicFeedDetail?[index].isLike == true
//                             ? unLikeButton(index)
//                             : likeButton(index),
//                         /* InkWell(
//                           onTap: () {
//                             _commonHelper.startActivity(FeedLikeActivity(
//                                 widget.publicFeedDetail[index].publicFeedId));
//                           },
//                           child: Container(
//                             padding: EdgeInsets.only(
//                                 top: DimensHelper.halfSides,
//                                 bottom: DimensHelper.halfSides),
//                             width: _commonHelper.screenWidth * .43,
//                             child: Material(
//                               color: Colors.transparent,
//                               child: Container(
//                                 alignment: Alignment.centerLeft,
//                                 margin:
//                                     EdgeInsets.only(left: DimensHelper.halfSides),
//                                 child: RichText(
//                                   text: TextSpan(
//                                     children: [
//                                       WidgetSpan(
//                                           child: Image.asset(
//                                         'images/ic_like_black.png',
//                                         width: 15,
//                                         height: 15,
//                                         fit: BoxFit.cover,
//                                         color: ColorsHelper.colorWhite,
//                                       )),
//                                       TextSpan(
//                                           text: likes,
//                                           style: TextStyle(
//                                               fontSize: Constants.FONT_LOW,
//                                               color: ColorsHelper.colorWhite)),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),*/
//                         InkWell(
//                           onTap: () {
//                             _commonHelper
//                                 ?.startActivity(PublicFeedCommentActivity(
//                               publicFeedId: widget
//                                   .publicFeedDetail![index].publicFeedId
//                                   .toString(),
//                               showKeyBoard: true,
//                               scrollMessage: false,
//                             ));
//
//                             /* _commonHelper.startActivity(FeedLikeActivity(
//                                     widget.publicFeedDetail[index].publicFeedId));*/
//                           },
//                           child: Container(
//                             alignment: Alignment.centerRight,
//                             padding: EdgeInsets.only(
//                                 top: DimensHelper.halfSides,
//                                 bottom: DimensHelper.halfSides),
//                             width: _commonHelper?.screenWidth * .43,
//                             child: Material(
//                               color: Colors.transparent,
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(right: 4.0),
//                                     child: Image.asset(
//                                       'images/comment.png',
//                                       width: 20,
//                                       height: 20,
//                                       fit: BoxFit.cover,
//                                       color: SoloColor.white,
//                                     ),
//                                   ),
//                                   Container(
//                                       padding: EdgeInsets.only(
//                                           right: DimensHelper.halfSides),
//                                       child: Text(comments,
//                                           style: TextStyle(
//                                               fontSize: Constants.FONT_LOW,
//                                               color: SoloColor.white))),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
// /*
//                 Container(
//                   child: Row(
//                     children: [
//                       widget.publicFeedDetail[index].isLike
//                           ? unLikeButton(index)
//                           : likeButton(index),
//                       InkWell(
//                         onTap: () {
//                           _commonHelper.startActivity(PublicFeedCommentActivity(
//                             publicFeedId:
//                                 widget.publicFeedDetail[index].publicFeedId,
//                             showKeyBoard: true,
//                             scrollMessage: false,
//                           ));
//                         },
//                         child: Container(
//                           padding: EdgeInsets.only(
//                               top: DimensHelper.sidesMargin,
//                               bottom: DimensHelper.sidesMargin),
//                           width: _commonHelper.screenWidth * .45,
//                           child: Material(
//                             color: Colors.transparent,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Image.asset(
//                                   'images/comment.png',
//                                   width: 20,
//                                   height: 20,
//                                   fit: BoxFit.cover,
//                                   color: ColorsHelper.colorLightGrey,
//                                 ),
//
//                                 Container(
//                                     margin: EdgeInsets.only(
//                                         left: DimensHelper.smallSides),
//                                     child: Text("Comment")), // text
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
// */
//               ],
//             )
//           ],
//         )),
//       );

      return FeedCardProfile(
        userProfile: widget.userProfile!.profilePic.toString(),
        userName: widget.userProfile!.fullName.toString(),
        userLocation: _commonHelper!
            .getTimeDifference(widget.publicFeedDetail?[index].insertDate ?? 0),
        userDetailsOnTap: () {},
        moreTap: () {},

        feedImage: widget.publicFeedDetail!,
        // feedImage: _searchList![index].image,
        controller: _controller,
        likeImage: IconsHelper.like,
        likeCount: "2.4K",
        likeOnTap: () {},
        commentCount: "658",
        indexForSearch: index,
        commentOnTap: () {},
        countDown: "3h ago",
        content: StringHelper.dummyHomeText,
        feedTap: () {},
      );
    }

    Widget imageTypePublicFeed(int index) {
      var likes = widget.publicFeedDetail?[index].totalLikes == 0
          ? ""
          : " " + widget.publicFeedDetail![index].totalLikes.toString();

      if (widget.publicFeedDetail?[index].totalLikes == 0) {
        likes = "";
      } else if (widget.publicFeedDetail?[index].totalLikes == 1) {
        likes = widget.publicFeedDetail![index].totalLikes.toString() + " Like";
      } else {
        likes =
            widget.publicFeedDetail![index].totalLikes.toString() + " Likes";
      }

      var comments;

      if (widget.publicFeedDetail?[index].totalComments == 0) {
        comments = "Comment";
      } else {
        var titleComment = widget.publicFeedDetail?[index].totalComments == 1
            ? "Comment"
            : "Comments";

        comments =
            '${widget.publicFeedDetail![index].totalComments.toString()} ';
      }

      Widget likeButton(int index) {
        return Container(
          width: _commonHelper?.screenWidth * .45,
          child: Material(
            color: Colors.transparent,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      var totalLikes =
                          widget.publicFeedDetail?[index].totalLikes ?? 0 + 1;
                      widget.publicFeedDetail?[index].totalLikes = totalLikes;
                      widget.publicFeedDetail?[index].isLike = true;
                    });

                    _onLikeButtonTap(widget
                        .publicFeedDetail![index].publicFeedId
                        .toString());
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: DimensHelper.halfSides),
                    child: Image.asset(
                      'images/ic_like_black.png',
                      width: 15,
                      height: 15,
                      fit: BoxFit.cover,
                      color: SoloColor.white,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    _commonHelper?.startActivity(FeedLikeActivity(widget
                        .publicFeedDetail![index].publicFeedId
                        .toString()));
                  },
                  child: Container(
                      margin: EdgeInsets.only(left: DimensHelper.halfSides),
                      child: Text(likes,
                          style: TextStyle(color: SoloColor.white))),
                ),
                // text
              ],
            ),
          ),
        );
      }

      Widget unLikeButton(int index) {
        return Container(
          width: _commonHelper?.screenWidth * .45,
          child: Material(
            color: Colors.transparent,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      var totalLikes =
                          widget.publicFeedDetail?[index].totalLikes ?? 0 - 1;
                      widget.publicFeedDetail?[index].totalLikes = totalLikes;
                      widget.publicFeedDetail?[index].isLike = false;
                    });

                    _onUnLikeButtonTap(widget
                        .publicFeedDetail![index].publicFeedId
                        .toString());
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: DimensHelper.halfSides),
                    child: Image.asset(
                      'images/ic_like_black.png',
                      width: 15,
                      height: 15,
                      fit: BoxFit.cover,
                      color: SoloColor.black,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    _commonHelper?.startActivity(FeedLikeActivity(widget
                        .publicFeedDetail![index].publicFeedId
                        .toString()));
                  },
                  child: Container(
                      margin: EdgeInsets.only(left: DimensHelper.halfSides),
                      child: Text(likes,
                          style: TextStyle(color: SoloColor.white))),
                ), // text
              ],
            ),
          ),
        );
      }

      return FeedCardProfile(
        userProfile: widget.userProfile!.profilePic.toString(),
        userName: widget.userProfile!.fullName.toString(),
        userLocation: _commonHelper!
            .getTimeDifference(widget.publicFeedDetail?[index].insertDate ?? 0),
        moreTap: () {
          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) {
                return widget.userProfile?.userId == mineUserId
                    ? _showDeleteBottomSheet(
                        widget.publicFeedDetail![index].publicFeedId.toString(),
                        index)
                    : _showBottomSheet(
                        widget.userProfile!.userId.toString(),
                        widget.publicFeedDetail![index].publicFeedId
                            .toString());
              });
        },
        feedImage: widget.publicFeedDetail!,
        indexForSearch: index,
        controller: _controller,
        likeImage: widget.publicFeedDetail?[index].isLike == true
            ? IconsHelper.like
            : IconsHelper.message,
        likeCount: likes,
        likeOnTap: () {
          if (widget.publicFeedDetail?[index].isLike == true) {
            setState(() {
              var totalLikes =
                  widget.publicFeedDetail?[index].totalLikes ?? 0 - 1;
              widget.publicFeedDetail?[index].totalLikes = totalLikes;
              widget.publicFeedDetail?[index].isLike = false;
            });

            _onUnLikeButtonTap(
                widget.publicFeedDetail![index].publicFeedId.toString());
          } else {
            setState(() {
              var totalLikes =
                  widget.publicFeedDetail?[index].totalLikes ?? 0 + 1;
              widget.publicFeedDetail?[index].totalLikes = totalLikes;
              widget.publicFeedDetail?[index].isLike = true;
            });

            _onLikeButtonTap(
                widget.publicFeedDetail![index].publicFeedId.toString());
          }
        },
        showLikesOnTap: () {
          _commonHelper?.startActivity(FeedLikeActivity(
              widget.publicFeedDetail![index].publicFeedId.toString()));
        },
        commentCount: comments,
        commentOnTap: () {
          _commonHelper?.startActivity(PublicFeedCommentActivity(
            publicFeedId:
                widget.publicFeedDetail![index].publicFeedId.toString(),
            scrollMessage: false,
          ));
        },
        content: StringHelper.dummyHomeText,
        feedTap: () {},
      );
//         Card(
//         elevation: DimensHelper.tinySides,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(DimensHelper.sidesMargin),
//         ),
//         margin: EdgeInsets.only(
//             left: DimensHelper.sidesMargin,
//             right: DimensHelper.sidesMargin,
//             top: DimensHelper.halfSides,
//             bottom: DimensHelper.halfSides),
//         child: Column(
//           children: [
//             Column(
//               children: [
//                 userDetails(index),
//                 Container(
//                   height: 335,
//                   margin: EdgeInsets.only(
//                       left: DimensHelper.halfSides,
//                       right: DimensHelper.halfSides),
//                   child: Stack(
//                     children: [
// /*
//
//                       Container(
//                         height: 335,
//                         width: _commonHelper.screenWidth * .9,
//                         child: ClipRRect(
//                           child: CachedNetworkImage(
//                             imageUrl: widget.publicFeedDetail[index].image[0],
//                             fit: BoxFit.cover,
//                             placeholder: (context, url) => imagePlaceHolder(),
//                         errorWidget: (context, url, error) =>
//                             imagePlaceHolder()
//                           ),
//                         ),
//                       ),
// */
//
//                       slidingImages(index),
//                       Align(
//                         alignment: Alignment.bottomCenter,
//                         child: Container(
//                           height: 40,
//                           alignment: Alignment.bottomCenter,
//                           color: SoloColor.blue,
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               widget.publicFeedDetail?[index].isLike == true
//                                   ? unLikeButton(index)
//                                   : likeButton(index),
//                               Spacer(),
// /*
//                               InkWell(
//                                 onTap: () {
//                                   _commonHelper.startActivity(FeedLikeActivity(
//                                       widget.publicFeedDetail[index]
//                                           .publicFeedId));
//                                 },
//                                 child: Container(
//                                   padding: EdgeInsets.only(
//                                       top: DimensHelper.halfSides,
//                                       bottom: DimensHelper.halfSides),
//                                   width: _commonHelper.screenWidth * .43,
//                                   child: Material(
//                                     color: Colors.transparent,
//                                     child: Container(
//                                         alignment: Alignment.centerLeft,
//                                         margin: EdgeInsets.only(
//                                             left: DimensHelper.halfSides),
//                                         child: RichText(
//                                           text: TextSpan(
//                                             children: [
//                                               WidgetSpan(
//                                                   child: Image.asset(
//                                                 'images/ic_like_black.png',
//                                                 width: 15,
//                                                 height: 15,
//                                                 fit: BoxFit.cover,
//                                                 color: ColorsHelper.colorWhite,
//                                               )),
//                                               TextSpan(
//                                                   text: likes,
//                                                   style: TextStyle(
//                                                       fontSize:
//                                                           Constants.FONT_LOW,
//                                                       color: ColorsHelper
//                                                           .colorWhite)),
//                                             ],
//                                           ),
//                                         )),
//                                   ),
//                                 ),
//                               ),
// */
//                               InkWell(
//                                 onTap: () {
//                                   _commonHelper
//                                       ?.startActivity(PublicFeedCommentActivity(
//                                     publicFeedId: widget
//                                         .publicFeedDetail![index].publicFeedId
//                                         .toString(),
//                                     scrollMessage: false,
//                                   ));
//                                 },
//                                 child: Container(
//                                   alignment: Alignment.centerRight,
//                                   padding: EdgeInsets.only(
//                                       top: DimensHelper.halfSides,
//                                       bottom: DimensHelper.halfSides),
//                                   width: _commonHelper?.screenWidth * .40,
//                                   child: Material(
//                                     color: Colors.transparent,
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         Image.asset(
//                                           'images/comment.png',
//                                           width: 20,
//                                           height: 20,
//                                           fit: BoxFit.cover,
//                                           color: SoloColor.white,
//                                         ),
//                                         Container(
//                                             padding: EdgeInsets.only(
//                                                 left: DimensHelper.halfSides,
//                                                 right: DimensHelper.halfSides),
//                                             child: Text(comments,
//                                                 style: TextStyle(
//                                                     fontSize:
//                                                         Constants.FONT_LOW,
//                                                     color: SoloColor.white))),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//                 Visibility(
//                   visible: widget.publicFeedDetail![index].title
//                       .toString()
//                       .isNotEmpty,
//                   child: Container(
//                     alignment: Alignment.centerLeft,
//                     margin: EdgeInsets.only(
//                         top: DimensHelper.sidesMargin,
//                         left: DimensHelper.sidesMargin,
//                         right: DimensHelper.sidesMargin,
//                         bottom: DimensHelper.sidesMargin),
//                     child: Text(
//                       widget.publicFeedDetail![index].title.toString(),
//                       style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           fontSize: Constants.FONT_MEDIUM,
//                           color: SoloColor.spanishGray),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       );
    }

    Widget photosCardDetail(int index) {
      return widget.publicFeedDetail?[index].type ==
              Constants.PUBLIC_FEED_TYPE_IMAGE
          ? imageTypePublicFeed(index)
          : titleTypePublicFeed(index);
    }

    return SoloScaffold(
      appBar: AppBar(
        backgroundColor: SoloColor.blue,
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            GestureDetector(
              onTap: () {
                _commonHelper?.closeActivity();
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
              child: Text(StringHelper.allPhotos.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: Constants.FONT_APP_TITLE)),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: DimensHelper.sidesMargin),
            height: _commonHelper?.screenHeight,
            child: ListView.builder(
                itemCount: widget.publicFeedDetail?.length,
                itemBuilder: (BuildContext context, int index) {
                  return photosCardDetail(index);
                }),
          ),
          Align(
            child: ProgressBarIndicator(
                _commonHelper?.screenSize, _isShowProgress),
            alignment: FractionalOffset.center,
          )
        ],
      ),
    );
  }

  Widget slidingImages(int index1) {
    return Stack(
      children: [
        widget.publicFeedDetail![index1].image!.length > 1
            ? CarouselSlider.builder(
                itemCount: widget.publicFeedDetail?[index1].image?.length,
                carouselController: _controller,
                options: CarouselOptions(
                  autoPlay: false,
                  height: 295,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      widget.publicFeedDetail?[index1].sliderPosition = index;
                    });
                  },
                ),
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  return Container(
                    height: 295,
                    width: _commonHelper?.screenWidth * .9,
                    child: ClipRRect(
                      child: CachedNetworkImage(
                        imageUrl:
                            widget.publicFeedDetail![index1].image![index],
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            imagePlaceHolder(),
                      ),
                    ),
                  );
                },
              )
            : Container(
                height: 295,
                width: _commonHelper?.screenWidth * .9,
                child: ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: widget.publicFeedDetail![index1].image![0],
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => imagePlaceHolder(),
                  ),
                ),
              ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Visibility(
            visible: widget.publicFeedDetail![index1].image!.length > 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.publicFeedDetail![index1].image!
                  .asMap()
                  .entries
                  .map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            widget.publicFeedDetail?[index1].sliderPosition ==
                                    entry.key
                                ? Colors.black
                                : Colors.grey),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _homeActivityBloc?.dispose();

    super.dispose();
  }
}
