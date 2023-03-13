import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/bottom_tabs/explore/group/group_detail_activity.dart';
import 'package:solomas/blocs/group/group_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/get_groups_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../../../resources_helper/common_widget.dart';
import '../../../../resources_helper/screen_area/scaffold.dart';
import '../../../../resources_helper/text_styles.dart';
import '../../../common_helpers/app_bar.dart';
import '../people/people_details_list.dart';

class GroupsDetailsList extends StatefulWidget {
  final dynamic Function(String)? onExploreData;
  const GroupsDetailsList({Key? key, this.onExploreData}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GroupsDetailsListState();
  }
}

class GroupsDetailsListState extends State<GroupsDetailsList> {
  //============================================================
// ** Properties **
//============================================================
  CommonHelper? _commonHelper;
  bool isVisible = false, _progressShow = false;
  bool isJoined = false, _isShowProgress = false;

  GroupBloc? _groupBloc;

  List<GroupList> _aList = [];

  List<GroupList> _searchList = [];

  String? authToken, searchDistance = "";
  String distanceValue = '10';
//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  void initState() {
    super.initState();

    _groupBloc = GroupBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getGroups(""));
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(130), child: _appBar()),
      body: Stack(
        children: [
          StreamBuilder(
              stream: _groupBloc?.groupsList,
              builder: (context, AsyncSnapshot<GetGroupsModel> snapshot) {
                if (snapshot.hasData) {
                  if (_aList.isEmpty) {
                    _aList = snapshot.data?.data?.groupList ?? [];

                    _searchList.addAll(_aList);
                  }

                  return _mainItem();
                  // return _groupContinents();
                } else if (snapshot.hasError) {
                  return Container();
                }

                return Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(SoloColor.blue)));
              }),
          Align(
            child: ProgressBarIndicator(
                _commonHelper?.screenSize, _isShowProgress),
            alignment: FractionalOffset.center,
          )
        ],
      ),
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
  Widget _appBar() {
    return SoloAppBar(
      onSearchBarTextChanged: widget.onExploreData,
      appBarType: StringHelper.searchBarWithTrilling,
      appbarTitle: StringHelper.groupsUpperCamelcase,
      hintText: StringHelper.search,
      leadingTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _mainItem() {
    return _searchList.isNotEmpty
        ? ListView.separated(
            itemCount: _searchList.length,
            separatorBuilder: (BuildContext context, int index) => divider(),
            padding: EdgeInsets.only(bottom: DimensHelper.halfSides),
            itemBuilder: (BuildContext context, int index) {
              return peopleDetailCard(index);
            })
        : _noGroupsWarning();
  }

  Widget peopleDetailCard(int index) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.all(DimensHelper.topBarMargin),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GroupDetailsActivity(
                          groupId: _searchList[index].groupId,
                          groupTitle: _searchList[index].title)),
                ).then((value) {
                  if (value == null) {
                    _showProgress();

                    _searchList.clear();

                    _aList.clear();

                    _getGroups(searchDistance.toString());
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.only(right: DimensHelper.halfSides),
                child:
                    profileImage(_searchList[index].groupProfilePic.toString()),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupDetailsActivity(
                            groupId: _searchList[index].groupId,
                            groupTitle: _searchList[index].title)),
                  ).then((value) {
                    if (value == null) {
                      _showProgress();

                      _searchList.clear();

                      _aList.clear();

                      _getGroups(searchDistance.toString());
                    }
                  });
                },
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_searchList[index].title.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: SoloColor.black,
                                        fontSize: Constants.FONT_TOP)),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: DimensHelper.smallSides),
                                    child: Text(
                                        "${_searchList[index].totalSubscribers} ${StringHelper.member}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: SoloColor.spanishGray
                                                .withOpacity(0.7),
                                            fontSize: Constants.FONT_MEDIUM)))
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: _searchList[index].isJoined == true
                  ? joinedButton(_searchList[index].groupId.toString(),
                      _searchList[index].title.toString())
                  : joinButton(_searchList[index].groupId.toString(),
                      _searchList[index].title.toString()),
            )
          ],
        ),
      ),
    );
  }
  // Widget _groupContinents() {
  //   return Stack(
  //     children: [
  //       Container(
  //           padding: const EdgeInsets.only(left: 10, right: 10),
  //           child: _searchList.isNotEmpty
  //               ? Container(
  //                   height: MediaQuery.of(context).size.height,
  //                   child: GridView.builder(
  //                       gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
  //                         maxCrossAxisExtent: _commonHelper?.screenWidth * 0.5,
  //                         crossAxisSpacing: 10,
  //                         childAspectRatio: 3 / 3,
  //                       ),
  //                       itemCount: _searchList.length,
  //                       itemBuilder: (BuildContext context, int index) {
  //                         return listCard(context, index,
  //                             countryTitle:
  //                                 _searchList[index].title!.toUpperCase(),
  //                             image: _searchList[index]
  //                                 .groupProfilePic
  //                                 .toString(), onAllTap: () {
  //                           Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                                 builder: (context) => GroupDetailsActivity(
  //                                     groupId: _searchList?[index].groupId,
  //                                     groupTitle: _searchList?[index].title)),
  //                           ).then((value) {
  //                             if (value == null) {
  //                               _showProgress();
  //
  //                               _searchList.clear();
  //
  //                               _aList.clear();
  //
  //                               _getGroups(searchDistance.toString());
  //                             }
  //                           });
  //                         },
  //                             padding: EdgeInsets.only(top: 10.0),
  //                             isWidth: true,
  //                             isHeight: true);
  //                         // return _cardContinent(index);
  //                       }),
  //                 )
  //               : _noCarnivalWarning()),
  //       Align(
  //         child: ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
  //         alignment: FractionalOffset.center,
  //       ),
  //     ],
  //   );
  // }

//============================================================
// ** Helper Widgets **
//============================================================

  //============================================================
// ** Helper Widgets **
//============================================================
  Widget _showBottomSheet(
      String msg, String sheetTitle, bool joinGroup, String groupId) {
    return CupertinoActionSheet(
      message: Text(msg,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.normal)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
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

  Widget profileImage(String groupProfilePic) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: groupProfilePic,
          height: 55,
          width: 55,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => imagePlaceHolder(),
        ));
  }

  Widget joinedButton(String groupId, String title) {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _showBottomSheet(
                StringHelper.groupLeaveMsg, "", false, groupId));
      },
      child: Container(
        height: 30,
        padding: EdgeInsets.only(
            left: DimensHelper.textSize, right: DimensHelper.textSize),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(DimensHelper.halfSides)),
          color: SoloColor.pink,
        ),
        child: Center(
          child: Text("+ ${StringHelper.joined.toUpperCase()}",
              style: TextStyle(
                  fontSize: Constants.FONT_LOW, color: SoloColor.white)),
        ),
      ),
    );
  }

  Widget joinButton(String groupId, String title) {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _showBottomSheet(
                " ${StringHelper.groupJoinMsg} ${title.trim()}?",
                "",
                true,
                groupId));
      },
      child: Container(
        height: 30,
        padding: EdgeInsets.only(
            left: DimensHelper.topBarMargin, right: DimensHelper.topBarMargin),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(DimensHelper.halfSides)),
          color: SoloColor.batteryChargedBlue,
        ),
        child: Center(
          child: Text("+ ${StringHelper.join.toUpperCase()}",
              // "Join",
              style: TextStyle(
                  fontSize: Constants.FONT_LOW, color: SoloColor.white)),
        ),
      ),
    );
  }

  Widget divider() {
    return Container(
      margin: EdgeInsets.only(
          left: DimensHelper.sidesMargin, right: DimensHelper.sidesMargin),
      child: Divider(color: SoloColor.silverSand.withOpacity(0.5), height: 1),
    );
  }

  void searchData(String searchQuery) {
    _searchList.clear();

    if (searchQuery.isEmpty) {
      _searchList.addAll(_aList);

      setState(() {});

      return;
    }

    _aList.forEach((carnivalDetail) {
      if (carnivalDetail.title!
          .toUpperCase()
          .contains(searchQuery.toUpperCase())) {
        _searchList.add(carnivalDetail);
      }
    });

    setState(() {});
  }

  void updateData(String distanceValue) {
    setState(() {
      searchDistance = distanceValue;
    });

    _showProgress();

    _searchList.clear();

    _aList.clear();

    _getGroups(distanceValue);
  }

  Widget _noCarnivalWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text("No groups found near your location",
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishGray)));
  }

  Widget distanceSeekBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        height: 95,
        decoration: BoxDecoration(
            border: Border.all(
              color: SoloColor.black.withOpacity(0.1),
              width: 1,
            ),
            color: SoloColor.silverSand.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20)),
        width: _commonHelper?.screenWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(StringHelper.distance,
                    style: SoloStyle.pinkBoldMediumRob),
              ),
              Container(
                height: 30,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    inactiveTrackColor: SoloColor.batteryChargedBlue,
                    activeTrackColor: SoloColor.batteryChargedBlue,
                    trackHeight: 1,
                    thumbShape: SliderThumbShape(),
                  ),
                  child: Slider(
                    min: 0.0,
                    max: 20.0,
                    value: double.parse(distanceValue),
                    onChanged: (value) {
                      double dragValue = value;

                      setState(() {
                        distanceValue = dragValue.toInt().toString();
                      });

                      _getDistanceData(distanceValue);
                    },
                    onChangeEnd: (value) {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(distanceValue + ' ML',
                      style: SoloStyle.blackNormalMediumRob),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noGroupsWarning() {
    return Center(
      child: Container(
        child: Text(
          "No Groups Found",
          style: TextStyle(
              fontSize: Constants.FONT_TOP,
              color: SoloColor.spanishGray,
              fontWeight: FontWeight.normal),
        ),
      ),
    );
  }

//============================================================
// ** Helper Function **
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

  void _onDisJoinButtonTap(String groupId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "groupId": groupId,
        });

        _groupBloc?.disJoinGroup(authToken.toString(), body).then((onValue) {
          _searchList.clear();

          _aList.clear();

          _getGroups(searchDistance.toString());
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
          _searchList.clear();

          _aList.clear();

          _getGroups(searchDistance.toString());
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _getGroups(String distance) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _groupBloc
              ?.getGroupList(token.toString(), "", distance)
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

  void _getDistanceData(String distanceValue) {
    updateData(distanceValue);
  }

//============================================================
// ** Firebase Function **
//============================================================
}
