import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/blocs/explore/carnival_list_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/carnival_continent_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../../../resources_helper/common_widget.dart';
import '../../../../resources_helper/screen_area/scaffold.dart';
import '../../../common_helpers/festival_card.dart';
import '../carnivals_activity.dart';
import '../carnivals_details_list.dart';

class ContinentActivity extends StatefulWidget {
  final dynamic Function(String)? onExploreData;
  GlobalKey<ContinentActivityState> data;
  ContinentActivity({key, this.onExploreData, required this.data})
      : super(key: key);

  @override
  ContinentActivityState createState() => ContinentActivityState();
}

class ContinentActivityState extends State<ContinentActivity> {
  //============================================================
// ** Properties **
//============================================================
  bool isVisible = false, _progressShow = false;
  CommonHelper? _commonHelper;
  List<ContinentList>? _aList = [];
  List<ContinentList>? _aDetailList = [];
  List<ContinentList>? _searchList = [];
  List<ContinentList>? _detailSearchList = [];
  CarnivalListBloc? _carnivalListBloc;
  GlobalKey<CarnivalDetailsListState> _CarnivalsAllListState = GlobalKey();
  //============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  void initState() {
    super.initState();

    _carnivalListBloc = CarnivalListBloc();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _getCarnivalContinentList());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SoloScaffold(
      body: StreamBuilder(
        stream: _carnivalListBloc?.continentList,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (_aList!.isEmpty || _aDetailList!.isEmpty) {
              _aList = snapshot.data?.data?.continentList;
              _aDetailList = snapshot.data?.data?.continentList;
              _searchList?.addAll(_aList ?? []);
              _detailSearchList?.addAll(_aDetailList ?? []);
            }
            return listExplore(
              context,
              isData: _searchList!.isNotEmpty ? true : false,
              title: StringHelper.carnivalUpperCamelcase,
              itemCount: _searchList?.length,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (
                    context,
                  ) =>
                          CarnivalDetailsList(
                            key: _CarnivalsAllListState,
                            onExploreData: _onSearchTextChanged,
                          )),
                );
              },
              itemListBuilder: (BuildContext context, int index) {
                return listCard(
                  context,
                  index,
                  countList: _searchList![index].carnivalCount.toString(),
                  countryTitle: _searchList![index].continent!.toUpperCase(),
                  image: _searchList![index].image.toString(),
                  onAllTap: () {
                    _commonHelper?.startActivity(CarnivalsActivity(
                      carnivalContinent: _searchList?[index].continent,
                    ));
                  },
                  isCount: true,
                );
              },
              warningText: StringHelper.carnivalWarning,
            );
          } else if (snapshot.hasError) {
            return listExplore(
              context,
              itemListBuilder: (BuildContext context, int index) {
                return listCard(context, index,
                    countryTitle: _searchList![index].continent!.toUpperCase(),
                    image: _searchList![index].image.toString());
              },
              warningText: StringHelper.carnivalWarning,
            );
          }

          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
        },
      ),
      // StreamBuilder(
      //     stream: _carnivalListBloc?.continentList,
      //     builder: (context, AsyncSnapshot<ContinentsModel> snapshot) {
      //       if (snapshot.hasData) {
      //         if (_aList!.isEmpty) {
      //           _aList = snapshot.data?.data?.continentList;
      //           _searchList?.addAll(_aList ?? []);
      //         }
      //         return _carnivalContinents();
      //       } else if (snapshot.hasError) {
      //         return _carnivalContinents();
      //       }
      //
      //       return Center(
      //           child: CircularProgressIndicator(
      //               valueColor:
      //                   AlwaysStoppedAnimation<Color>(SoloColor.blue)));
      //     }),
    );
  }

  //============================================================
// ** Helper Widgets **
//============================================================
  // Widget _carnivalContinents() {
  //   return Stack(
  //     children: [
  //       Container(
  //           margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
  //           child: _searchList!.isNotEmpty
  //               ? GridView.builder(
  //                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                       crossAxisCount: 2),
  //                   itemCount: _searchList?.length,
  //                   itemBuilder: (BuildContext context, int index) {
  //                     return _cardContinent(index);
  //                   })
  //               : _noCarnivalWarning()),
  //       Align(
  //         child: ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
  //         alignment: FractionalOffset.center,
  //       ),
  //     ],
  //   );
  // }

  Widget _cardContinent(int index) {
    return GestureDetector(
      onTap: () {
        _commonHelper?.startActivity(CarnivalsActivity(
          carnivalContinent: _searchList?[index].continent,
        ));
      },
      child: Container(
        margin: EdgeInsets.all(DimensHelper.sidesMargin),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DimensHelper.sidesMargin),
          child: Stack(
            children: [
              Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    height: _commonHelper?.screenHeight * .4,
                    imageUrl: _searchList![index].image.toString(),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => imagePlaceHolder(),
                    errorWidget: (context, url, error) => imagePlaceHolder(),
                  ),
                ],
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  height: 40,
                  child: Center(
                      child: Text(
                    _searchList![index].carnivalCount.toString(),
                    style: TextStyle(color: SoloColor.white),
                  )),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: SoloColor.blue.withOpacity(0.90),
                  height: 40,
                  child: Center(
                      child: Text(
                    _searchList![index].continent.toString(),
                    style: TextStyle(color: SoloColor.white),
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _noCarnivalWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text(StringHelper.noCarnivalLocation,
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishGray)));
  }

  Widget _loadingProgressBar() {
    return Container(
      width: 70,
      height: 70,
      child: Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)),
      ),
    );
  }
  //============================================================
// ** Helper Function **
//============================================================

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

  void _getCarnivalContinentList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _carnivalListBloc
              ?.getCarnivalsContinentList(token.toString())
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
    _searchList?.clear();

    if (searchQuery.isEmpty) {
      _searchList?.addAll(_aList ?? []);

      setState(() {});

      return;
    }
    _aList?.forEach((carnivalDetail) {
      if (carnivalDetail.continent!
          .toUpperCase()
          .contains(searchQuery.toUpperCase())) {
        _searchList?.add(carnivalDetail);
      }
    });

    setState(() {});
  }

  void detailSearchData(String searchQuery) {
    _detailSearchList?.clear();

    if (searchQuery.isEmpty) {
      _detailSearchList?.addAll(_aDetailList ?? []);

      setState(() {});

      return;
    }
    _aDetailList?.forEach((carnivalDetail) {
      if (carnivalDetail.continent!
          .toUpperCase()
          .contains(searchQuery.toUpperCase())) {
        _detailSearchList?.add(carnivalDetail);
      }
    });

    setState(() {});
  }

  void updateData(String distanceValue) {
    _showProgress();

    _aList?.clear();

    _searchList?.clear();

    // _getCarnivalList(distanceValue);
  }

  _onSearchTextChanged(String text) async {
    _CarnivalsAllListState.currentState?.searchData(text);
  }
//============================================================
// ** Firebase Function **
//============================================================
}
