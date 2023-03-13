import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solomas/activities/bottom_tabs/events_tab.dart';
import 'package:solomas/blocs/serives/ServicesBloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/helpers/space.dart';
import 'package:solomas/model/service_list_response.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';

class ServiceDetail extends StatefulWidget {
  final String? serviceId;
  final bool? refresh;
  final context;

  const ServiceDetail({this.serviceId, this.refresh, this.context});

  @override
  _ServiceDetailState createState() => _ServiceDetailState();
}

class _ServiceDetailState extends State<ServiceDetail> {
  //============================================================
// ** Properties **
//============================================================
  CommonHelper? _commonHelper;
  ApiHelper? _apiHelper;
  ServicesBloc? _servicesBloc;
  bool _progressShow = false,
      refreshData = false,
      _isEventJoined = false,
      isCurrentUser = false;
  RefreshData? _refreshData;
  List<ServiceList>? _serviceList;
  String authToken = "", mineUserId = "";
  var _commentController = TextEditingController();
  var _commentFocusNode = FocusNode();

//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  void initState() {
    _getInitData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SoloScaffold(
          body: StreamBuilder(
        stream: _servicesBloc?.serviceDetail,
        builder: (context, AsyncSnapshot<ServiceListResponse> snapshot) {
          if (snapshot.hasData) {
            if (_serviceList == null || _serviceList!.isEmpty) {
              _serviceList = snapshot.data?.data?.serviceList;

              if (_serviceList!.length > 0) {
                /* if (_serviceList[0].userId == mineUserId) {
                      isCurrentUser = true;
                    } else {
                      isCurrentUser = false;
                    }
                    _isEventJoined = _serviceList[0].isEventJoined;*/
                return _mainListView();
              }
              return Container();
            }
          } else if (snapshot.hasError) {
            return Container();
          }
          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
        },
      )),
    );
  }
//============================================================
// ** Main Widgets **
//============================================================

  Widget topView() {
    _commonHelper = CommonHelper(context);
    return Container(
      width: _commonHelper?.screenWidth,
      child: Stack(
        children: [
          Container(
            height: _commonHelper?.screenHeight * 0.3,
            width: _commonHelper?.screenWidth,
            child: ClipRRect(
              child: CachedNetworkImage(
                  imageUrl: _serviceList![0].image.toString(),
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => imagePlaceHolder()),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: DimensHelper.sidesMargin,
                right: DimensHelper.sidesMargin,
                top: _commonHelper?.screenHeight * .22,
                bottom: DimensHelper.sidesMargin),
            // alignment: Alignment.topCenter,
            width: _commonHelper?.screenWidth,
            child: infoCard(),
          ),
          Container(
            height: _commonHelper?.screenHeight * .07,
            width: _commonHelper?.screenWidth,
            child: _topViewDetails(),
          ),
        ],
      ),
    );
  }

  Widget _mainListView() {
    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: [
            topView(),
            Visibility(
              visible: _serviceList?[0].carnivalTitle != null &&
                  _serviceList![0].carnivalTitle!.isNotEmpty,
              child: Container(
                margin: EdgeInsets.only(
                    top: DimensHelper.textSize,
                    left: DimensHelper.sidesMarginDouble,
                    right: DimensHelper.sidesMargin),
                child: Text(
                  StringHelper.carnivals.toUpperCase(),
                  style: SoloStyle.boldBoldF0ntTopBlack,
                ),
              ),
            ),
            Divider(
              thickness: 1.5,
              indent: 32,
              endIndent: _commonHelper?.screenWidth * 0.4,
            ),
            Visibility(
              visible: _serviceList?[0].carnivalTitle != null &&
                  _serviceList![0].carnivalTitle!.isNotEmpty,
              child: Container(
                  margin: EdgeInsets.only(
                    top: DimensHelper.mediumSides,
                    left: DimensHelper.textSideDouble,
                    right: DimensHelper.sidesMargin,
                  ),
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _serviceList?[0].carnivalTitle?.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 7.0),
                          child: Text(
                            _serviceList?[0].carnivalTitle?[index] == null
                                ? ""
                                : "•  " +
                                    _serviceList![0].carnivalTitle![index],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: Constants.FONT_MEDIUM,
                                color: SoloColor.spanishGray),
                          ),
                        );
                      })),
            ),
            SizedBox(
              height: DimensHelper.sidesMargin,
            )
          ],
        ),
        Align(
          child: ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
          alignment: FractionalOffset.center,
        ),
      ],
    );
  }

  //============================================================
// ** Helper Widgets **
//============================================================

  Widget _topViewDetails() {
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(right: 10, top: 5, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    /*if (widget.refresh) {
                      setState(() {
                        refreshData=true;

                      });
                    }*/

                    if (widget.refresh == true) {
                      _refreshData = widget.context;
                      _refreshData?.updateData();
                      Navigator.pop(context, refreshData);
                    } else {
                      Navigator.pop(context, refreshData);
                    }

                    //  }
                    // _commonHelper.closeActivity();
                  },
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          height: 35,
                          width: 35,
                          alignment: Alignment.centerLeft,
                          child: Image.asset(IconsHelper.back_with_whightbg)
                          //
                          // Image.asset('images/back_arrow.png'),
                          )),
                ),
              ],
            ),
          ),
        ),
        /*Visibility(
          visible: !isCurrentUser,
          child: Align(
            alignment: Alignment.centerRight,
            child:
            _isEventJoined ? _joinedCarnivalUi() : _disJoinedCarnivalUi(),
          ),
        )*/
      ],
    );
  }

  Widget _showCarnivalBottomSheet(String msg, String sheetTitle) {
    return CupertinoActionSheet(
      message: Text(msg,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.normal)),
      title: Text(sheetTitle,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            if (_isEventJoined) {
              // _disJoinCarnivalTap();
            } else {
              // _joinCarnivalTap();
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancel",
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

  Widget _dataList(
    String image,
    String title, {
    double? isWidth,
    bool linkify = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: title.isNotEmpty ? 10 : 15, left: 5),
      child: Row(
        children: [
          if (title.isNotEmpty)
            Container(
              width: 20,
              child: SvgPicture.asset(image,
                  width: isWidth ?? _commonHelper?.screenWidth * 0.045),
            ),
          space(width: 10),
          if (title.isNotEmpty)
            linkify
                ? SizedBox(
                    width: _commonHelper?.screenWidth * 0.6,
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text: title,
                      // _serviceList?[0].website == null
                      //     ? ""
                      //     : _serviceList![0].website.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      linkStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: Constants.FONT_MEDIUM,
                          color: SoloColor.blue),
                      /* child: Text(
                          _serviceList[0].website,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: Constants.FONT_MEDIUM,
                              color: ColorsHelper.colorGrey),
                        ),*/
                    ),
                  )
                : SizedBox(
                    width: _commonHelper?.screenWidth * 0.7,
                    child: Text(
                      title,
                      maxLines: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: Constants.FONT_MEDIUM,
                          overflow: TextOverflow.ellipsis,
                          color: SoloColor.spanishGray),
                    ),
                  ),
        ],
      ),
    );
  }

  Widget infoCard() {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
        Radius.circular(20),
      )),
      // elevation: 3.0,
      child: Container(
        // height: _commonHelper?.screenHeight * 0.35,
        margin: EdgeInsets.only(
          left: DimensHelper.sidesMargin,
          right: DimensHelper.textSize,
          top: DimensHelper.sideDoubleMargin,
          bottom: DimensHelper.sideDoubleMargin,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_serviceList![0].businessName.toString(),
                overflow: TextOverflow.ellipsis, style: SoloStyle.blackBold22),
            space(height: _commonHelper?.screenHeight * 0.01),
            Text(_serviceList![0].category.toString().toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: SoloStyle.batteryChargedBlueBoldF0ntTop),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dataList(
                    IconsHelper.phone_logo,
                    _serviceList![0].phoneNumber.toString(),
                  ),
                  _dataList(
                      IconsHelper.email_logo, _serviceList![0].email.toString(),
                      isWidth: _commonHelper?.screenWidth * 0.05),
                  _dataList(
                    IconsHelper.location_logo,
                    _serviceList![0].locationName.toString(),
                  ),
                  _dataList(
                      IconsHelper.website_logo,
                      _serviceList?[0].website == null
                          ? ""
                          : _serviceList![0].website.toString(),
                      isWidth: _commonHelper?.screenWidth * 0.055,
                      linkify: true),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

//============================================================
// ** Helper Function **
//============================================================
  void _getInitData() {
    _apiHelper = ApiHelper();
    _servicesBloc = ServicesBloc();
    _serviceList = [];
    PrefHelper.getUserId().then((token) {
      setState(() {
        mineUserId = token.toString();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getEventDetail();
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

  void _getEventDetail() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token.toString();
          _showProgress();
          _servicesBloc
              ?.getServiceDetail(authToken, widget.serviceId.toString())
              .then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              if (onValue.data!.serviceList!.isNotEmpty) {
                //_serviceList = onValue.data.eventList;
              } else {}
            } else {
              _commonHelper?.showAlert(
                  StringHelper.noInternetTitle, "Something Wrong");
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

  Future<bool> _willPopCallback() async {
    /* if (widget.refresh) {
      _commonHelper.startActivityAndCloseOther(EventsTab());
    }
    else{*/
    /*  if (widget.refresh) {
      setState(() {
        refreshData=true;

      });
    }*/

    // _commonHelper.startActivityAndCloseOther(EventsTab());
    if (widget.refresh == true) {
      _refreshData = widget.context;
      _refreshData?.updateData();
      Navigator.pop(context, refreshData);
    } else {
      Navigator.pop(context, refreshData);
    }

    // }
    return false;
  }

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }

//============================================================
// ** Firebase Function **
//============================================================
}
