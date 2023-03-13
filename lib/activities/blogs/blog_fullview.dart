import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:solomas/blocs/blogs/blog_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../blocs/blogs/blog_comment_bloc.dart';
import '../../helpers/api_helper.dart';
import '../../helpers/comment_helper.dart';
import '../../helpers/pref_helper.dart';
import '../../helpers/space.dart';
import '../../model/blog_comment_blog.dart';
import '../../resources_helper/colors.dart';
import '../../resources_helper/dimens.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../common_helpers/app_bar.dart';
import 'blogs_comment_activity.dart';

class BlogFullView extends StatefulWidget {
  dynamic date;
  String? blogName;
  String? image;
  String? description;
  String? blogId;
  int? shareCount;
  int? totalLike;
  bool? isLike;
  int? totalComments;
  final bool? showKeyBoard;
  bool? scrollMessage;
  final String? publicCommentId;

  BlogFullView(
      {this.showKeyBoard,
      this.date,
      this.blogName,
      this.image,
      this.scrollMessage,
      this.description,
      this.blogId,
      this.shareCount,
      this.totalLike,
      this.publicCommentId,
      this.isLike,
      this.totalComments});

  @override
  State<BlogFullView> createState() => _BlogFullViewState();
}

class _BlogFullViewState extends State<BlogFullView> {
  var _sendCommentFocusNode = FocusNode();
  BlogBLoc? _blogBLoc;
  CommonHelper? _commonHelper;
  ScrollController? _scrollController;
  BlogCommentBloc? _blogCommentBloc;
  //String? authToken;
  String? editBlogID;
  bool isEditComment = false;
  ApiHelper? _apiHelper;
  List<BlogCommentsList>? _aList;
  String? authToken, replyId = "", mineUserId;
  bool _progressShow = false, refreshData = false;
  var pos = -1;

  var _sendCommentController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    _blogBLoc = BlogBLoc();
    _scrollController = ScrollController();
    _blogCommentBloc = BlogCommentBloc();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getBlogCommentList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    DateTime start = new DateFormat("MM/dd/yyyy").parse(widget.date);
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    final String formattedDate = formatter.format(start);

    var comments;

    if (widget.totalComments == 0) {
      comments = "";
    } else {
      var titleComment = widget.totalComments == 1 ? "" : "";

      comments = '${widget.totalComments.toString()} $titleComment';
    }

    return SoloScaffold(
        backGroundColor: SoloColor.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 6, bottom: 3, right: 8, left: 10),
            child: _appBar(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(children: [
                  Container(
                    height: _commonHelper?.screenHeight * 0.3,
                    width: _commonHelper?.screenWidth,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.image ?? "",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(15.0),
                  //   child: Container(
                  //     height: _commonHelper?.screenHeight * 0.35,
                  //     child:
                  //         Image.network(widget.image ?? "", fit: BoxFit.fill),
                  //   ),
                  // ),
                  Container(
                    height: 50,
                    color: SoloColor.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate.toUpperCase(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: SoloColor.batteryChargedBlue),
                        ),
                        Row(
                          children: [
                            widget.isLike == true
                                ? unLikeButton()
                                : likeButton(),
                            space(width: _commonHelper?.screenWidth * 0.02),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BlogCommentActivity(
                                          blogId: widget.blogId,
                                          showKeyBoard: false,
                                          scrollMessage: false)),
                                ).then((value) {
                                  if (value != null && value) {
                                    _showProgress();
                                    // _aList.clear();
                                    // _searchList.clear();
                                    // _getBlog();
                                  }
                                });
                              },
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(
                                    top: DimensHelper.halfSides,
                                    bottom: DimensHelper.halfSides),
                                //width: _commonHelper?.screenWidth * .20,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SvgPicture.asset(IconsHelper.message,
                                          fit: BoxFit.cover,
                                          color: SoloColor.black,
                                          height: 15,
                                          width: 15),
                                      Text(" " + comments,
                                          style: TextStyle(
                                              fontSize: Constants.FONT_MEDIUM,
                                              color: SoloColor.black)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 50, top: 10, left: 0, right: 0),
                      child: Text(
                        widget.description ?? "",
                        style: TextStyle(
                            fontSize: Constants.FONT_MEDIUM,
                            color: SoloColor.lightGrey200),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            Container(
              child: CommentHelper.sendCommentField(context,
                  focusNode: _sendCommentFocusNode, onSend: () {
                isEditComment
                    ? _onEditCommentTap(replyId.toString())
                    : _onSendCommentTap(replyId.toString());
              }, controller: _sendCommentController, id: replyId),
            ),
          ],
        ));
  }

  void _animateScrollingMessage(int pos) {
    var position = pos + 1;
    Timer(Duration(milliseconds: 500),
        () => _scrollController?.jumpTo(position.toDouble()));
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

          // _getBlogCommentList();
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
    // scrollMessage = false;
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

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BlogCommentActivity(
                    blogId: widget.blogId,
                    showKeyBoard: false,
                    scrollMessage: false)),
          );
        }).catchError((onError) {
          _hideKeyBoard();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: widget.blogName,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  Future<Uri?> _createDynamicLink(String blogId) async {
    print("Create Dyanmic link called");
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://solomasdeeplink.page.link',
      link: Uri.parse(
          "https://solomasdeeplink.page.link?blogId=$blogId&type=blog&imageUrl=${widget.image}"),
      androidParameters: AndroidParameters(
        packageName: 'com.solomas1.android',
        minimumVersion: 0,
      ),
      //Todo now
      /*  dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),*/

      //Todo now
      /*  iosParameters: IosParameters(
          bundleId: 'com.solomas1.ios',
          minimumVersion: '0',
          appStoreId: "1522424256"),*/

      iosParameters: IOSParameters(
          bundleId: 'com.solomas1.ios',
          minimumVersion: '0',
          appStoreId: "1522424256"),
    );
    var url = await dynamicLinks.buildLink(parameters);
    //Todo now
    // var url = await parameters.buildUrl();

    Share.share(
        "${widget.blogName}  \n\n" +
            widget.image.toString() +
            "\n\n" +
            //  _searchList[index]. +
            //  "\n\n" +
            StringHelper.openApp +
            "\n\n" +
            url.toString(),
        subject: StringHelper.eventCarnival);
    return url;
    //return url;
  }

  void _animateScrolling() {
    Timer(
        Duration(milliseconds: 500),
        () => _scrollController
            ?.jumpTo(_scrollController!.position.maxScrollExtent));
  }

  void _shareBlog(blogId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var body;

        body = json.encode({
          "blogId": widget.blogId,
        });

        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();
          _blogBLoc?.shareBlog(token.toString(), body).then((onValue) {
            _hideProgress();
            if (onValue?.statusCode == 200) {
              //  _getBlog();

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
    setState(() {});
  }

  void _hideProgress() {
    setState(() {});
  }

  Widget likeButton() {
    var likes = widget.totalLike == 0 ? "" : " " + widget.totalLike.toString();
    return InkWell(
      onTap: () {
        setState(() {
          var totalLikes = widget.totalLike ?? 0 + 1;
          widget.totalLike = totalLikes;
          widget.isLike = true;
        });

        _onLikeButtonTap(widget.blogId ?? "");
      },
      child: Container(
        //width: _commonHelper?.screenWidth * .1,
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: DimensHelper.halfSides),
                child: SvgPicture.asset(
                  IconsHelper.like,
                  fit: BoxFit.cover,
                  color: SoloColor.black,
                  height: 15,
                  width: 15,
                ),
              ),

              Container(
                  child: Text(likes, style: TextStyle(color: SoloColor.black))),
              // text
            ],
          ),
        ),
      ),
    );
  }

  Widget unLikeButton() {
    var likes = widget.totalLike == 0 ? "" : " " + widget.totalLike.toString();
    return InkWell(
      onTap: () {
        setState(() {
          var totalLikes = widget.totalLike ?? 0 - 1;
          widget.totalLike = totalLikes;
          widget.isLike = false;
        });

        _onUnLikeButtonTap(widget.blogId ?? "");
      },
      child: Container(
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: DimensHelper.halfSides),
                child: SvgPicture.asset(
                  IconsHelper.unLike,
                  fit: BoxFit.cover,
                  color: SoloColor.black,
                  height: 15,
                  width: 15,
                ),
              ),

              Container(
                  child: Text(likes, style: TextStyle(color: SoloColor.black))),
              // text
            ],
          ),
        ),
      ),
    );
  }

  void _hideKeyBoard() {
    replyId = "";

    FocusScope.of(context).unfocus();
  }

  void _onUnLikeButtonTap(String blogID) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var unLikeBody = json.encode({
          "blogId": blogID,
        });

        _blogBLoc?.blogUnLike(unLikeBody, authToken.toString());
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
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
}
