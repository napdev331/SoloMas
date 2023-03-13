import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:solomas/activities/bottom_tabs/events_tab.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/activities/services/add_service.dart';
import 'package:solomas/activities/services/services_likes_activity.dart';
import 'package:solomas/blocs/serives/ServicesBloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/report_feed_model.dart';
import 'package:solomas/model/service_category_response.dart';
import 'package:solomas/model/service_list_response.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/progress_indicator.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';
import '../common_helpers/feed_card_services.dart';
import '../services/search_autocomplete.dart';
import '../services/service_comment_activity.dart';
import '../services/view_service_detail.dart';

class ServiceTab extends StatefulWidget {
  final String? serviceContinent;

  const ServiceTab({Key? key, this.serviceContinent}) : super(key: key);

  @override
  _ServiceTabState createState() => _ServiceTabState();
}

class _ServiceTabState extends State<ServiceTab> implements RefreshData {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  ApiHelper? _apiHelper;
  ServicesBloc? _serviceBloc;
  List<ServiceList> _aList = [];
  List<ServiceList> _searchList = [];
  Timer? debounce;
  List<ServiceCategoryList>? _serviceCategory;
  String _selectCategory = "";
  String locationValue = "";
  bool isLocation = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  var _addressController = TextEditingController();
  final CarouselController _controller = CarouselController();
  var _progressShow = false;
  String? authToken, mineUserId = "", mineProfilePic = "";
  bool isLocationSearchVisible = false;
  var lastInputValue;
  var lat, lng;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _apiHelper = ApiHelper();
    _serviceBloc = ServicesBloc();
    _serviceCategory = [];

    PrefHelper.getUserId().then((token) {
      setState(() {
        mineUserId = token;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getServiceCategory();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getService(
          "", "", "", widget.serviceContinent.toString(), _selectCategory);
    });
  }
  /*_onSearchTextChanged(String text) async {
    if (text.isNotEmpty) {
      _aList.clear();
      _getSearchedEvent(text);
    } else {
      _aList.clear();

      _getService();
    }

    //searchData(text);
  }*/

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: _appBar(context),
        ),
      ),
      body: StreamBuilder(
          stream: _serviceBloc?.serviceList,
          builder: (context, AsyncSnapshot<ServiceListResponse> snapshot) {
            if (snapshot.hasData) {
              if (_aList.isEmpty) {
                _aList = snapshot.data?.data?.serviceList ?? [];
                _searchList.addAll(_aList);
              }

              return mainListing();
            } else if (snapshot.hasError) {
              return mainListing();
            }

            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
          }),
    );
  }

  @override
  void updateData() {
    _refresh();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _appBar(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: _commonHelper?.screenWidth * 0.15,
              width: _commonHelper?.screenWidth * 0.1,
              child: SvgPicture.asset(
                IconsHelper.backwardBackArrow,
              ),
            ),
          ),
          SizedBox(
            width: _commonHelper?.screenWidth * 0.70,
            child: SoloAppBar(
              appBarType: StringHelper.searchBar,
              onSearchBarTextChanged: _onSearchTextChanged,
              hintText: StringHelper.searchServices,
              leadingTap: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: GestureDetector(
              onTap: () {
                _addressController.text = "";
                _commonHelper?.startActivity(AddService(
                  isFrom: false,
                  context: this,
                ));
              },
              child: SvgPicture.asset(IconsHelper.ic_plus,
                  width: CommonHelper(context).screenWidth * 0.08),
            ),
          ),
        ],
      ),
    );
  }

  Widget mainListing() {
    return Column(
      children: [
        _findTab(),
        Expanded(
          child: Stack(
            children: [
              RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: _searchList.isNotEmpty
                    ? ListView.builder(
                        itemCount: _searchList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _eventsPost(index);
                        },
                      )
                    : _noCarnivalWarning(),
              ),
              Align(
                child: ProgressBarIndicator(
                    _commonHelper?.screenSize, _progressShow),
                alignment: FractionalOffset.center,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _findTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              _hideKeyBoard();
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SearchPlaces()))
                  .then((value) {
                _hideKeyBoard();

                if (value != null) {
                  isLocation = true;
                  lat = value.lat;
                  lng = value.lng;
                  _addressController.text = value.placeName.toString();
                  locationValue = value.placeName.toString();

                  print(value);
                  _aList.clear();
                  _searchList.clear();
                  _getService(
                      lastInputValue == null ? "" : lastInputValue,
                      lat.toString(),
                      lng.toString(),
                      widget.serviceContinent.toString(),
                      _selectCategory);
                  // locationDetail = value;

                  //         _addressController.text = locationDetail['locationName'];
                }
              });
            },
            child: Container(
              child: Row(
                children: [
                  Container(
                    height: _commonHelper?.screenWidth * 0.15,
                    width: _commonHelper?.screenWidth * 0.1,
                    child: SvgPicture.asset(
                      IconsHelper.internetNavigation,
                    ),
                  ),
                  Container(
                      width: _commonHelper?.screenWidth * 0.4,
                      child: isLocation
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  StringHelper.map,
                                  style: SoloStyle.blackW600medium,
                                ),
                                Text(
                                  locationValue,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            )
                          : Container(
                              child: Center(
                                  child: Text(
                                StringHelper.map,
                                style: SoloStyle.blackW600medium,
                              )),
                            )),
                ],
              ),
            ),
          ),
          Container(
            width: _commonHelper?.screenWidth * 0.44,
            decoration: BoxDecoration(
              border: Border.all(
                color: SoloColor.taupeGray.withOpacity(0.3),
                // Colors.black.withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(DimensHelper.searchBarMargin),
            ),
            // margin: EdgeInsets.only(
            //     left: DimensHelper.halfSides,
            //     right: DimensHelper.halfSides),
            child: DropdownButton<ServiceCategoryList>(
              icon: Padding(
                padding: const EdgeInsets.only(right: DimensHelper.sidesMargin),
                child: Icon(Icons.arrow_drop_down, color: SoloColor.black),
              ),
              iconSize: 24,
              hint: Padding(
                padding: EdgeInsets.only(
                    // right: DimensHelper.sidesMargin,
                    top: DimensHelper.halfSides,
                    bottom: DimensHelper.halfSides,
                    left: DimensHelper.sidesMargin),
                child: Text(
                  _selectCategory == "" ? "Select service" : _selectCategory,
                  style: SoloStyle.blackW600medium,
                ),
              ),
              isExpanded: true,
              items: _serviceCategory?.map((ServiceCategoryList serviceCat) {
                return DropdownMenuItem<ServiceCategoryList>(
                  value: serviceCat,
                  child: Text(
                      toBeginningOfSentenceCase(serviceCat.serviceCategoryId) ??
                          ""),
                );
              }).toList(),
              onTap: () {
                _hideKeyBoard();
              },
              onChanged: (val) {
                setState(() {
                  _selectCategory =
                      toBeginningOfSentenceCase(val?.serviceCategoryId) ?? '';
                });
                _aList.clear();
                _searchList.clear();
                _showProgress();
                _getService(
                    "",
                    lat == null ? "" : lat.toString(),
                    lng == null ? "" : lng.toString(),
                    widget.serviceContinent.toString(),
                    _selectCategory);
              },
              underline: Container(
                height: 0,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget _showDeleteBottomSheet(String delId) {
    return CupertinoActionSheet(
      title: Text("Delete Service",
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("Are you sure you want to delete this service?",
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
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
            "No",
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

  Widget _showEditBottomSheet(String edit, ServiceList serviceList) {
    return CupertinoActionSheet(
      title: Text("Edit Service",
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("Are you sure you want to edit this service?",
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _editButtonTap(edit, serviceList);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            "No",
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

  Widget _showBottomSheetEditDel(String id, ServiceList serviceList) {
    return CupertinoActionSheet(actions: [
      CupertinoActionSheetAction(
        child: Text("Edit",
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        onPressed: () {
          Navigator.pop(context);

          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) =>
                  _showEditBottomSheet(id, serviceList));
        },
      ),
      CupertinoActionSheetAction(
        child: Text("Delete",
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
    ]);
  }

  Widget _showBottomSheet(String blockUserId, String eventId) {
    return CupertinoActionSheet(
      actions: [
        /* CupertinoActionSheetAction(
          child: Text("Block",
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
        ),*/
        CupertinoActionSheetAction(
          child: Text(
            "Report",
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

  Widget _profileImage(int index) {
    return ClipOval(
        child: CachedNetworkImage(
      imageUrl: _searchList[index].userProfilePic.toString(),
      height: 30,
      width: 30,
      fit: BoxFit.cover,
      placeholder: (context, url) => imagePlaceHolder(),
      errorWidget: (context, url, error) => imagePlaceHolder(),
    ));
  }

  Widget _showReportBottomSheet(String eventId) {
    return CupertinoActionSheet(
      title: Text("Report",
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("Are you sure you want to report this service?",
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
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
            "No",
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

  Widget userDetails(int index) {
    return Container(
      padding: EdgeInsets.only(top: DimensHelper.borderRadius),
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
                child: GestureDetector(
                  onTap: () {
                    if (_searchList[index].userId == mineUserId) {
                      //_commonHelper.startActivity(ProfileTab(isFromHome: true));

                      Navigator.of(context)
                          .push(
                        new MaterialPageRoute(
                            builder: (_) => new ProfileTab(isFromHome: true)),
                      )
                          .then((mapData) {
                        if (mapData != null && mapData) {
                          _aList.clear();
                          _searchList.clear();
                          _showProgress();
                          _getService(
                              "",
                              "",
                              "",
                              widget.serviceContinent.toString(),
                              _selectCategory);
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
                        padding:
                            EdgeInsets.only(right: DimensHelper.sidesMargin),
                        child: _profileImage(index),
                      ),
                      Container(
                        width: _commonHelper?.screenWidth * .5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_searchList[index].businessName.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: SoloColor.black,
                                    fontSize: Constants.FONT_LOW)),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: DimensHelper.smallSides),
                              child: Text(
                                  _commonHelper!.getTimeDifference(
                                      _searchList[index].insertDate ?? 0),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: SoloColor.spanishGray,
                                      fontSize: Constants.FONT_LOW_SIZE)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
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
          child: Text("Ok",
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

  Widget _noCarnivalWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text("No Services Found",
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishGray)));
  }

  Widget _eventsPost(int index) {
    var likes = _searchList[index].totalLikes == 0
        ? ""
        : " " + _searchList[index].totalLikes.toString();

    if (_aList[index].totalLikes == 0) {
      likes = "";
    } else if (_searchList[index].totalLikes == 1) {
      likes = _searchList[index].totalLikes.toString() + "";
    } else {
      likes = _searchList[index].totalLikes.toString() + "";
    }

    var comments;

    if (_searchList[index].totalComments == 0) {
      comments = "";
    } else {
      var titleComment = _searchList[index].totalComments == 1 ? "" : "";

      comments = '${_searchList[index].totalComments.toString()} $titleComment';
    }

    return FeedCardService(
      carnivalsText: _searchList[index].category.toString(),
      userProfile: _searchList[index].userProfilePic.toString(),
      userName: _searchList[index].businessName.toString(),
      userLocation: StringHelper.userLocation,
      imageUrl: _searchList[index].image.toString(),
      countDown:
          _commonHelper!.getTimeDifference(_searchList[index].insertDate ?? 0),
      userDetailsOnTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ServiceDetail(
                      serviceId: _searchList[index].serviceId.toString(),
                      refresh: false,
                      context: this,
                    ))).then((value) {
          if (value) {
            _showProgress();

            _aList.clear();
            _searchList.clear();

            _getService("", "", "", widget.serviceContinent.toString(),
                _selectCategory);
          }
        });
      },
      moreTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) {
              return _searchList[index].userId == mineUserId
                  ? _showBottomSheetEditDel(
                      _searchList[index].serviceId.toString(),
                      _searchList[index])
                  : _showBottomSheet(_searchList[index].userId.toString(),
                      _searchList[index].serviceId.toString());
            });
      },
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

          _onUnLikeButtonTap(_searchList[index].serviceId.toString());
        } else {
          setState(() {
            var totalLikes = _searchList[index].totalLikes ?? 0 + 1;
            _searchList[index].totalLikes = totalLikes;
            _searchList[index].isLike = true;
          });

          _onLikeButtonTap(_searchList[index].serviceId.toString());
        }
      },
      commentCount: comments,
      indexForSearch: index,
      likeTextTap: () {
        _commonHelper?.startActivity(
            ServiceLikeActivity(_searchList[index].serviceId.toString()));
      },
      commentOnTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ServiceCommentActivity(
                  serviceId: _searchList[index].serviceId.toString(),
                  showKeyBoard: false,
                  scrollMessage: false)),
        ).then((value) {
          if (value != null && value) {
            _showProgress();
            _aList.clear();
            _searchList.clear();
            _getService("", "", "", widget.serviceContinent.toString(),
                _selectCategory);
          }
        });
      },
      feedTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ServiceDetail(
                      serviceId: _searchList[index].serviceId.toString(),
                      refresh: false,
                      context: this,
                    ))).then((value) {
          if (value) {
            _showProgress();

            _aList.clear();
            _searchList.clear();

            _getService("", "", "", widget.serviceContinent.toString(),
                _selectCategory);
          }
        });
      },
    );
  }

  Widget userDetail({
    Function()? moreTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                height: 45,
                width: 250,
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                  style: SoloStyle.blackW700TopXs,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: moreTap,
              child: SvgPicture.asset(
                IconsHelper.drop_arrow,
                height: _commonHelper?.screenHeight * 0.01,
              ),
            ),
          ),
        ],
      ),
    );
  }

//============================================================
// ** Helper Function **
//============================================================
  Future<Null> _refresh() async {
    _showProgress();
    _aList.clear();
    _searchList.clear();
    _getService(
        "", "", "", widget.serviceContinent.toString(), _selectCategory);
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

  void _getService(String text, String lat, String lng, String serviceContinent,
      String service) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();
          _serviceBloc
              ?.getService(
                  token.toString(), text, lat, lng, serviceContinent, service)
              .then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              _aList.clear();
              _searchList.clear();
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

  void _getSearchedEvent(String text) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();
          _serviceBloc
              ?.getSearchedSearch(token.toString(), text)
              .then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              /* if (onValue.data.eventList.isNotEmpty) {
                _aList = onValue.data.eventList;
              } else {}*/
            } else {
              /*    _commonHelper.showAlert(
                  StringHelper.noInternetTitle, "Something Wrong");*/
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

  _onSearchTextChanged(String text) async {
    if (lastInputValue.toString().trim() != text) {
      lastInputValue = text;

      _aList.clear();

      _searchList.clear();

      if (text.isEmpty) {
        //_searchList.addAll(_aList);

        //setState(() {});
        _getService(
            "",
            lat == null ? "" : lat.toString(),
            lng == null ? "" : lng.toString(),
            widget.serviceContinent.toString(),
            _selectCategory);

        return;
      }
      // _getService(text);

      if (debounce != null) debounce?.cancel();
      setState(() {
        debounce = Timer(Duration(seconds: 2), () {
          _getService(
              text,
              lat == null ? "" : lat.toString(),
              lng == null ? "" : lng.toString(),
              widget.serviceContinent.toString(),
              _selectCategory);

          //call api or other search functions here
        });
      });
    }

    /* _aList.forEach((carnivalDetail) {
      if (carnivalDetail.businessName
          .toUpperCase()
          .contains(text.toUpperCase())) {
        _searchList.add(carnivalDetail);
      }
    });*/

    setState(() {});
  }

  void _onReportPostTap(String eventId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "feedId": eventId,
          "feedType": "service",
        });

        _apiHelper?.reportFeed(body, authToken.toString()).then((onValue) {
          _hideProgress();

          ReportFeedModel _reportModel = onValue;

          if (_reportModel.statusCode == 200)
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _successBottomSheet(
                    "Success", "Service Reported Successfully"));
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

        _serviceBloc
            ?.deleteService(authToken.toString(), feedId)
            .then((onValue) {
          _aList.clear();
          _searchList.clear();

          _commonHelper?.showToast("Service deleted successfully");

          _getService(
              "", "", "", widget.serviceContinent.toString(), _selectCategory);
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _editButtonTap(String id, ServiceList serviceList) {
    _addressController.text = "";

    _commonHelper
        ?.startActivity(
            AddService(serviceList: serviceList, isFrom: true, context: this))
        .then((value) {
      if (value) {
        _showProgress();

        // _getProfileData();
      }
    });
  }

  void searchData(String searchQuery) {
    _searchList.clear();

    if (searchQuery.isEmpty) {
      _searchList.addAll(_aList);

      setState(() {});

      return;
    }

    _aList.forEach((carnivalDetail) {
      // if (carnivalDetail.carnivalTitle
      //     .toUpperCase()
      //     .contains(searchQuery.toUpperCase())) {
      //   _searchList.add(carnivalDetail);
      // }

      carnivalDetail.carnivalTitle?.forEach((element) {
        if (element.toUpperCase().contains(searchQuery.toUpperCase())) {
          _searchList.add(carnivalDetail);
        }
      });
    });

    setState(() {});
  }

  void _getServiceCategory() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _serviceBloc?.getServiceCategory(token.toString()).then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              if (onValue.data!.serviceCategoryList!.isNotEmpty) {
                _serviceCategory
                    ?.add(ServiceCategoryList(serviceCategoryId: "All"));
                _serviceCategory
                    ?.addAll(onValue.data?.serviceCategoryList ?? []);
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

  void _onLikeButtonTap(String serviceId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var likeBody = json.encode({
          "serviceId": serviceId,
        });

        _serviceBloc?.serviceLike(likeBody, authToken.toString());
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onUnLikeButtonTap(String serviceId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        var unLikeBody = json.encode({
          "serviceId": serviceId,
        });

        _serviceBloc?.serviceUnLike(unLikeBody, authToken.toString());
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }

//============================================================
// ** Firebase Function **
//============================================================
}
