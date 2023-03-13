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
import '../../../common_helpers/festival_card.dart';
import 'groups_details_list.dart';

class GroupsActivity extends StatefulWidget {
  final dynamic Function(String)? onExploreData;
  const GroupsActivity({Key? key, this.onExploreData}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GroupsState();
  }
}

class GroupsState extends State<GroupsActivity> {
  //============================================================
// ** Properties **
//============================================================
  CommonHelper? _commonHelper;
  bool isJoined = false, _isShowProgress = false;
  GroupBloc? _groupBloc;
  List<GroupList> _aList = [];
  List<GroupList> _searchList = [];
  String? authToken, searchDistance = "";
  GlobalKey<GroupsDetailsListState> _GroupsDetailsListState = GlobalKey();

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

                  return listExplore(context,
                      isData: _searchList.isNotEmpty ? true : false,
                      title: StringHelper.groupsUpperCamelcase,
                      itemCount: _searchList.length,
                      itemListBuilder: (BuildContext context, int index) {
                    return listCard(
                      context,
                      index,
                      countryTitle: _searchList[index].title!.toUpperCase(),
                      image: _searchList[index].groupProfilePic.toString(),
                      onAllTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupDetailsActivity(
                                  groupId: _searchList?[index].groupId,
                                  groupTitle: _searchList?[index].title)),
                        ).then((value) {
                          if (value == null) {
                            _showProgress();

                            _searchList.clear();

                            _aList.clear();

                            _getGroups(searchDistance.toString());
                          }
                        });
                      },
                    );
                  }, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (
                        context,
                      ) =>
                              GroupsDetailsList(
                                key: _GroupsDetailsListState,
                                onExploreData: _onSearchTextChanged,
                              )
                          // ExploreAllScreen(
                          //   onExploreData: widget.onExploreData,
                          //   itemListBuilder:
                          //       (BuildContext context, int index) {
                          //     return listCard(context, index,
                          //         countryTitle: _searchList[index]
                          //             .title!
                          //             .toUpperCase(),
                          //         image: _searchList[index]
                          //             .groupProfilePic
                          //             .toString(), onAllTap: () {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) =>
                          //                 GroupDetailsActivity(
                          //                     groupId: _searchList?[index]
                          //                         .groupId,
                          //                     groupTitle:
                          //                         _searchList?[index]
                          //                             .title)),
                          //       ).then((value) {
                          //         if (value == null) {
                          //           _showProgress();
                          //
                          //           _searchList.clear();
                          //
                          //           _aList.clear();
                          //
                          //           _getGroups(searchDistance.toString());
                          //         }
                          //       });
                          //     },
                          //         padding: EdgeInsets.only(top: 10.0),
                          //         isWidth: true);
                          //   },
                          //   itemListCount: _searchList?.length,
                          //   headerName: StringHelper.groupsUpperCamelcase,
                          // )
                          ),
                    );
                  }, warningText: StringHelper.groupsWarning);
                } else if (snapshot.hasError) {
                  return Container();
                }

                return Container();
              }),
          // StreamBuilder(
          //     stream: _groupBloc?.groupsList,
          //     builder: (context, AsyncSnapshot<GetGroupsModel> snapshot) {
          //       if (snapshot.hasData) {
          //         if (_aList.isEmpty) {
          //           _aList = snapshot.data?.data?.groupList ?? [];
          //
          //           _searchList.addAll(_aList);
          //         }
          //
          //         return _mainItem();
          //       } else if (snapshot.hasError) {
          //         return Container();
          //       }
          //
          //       return Center(
          //           child: CircularProgressIndicator(
          //               valueColor:
          //                   AlwaysStoppedAnimation<Color>(SoloColor.blue)));
          //     }),
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

  //============================================================
// ** Helper Widgets **
//============================================================
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

  Widget _mainItem() {
    return _searchList.isNotEmpty
        ? ListView.separated(
            itemCount: _searchList.length,
            separatorBuilder: (BuildContext context, int index) => divider(),
            padding: EdgeInsets.only(
                top: DimensHelper.halfSides, bottom: DimensHelper.halfSides),
            itemBuilder: (BuildContext context, int index) {
              return peopleDetailCard(index);
            })
        : _noGroupsWarning();
  }

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
    return ClipOval(
        child: CachedNetworkImage(
      imageUrl: groupProfilePic,
      height: 50,
      width: 50,
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
                "Are you sure you want to leave this group?",
                "",
                false,
                groupId));
      },
      child: Container(
        height: 25,
        padding: EdgeInsets.only(
            left: DimensHelper.sidesMargin, right: DimensHelper.sidesMargin),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(DimensHelper.halfSides)),
          color: SoloColor.pink,
        ),
        child: Center(
          child: Text("Joined",
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
                "Are you sure you want to join the ${title.trim()}?",
                "",
                true,
                groupId));
      },
      child: Container(
        height: 25,
        padding: EdgeInsets.only(
            left: DimensHelper.sidesMargin, right: DimensHelper.sidesMargin),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(DimensHelper.halfSides)),
          color: SoloColor.brightGray,
        ),
        child: Center(
          child: Text("Join",
              style: TextStyle(
                  fontSize: Constants.FONT_LOW,
                  color: SoloColor.philippineSilver)),
        ),
      ),
    );
  }

  Widget peopleDetailCard(int index) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: DimensHelper.halfSides),
      child: Container(
        padding: EdgeInsets.all(DimensHelper.sidesMargin),
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
                                        fontWeight: FontWeight.w500,
                                        color: SoloColor.black,
                                        fontSize: Constants.FONT_TOP)),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: DimensHelper.smallSides),
                                    child: Text(
                                        "${_searchList[index].totalSubscribers} subscribers",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: SoloColor.spanishGray,
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

  Widget divider() {
    return Container(
      margin: EdgeInsets.only(
          left: DimensHelper.sidesMargin, right: DimensHelper.sidesMargin),
      child: Divider(color: SoloColor.silverSand, height: 1),
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

  _onSearchTextChanged(String text) async {
    _GroupsDetailsListState.currentState?.searchData(text);
  }

//============================================================
// ** Firebase Function **
//============================================================
}
