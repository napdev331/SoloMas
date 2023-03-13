import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:solomas/activities/home/feed_comments_activity.dart';
import 'package:solomas/activities/home/feed_likes_activity.dart';
import 'package:solomas/activities/home/share_home_moment_activity.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/search_user_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../blocs/home/home_bloc.dart';
import '../../helpers/show_dialog.dart';
import '../../model/public_feeds_model.dart' as feed;
import '../../model/report_feed_model.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/text_styles.dart';
import '../bottom_tabs/profile_tab.dart';
import '../chat/chat_activity.dart';
import '../common_helpers/app_bar.dart';
import '../common_helpers/feed_card.dart';

class SearchPeopleActivity extends StatefulWidget {
  String? publicFeedId;
  bool? scrollMessage;
  SearchPeopleActivity({this.publicFeedId, this.scrollMessage});
  @override
  State<StatefulWidget> createState() {
    return _SearchPeopleState();
  }
}

class _SearchPeopleState extends State<SearchPeopleActivity> {
//============================================================
// ** Properties **
//============================================================
  var isFeed = true;
  var textToSearch;
  var _progressShow = false, showWarning = false;
  var _searchController = TextEditingController();
  List<Data> _aList = [];
  CommonHelper? _commonHelper;
  ApiHelper? _apiHelper;
  String? authToken;
  List<feed.PublicFeedList>? _searchList;
  String? mineUserId = "", mineProfilePic = "";
  List<feed.PublicFeedList>? _aListFeed = [];
  ItemScrollController? _scrollController;
  final CarouselController _controller = CarouselController();
  HomeBloc? _homeActivityBloc;
  bool _isShowProgress = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    _homeActivityBloc = HomeBloc();

    _scrollController = ItemScrollController();
    PrefHelper.getAuthToken().then((onValue) {
      authToken = onValue;
    });
    _aListFeed = [];
    _searchList = [];
    _apiHelper = ApiHelper();

    PrefHelper.getUserId().then((token) {
      setState(() {
        mineUserId = token;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    // Widget searchBar() {
    //   return Container(
    //     margin: EdgeInsets.only(
    //         left: DimensHelper.sidesMargin,
    //         right: DimensHelper.sidesMargin,
    //         top: DimensHelper.sidesMargin),
    //     child: Card(
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.all(
    //               Radius.circular(DimensHelper.sidesMarginDouble))),
    //       child: Row(
    //         children: [
    //           Expanded(
    //               child: Container(
    //             padding: EdgeInsets.all(DimensHelper.searchBarMargin),
    //             margin: EdgeInsets.only(left: DimensHelper.sidesMargin),
    //             child: TextFormField(
    //               onFieldSubmitted: (value) {
    //                 _getSearchedUser(value);
    //               },
    //               keyboardType: TextInputType.text,
    //               textInputAction: TextInputAction.search,
    //               maxLines: 1,
    //               minLines: 1,
    //               autofocus: true,
    //               controller: _searchController,
    //               inputFormatters: [
    //                 FilteringTextInputFormatter.allow(RegExp("[a-zA-Z -]")),
    //                 LengthLimitingTextInputFormatter(30),
    //               ],
    //               decoration: InputDecoration.collapsed(
    //                   hintText: 'Search here...',
    //                   hintStyle: TextStyle(
    //                     fontSize: Constants.FONT_MEDIUM,
    //                   )),
    //             ),
    //           )),
    //           Container(
    //             padding: EdgeInsets.only(
    //               left: DimensHelper.halfSides,
    //               right: DimensHelper.sidesMargin,
    //             ),
    //             child: Image.asset(
    //               'images/ic_lg_bag.png',
    //               height: 20,
    //               width: 20,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    /*PreferredSizeWidget topAppBar() {
      return PreferredSize(
        child: Container(
            decoration: BoxDecoration(color: SoloColor.blue),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: [],
            )),
        preferredSize: Size(_commonHelper?.screenWidth, 120),
      );
    }*/

    /*Widget profileImage(int index) {
      return GestureDetector(
        onTap: () {
          _commonHelper?.startActivity(
              UserProfileActivity(userId: _aList[index].userId.toString()));
        },
        child: ClipOval(
            child: CachedNetworkImage(
          imageUrl: _aList[index].profilePic.toString(),
          height: 70,
          width: 70,
          fit: BoxFit.cover,
         placeholder: (context, url) => imagePlaceHolder(),
                        errorWidget: (context, url, error) =>
                            imagePlaceHolder()
        )),
      );
    }*/

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: _appBar(context),
            ),
          ),
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                SizedBox(
                  height: _commonHelper?.screenHeight * 0.06,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                        //                   <--- left side
                        color: Colors.black,
                        width: 0.1,
                      )),
                      // boxShadow: <BoxShadow>[
                      //   BoxShadow(
                      //       color: Colors.black54,
                      //       blurRadius: 25.0,
                      //       offset: Offset(0.0, 0.))
                      // ],
                    ),
                    child: TabBar(
                        indicatorColor: Colors.black,
                        unselectedLabelColor: const Color(0xff969696),
                        labelColor: Colors.black,
                        onTap: (index) {
                          // final index = DefaultTabController.of(context)?.index;
                          print("index ${index}");
                        },
                        indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(width: 1.5),
                            insets: EdgeInsets.symmetric(horizontal: 17.0)),
                        tabs: <Widget>[
                          _tabTitle(
                            StringHelper.feeds.toUpperCase(),
                          ),
                          _tabTitle(
                            StringHelper.peoples.toUpperCase(),
                          ),
                        ]),
                  ),
                ),
                // Container(
                //   height: 20,
                //   child: TabBar(
                //       isScrollable: true,
                //       indicatorColor: Colors.black,
                //       labelColor: Colors.black,
                //       unselectedLabelColor: Colors.grey,
                //       labelPadding: EdgeInsets.symmetric(horizontal: 7),
                //       indicatorSize: TabBarIndicatorSize.label,
                //       tabs: <Widget>[
                //         _tabTitle(
                //           StringHelper.feeds,
                //         ),
                //         _tabTitle(
                //           StringHelper.peoples,
                //         ),
                //       ]),
                // ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: TabBarView(
                      children: [
                        homeTab(),
                        // feeds_tab(),
                        peopleTab(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
          //people_tab(),
          ),
    );
  }

  Widget peopleTab() {
    print("lenght${_aList.length}");
    return _aList.length <= 0
        ? Center(child: Text(StringHelper.noPeopleFound))
        : Stack(
            children: [
              Container(
                height: _commonHelper?.screenHeight,
                width: _commonHelper?.screenWidth,
                margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
                child: ListView.builder(
                    itemCount: _aList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return peopleDetailCard(index);
                    }),
              ),
              // _notfoundWarning(StringHelper.noPeopleFound),
              Align(
                child: ProgressBarIndicator(
                    _commonHelper?.screenSize, _progressShow),
                alignment: FractionalOffset.center,
              ),
            ],
          );
  }

  @override
  void dispose() {
    _searchController.clear();

    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================
  getsearchdata(String text) {
    PrefHelper.getAuthToken().then((token) {
      authToken = token;
      _showProgress();
      _apiHelper?.getPublicFeeds(token.toString()).then((onValue) {
        final _feedModel = onValue;

        _aListFeed = _feedModel.data?.publicFeedList ?? [];

        _onSearchTextChanged(text);
        _getSearchedUser(text);
        _hideProgress();
      }).catchError((onError) {
        _hideProgress();
      });
    });
  }

  /// tabbar tabs
  Widget homeTab() {
    return Stack(
      children: [
        _homeData(),
        // _notfoundWarning("No Feed Found"),
        Align(
          child: ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
          alignment: FractionalOffset.center,
        ),
      ],
    );
  }

  Widget feeds_tab() {
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
                        child: _notfoundWarning(StringHelper.noFeedFound),
                        visible: _searchList!.isEmpty,
                      ),
                    ),
            ],
          ),
        ),
        // Align(
        //   child:
        //       ProgressBarIndicator(_commonHelper?.screenSize, _isShowProgress),
        //   alignment: FractionalOffset.center,
        // )
      ],
    );
  }

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.searchBarWithBackNavigation,
      appbarTitle: StringHelper.blockUser,
      hintText: StringHelper.searchSolomas,
      backOnTap: () {
        Navigator.pop(context);
      },
      onSearchBarTextChanged: (v) {},
      onFieldSubmitted: (v) {
        setState(() {
          textToSearch = v;
        });
        _commonHelper?.isInternetAvailable().then((available) {
          if (available) {
            getsearchdata(v);
          } else {
            _commonHelper?.showAlert(
                StringHelper.noInternetTitle, StringHelper.noInternetMsg);
          }
        });

        // WidgetsBinding.instance.addPostFrameCallback((_) => _getPublicFeeds());
        // if (isFeed == true) {
        // _onSearchTextChanged(v);
        // // } else {
        // _getSearchedUser(v);
        // _onSearchTextChanged(v);
        // }
      },
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================
  void _getSearchedUser(String v) {
    _searchController.text = v;

    if (_searchController.text.toString().trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();
        _apiHelper
            ?.searchPeoples(
                authToken.toString(), _searchController.text.toString().trim())
            .then((onSuccess) {
          _aList.clear();
          SearchUserModel _searchModel = onSuccess;
          _aList = _searchModel.data ?? [];

          if (_aList.isEmpty) {
            showWarning = true;
          } else {
            showWarning = false;
          }

          _hideProgress();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  Widget _notfoundWarning(String str) {
    return Visibility(
      visible: showWarning,
      child: Container(
          color: Colors.white,
          alignment: Alignment.center,
          padding: EdgeInsets.all(DimensHelper.btnTopMargin),
          child: Text(str,
              style: TextStyle(
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.normal,
                  color: SoloColor.spanishGray))),
    );
  }

  Widget userDetails(int index) {
    return Padding(
      padding: EdgeInsets.only(top: _commonHelper?.screenHeight * 0.01),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.white),
        child: Container(
          decoration: BoxDecoration(
              color: SoloColor.lightYellow,
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: SoloColor.graniteGray.withOpacity(0.2))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _commonHelper?.startActivity(UserProfileActivity(
                            userId: _aList[index].userId.toString()));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                            imageUrl: _aList[index].profilePic.toString(),
                            height: 48,
                            width: 48,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => imagePlaceHolder(),
                            errorWidget: (context, url, error) =>
                                imagePlaceHolder()),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          padding:
                              EdgeInsets.only(left: DimensHelper.halfSides),
                          child: Text(_aList[index].fullName!.toUpperCase(),
                              style: SoloStyle.blackLower),
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5, top: 2),
                            // child: Image.asset("assets/images/ic_band_user.png",
                            //     height: 20),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _commonHelper?.startActivity(
                          ChatActivity(
                            _aList[index].fullName.toString(),
                            _aList[index].userId.toString(),
                            _aList[index].profilePic.toString(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: SvgPicture.asset(IconsHelper.message,
                                  width: 22),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget peopleDetailCard(int index) {
    return Container(
      margin: EdgeInsets.only(
        left: DimensHelper.sidesMargin,
        right: DimensHelper.sidesMargin,
      ),
      child: Stack(
        children: [
          Container(
            child: userDetails(index),
          ),
        ],
      ),
    );
  }

  Widget imageDialogProfile(context, {imgUrl}) {
    return Dialog(
        child: Container(
      height: _commonHelper?.screenHeight * 0.3,
      width: _commonHelper?.screenWidth,
      child: ClipRRect(
        child: CachedNetworkImage(
          imageUrl: imgUrl,
          fit: BoxFit.fill,
          errorWidget: (context, url, error) => imagePlaceHolder(),
          placeholder: (context, url) => CupertinoActivityIndicator(
            color: Colors.black,
          ),
        ),
      ),
    ));
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
              _aListFeed?.clear();
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
        showDialog(
            barrierColor: SoloColor.black.withOpacity(0.9),
            context: context,
            builder: (_) => imageDialogProfile(context,
                imgUrl: _searchList![index].userProfilePic.toString()));
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
              _aListFeed?.clear();
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
              _aListFeed?.clear();
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
        await showDialog(
            barrierColor: SoloColor.black.withOpacity(0.9),
            context: context,
            builder: (_) => imageDialogProfile(context,
                imgUrl: _searchList![index].userProfilePic.toString()));
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

  Widget mainItem(int index) {
    return _searchList![index].type == Constants.PUBLIC_FEED_TYPE_IMAGE
        ? imageTypePublicFeed(index)
        : titleTypePublicFeed(index);
  }

  Widget _showBottomSheetEditDel(
    String id,
    feed.PublicFeedList searchList,
  ) {
    return CupertinoActionSheet(actions: [
      CupertinoActionSheetAction(
        child: Text(StringHelper.edit,
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
        child: Text(StringHelper.delete,
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

  Widget _showEditBottomSheet(
    String edit,
    feed.PublicFeedList searchList,
  ) {
    return CupertinoActionSheet(
      title: Text(StringHelper.editPost,
          style: TextStyle(
              color: SoloColor.graniteGray,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.editPostMsg,
          style: TextStyle(
              color: SoloColor.taupeGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes,
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
            StringHelper.no,
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

  Widget _showBottomSheet(String blockUserId, String publicFeedId) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.block,
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
            StringHelper.report,
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
        child: Text(StringHelper.cancel,
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

  Widget _showBlockBottomSheet(String blockUserId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.block,
          style: TextStyle(
              color: SoloColor.graniteGray,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.blockProfileMsg,
          style: TextStyle(
              color: SoloColor.taupeGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes,
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
            StringHelper.no,
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
      title: Text(StringHelper.deletePost,
          style: TextStyle(
              color: SoloColor.graniteGray,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.areYouSureWantToDelete,
          style: TextStyle(
              color: SoloColor.taupeGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes,
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
            StringHelper.no,
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

  Widget _showReportBottomSheet(String publicFeedId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.report,
          style: TextStyle(
              color: SoloColor.graniteGray,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.reportPostMsg,
          style: TextStyle(
              color: SoloColor.taupeGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes,
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
            StringHelper.no,
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

  Widget _noFeedWarning() {
    return Container(
        height: _commonHelper?.screenHeight * .65,
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text(StringHelper.noFeedFound,
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.black)));
  }

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
          child: Text(StringHelper.Ok,
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
                        child: _noFeedWarning(),
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////

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

  Future<Null> _refresh() async {
    widget.scrollMessage = false;
    _showProgress();
    _aListFeed?.clear();
    _searchList?.clear();
    getsearchdata(textToSearch);
    // _getPublicFeeds();
  }

  // for the feed
  void _onSearchTextChanged(String searchQuery) {
    _searchList?.clear();
    if (searchQuery.isEmpty) {
      print("test2${searchQuery}");
      _searchList?.addAll(_aListFeed ?? []);

      setState(() {});

      return;
    }

    _aListFeed?.forEach((carnivalDetail) {
      if (carnivalDetail.title!
          .toUpperCase()
          .contains(searchQuery.toUpperCase())) {
        _searchList?.add(carnivalDetail);
      }
    });

    setState(() {});
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

  void _editButtonTap(String id, feed.PublicFeedList searchList) {
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
                  StringHelper.success, StringHelper.blocUserSucMsg, false));

          _searchList?.clear();
          _aListFeed?.clear();

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
        _aListFeed?.clear();
        _getPublicFeeds();
      }
    });
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

  void _deleteButtonTap(String feedId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _homeActivityBloc
            ?.deleteFeed(authToken.toString(), feedId)
            .then((onValue) {
          _aListFeed?.clear();
          _searchList?.clear();

          _commonHelper?.showToast(StringHelper.postDelMsg);

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

  Tab _tabTitle(String content) {
    return Tab(
      child: Text(
        content,
        style: TextStyle(
          letterSpacing: 1,
        ),
      ),
    );
  }

//============================================================
// ** Firebase Functions **
//============================================================

//============================================================
// ** Helper Class **
//============================================================

}
