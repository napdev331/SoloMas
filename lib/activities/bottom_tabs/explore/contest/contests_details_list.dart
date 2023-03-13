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

import '../../../../resources_helper/common_widget.dart';
import '../../../../resources_helper/screen_area/scaffold.dart';
import '../../../../resources_helper/text_styles.dart';
import '../../../common_helpers/app_bar.dart';
import '../../../common_helpers/festival_card.dart';
import '../people/people_details_list.dart';
import 'contest_detail_activity.dart';

class ContestsDetailsList extends StatefulWidget {
  final dynamic Function(String)? onExploreData;
  const ContestsDetailsList({Key? key, this.onExploreData}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ContestsDetailsListState();
  }
}

class ContestsDetailsListState extends State<ContestsDetailsList> {
  //============================================================
// ** Properties **
//============================================================
  CommonHelper? _commonHelper;
  ContestBloc? _contestBloc;
  String? authToken;
  bool isJoined = false, _isShowProgress = false;
  List<ContestList> _aList = [];
  List<ContestList> _searchList = [];
  bool isVisible = false, _progressShow = false;
  String distanceValue = '10';
  double appBarHeight = 120;
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

    Widget _contestsContinents() {
      return Stack(
        children: [
          Container(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: _searchList.isNotEmpty
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                _commonHelper?.screenWidth * 0.4,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2.4 / 3,
                          ),
                          itemCount: _searchList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return listCard(context, index,
                                countryTitle:
                                    _searchList[index].title.toString(),
                                image: _searchList[index]
                                    .coverImageUrl
                                    .toString(), onAllTap: () {
                              _commonHelper?.startActivity(
                                  ContestDetailActivity(
                                      contestId: _searchList[index].contestId,
                                      contestTitle: _searchList[index].title));
                            },
                                padding: EdgeInsets.only(top: 10.0),
                                isWidth: true,
                                isHeight: true);
                            // return _cardContinent(index);
                          }),
                    )
                  : _noCarnivalWarning()),
          Align(
            child:
                ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
            alignment: FractionalOffset.center,
          ),
        ],
      );
    }

    return SoloScaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(isVisible ? 185 : 140),
          // preferredSize: Size.fromHeight(isVisible ? 165 : 120),
          child: _appBar()),
      body: Stack(children: [
        StreamBuilder(
            stream: _contestBloc?.contestList,
            builder: (context, AsyncSnapshot<ContestListModel> snapshot) {
              if (snapshot.hasData) {
                if (_aList.isEmpty) {
                  _aList = snapshot.data?.data?.contestList ?? [];

                  _searchList.addAll(_aList);
                }

                return _contestsContinents();
              } else if (snapshot.hasError) {
                return Container();
              }

              return Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(SoloColor.blue)));
            }),
        Align(
          child:
              ProgressBarIndicator(_commonHelper?.screenSize, _isShowProgress),
          alignment: FractionalOffset.center,
        )
      ]),
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
  Widget _appBar() {
    return SoloAppBar(
      onSearchBarTextChanged: widget.onExploreData,
      appBarType: StringHelper.searchBarWithTrilling,
      appbarTitle: StringHelper.contestsUpperCamelcase,
      hintText: StringHelper.search,
      leadingTap: () {
        Navigator.pop(context);
      },
      child: Container(
          child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(
                top: DimensHelper.sidesMargin,
                right: DimensHelper.smallSides,
                bottom: DimensHelper.sidesMargin),
            child: Image.asset("assets/images/ic_distance.png",
                color: SoloColor.pink, height: 20, width: 25),
          ),
          GestureDetector(
              onTap: () {
                if (isVisible) {
                  setState(() {
                    appBarHeight = 120;

                    isVisible = false;
                  });
                } else {
                  setState(() {
                    appBarHeight = 190;

                    isVisible = true;
                  });
                }
              },
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: DimensHelper.sidesMargin,
                      bottom: DimensHelper.sidesMargin),
                  child: Text(StringHelper.distance,
                      style: SoloStyle.pinkBoldMediumRob),
                ),
              ))
        ],
      )),
      distanceWidget: distanceSeekBar(),
    );
  }
//============================================================
// ** Helper Widgets **
//============================================================

  Widget _noCarnivalWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text("No contests found near your location",
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishGray)));
  }

  Widget distanceSeekBar() {
    return Visibility(
      visible: isVisible,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(
              color: SoloColor.black.withOpacity(0.1),
              width: 1,
            ),
            color: SoloColor.silverSand.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20)),
        width: _commonHelper?.screenWidth,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            children: [
              Expanded(
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
              Text(distanceValue + ' ML',
                  style: SoloStyle.blackNormalMediumRob),
            ],
          ),
        ),
      ),
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

    setState(() {});
  }

  void updateData(String distanceValue) {
    _showProgress();

    _searchList.clear();

    _aList.clear();

    _getContestList(distanceValue);
  }

  void _getDistanceData(String distanceValue) {
    updateData(distanceValue);
  }

//============================================================
// ** Firebase Function **
//============================================================

}
