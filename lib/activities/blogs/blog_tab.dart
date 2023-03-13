import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:solomas/activities/common_helpers/feed_card_blog.dart';
import 'package:solomas/blocs/blogs/blog_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/blog_list_model.dart';
import 'package:solomas/model/report_feed_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../common_helpers/app_bar.dart';
import 'blog_fullview.dart';
import 'blogs_comment_activity.dart';

class BlogTab extends StatefulWidget {
  final String? blogId;
  String? blogShareId;
  bool? isScroll;
  BlogTab({this.blogId, this.isScroll, this.blogShareId, Key? key})
      : super(key: key);

  @override
  _BlogTabState createState() => _BlogTabState();
}

class _BlogTabState extends State<BlogTab> {
  CommonHelper? _commonHelper;
  ApiHelper? _apiHelper;
  BlogBLoc? _blogBLoc;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  var _progressShow = false;
  String? authToken, mineUserId = "", mineProfilePic = "";

  List<BlogList> _aList = [];

  List<BlogList> _searchList = [];

  var pos = -1;

  ItemScrollController? _scrollController;
  final CarouselController _controller = CarouselController();
  Future<Null> _refresh() async {
    widget.isScroll = false;
    _aList.clear();
    _searchList.clear();
    _showProgress();

    _getBlog();
  }

  @override
  void initState() {
    super.initState();
    print("Blog Share Id is ${widget.blogShareId}");
    _commonHelper?.showToast(StringHelper.toastMsg);
    _scrollController = ItemScrollController();
    _apiHelper = ApiHelper();
    _blogBLoc = BlogBLoc();
    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _getBlog());
  }

  @override
  void dispose() {
    widget.blogShareId = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SafeArea(
      child: SoloScaffold(
        backGroundColor: SoloColor.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: _appBar(context),
          ),
        ),
        body: _mainBody(),
      ),
    );
  }

  _onSearchTextChanged(String text) async {
    _searchList.clear();

    if (text.isEmpty) {
      _searchList.addAll(_aList);

      setState(() {});

      return;
    }

    _aList.forEach((carnivalDetail) {
      if (carnivalDetail.title!.toUpperCase().contains(text.toUpperCase())) {
        _searchList.add(carnivalDetail);
      }
    });

    setState(() {});
  }

  void _getBlog() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();

          _blogBLoc?.getBlog(token.toString()).then((onValue) {
            _hideProgress();
            var data = onValue as BlogListResponse;
            if (data.statusCode == 200) {
              Constants.isNavigated = false;
              var blogList = data.data?.blogList;
              for (var i = 0; i < blogList!.length; i++) {
                if (widget.blogShareId == blogList[i].blogId) {
                  _commonHelper?.startActivity(BlogFullView(
                    blogName: blogList[i].title.toString(),
                    image: blogList[i].image.toString(),
                    description: blogList[i].body.toString(),
                    blogId: blogList[i].blogId.toString(),
                    shareCount: blogList[i].shareCount,
                    isLike: blogList[i].isLike,
                    totalLike: blogList[i].totalLikes,
                    totalComments: blogList[i].totalComments,
                  ));
                  break;
                }
              }
            } else {}
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

  Widget _noCarnivalWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text(StringHelper.noBlogFound,
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishGray)));
  }

  void _shareBlog(blogId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var body;

        body = json.encode({
          "blogId": blogId,
        });

        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();
          _blogBLoc?.shareBlog(token.toString(), body).then((onValue) {
            _hideProgress();
            if (onValue?.statusCode == 200) {
              _getBlog();
            } else {}
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

  void _onUnLikeButtonTap(String serviceId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var unLikeBody = json.encode({
          "blogId": serviceId,
        });

        _blogBLoc?.blogUnLike(unLikeBody, authToken.toString());
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onLikeButtonTap(String serviceId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var likeBody = json.encode({
          "blogId": serviceId,
        });

        _blogBLoc?.blogLike(likeBody, authToken.toString());
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  StreamBuilder<BlogListResponse> _mainBody() {
    return StreamBuilder(
      stream: _blogBLoc?.blocList,
      builder: (context, AsyncSnapshot<BlogListResponse> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            if (_aList.isEmpty) {
              _aList = snapshot.data?.data?.blogList ?? [];
              if (widget.blogId != null) {
                pos = _aList
                    .indexWhere((element) => element.blogId == widget.blogId);
                print(_aList
                    .indexWhere((element) => element.blogId == widget.blogId));
                Future.delayed(Duration.zero, () => _scrollToIndex(pos));
              }

              _searchList.addAll(_aList);
            }
          }

          return mainListing();
        } else if (snapshot.hasError) {
          return Container();
        }
        return Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
      },
    );
  }

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      leadingTap: () {
        Scaffold.of(context).openDrawer();
      },
      appBarType: StringHelper.drawerWithSearchbar,
      isMore: true,
      onSearchBarTextChanged: _onSearchTextChanged,
      hintText: StringHelper.searchBlogsArticles,
    );
  }

  Widget _showBottomSheet(String blockUserId, String eventId) {
    return CupertinoActionSheet(
      actions: [
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
      message: Text(StringHelper.reportBlog,
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

  void _onReportPostTap(String eventId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "feedId": eventId,
          "feedType": "blog",
        });

        _apiHelper?.reportFeed(body, authToken.toString()).then((onValue) {
          _hideProgress();

          ReportFeedModel _reportModel = onValue;

          if (_reportModel.statusCode == 200)
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _successBottomSheet(
                    StringHelper.success, StringHelper.blogReportSucMsg));
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

  Widget mainListing() {
    return Stack(
      children: [
        RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: Container(
            height: _commonHelper?.screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                _searchList.isNotEmpty
                    ? Expanded(
                        child: ScrollablePositionedList.builder(
                          itemCount: _searchList.length,
                          itemScrollController: _scrollController,
                          itemBuilder: (BuildContext context, int index) {
                            return _eventsPost(index);
                          },
                        ),
                      )
                    : _noCarnivalWarning()
              ],
            ),
          ),
        ),
        Align(
          child: ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
          alignment: FractionalOffset.center,
        )
      ],
    );
  }

  Widget likeButton(int index) {
    var likes = _searchList[index].totalLikes == 0
        ? ""
        : " " + _searchList[index].totalLikes.toString();

    return InkWell(
      onTap: () {
        setState(() {
          var totalLikes = _searchList[index].totalLikes ?? 0 + 1;
          _searchList[index].totalLikes = totalLikes;
          _searchList[index].isLike = true;
        });

        _onLikeButtonTap(_searchList[index].blogId.toString());
      },
      child: Container(
        width: _commonHelper?.screenWidth * .43,
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: DimensHelper.halfSides),
                child: Image.asset(
                  'images/ic_like_black.png',
                  width: 15,
                  height: 14,
                  fit: BoxFit.cover,
                  color: SoloColor.white,
                ),
              ),

              Container(
                  margin: EdgeInsets.only(left: DimensHelper.halfSides),
                  child: Text(likes, style: TextStyle(color: SoloColor.white))),
              // text
            ],
          ),
        ),
      ),
    );
  }

  Widget unLikeButton(int index) {
    var likes = _searchList[index].totalLikes == 0
        ? ""
        : " " + _searchList[index].totalLikes.toString();

    return InkWell(
      onTap: () {
        setState(() {
          var totalLikes = _searchList[index].totalLikes ?? 0 - 1;
          _searchList[index].totalLikes = totalLikes;
          _searchList[index].isLike = false;
        });

        _onUnLikeButtonTap(_searchList[index].blogId.toString());
      },
      child: Container(
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: DimensHelper.halfSides),
                child: Image.asset(
                  'images/ic_like_black.png',
                  width: 15,
                  height: 15,
                  fit: BoxFit.cover,
                  color: SoloColor.black,
                ),
              ),

              Container(
                  margin: EdgeInsets.only(left: DimensHelper.halfSides),
                  child: Text(likes, style: TextStyle(color: SoloColor.white))),
              // text
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventsPost(int index) {
    var share;

    if (_searchList[index].shareCount == 0) {
      share = StringHelper.share;
    } else {
      var titleShare = _searchList[index].shareCount == 1
          ? StringHelper.share
          : StringHelper.shares;

      share = '${_searchList[index].shareCount.toString()} $titleShare';
    }

    var likes;

    if (_searchList[index].totalLikes == 0) {
      likes = StringHelper.like;
    } else {
      var titleLike = _searchList[index].totalLikes == 1 ? "" : "";

      likes = '${_searchList[index].totalLikes.toString()} $titleLike';
    }

    var comments;

    if (_searchList[index].totalComments == 0) {
      comments = "";
    } else {
      var titleComment = _searchList[index].totalComments == 1 ? "" : "";

      comments = '${_searchList[index].totalComments.toString()} $titleComment';
    }
    void _detailsScreen() {
      _commonHelper?.startActivity(BlogFullView(
        date: _searchList[index].date ?? 0,
        blogName: _searchList[index].title.toString(),
        image: _searchList[index].image.toString(),
        description: _searchList[index].body.toString(),
        blogId: _searchList[index].blogId.toString(),
        shareCount: _searchList[index].shareCount,
        isLike: _searchList[index].isLike,
        totalLike: _searchList[index].totalLikes,
        totalComments: _searchList[index].totalComments,
      ));
    }

    return FeedCardBlog(
        userProfile: _searchList[index].image.toString(),
        userName: _searchList[index].title.toString(),
        userLocation: StringHelper.userLocation,
        userDetailsOnTap: () {
          _detailsScreen();
        },
        moreTap: () {
          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) {
                return _showBottomSheet(_searchList[index].userId.toString(),
                    _searchList[index].blogId.toString());
              });
        },
        feedImage: _searchList,
        controller: _controller,
        likeImage: _searchList[index].isLike == true
            ? IconsHelper.unLike
            : IconsHelper.like,
        likeCount: likes,
        likeOnTap: () {
          if (_searchList[index].isLike == true) {
            setState(() {
              var totalLikes = _searchList[index].totalLikes ?? 0 - 1;
              _searchList[index].totalLikes = totalLikes;
              _searchList[index].isLike = false;
            });
            _onUnLikeButtonTap(_searchList[index].blogId.toString());
          } else {
            setState(() {
              var totalLikes = _searchList[index].totalLikes ?? 0 + 1;
              _searchList[index].totalLikes = totalLikes;
              _searchList[index].isLike = true;
            });
            _onLikeButtonTap(_searchList[index].blogId.toString());
          }
        },
        commentCount: comments,
        indexForSearch: index,
        commentOnTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BlogCommentActivity(
                      blogId: _searchList[index].blogId.toString(),
                      showKeyBoard: false,
                      scrollMessage: false))).then((value) {
            if (value != null && value) {
              _showProgress();
              _aList.clear();
              _searchList.clear();
              _getBlog();
            }
          });
        },
        countDown: _commonHelper!
            .getTimeDifference(_searchList[index].insertDate ?? 0),
        content: _searchList[index].body.toString(),
        feedTap: () {
          _detailsScreen();
        },
        customReadMoreTap: TapGestureRecognizer()
          ..onTap = () {
            _detailsScreen();
          });
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
                  /*  if (_aList[index].userId == mineUserId) {
                    _commonHelper.startActivity(ProfileTab(isFromHome: true));
                  } else {
                    _commonHelper.startActivity(
                        UserProfileActivity(userId: _aList[index].userId));
                  }*/
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: _commonHelper?.screenWidth * .6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_searchList[index].title.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: SoloColor.black,
                                  fontSize: Constants.FONT_TOP)),
                          Padding(
                            padding:
                                EdgeInsets.only(top: DimensHelper.smallSides),
                            child: Text(
                                getFormattedDate(
                                    _searchList[index].date.toString()),
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
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return _showBottomSheet(
                        _searchList[index].userId.toString(),
                        _searchList[index].blogId.toString());
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

  String getFormattedDate(String date) {
    var inputFormat = DateFormat('MM/dd/yyyy');
    var inputDate = inputFormat.parse(date);

    var outputFormat = DateFormat('d MMM yyyy');
    var outputDate = outputFormat.format(inputDate);

    return outputDate.toString();
  }

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  Future<Uri?> _createDynamicLink(String blogId, int index) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://solomasdeeplink.page.link',
        link: Uri.parse(
            "https://solomasdeeplink.page.link?blogId=$blogId&type=blog&imageUrl=${_searchList[index].image}"),
        androidParameters: AndroidParameters(
          packageName: 'com.solomas1.android',
          minimumVersion: 0,
        ),
        iosParameters: IOSParameters(
            bundleId: 'com.solomas1.ios',
            minimumVersion: '0',
            appStoreId: "1522424256"));
    var url = await dynamicLinks.buildLink(parameters);

    Share.share(
        "${_searchList[index].title}  \n\n" +
            _searchList[index].image.toString() +
            "\n\n" +
            StringHelper.openApp +
            "\n\n" +
            url.toString(),
        subject: StringHelper.eventCarnival);
    return url;
  }

  void _scrollToIndex(index) {
    _scrollController?.jumpTo(index: index);
  }
}

class DescriptionTextWidget extends StatefulWidget {
  final String? text;

  DescriptionTextWidget({this.text});

  @override
  _DescriptionTextWidgetState createState() =>
      new _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<DescriptionTextWidget> {
  String? firstHalf;
  String? secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();

    if (widget.text!.length > 200) {
      firstHalf = widget.text?.substring(0, 200);
      secondHalf = widget.text?.substring(200, widget.text?.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: secondHalf!.isEmpty
          ? new Text(firstHalf.toString())
          : new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                          text: flag
                              ? (firstHalf.toString() + "...")
                              : (firstHalf.toString() + secondHalf.toString()),
                          style: TextStyle(
                              fontSize: Constants.FONT_MEDIUM,
                              color: SoloColor.sonicSilver)),
                      TextSpan(
                          text: flag
                              ? StringHelper.showMore
                              : StringHelper.showLess,
                          style: new TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                flag = !flag;
                              });
                            }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
