import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/activities/bottom_tabs/explore/carnivals_continets/share_carnival_review_activity.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/blocs/explore/carnival_list_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/space.dart';
import 'package:solomas/model/carnival_review_list.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:solomas/widgets/image_expanded.dart';

import '../../../../helpers/progress_indicator.dart';
import '../../../../resources_helper/common_widget.dart';
import '../../../../resources_helper/images.dart';
import '../../../../resources_helper/screen_area/scaffold.dart';
import '../../../common_helpers/app_bar.dart';
import '../../profile_tab.dart';

class CarnivalReviews extends StatefulWidget {
  final String? carnivalId, carnivalName;

  const CarnivalReviews({key, this.carnivalId, this.carnivalName})
      : super(key: key);

  @override
  _CarnivalReviewsState createState() => _CarnivalReviewsState();
}

class _CarnivalReviewsState extends State<CarnivalReviews> {
  CommonHelper? _commonHelper;
  bool _isShowProgress = false;
  String postImageUrl = "";
  CarnivalListBloc? _carnivalListBloc;
  String? authToken, mineUserId = "", mineProfilePic = "";
  List<CarnivalReviewList> _aList = [];

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
    PrefHelper.getUserId().then((token) {
      setState(() {
        mineUserId = token;
      });
    });

    _carnivalListBloc = CarnivalListBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _carnivalReviewsData());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding:
                const EdgeInsets.only(right: 10, left: 10, top: 15, bottom: 15),
            child: SoloAppBar(
                appBarType: StringHelper.backWithText,
                appbarTitle: widget.carnivalName!.toString(),
                backOnTap: () {
                  _commonHelper?.closeActivity();
                }),
          ),
        ),
        body: StreamBuilder(
            stream: _carnivalListBloc?.carnivalReviewList,
            builder: (context, AsyncSnapshot<CarnivalsReviewList> snapshot) {
              if (snapshot.hasData) {
                if (_aList.isEmpty) {
                  _aList = snapshot.data!.data!.carnivalReviewList!;
                }

                return mainList();
              } else if (snapshot.hasError) {
                return mainList();
              }

              return Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(SoloColor.blue)));
            }));
  }

  void _addReview() {
    Navigator.of(context)
        .push(
      new MaterialPageRoute(
          builder: (_) => ShareMomentReviewActivity(
                carnivalId: widget.carnivalId.toString(),
              )),
    )
        .then((mapData) {
      if (mapData != null && mapData) {
        setState(() {
          _aList.clear();
        });
        _showProgress();
        _carnivalReviewsData();
      }
    });
  }

  Widget sendMessage() {
    return InkWell(
      onTap: () {
        _addReview();
      },
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: SoloColor.white,
          boxShadow: [
            BoxShadow(
              color: SoloColor.spanishGray.withOpacity(0.4),
              blurRadius: 2.5,
              spreadRadius: 0.7,
            ), //BoxShadow//BoxShadow
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(IconsHelper.uploadImage,
                      width: CommonHelper(context).screenWidth * 0.08),
                  space(width: 10),
                  Text(
                    StringHelper.typeMessage,
                    style: TextStyle(
                        color: SoloColor.sonicSilver.withOpacity(0.7),
                        fontSize: 15),
                  )
                ],
              ),
              IconButton(
                icon: SvgPicture.asset(
                  IconsHelper.send_msg,
                  width: 25,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mainList() {
    return Stack(
      children: [
        Container(
          height: _commonHelper?.screenHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _aList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return notificationList(index);
                  },
                ),
              ),
              sendMessage(),
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
  // Widget mainList() {
  //   return Stack(
  //     children: [
  //       Container(
  //         height: _commonHelper?.screenHeight,
  //         child: Column(
  //           children: [
  //             GestureDetector(
  //               onTap: () {
  //                 Navigator.of(context)
  //                     .push(
  //                   new MaterialPageRoute(
  //                       builder: (_) => ShareMomentReviewActivity(
  //                             carnivalId: widget.carnivalId.toString(),
  //                           )),
  //                 )
  //                     .then((mapData) {
  //                   if (mapData != null && mapData) {
  //                     setState(() {
  //                       _aList.clear();
  //                     });
  //                     _showProgress();
  //                     _carnivalReviewsData();
  //                   }
  //                 });
  //               },
  //               child: Card(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(0.0),
  //                 ),
  //                 margin: EdgeInsets.all(0.0),
  //                 elevation: DimensHelper.tinySides,
  //                 child: Container(
  //                   height: 70,
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Expanded(
  //                           child: Container(
  //                         child: Text(
  //                           'Add your review...',
  //                           style: TextStyle(
  //                               color: SoloColor.spanishGray,
  //                               fontSize: Constants.FONT_MEDIUM),
  //                         ),
  //                         padding: EdgeInsets.only(
  //                             left: DimensHelper.sidesMarginDouble),
  //                       )),
  //                       Container(
  //                           child: Align(
  //                             alignment: Alignment.centerRight,
  //                             child: Image.asset(
  //                               'images/ic_lg_bag.png',
  //                               width: 25,
  //                               height: 25,
  //                               fit: BoxFit.fill,
  //                             ),
  //                           ),
  //                           padding: EdgeInsets.all(DimensHelper.sidesMargin)),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Expanded(
  //               child: ListView.builder(
  //                 itemCount: _aList.length,
  //                 itemBuilder: (BuildContext context, int index) {
  //                   return notificationList(index);
  //                 },
  //               ),
  //             )
  //           ],
  //         ),
  //       ),
  //       Align(
  //         child:
  //             ProgressBarIndicator(_commonHelper?.screenSize, _isShowProgress),
  //         alignment: FractionalOffset.center,
  //       )
  //     ],
  //   );
  // }

  Widget userDetails(int index) {
    return Container(
      padding: EdgeInsets.only(
          left: DimensHelper.sidesMargin,
          right: DimensHelper.sidesMargin,
          top: DimensHelper.sidesMargin),
      child: Stack(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  if (_aList[index].userId == mineUserId) {
                    _hideKeyBoard();
                    Navigator.of(context).push(
                      new MaterialPageRoute(
                          builder: (_) => new ProfileTab(isFromHome: true)),
                    );
                  } else {
                    _hideKeyBoard();
                    _commonHelper?.startActivity(UserProfileActivity(
                        userId: _aList[index].userId.toString()));
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: DimensHelper.halfSides),
                      child: _profileImage(index),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: DimensHelper.halfSides),
                      child: Text(_aList[index].userName.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: SoloColor.black,
                              fontSize: Constants.FONT_TOP)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                          _commonHelper!
                              .getTimeDifference(_aList[index].insertDate ?? 0),
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: SoloColor.spanishGray,
                              fontSize: Constants.FONT_LOW)),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        _hideKeyBoard();
                        showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) {
                              return _showDeleteBottomSheet(
                                  _aList[index].carnivalReviewId.toString(),
                                  index);
                            });
                      },
                      child: Visibility(
                        visible: _aList[index].userId == mineUserId,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              child: Icon(Icons.more_vert,
                                  color: SoloColor.spanishGray),
                            )),
                      ),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }
  // Widget userDetails(int index) {
  //   return Container(
  //     padding: EdgeInsets.only(
  //         left: DimensHelper.sidesMargin,
  //         right: DimensHelper.sidesMargin,
  //         top: DimensHelper.sidesMargin),
  //     child: Stack(
  //       children: [
  //         Align(
  //             alignment: Alignment.centerLeft,
  //             child: GestureDetector(
  //               onTap: () {
  //                 if (_aList[index].userId == mineUserId) {
  //                   _hideKeyBoard();
  //                   Navigator.of(context).push(
  //                     new MaterialPageRoute(
  //                         builder: (_) => new ProfileTab(isFromHome: true)),
  //                   );
  //                 } else {
  //                   _hideKeyBoard();
  //                   _commonHelper?.startActivity(UserProfileActivity(
  //                       userId: _aList[index].userId.toString()));
  //                 }
  //               },
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   Container(
  //                     padding: EdgeInsets.only(right: DimensHelper.halfSides),
  //                     child: _profileImage(index),
  //                   ),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(_aList[index].userName.toString(),
  //                           style: TextStyle(
  //                               fontWeight: FontWeight.w500,
  //                               color: SoloColor.black,
  //                               fontSize: Constants.FONT_TOP)),
  //                       Padding(
  //                         padding: const EdgeInsets.only(top: 4.0),
  //                         child: Text(
  //                             _commonHelper!.getTimeDifference(
  //                                 _aList[index].insertDate ?? 0),
  //                             style: TextStyle(
  //                                 fontWeight: FontWeight.w500,
  //                                 color: SoloColor.spanishGray,
  //                                 fontSize: Constants.FONT_LOW)),
  //                       )
  //                     ],
  //                   ),
  //                   Spacer(),
  //                   GestureDetector(
  //                     onTap: () {
  //                       _hideKeyBoard();
  //                       showCupertinoModalPopup(
  //                           context: context,
  //                           builder: (BuildContext context) {
  //                             return _showDeleteBottomSheet(
  //                                 _aList[index].carnivalReviewId.toString(),
  //                                 index);
  //                           });
  //                     },
  //                     child: Visibility(
  //                       visible: _aList[index].userId == mineUserId,
  //                       child: Align(
  //                           alignment: Alignment.centerRight,
  //                           child: Container(
  //                             child: Icon(Icons.more_vert,
  //                                 color: SoloColor.spanishGray),
  //                           )),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             )),
  //       ],
  //     ),
  //   );
  // }

  Widget _profileImage(int index) {
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

  // Widget notificationList(int index) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: Container(
  //       width: _commonHelper?.screenWidth,
  //       decoration: BoxDecoration(
  //         border: Border.all(
  //             color: SoloColor.sonicSilver.withOpacity(0.1),
  //             style: BorderStyle.solid),
  //         color: SoloColor.spanishLightGrey.withOpacity(0.1),
  //         borderRadius: BorderRadius.all(Radius.circular(10)),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.only(bottom: 5),
  //         child: Row(
  //           children: [
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 userDetails(index),
  //                 Padding(
  //                     padding: EdgeInsets.only(
  //                         left: DimensHelper.sidesMargin,
  //                         right: DimensHelper.sidesMargin,
  //                         top: DimensHelper.halfSides),
  //                     child: DescriptionTextWidget(
  //                       text: _aList[index].review.toString(),
  //                     )),
  //                 Visibility(
  //                   visible: _aList[index].image != null &&
  //                       _aList[index].image!.isNotEmpty,
  //                   child: GestureDetector(
  //                     onTap: () {
  //                       expendedImage(_aList[index].image.toString());
  //                     },
  //                     child: Padding(
  //                       padding: EdgeInsets.only(
  //                           left: DimensHelper.sidesMargin,
  //                           right: DimensHelper.sidesMargin,
  //                           top: DimensHelper.halfSides),
  //                       child: Card(
  //                         elevation: 5,
  //                         child: Container(
  //                           width: 100,
  //                           height: 100,
  //                           decoration: BoxDecoration(
  //                             borderRadius:
  //                                 BorderRadius.all(Radius.circular(100)),
  //                           ),
  //                           child: ClipRRect(
  //                             child: CachedNetworkImage(
  //                               imageUrl: _aList[index].image.toString(),
  //                               fit: BoxFit.fill,
  //                               errorWidget: (context, url, error) =>
  //                                  imagePlaceHolder(),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget notificationList(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        width: _commonHelper?.screenWidth,
        decoration: BoxDecoration(
          border: Border.all(
              color: SoloColor.sonicSilver.withOpacity(0.1),
              style: BorderStyle.solid),
          color: SoloColor.spanishLightGrey.withOpacity(0.1),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15, left: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: DimensHelper.halfSides),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // if (_aList[index].userId == mineUserId) {
                        //   _hideKeyBoard();
                        //   Navigator.of(context).push(
                        //     new MaterialPageRoute(
                        //         builder: (_) =>
                        //             new ProfileTab(isFromHome: true)),
                        //   );
                        // } else {
                        //   _hideKeyBoard();
                        //   _commonHelper?.startActivity(UserProfileActivity(
                        //       userId: _aList[index].userId.toString()));
                        // }
                      },
                      child: Container(
                        padding: EdgeInsets.only(right: DimensHelper.halfSides),
                        child: _profileImage(index),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  right: DimensHelper.halfSides),
                              child: Text(_aList[index].userName.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.spanishGray,
                                      fontSize: Constants.FONT_TOP)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                  _commonHelper!.getTimeDifference(
                                      _aList[index].insertDate ?? 0),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: SoloColor.spanishGray,
                                      fontSize: Constants.FONT_LOW)),
                            ),
                          ],
                        ),
                        DescriptionTextWidget(
                          text: _aList[index].review.toString(),
                        ),
                        Visibility(
                          visible: _aList[index].image != null &&
                              _aList[index].image!.isNotEmpty,
                          child: GestureDetector(
                            onTap: () {
                              expendedImage(_aList[index].image.toString());
                            },
                            child: Container(
                              width: _commonHelper?.screenWidth * 0.4,
                              height: 100,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                child: CachedNetworkImage(
                                  imageUrl: _aList[index].image.toString(),
                                  fit: BoxFit.fill,
                                  errorWidget: (context, url, error) =>
                                      imagePlaceHolder(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        _hideKeyBoard();
                        showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) {
                              return _showDeleteBottomSheet(
                                  _aList[index].carnivalReviewId.toString(),
                                  index);
                            });
                      },
                      child: Visibility(
                        visible: _aList[index].userId == mineUserId,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Container(
                                child: Icon(Icons.more_horiz,
                                    color: SoloColor.black),
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              // userDetails(index),
            ],
          ),
        ),
      ),
    );
  }
  // Widget notificationList(int index) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       userDetails(index),
  //       Padding(
  //           padding: EdgeInsets.only(
  //               left: DimensHelper.sidesMargin,
  //               right: DimensHelper.sidesMargin,
  //               top: DimensHelper.halfSides),
  //           child: DescriptionTextWidget(
  //             text: _aList[index].review.toString(),
  //           )),
  //       Visibility(
  //         visible:
  //             _aList[index].image != null && _aList[index].image!.isNotEmpty,
  //         child: GestureDetector(
  //           onTap: () {
  //             expendedImage(_aList[index].image.toString());
  //           },
  //           child: Padding(
  //             padding: EdgeInsets.only(
  //                 left: DimensHelper.sidesMargin,
  //                 right: DimensHelper.sidesMargin,
  //                 top: DimensHelper.halfSides),
  //             child: Card(
  //               elevation: 5,
  //               child: Container(
  //                 width: 100,
  //                 height: 100,
  //                 child: ClipRRect(
  //                   child: CachedNetworkImage(
  //                     imageUrl: _aList[index].image.toString(),
  //                     fit: BoxFit.fill,
  //                     errorWidget: (context, url, error) =>imagePlaceHolder(),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  void _carnivalReviewsData() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _carnivalListBloc
              ?.getCarnivalReviews(
                  token.toString(), widget.carnivalId.toString())
              .then((onValue) {
            print(onValue);
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

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }

  Widget _showDeleteBottomSheet(String delId, int index) {
    return CupertinoActionSheet(
      title: Text(StringHelper.deleteReview,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.deleteReviewText,
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

            _deleteReviews(delId, index);
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

  void _deleteReviews(var reviewId, int index) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();
          _carnivalListBloc
              ?.deleteCarnivalReview(token.toString(), reviewId)
              .then((onValue) {
            if (onValue.statusCode == 200) {
              _aList.removeAt(index);
              _aList.clear();
              setState(() {});

              // _hideProgress();
              _carnivalReviewsData();

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  StringHelper.deleteSuccess,
                ),
              ));
              //_getEventCommentList();
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

  void expendedImage(String url) {
    showGeneralDialog(
        barrierDismissible: false,
        context: context,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return Container(
              width: _commonHelper?.screenWidth,
              height: _commonHelper?.screenHeight,
              child: ImageExpandedWidget(
                onTapDownload: () {
                  //imageDownload(url);

                  // _commonHelper.closeActivity();
                },
                isRotated: false,
                imgPath: url,
                progress: true,
                onTapClose: () {
                  Navigator.of(context).pop();
                },
              ));
        });
  }
}

class DescriptionTextWidget extends StatefulWidget {
  final String? text;

  DescriptionTextWidget({@required this.text});

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

    if (widget.text!.length > 100) {
      firstHalf = widget.text?.substring(0, 100);
      secondHalf = widget.text?.substring(100, widget.text?.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: new EdgeInsets.only(bottom: 5, top: 5),
      child: secondHalf!.isEmpty
          ? new Text(
              firstHalf.toString(),
            )
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
                          text: flag ? "show more" : "show less",
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
                /*    new Text(flag ? (firstHalf + "...") : (firstHalf + secondHalf),
                    style: TextStyle(
                        fontSize: Constants.FONT_MEDIUM,
                        color: ColorsHelper.colorLightGreySetting)),
                new InkWell(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new Text(
                        flag ? "show more" : "show less",
                        style: new TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      flag = !flag;
                    });
                  },
                ),*/
              ],
            ),
    );
  }
}
