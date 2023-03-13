import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/bottom_tabs/explore/carnivals_continets/share_multiple_moment_activity.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/blocs/explore/carnival_list_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/carnival_photos_list.dart';
import 'package:solomas/model/report_feed_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../../../resources_helper/common_widget.dart';
import '../../../../resources_helper/screen_area/scaffold.dart';
import '../../profile_tab.dart';
import 'carnival_photos_comment_activity.dart';
import 'carnival_photos_likes_activity.dart';

class CarnivalPhotos extends StatefulWidget {
  final String? carnivalId, carnivalName, commentID;

  const CarnivalPhotos(
      {key, this.carnivalId, this.carnivalName, this.commentID})
      : super(key: key);

  @override
  _CarnivalPhotosState createState() => _CarnivalPhotosState();
}

class _CarnivalPhotosState extends State<CarnivalPhotos> {
  bool _isShowProgress = false;

  CommonHelper? _commonHelper;

  List<CarnivalPhotoList> _aList = [];

  CarnivalListBloc? _carnivalListBloc;

  String? authToken, mineUserId = "", mineProfilePic = "";

  ApiHelper? _apiHelper;

  int currentPos = 0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final CarouselController _controller = CarouselController();

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

  @override
  void initState() {
    super.initState();
    print("Comment Id is ${widget.commentID}");
    PrefHelper.getUserId().then((token) {
      setState(() {
        mineUserId = token;
      });
    });

    _carnivalListBloc = CarnivalListBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _carnivalPhotosData());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SoloScaffold(
      appBar: appBar(),
      body: StreamBuilder(
          stream: _carnivalListBloc?.carnivalPhotosList,
          builder: (context, AsyncSnapshot<CarnivalPhotosList> snapshot) {
            if (snapshot.hasData) {
              if (_aList.isEmpty) {
                _aList = snapshot.data!.data!.carnivalPhotoList!;
                print("alist" + _aList.toString());
              }

              return _carnivalListData();
            } else if (snapshot.hasError) {
              return _carnivalListData();
            }

            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
          }),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
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
            child: Text(widget.carnivalName!.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white, fontSize: Constants.FONT_APP_TITLE)),
          )
        ],
      ),
    );
  }

  Widget _carnivalListData() {
    return Stack(
      children: [
        RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: Container(
            height: _commonHelper?.screenHeight,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      new MaterialPageRoute(
                          builder: (_) => ShareMultipleMomentActivity(
                                carnivalId: widget.carnivalId.toString(),
                              )),
                    )
                        .then((mapData) {
                      if (mapData != null && mapData) {
                        setState(() {
                          _aList.clear();
                        });
                        _showProgress();
                        _carnivalPhotosData();
                      }
                    });
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    margin: EdgeInsets.all(0.0),
                    elevation: DimensHelper.tinySides,
                    child: Container(
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Container(
                            child: Text(
                              StringHelper.shareYourPhoto,
                              style: TextStyle(
                                  color: SoloColor.spanishGray,
                                  fontSize: Constants.FONT_MEDIUM),
                            ),
                            padding: EdgeInsets.only(
                                left: DimensHelper.sidesMarginDouble),
                          )),
                          Container(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Image.asset(
                                  'images/ic_lg_bag.png',
                                  width: 25,
                                  height: 25,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              padding:
                                  EdgeInsets.all(DimensHelper.sidesMargin)),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  child: _noCarnivalWarning(),
                  visible: _aList.isEmpty,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _aList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return mainItem(index);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        Align(
          child:
              ProgressBarIndicator(_commonHelper?.screenSize, _isShowProgress),
          alignment: FractionalOffset.center,
        )
      ],
    );
  }

  Widget mainItem(int index) {
    return imageTypePublicFeed(index);
  }

  Widget imageTypePublicFeed(int index) {
    var likes = _aList[index].totalLikes == 0
        ? ""
        : " " + _aList[index].totalLikes.toString();
    if (_aList[index].totalLikes == 0) {
      likes = "";
    } else if (_aList[index].totalLikes == 1) {
      likes = _aList[index].totalLikes.toString() + " Like";
    } else {
      likes = _aList[index].totalLikes.toString() + " Likes";
    }

    var comments;

    if (_aList[index].totalComments == 0) {
      comments = "Comment";
    } else {
      var titleComment =
          _aList[index].totalComments == 1 ? "Comment" : "Comments";

      comments = '${_aList[index].totalComments.toString()} $titleComment';
    }

    Widget likeButton(int index) {
      return InkWell(
        child: Container(
          width: _commonHelper?.screenWidth * .43,
          child: Material(
            color: Colors.transparent,
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      var totalLikes = _aList[index].totalLikes ?? 0 + 1;
                      _aList[index].totalLikes = totalLikes;

                      _aList[index].isLike = true;
                    });

                    _onLikeButtonTap(_aList[index].carnivalPhotoId.toString());
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: DimensHelper.halfSides),
                    child: Image.asset(
                      'images/ic_like_black.png',
                      width: 15,
                      height: 14,
                      fit: BoxFit.cover,
                      color: SoloColor.white,
                    ),
                  ),
                ),

                Container(
                    margin: EdgeInsets.only(left: DimensHelper.halfSides),
                    child:
                        Text(likes, style: TextStyle(color: SoloColor.white))),
                // text
              ],
            ),
          ),
        ),
      );
    }

    Widget unLikeButton(int index) {
      return Container(
        width: _commonHelper?.screenWidth * .43,
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    var totalLikes = _aList[index].totalLikes ?? 0 - 1;
                    _aList[index].totalLikes = totalLikes;
                    _aList[index].isLike = false;
                  });

                  _onUnLikeButtonTap(_aList[index].carnivalPhotoId.toString());
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: DimensHelper.halfSides),
                  child: Image.asset(
                    'images/ic_like_black.png',
                    width: 15,
                    height: 15,
                    fit: BoxFit.cover,
                    color: SoloColor.black,
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  _commonHelper?.startActivity(CarnivalPhotosLikeActivity(
                      _aList[index].carnivalPhotoId.toString()));
                },
                child: Container(
                    margin: EdgeInsets.only(left: DimensHelper.halfSides),
                    child:
                        Text(likes, style: TextStyle(color: SoloColor.white))),
              ),
              // text
            ],
          ),
        ),
      );
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
                height: 340,
                margin: EdgeInsets.only(
                    left: DimensHelper.halfSides,
                    right: DimensHelper.halfSides,
                    bottom: DimensHelper.halfSides),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            /* if (_aList[index].userId == mineUserId) {
                              */ /*_commonHelper
                                    .startActivity(ProfileTab(isFromHome: true));*/ /*
                              Navigator.of(context)
                                  .push(
                                new MaterialPageRoute(
                                    builder: (_) =>
                                        new ProfileTab(isFromHome: true)),
                              )
                                  .then((mapData) {
                                if (mapData != null && mapData) {
                                  _aList.clear();

                                  _showProgress();
                                  _carnivalPhotosData();
                                }
                              });
                            } else {
                              _commonHelper.startActivity(UserProfileActivity(
                                  userId: _aList[index].userId));
                            }*/
                          },
                          child: slidingImages(index),
                        ),
                      ],
                    ),
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      color: SoloColor.blue,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _aList[index].isLike == true
                              ? unLikeButton(index)
                              : likeButton(index),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CarnivalPhotosComment(
                                        carnivalPhotoId: _aList[index]
                                            .carnivalPhotoId
                                            .toString(),
                                        showKeyBoard: false,
                                        scrollMessage: false)),
                              ).then((value) {
                                if (value != null && value) {
                                  _showProgress();
                                  _aList.clear();
                                  _carnivalPhotosData();
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
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: Image.asset(
                                        'images/comment.png',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.cover,
                                        color: SoloColor.white,
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(
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
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _onUnLikeButtonTap(String carnivalPhotoId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var unLikeBody = json.encode({
          "carnivalPhotoId": carnivalPhotoId,
        });
        _carnivalListBloc?.carnivalPhotoUnLike(
            unLikeBody, authToken.toString());
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onLikeButtonTap(String carnivalPhotoId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var likeBody = json.encode({
          "carnivalPhotoId": carnivalPhotoId,
        });

        _carnivalListBloc?.carnivalPhotoLike(likeBody, authToken.toString());
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  Widget _noCarnivalWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text(StringHelper.noCarnivalPhoto,
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishGray)));
  }

  Future<Null> _refresh() async {
    _showProgress();

    _aList.clear();

    _carnivalPhotosData();
  }

  void _carnivalPhotosData() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _carnivalListBloc
              ?.getCarnivalPhotos(
                  token.toString(), widget.carnivalId.toString())
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

  Widget slidingImages(int index1) {
    return Stack(
      children: [
        _aList[index1].images!.length > 1
            ? CarouselSlider.builder(
                itemCount: _aList[index1].images?.length,
                carouselController: _controller,
                options: CarouselOptions(
                  autoPlay: false,
                  height: 295,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _aList[index1].sliderPosition = index;
                    });
                  },
                ),
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  return Container(
                    height: 295,
                    width: _commonHelper?.screenWidth * .9,
                    child: ClipRRect(
                      child: CachedNetworkImage(
                          imageUrl: _aList[index1].images![index],
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              imagePlaceHolder()),
                    ),
                  );
                },
              )
            : Container(
                height: 295,
                width: _commonHelper?.screenWidth * .9,
                child: ClipRRect(
                  child: CachedNetworkImage(
                      imageUrl: _aList[index1].images![0],
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => imagePlaceHolder()),
                ),
              ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Visibility(
            visible: _aList[index1].images!.length > 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _aList[index1].images!.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _aList[index1].sliderPosition == entry.key
                            ? Colors.black
                            : Colors.grey),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
/*
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Visibility(
            visible: _aList[index1].images.length > 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _aList[index1].images.map((url) {
                int index2 = _aList[index1].images.indexOf(url);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentPos == index2 ? Colors.black : Colors.grey,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
*/
      ],
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
                  if (_aList[index].userId == mineUserId) {
                    Navigator.of(context)
                        .push(
                      new MaterialPageRoute(
                          builder: (_) => new ProfileTab(isFromHome: true)),
                    )
                        .then((mapData) {
                      if (mapData != null && mapData) {
                        _aList.clear();
                        _showProgress();
                        _carnivalPhotosData();
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
                      child: profileImage(index),
                    ),
                    Container(
                      width: _commonHelper?.screenWidth * .6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_aList[index].userName.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: SoloColor.black,
                                  fontSize: Constants.FONT_TOP)),
                          Padding(
                            padding:
                                EdgeInsets.only(top: DimensHelper.smallSides),
                            child: Text(
                                _commonHelper!.getTimeDifference(
                                    _aList[index].insertDate ?? 0),
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
                    return _aList[index].userId == mineUserId
                        ? _showBottomSheetEditDel(
                            _aList[index].carnivalPhotoId.toString(),
                            _aList[index])
                        : _showBottomSheet(_aList[index].userId.toString(),
                            _aList[index].carnivalPhotoId.toString());
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

  Widget _showBottomSheetEditDel(
    String id,
    CarnivalPhotoList aList,
  ) {
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
      CupertinoActionSheetAction(
        child: Text(StringHelper.cancel,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ]);
  }

  Widget _showDeleteBottomSheet(String delId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.deleteEvent,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.deleteEventWarring,
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

  void _deleteButtonTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _carnivalListBloc
            ?.deletePhoto(authToken.toString(), feedId)
            .then((onValue) {
          _aList.clear();

          _commonHelper?.showToast(StringHelper.photoDelete);
          _carnivalPhotosData();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
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
      message: Text(StringHelper.deleteEventWarring,
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

  void _onReportPostTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "feedId": feedId,
          "feedType": "carnivalPhoto",
        });

        _apiHelper?.reportFeed(body, authToken.toString()).then((onValue) {
          _hideProgress();

          ReportFeedModel _reportModel = onValue;

          if (_reportModel.statusCode == 200)
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _successBottomSheet(
                    StringHelper.success, StringHelper.photoReported));
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

  Widget profileImage(int index) {
    return ClipOval(
        child: CachedNetworkImage(
      imageUrl: _aList[index].userProfilePic.toString(),
      height: 40,
      width: 40,
      fit: BoxFit.cover,
      placeholder: (context, url) => imagePlaceHolder(),
      errorWidget: (context, url, error) => imagePlaceHolder(),
    ));
  }

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }
}
