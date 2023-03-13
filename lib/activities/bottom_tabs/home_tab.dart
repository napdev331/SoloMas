import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/home/add_video/add_video_screen.dart';
import 'package:solomas/activities/home/feed_comments_activity.dart';
import 'package:solomas/activities/home/feed_likes_activity.dart';
import 'package:solomas/activities/home/share_home_moment_activity.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/blocs/home/home_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/public_feeds_model.dart';
import 'package:solomas/model/report_feed_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/images.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/show_dialog.dart';
import '../../helpers/space.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';
import '../common_helpers/common.dart';
import '../common_helpers/feed_card.dart';
import '../home/search_people_activity.dart';

class HomeTab extends StatefulWidget {
  String? publicFeedId;
  bool? scrollMessage;

  HomeTab({this.publicFeedId, this.scrollMessage});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
//============================================================
// ** Properties **
//============================================================
  bool _isShowProgress = false;
  String? authToken, mineUserId = "", mineProfilePic = "";

  List<PublicFeedList>? _aList;
  List<PublicFeedList>? _searchList;
  HomeBloc? _homeActivityBloc;
  CommonHelper? _commonHelper;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final CarouselController _controller = CarouselController();

  ItemScrollController? _scrollController;

  ApiHelper? _apiHelper;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();

    _scrollController = ItemScrollController();
    print("public feed Id is ${widget.publicFeedId}");
    PrefHelper.getUserId().then((token) {
      setState(() {
        mineUserId = token;
      });
    });

    PrefHelper.getUserProfilePic().then((picture) {
      setState(() {
        mineProfilePic = picture;
      });
    });

    _apiHelper = ApiHelper();
    _aList = [];
    _searchList = [];

    _homeActivityBloc = HomeBloc();

    Timer.periodic(Duration(minutes: 20), (timer) {
      PrefHelper.getAuthToken().then((token) {
        _homeActivityBloc?.getCurrentLocation(token.toString());
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _getPublicFeeds());
  }

  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    print("Img Url");
    print(mineProfilePic.toString());
    return SoloScaffold(
      key: scaffoldKey,
      backGroundColor: SoloColor.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: appBar(),
        ),
      ),
      body: Column(children: [Expanded(child: mainBody())]),
    );
    /*Scaffold(
      backgroundColor: SoloColor.white,
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 0),
          child: appBar(),
        ),
      ),
      body: Column(children: [Expanded(child: mainBody())]),
    );*/
  }

  @override
  void dispose() {
    _homeActivityBloc?.dispose();
    widget.scrollMessage = false;
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================
  Widget appBar() {
    return SoloAppBar(
      leadingTap: () {
        Scaffold.of(context).openDrawer();
      },
      postOnTap: () {
        CommonHelper(context).startActivity(ShareMomentActivity());
      },
      searchOnTap: () {
        CommonHelper(context).startActivity(SearchPeopleActivity());
      },
      profileOnTap: () {
        CommonHelper(context).startActivity(ProfileTab(isFromHome: true));
      },
      profileImage: mineProfilePic.toString(),
    );
  }

  Widget mainBody() {
    return StreamBuilder(
        stream: _homeActivityBloc?.publicFeedList,
        builder: (context, AsyncSnapshot<PublicFeedsModel> snapshot) {
          if (snapshot.hasData) {
            if (_aList!.isEmpty) {
              _aList = snapshot.data?.data?.publicFeedList;
              if (widget.publicFeedId != null) {
                var pos = _aList!.indexWhere((innerElement) =>
                    innerElement.publicFeedId == widget.publicFeedId);
                Future.delayed(Duration.zero, () => _scrollToIndex(pos));
              }
            }
            _searchList?.addAll(_aList ?? []);
            return _homeData();
          } else if (snapshot.hasError) {
            return Container();
          }
          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
        });
  }

  Widget groupsTab() {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: SoloColor.spanishLightGrey.withOpacity(0.6),
                  blurRadius: 3,
                  spreadRadius: 0.5,
                ),
              ],
              color: SoloColor.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage(
                                IconsHelper.group_img,
                              ),
                              fit: BoxFit.fill,
                            )),
                      ),
                      space(width: _commonHelper?.screenWidth * 0.04),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            StringHelper.baltimoreGroup,
                            style: SoloStyle.black54W500SmallMax,
                          ),
                          space(height: 5),
                          Container(
                              width: _commonHelper?.screenWidth * 0.55,
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  text: StringHelper.bryDown,
                                  style: SoloStyle.lightGrey200W700Medium,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: StringHelper.loremIpsumDolor,
                                        style:
                                            SoloStyle.lightGrey200W500Medium),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        StringHelper.groupDate,
                        style: SoloStyle.lightGrey20005W500Medium,
                      ),
                      space(height: 10),
                      Container(
                        decoration: BoxDecoration(
                            color: SoloColor.blue,
                            borderRadius: BorderRadius.circular(30)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(StringHelper.groupNumber,
                              style: SoloStyle.whiteLower),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ));
      },
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget _successBottomSheet(String title, String msg) {
    return CupertinoActionSheet(
      title: Text(title,
          style: TextStyle(
              color: SoloColor.graniteGray,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(msg,
          style: TextStyle(
              color: SoloColor.taupeGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Ok",
              style: TextStyle(
                  color: SoloColor.graniteGray,
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
                    "Success", "Post Reported Successfully"));
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  Widget _showReportBottomSheet(String publicFeedId) {
    return CupertinoActionSheet(
      title: Text("Report",
          style: TextStyle(
              color: SoloColor.graniteGray,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("Are you sure you want to report this post?",
          style: TextStyle(
              color: SoloColor.taupeGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
              style: TextStyle(
                  color: SoloColor.graniteGray,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _onReportPostTap(publicFeedId);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            "No",
            style: TextStyle(
                color: SoloColor.graniteGray,
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

  Widget _showBlockBottomSheet(String blockUserId) {
    return CupertinoActionSheet(
      title: Text("Block",
          style: TextStyle(
              color: SoloColor.graniteGray,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("Are you sure you want to block this profile?",
          style: TextStyle(
              color: SoloColor.taupeGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
              style: TextStyle(
                  color: SoloColor.graniteGray,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _onBlockUserTap(blockUserId);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            "No",
            style: TextStyle(
                color: SoloColor.graniteGray,
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

  Widget _showDeleteBottomSheet(String publicFeedID) {
    return CupertinoActionSheet(
      title: Text("Delete Post",
          style: TextStyle(
              color: SoloColor.graniteGray,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("Are you sure you want to delete this post?",
          style: TextStyle(
              color: SoloColor.taupeGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
              style: TextStyle(
                  color: SoloColor.graniteGray,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _deleteButtonTap(publicFeedID);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            "No",
            style: TextStyle(
                color: SoloColor.graniteGray,
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

  void _editButtonTap(String id, PublicFeedList searchList) {
    //_addressController.text = "";

    _commonHelper
        ?.startActivity(ShareMomentActivity(
            feedList: searchList, isFrom: true, context: this))
        .then((value) {
      if (value) {
        _showProgress();

        // _getProfileData();
      }
    });
  }

  Widget _showEditBottomSheet(
    String edit,
    PublicFeedList searchList,
  ) {
    return CupertinoActionSheet(
      title: Text("Edit Post",
          style: TextStyle(
              color: SoloColor.graniteGray,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("Are you sure you want to edit this Post?",
          style: TextStyle(
              color: SoloColor.taupeGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
              style: TextStyle(
                  color: SoloColor.graniteGray,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _editButtonTap(edit, searchList);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            "No",
            style: TextStyle(
                color: SoloColor.graniteGray,
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
    PublicFeedList searchList,
  ) {
    return CupertinoActionSheet(actions: [
      CupertinoActionSheetAction(
        child: Text("Edit",
            style: TextStyle(
                color: SoloColor.graniteGray,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        onPressed: () {
          Navigator.pop(context);

          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) =>
                  _showEditBottomSheet(id, searchList));
        },
      ),
      CupertinoActionSheetAction(
        child: Text("Delete",
            style: TextStyle(
                color: SoloColor.graniteGray,
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

  Widget _showBottomSheet(String blockUserId, String publicFeedId) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text("Block",
              style: TextStyle(
                  color: SoloColor.graniteGray,
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
            "Report",
            style: TextStyle(
                color: SoloColor.graniteGray,
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
        child: Text("Cancel",
            style: TextStyle(
                color: SoloColor.graniteGray,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget momentProfilePic() {
    return Container(
      margin: EdgeInsets.only(left: DimensHelper.halfSides),
      child: ClipOval(
          child: CachedNetworkImage(
        fit: BoxFit.cover,
        height: _commonHelper?.screenHeight * 0.05,
        width: _commonHelper?.screenHeight * 0.05,
        imageUrl: mineProfilePic ?? "",
        placeholder: (context, url) => imagePlaceHolder(),
        errorWidget: (context, url, error) => imagePlaceHolder(),
      )),
    );
  } //todo Avi

  Widget profileImage(int index) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: _searchList![index].userProfilePic.toString(),
          height: 50,
          width: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) => imagePlaceHolder(),
          errorWidget: (context, url, error) => imagePlaceHolder(),
        ));
  }

  Widget userDetails(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (_searchList?[index].userId == mineUserId) {
                //_commonHelper.startActivity(ProfileTab(isFromHome: true));
                Navigator.of(context)
                    .push(
                  new MaterialPageRoute(
                      builder: (_) => new ProfileTab(isFromHome: true)),
                )
                    .then((mapData) {
                  if (mapData != null && mapData) {
                    _searchList?.clear();
                    _aList?.clear();
                    _showProgress();
                    _getPublicFeeds();
                  }
                });
              } else {
                _commonHelper?.startActivity(UserProfileActivity(
                    userId: _searchList![index].userId.toString()));
              }
            },
            child: Row(
              children: [
                profileImage(index),
                space(width: _commonHelper?.screenWidth * 0.04),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _searchList![index].userName.toString(),
                      style: SoloStyle.black54W500SmallMax,
                    ),
                    Text(
                      _commonHelper!.getTimeDifference(
                          _searchList?[index].insertDate ?? 0),
                      style: SoloStyle.lightGrey200W600MediumXs,
                    )
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) {
                      return _searchList?[index].userId == mineUserId
                          ? _showBottomSheetEditDel(
                              _searchList![index].publicFeedId.toString(),
                              _searchList![index])
                          : _showBottomSheet(
                              _searchList![index].userId.toString(),
                              _searchList![index].publicFeedId.toString());
                    });
              },
              child: SvgPicture.asset(
                IconsHelper.drop_arrow,
                height: _commonHelper?.screenHeight * 0.01,
              ),
            ),
          )
        ],
      ),
    );
  }

  RichText _convertHashtag(String text) {
    List<String> split = text.split(RegExp("#"));
    List<String> hashtags = split.getRange(1, split.length).fold([], (t, e) {
      var texts = e.split(" ");
      if (texts.length > 1) {
        return List.from(t)
          ..addAll(["#${texts.first}", "${e.substring(texts.first.length)}"]);
      }
      return List.from(t)..add("#${texts.first}");
    });
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: split.first,
              style: TextStyle(
                color: SoloColor.graniteGray,
                fontSize: Constants.FONT_TOP,
              ))
        ]..addAll(hashtags
            .map((text) => text.contains("#")
                ? TextSpan(
                    text: text,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: Constants.FONT_TOP,
                    ))
                : TextSpan(
                    text: text,
                    style: TextStyle(
                      color: SoloColor.graniteGray,
                      fontSize: Constants.FONT_TOP,
                    )))
            .toList()),
      ),
    );
  }

  Widget _noCarnivalWarning() {
    return Container(
        height: _commonHelper?.screenHeight * .65,
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text("No post available.",
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.taupeGray)));
  }

  Widget imageDialog(context,
      {List<PublicFeedList>? imgUrl,
      required int indexSearch,
      CarouselController? controller}) {
    return Dialog(
      child: imgUrl != null
          ? Stack(
              children: [
                imgUrl[indexSearch].image!.length > 1
                    ? CarouselSlider.builder(
                        itemCount: imgUrl[indexSearch].image!.length,
                        carouselController: controller,
                        options: CarouselOptions(
                          autoPlay: false,
                          height: _commonHelper?.screenHeight * 0.3,
                          viewportFraction: 1.0,
                          onPageChanged: (index, reason) {
                            print(
                                "seethisguy${imgUrl[index].sliderPosition}${index}");
                            setState(() {
                              imgUrl[index].sliderPosition = index;
                            });
                          },
                        ),
                        itemBuilder:
                            (BuildContext context, int index, int realIndex) {
                          return Container(
                            height: _commonHelper?.screenHeight * 0.3,
                            width: _commonHelper?.screenWidth,
                            child: ClipRRect(
                              child: CachedNetworkImage(
                                imageUrl: imgUrl[indexSearch].image![index],
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    imagePlaceHolder(),
                                placeholder: (context, url) =>
                                    imagePlaceHolder(),
                              ),
                            ),
                          );
                        },
                      )
                    : Stack(
                        children: [
                          Container(
                            height: _commonHelper?.screenHeight * 0.3,
                            width: _commonHelper?.screenWidth,
                            child: ClipRRect(
                              child: CachedNetworkImage(
                                imageUrl: imgUrl[indexSearch].image![0],
                                fit: BoxFit.fill,
                                placeholder: (context, url) =>
                                    imagePlaceHolder(),
                                errorWidget: (context, url, error) =>
                                    imagePlaceHolder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Visibility(
                    visible: imgUrl[indexSearch].image!.length > 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: imgUrl[indexSearch]
                          .image!
                          .asMap()
                          .entries
                          .map((entry) {
                        return GestureDetector(
                          onTap: () {
                            var res =
                                imgUrl[indexSearch].sliderPosition == entry.key;
                            print("valueoftheres$res");
                            controller?.animateToPage(entry.key);
                          },
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: imgUrl[indexSearch].sliderPosition ==
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
            )
          : Container(),
      // Container(
      //   child: CachedNetworkImage(
      //     fit: BoxFit.cover,
      //     height: _commonHelper?.screenHeight * .45,
      //     imageUrl: imgUrl,
      //     errorWidget: (context, url, error) => Image.asset(
      //       IconsHelper.profile_icon,
      //       width: _commonHelper?.screenHeight * .13,
      //       height: _commonHelper?.screenHeight * .13,
      //       fit: BoxFit.cover,
      //     ),
      //   ),
      // ),
    );
  }

  Widget imageTypePublicFeed(int index) {
    var likes = _searchList?[index].totalLikes == 0
        ? ""
        : " " + _searchList![index].totalLikes.toString();

    if (_searchList?[index].totalLikes == 0) {
      likes = "";
    } else if (_searchList?[index].totalLikes == 1) {
      likes = _searchList![index].totalLikes.toString() /* + " Like"*/;
    } else {
      likes = _searchList![index].totalLikes.toString() /*+ " Likes"*/;
    }

    var comments;

    if (_searchList?[index].totalComments == 0) {
      comments = "";
    } else {
      var titleComment = _searchList?[index].totalComments == 1 ? "" : "";

      comments = '${_searchList![index].totalComments.toString()}';
    }

    return FeedCard(
      userProfile: _searchList![index].userProfilePic.toString(),
      userName: _searchList![index].userName.toString(),
      userLocation: StringHelper.userLocation,
      feedImageZoomOnTap: () async {
        print("images" + _searchList![index].image![0].toString());

        ShowDialog.showFeedDialog(
          context,
          indexSearch: index,
          imgUrl: _searchList!,
          controller: _controller,
          isHome: true,
        );
      },
      userDetailsOnTap: () {
        if (_searchList?[index].userId == mineUserId) {
          //_commonHelper.startActivity(ProfileTab(isFromHome: true));
          Navigator.of(context)
              .push(
            new MaterialPageRoute(
                builder: (_) => new ProfileTab(isFromHome: true)),
          )
              .then((mapData) {
            if (mapData != null && mapData) {
              _searchList?.clear();
              _aList?.clear();
              _showProgress();
              _getPublicFeeds();
            }
          });
        } else {
          _commonHelper?.startActivity(UserProfileActivity(
              userId: _searchList![index].userId.toString()));
        }
      },
      userprofileOnTap: () async {
        ShowDialog.showProfileDialog(context,
            imgUrl: _searchList![index].userProfilePic.toString());
      },
      moreTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return _searchList?[index].userId == mineUserId
                  ? _showBottomSheetEditDel(
                      _searchList![index].publicFeedId.toString(),
                      _searchList![index])
                  : _showBottomSheet(_searchList![index].userId.toString(),
                      _searchList![index].publicFeedId.toString());
            });
      },
      feedImage: _searchList!,
      controller: _controller,
      feedTap: () {
        if (_searchList?[index].userId == mineUserId) {
          /*_commonHelper
                                .startActivity(ProfileTab(isFromHome: true));*/
          Navigator.of(context)
              .push(
            new MaterialPageRoute(
                builder: (_) => new ProfileTab(isFromHome: true)),
          )
              .then((mapData) {
            if (mapData != null && mapData) {
              _searchList?.clear();
              _aList?.clear();
              _showProgress();
              _getPublicFeeds();
            }
          });
        } else {
          _commonHelper?.startActivity(UserProfileActivity(
              userId: _searchList![index].userId.toString()));
        }
      },
      likeImage: _searchList?[index].isLike == true
          ? IconsHelper.like
          : IconsHelper.unLike,
      likeCount: likes,
      likeOnTap: () {
        if (_searchList?[index].isLike == true) {
          setState(() {
            var totalLikes = _searchList?[index].totalLikes ?? 0 - 1;
            _searchList?[index].totalLikes = totalLikes;
            _searchList?[index].isLike = false;
          });
          _onUnLikeButtonTap(_searchList![index].publicFeedId.toString());
        } else {
          setState(() {
            var totalLikes = _searchList?[index].totalLikes ?? 0 + 1;
            _searchList?[index].totalLikes = totalLikes;
            _searchList?[index].isLike = true;
          });
          _onLikeButtonTap(_searchList![index].publicFeedId.toString());
        }
      },
      likeTextOnTap: () {
        _commonHelper?.startActivity(
            FeedLikeActivity(_searchList![index].publicFeedId.toString()));
      },
      commentCount: comments,
      indexForSearch: index,
      commentOnTap: () {
        commentOnTap(index);
      },
      commentTextOnTap: () {
        commentOnTap(index);
      },
      countDown:
          _commonHelper!.getTimeDifference(_searchList?[index].insertDate ?? 0),
      content: _searchList![index].title.toString(),
    );
  }

  Widget titleTypePublicFeed(int index) {
    var likes = _searchList?[index].totalLikes == 0
        ? ""
        : " " + _searchList![index].totalLikes.toString();

    if (_searchList?[index].totalLikes == 0) {
      likes = "";
    } else if (_searchList?[index].totalLikes == 1) {
      likes = _searchList![index].totalLikes.toString() /*+ " Like"*/;
    } else {
      likes = _searchList![index].totalLikes.toString() /*+ " Likes"*/;
    }

    var comments;

    if (_searchList?[index].totalComments == 0) {
      comments = "";
    } else {
      var titleComment = _searchList?[index].totalComments == 1 ? "" : "";

      comments = '${_searchList![index].totalComments.toString()} ';
    }
    Widget likeButton(int index) {
      return Container(
        width: _commonHelper?.screenWidth * .43,
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    var totalLikes = _searchList?[index].totalLikes ?? 0 + 1;
                    _searchList?[index].totalLikes = totalLikes;
                    _searchList?[index].isLike = true;
                  });

                  _onLikeButtonTap(_searchList![index].publicFeedId.toString());
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: DimensHelper.halfSides),
                  child: Image.asset(
                    'images/ic_like_black.png',
                    width: 14,
                    height: 14,
                    fit: BoxFit.cover,
                    color: SoloColor.white,
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  _commonHelper?.startActivity(FeedLikeActivity(
                      _searchList![index].publicFeedId.toString()));
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

    Widget unLikeButton(int index) {
      return Container(
        width: _commonHelper?.screenWidth * .43,
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    var totalLikes = _searchList?[index].totalLikes ?? 0 - 1;
                    _searchList?[index].totalLikes = totalLikes;
                    _searchList?[index].isLike = false;
                  });

                  _onUnLikeButtonTap(
                      _searchList![index].publicFeedId.toString());
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: DimensHelper.halfSides),
                  child: Image.asset(
                    'images/ic_like_black.png',
                    width: 14,
                    height: 15,
                    fit: BoxFit.cover,
                    color: SoloColor.graniteGray,
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  _commonHelper?.startActivity(FeedLikeActivity(
                      _searchList![index].publicFeedId.toString()));
                },
                child: Container(
                    margin: EdgeInsets.only(left: DimensHelper.halfSides),
                    child:
                        Text(likes, style: TextStyle(color: SoloColor.white))),
              ), // text
            ],
          ),
        ),
      );
    }

    return FeedCard(
      reverseContent: true,
      userProfile: _searchList![index].userProfilePic.toString(),
      userName: _searchList![index].userName.toString(),
      userLocation: StringHelper.userLocation,
      userDetailsOnTap: () {
        if (_searchList?[index].userId == mineUserId) {
          //_commonHelper.startActivity(ProfileTab(isFromHome: true));
          Navigator.of(context)
              .push(
            new MaterialPageRoute(
                builder: (_) => new ProfileTab(isFromHome: true)),
          )
              .then((mapData) {
            if (mapData != null && mapData) {
              _searchList?.clear();
              _aList?.clear();
              _showProgress();
              _getPublicFeeds();
            }
          });
        } else {
          _commonHelper?.startActivity(UserProfileActivity(
              userId: _searchList![index].userId.toString()));
        }
      },
      userprofileOnTap: () async {
        ShowDialog.showProfileDialog(context,
            imgUrl: _searchList![index].userProfilePic.toString());
      },
      moreTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return _searchList?[index].userId == mineUserId
                  ? _showBottomSheetEditDel(
                      _searchList![index].publicFeedId.toString(),
                      _searchList![index])
                  : _showBottomSheet(_searchList![index].userId.toString(),
                      _searchList![index].publicFeedId.toString());
            });
      },
      likeImage: _searchList?[index].isLike != true
          ? IconsHelper.unLike
          : IconsHelper.like,
      likeCount: likes,
      likeOnTap: () {
        if (_searchList?[index].isLike == true) {
          setState(() {
            var totalLikes = _searchList?[index].totalLikes ?? 0 - 1;
            _searchList?[index].totalLikes = totalLikes;
            _searchList?[index].isLike = false;
          });
          _onUnLikeButtonTap(_searchList![index].publicFeedId.toString());
        } else {
          setState(() {
            var totalLikes = _searchList?[index].totalLikes ?? 0 + 1;
            _searchList?[index].totalLikes = totalLikes;
            _searchList?[index].isLike = true;
          });
          _onLikeButtonTap(_searchList![index].publicFeedId.toString());
        }
      },
      likeTextOnTap: () {
        _commonHelper?.startActivity(
            FeedLikeActivity(_searchList![index].publicFeedId.toString()));
      },
      commentCount: comments,
      commentTextOnTap: () {
        commentOnTap(index);
      },
      indexForSearch: index,
      commentOnTap: () {
        commentOnTap(index);
      },
      countDown:
          _commonHelper!.getTimeDifference(_searchList?[index].insertDate ?? 0),
      content: _searchList![index].title.toString(),
    );

//     Card(
//       elevation: DimensHelper.tinySides,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(DimensHelper.sidesMargin),
//       ),
//       margin: EdgeInsets.only(
//           left: DimensHelper.sidesMargin,
//           right: DimensHelper.sidesMargin,
//           top: DimensHelper.halfSides,
//           bottom: DimensHelper.halfSides),
//       child: Container(
//           child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           userDetails(index),
//           Stack(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   /*  if (_searchList[index].userId == mineUserId) {
//                       // _commonHelper.startActivity(ProfileTab(isFromHome: true));
//
//                       Navigator.of(context)
//                           .push(
//                         new MaterialPageRoute(
//                             builder: (_) => new ProfileTab(isFromHome: true)),
//                       )
//                           .then((mapData) {
//                         if (mapData != null && mapData) {
//                           _searchList.clear();
//
//                           _showProgress();
//                           _getPublicFeeds();
//                         }
//                       });
//                     } else {
//                       _commonHelper.startActivity(
//                           UserProfileActivity(userId: _searchList[index].userId));
//                     }*/
//                 },
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       alignment: Alignment.centerLeft,
//                       margin: EdgeInsets.only(
//                           left: DimensHelper.sidesMargin,
//                           right: DimensHelper.sidesMargin),
//                       child:
//                           _convertHashtag(_searchList![index].title.toString())
//                       /* child: Text(
//                           _searchList[index].title,
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: Constants.FONT_TOP,
//                               color: ColorsHelper.graniteGray),
//                         )*/
//                       ,
//                     ),
//                     Container(
//                       alignment: Alignment.centerLeft,
//                       margin: EdgeInsets.only(
//                           top: DimensHelper.halfSides,
//                           left: DimensHelper.sidesMargin,
//                           right: DimensHelper.sidesMargin,
//                           bottom: DimensHelper.sidesMargin),
//                       child: Text(
//                         _searchList![index].description.toString(),
//                         style: TextStyle(
//                             fontWeight: FontWeight.normal,
//                             fontSize: Constants.FONT_MEDIUM,
//                             color: SoloColor.taupeGray),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           bottom: 16.0, left: 8.0, right: 8.0),
//                       child: Container(
//                         height: 40,
//                         alignment: Alignment.bottomCenter,
//                         color: SoloColor.blue,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             _searchList?[index].isLike == true
//                                 ? unLikeButton(index)
//                                 : likeButton(index),
//                             Spacer(),
//                             InkWell(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           PublicFeedCommentActivity(
//                                               publicFeedId: _searchList![index]
//                                                   .publicFeedId
//                                                   .toString(),
//                                               showKeyBoard: false,
//                                               scrollMessage: false)),
//                                 ).then((value) {
//                                   if (value != null && value) {
//                                     _showProgress();
//
//                                     _searchList?.clear();
//                                     _aList?.clear();
//
//                                     _getPublicFeeds();
//                                   }
//                                 });
//                               },
//                               child: Container(
//                                 alignment: Alignment.centerRight,
//                                 padding: EdgeInsets.only(
//                                     top: DimensHelper.halfSides,
//                                     bottom: DimensHelper.halfSides),
//                                 width: _commonHelper?.screenWidth * .43,
//                                 child: Material(
//                                   color: Colors.transparent,
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       Padding(
//                                         padding:
//                                             const EdgeInsets.only(right: 4.0),
//                                         child: Image.asset(
//                                           'images/comment.png',
//                                           width: 20,
//                                           height: 20,
//                                           fit: BoxFit.cover,
//                                           color: SoloColor.white,
//                                         ),
//                                       ),
//                                       Container(
//                                           padding: EdgeInsets.only(
//                                               right: DimensHelper.halfSides),
//                                           child: Text(comments,
//                                               style: TextStyle(
//                                                   fontSize: Constants.FONT_LOW,
//                                                   color: SoloColor.white))),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//
// /*
//                           child: Row(
//                             children: [
//                               InkWell(
//                                 onTap: () {
//                                   _commonHelper.startActivity(FeedLikeActivity(
//                                       _searchList[index].publicFeedId));
//                                 },
//                                 child: Container(
//                                   padding: EdgeInsets.only(
//                                       top: DimensHelper.halfSides,
//                                       bottom: DimensHelper.halfSides),
//                                   width: _commonHelper.screenWidth * .43,
//                                   child: Material(
//                                     color: Colors.transparent,
//                                     child: Container(
//                                       alignment: Alignment.centerLeft,
//                                       margin: EdgeInsets.only(
//                                           left: DimensHelper.halfSides),
//                                       child: RichText(
//                                         text: TextSpan(
//                                           children: [
//                                             WidgetSpan(
//                                                 child: Image.asset(
//                                               'images/ic_like_black.png',
//                                               width: 15,
//                                               height: 15,
//                                               fit: BoxFit.cover,
//                                               color: ColorsHelper.colorWhite,
//                                             )),
//                                             TextSpan(
//                                                 text: likes,
//                                                 style: TextStyle(
//                                                     fontSize: Constants.FONT_LOW,
//                                                     color:
//                                                         ColorsHelper.colorWhite)),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               InkWell(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             PublicFeedCommentActivity(
//                                                 publicFeedId:
//                                                     _searchList[index].publicFeedId,
//                                                 showKeyBoard: false,
//                                                 scrollMessage: false)),
//                                   ).then((value) {
//                                     if (value != null && value) {
//                                       _showProgress();
//
//                                       _searchList.clear();
//
//                                       _getPublicFeeds();
//                                     }
//                                   });
//                                 },
//                                 child: Container(
//                                   alignment: Alignment.centerRight,
//                                   padding: EdgeInsets.only(
//                                       top: DimensHelper.halfSides,
//                                       bottom: DimensHelper.halfSides),
//                                   width: _commonHelper.screenWidth * .43,
//                                   child: Material(
//                                     color: Colors.transparent,
//                                     child: Container(
//                                         padding: EdgeInsets.only(
//                                             right: DimensHelper.halfSides),
//                                         child: Text(comments,
//                                             style: TextStyle(
//                                                 fontSize: Constants.FONT_LOW,
//                                                 color: ColorsHelper.colorWhite))),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
// */
//                       ),
//                     ),
// /*
//                       Container(
//                         child: Row(
//                           children: [
//                             _searchList[index].isLike
//                                 ? unLikeButton(index)
//                                 : likeButton(index),
//                             InkWell(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           PublicFeedCommentActivity(
//                                               publicFeedId:
//                                                   _searchList[index].publicFeedId,
//                                               showKeyBoard: true,
//                                               scrollMessage: false)),
//                                 ).then((value) {
//                                   if (value != null && value) {
//                                     _showProgress();
//
//                                     _searchList.clear();
//
//                                     _getPublicFeeds();
//                                   }
//                                 });
//                               },
//                               child: Container(
//                                 padding: EdgeInsets.only(
//                                     top: DimensHelper.sidesMargin,
//                                     bottom: DimensHelper.sidesMargin),
//                                 width: _commonHelper.screenWidth * .45,
//                                 child: Material(
//                                   color: Colors.transparent,
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Image.asset(
//                                         'images/comment.png',
//                                         width: 20,
//                                         height: 20,
//                                         fit: BoxFit.cover,
//                                         color: ColorsHelper.colorLightGrey,
//                                       ),
//
//                                       Container(
//                                           margin: EdgeInsets.only(
//                                               left: DimensHelper.smallSides),
//                                           child: Text("Comment")), // text
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
// */
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       )),
//     );
  }

  void gotonext() {
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (_) => new ProfileTab(isFromHome: true)),
    );
  }

  void commentOnTap(index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PublicFeedCommentActivity(
              publicFeedId: _searchList![index].publicFeedId.toString(),
              showKeyBoard: false,
              scrollMessage: false)),
    ).then((value) {
      if (value != null && value) {
        _showProgress();
        _searchList?.clear();
        _aList?.clear();
        _getPublicFeeds();
      }
    });
  }

  Widget mainItem(int index) {
    return _searchList![index].type == Constants.PUBLIC_FEED_TYPE_IMAGE
        ? imageTypePublicFeed(index)
        : titleTypePublicFeed(index);
  }

  AutoScrollController autoScrollController = AutoScrollController();

  Widget _homeData() {
    return Stack(
      children: [
        RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: Column(
            children: [

              _searchList!.isNotEmpty
                  ? Expanded(
                      child: ScrollablePositionedList.builder(
                        itemCount: _searchList!.length,
                        itemScrollController: _scrollController,
                        itemBuilder: (BuildContext context, int index) {
                          return mainItem(index);
                        },
                      ),
                    )
                  : Expanded(
                      child: Visibility(
                        child: _noCarnivalWarning(),
                        visible: _searchList!.isEmpty,
                      ),
                    ),
            ],
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

//============================================================
// ** Helper Functions **
//============================================================

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

  void _getPublicFeeds() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _homeActivityBloc?.getPublicFeeds(token.toString()).then((onValue) {
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

  void _deleteButtonTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _homeActivityBloc
            ?.deleteFeed(authToken.toString(), feedId)
            .then((onValue) {
          _aList?.clear();
          _searchList?.clear();

          _commonHelper?.showToast("Post Deleted");

          _getPublicFeeds();
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
          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => _commonHelper!
                  .successBottomSheet(
                      "Success", "User Blocked Successfully", false));

          _searchList?.clear();
          _aList?.clear();

          _getPublicFeeds();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  Future<Null> _refresh() async {
    widget.scrollMessage = false;
    _showProgress();
    _aList?.clear();
    _searchList?.clear();
    _getPublicFeeds();
  }

  void _scrollToIndex(index) {
    _scrollController?.jumpTo(index: index);
  }

  _onSearchTextChanged(String searchQuery) {
    _searchList?.clear();

    if (searchQuery.isEmpty) {
      _searchList?.addAll(_aList ?? []);

      setState(() {});

      return;
    }

    _aList?.forEach((carnivalDetail) {
      if (carnivalDetail.title!
          .toUpperCase()
          .contains(searchQuery.toUpperCase())) {
        _searchList?.add(carnivalDetail);
      }
    });

    setState(() {});
  }
}
