import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/blocs/explore/contest_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/contest_list_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../../resources_helper/common_widget.dart';
import '../../../resources_helper/screen_area/scaffold.dart';
import '../../common_helpers/festival_card.dart';
import 'contest/contest_detail_activity.dart';
import 'contest/contests_details_list.dart';

class ContestsActivity extends StatefulWidget {
  final dynamic Function(String)? onExploreData;
  const ContestsActivity({Key? key, this.onExploreData}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ContestsState();
  }
}

class ContestsState extends State<ContestsActivity> {
  //============================================================
// ** Properties **
//============================================================
  CommonHelper? _commonHelper;
  ContestBloc? _contestBloc;
  String? authToken;
  bool? _isShowProgress;
  List<ContestList> _aList = [];
  List<ContestList> _searchList = [];
  GlobalKey<ContestsDetailsListState> _ContestsDetailsListState = GlobalKey();

//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  void initState() {
    super.initState();

    _contestBloc = ContestBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getContestList(""));
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SoloScaffold(
      body: StreamBuilder(
          stream: _contestBloc?.contestList,
          builder: (context, AsyncSnapshot<ContestListModel> snapshot) {
            if (snapshot.hasData) {
              if (_aList.isEmpty) {
                _aList = snapshot.data?.data?.contestList ?? [];

                _searchList.addAll(_aList);
              }

              return listExplore(
                context,
                isData: _searchList.isNotEmpty ? true : false,
                title: StringHelper.contestsUpperCamelcase,
                itemCount: _searchList.length,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (
                      context,
                    ) =>
                            ContestsDetailsList(
                              key: _ContestsDetailsListState,
                              onExploreData: _onSearchTextChanged,
                            )),
                  );
                },
                itemListBuilder: (BuildContext context, int index) {
                  return listCard(
                    context,
                    index,
                    countryTitle: _searchList[index].title.toString(),
                    image: _searchList[index].coverImageUrl.toString(),
                    onAllTap: () {
                      _commonHelper?.startActivity(ContestDetailActivity(
                          contestId: _searchList[index].contestId,
                          contestTitle: _searchList[index].title));
                    },
                  );
                },
                warningText: StringHelper.contestWarning,
              );
            } else if (snapshot.hasError) {
              return Container();
            }

            return Container();
          }),
      // StreamBuilder(
      //     stream: _contestBloc?.contestList,
      //     builder: (context, AsyncSnapshot<ContestListModel> snapshot) {
      //       if (snapshot.hasData) {
      //         if (_aList.isEmpty) {
      //           _aList = snapshot.data?.data?.contestList ?? [];
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
      //               valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
      //     }),
    );
  }

  @override
  void dispose() {
    _contestBloc?.dispose();

    super.dispose();
  }
  //============================================================
// ** Main Widgets **
//============================================================

//============================================================
// ** Helper Widgets **
//============================================================
  Widget profileImage(String coverImageUrl) {
    return ClipOval(
        child: CachedNetworkImage(
      imageUrl: coverImageUrl,
      height: 50,
      width: 50,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => imagePlaceHolder(),
    ));
  }

  Widget contestCard(ContestList contestList) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: DimensHelper.halfSides),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              _commonHelper?.startActivity(ContestDetailActivity(
                  contestId: contestList.contestId,
                  contestTitle: contestList.title));
            },
            child: Container(
              padding: EdgeInsets.all(DimensHelper.sidesMargin),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: DimensHelper.halfSides),
                    child: profileImage(contestList.coverImageUrl.toString()),
                  ),
                  Container(
                    width: _commonHelper?.screenWidth * .68,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contestList.title.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: SoloColor.black,
                                fontSize: Constants.FONT_TOP)),
                        Padding(
                            padding:
                                EdgeInsets.only(top: DimensHelper.smallSides),
                            child: Text(contestList.description.toString(),
                                maxLines: 2,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: SoloColor.spanishGray,
                                    fontSize: Constants.FONT_MEDIUM)))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _noContestWarning() {
    return Center(
      child: Container(
        child: Text(
          "No Wins Yet!",
          style: TextStyle(
              fontSize: Constants.FONT_TOP,
              color: SoloColor.spanishGray,
              fontWeight: FontWeight.normal),
        ),
      ),
    );
  }

  Widget _mainItem() {
    return Stack(
      children: [
        _searchList.isNotEmpty
            ? ListView.separated(
                itemCount: _searchList.length,
                separatorBuilder: (BuildContext context, int index) =>
                    divider(),
                padding: EdgeInsets.only(
                    top: DimensHelper.halfSides,
                    bottom: DimensHelper.halfSides),
                itemBuilder: (BuildContext context, int index) {
                  return contestCard(_searchList[index]);
                })
            : _noContestWarning(),
        Align(
          child:
              ProgressBarIndicator(_commonHelper?.screenSize, _isShowProgress!),
          alignment: FractionalOffset.center,
        )
      ],
    );
  }

//============================================================
// ** Helper Function **
//============================================================

  void _getContestList(String distance) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _contestBloc
              ?.getContests(token.toString(), distance, "")
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

  void searchData(String searchQuery) {
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
    // _searchList.clear();
    //
    // if (searchQuery.isEmpty) {
    //   _searchList.addAll(_aList);
    //
    //   setState(() {});
    //
    //   return;
    // }

    // _aList.forEach((carnivalDetail) {
    //   if (carnivalDetail.title!
    //       .toUpperCase()
    //       .contains(searchQuery.toUpperCase())) {
    //     _searchList.add(carnivalDetail);
    //   }
    // });

    setState(() {});
  }

  void updateData(String distanceValue) {
    _showProgress();

    _searchList.clear();

    _aList.clear();

    _getContestList(distanceValue);
  }

  _onSearchTextChanged(String text) async {
    _ContestsDetailsListState.currentState?.searchData(text);
  }
//============================================================
// ** Firebase Function **
//============================================================
}
