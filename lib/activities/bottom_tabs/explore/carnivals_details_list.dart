import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/blocs/explore/carnival_list_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/carnival_continent_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../../resources_helper/screen_area/scaffold.dart';
import '../../common_helpers/app_bar.dart';
import '../../common_helpers/festival_card.dart';
import 'carnivals_activity.dart';

class CarnivalDetailsList extends StatefulWidget {
  dynamic Function(String)? onExploreData;

  CarnivalDetailsList({
    key,
    this.onExploreData,
  }) : super(key: key);

  @override
  CarnivalDetailsListState createState() => CarnivalDetailsListState();
}

class CarnivalDetailsListState extends State<CarnivalDetailsList> {
  //============================================================
// ** Properties **
//============================================================
  bool isVisible = false, _progressShow = false;
  CommonHelper? _commonHelper;
  List<ContinentList>? _aCarnivalList = [];
  List<ContinentList>? _searchCarnivalList = [];

  CarnivalListBloc? _carnivalListBloc;
//============================================================
// ** Flutter Build Cycle **
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
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(130), child: _appBar()),
      body: StreamBuilder(
          stream: _carnivalListBloc?.continentList,
          builder: (context, AsyncSnapshot<ContinentsModel> snapshot) {
            if (snapshot.hasData) {
              if (_aCarnivalList!.isEmpty) {
                _aCarnivalList = snapshot.data?.data?.continentList;
                _searchCarnivalList?.addAll(_aCarnivalList ?? []);
              }
              return _carnivalContinents();
            } else if (snapshot.hasError) {
              return _carnivalContinents();
            }

            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
          }),
    );
  }

  //============================================================
// ** Main Widgets **
//============================================================
  Widget _appBar() {
    return SoloAppBar(
      onSearchBarTextChanged: widget.onExploreData,
      appBarType: StringHelper.searchBarWithTrilling,
      appbarTitle: StringHelper.carnivalUpperCamelcase,
      hintText: StringHelper.search,
      leadingTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _carnivalContinents() {
    return Stack(
      children: [
        Container(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: _searchCarnivalList!.isNotEmpty
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: _commonHelper?.screenWidth * 0.4,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.4 / 3,
                          // childAspectRatio: 3 / 3,
                        ),
                        itemCount: _searchCarnivalList?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return listCard(context, index,
                              countryTitle: _searchCarnivalList![index]
                                  .continent!
                                  .toUpperCase(),
                              image:
                                  _searchCarnivalList![index].image.toString(),
                              countList: _searchCarnivalList![index]
                                  .carnivalCount
                                  .toString(),
                              isCount: true, onAllTap: () {
                            _commonHelper?.startActivity(CarnivalsActivity(
                              carnivalContinent:
                                  _searchCarnivalList?[index].continent,
                            ));
                          },
                              padding: EdgeInsets.only(top: 10.0),
                              isWidth: true,
                              isHeight: true);
                          // return _cardContinent(index);
                        }),
                  )
                : _noCarnivalWarning()),
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

  Widget _noCarnivalWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text("No carnival found near your location",
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishGray)));
  }
  //============================================================
// ** Helper Function **
//============================================================

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
    _searchCarnivalList?.clear();
    print("gfgfg${searchQuery}");
    PrefHelper.setSearchData(searchQuery);
    if (searchQuery.isEmpty) {
      _searchCarnivalList?.addAll(_aCarnivalList ?? []);
      // PrefHelper.setSearchData(searchQuery);

      setState(() {});
      return;
    }
    _aCarnivalList?.forEach((carnivalDetail) {
      if (carnivalDetail.continent!
          .toUpperCase()
          .contains(searchQuery.toUpperCase())) {
        _searchCarnivalList?.add(carnivalDetail);
      }
    });

    setState(() {});
  }

  void updateData(String distanceValue) {
    _showProgress();

    _aCarnivalList?.clear();

    _searchCarnivalList?.clear();

    // _getCarnivalList(distanceValue);
  }
//============================================================
// ** Firebase Function **
//============================================================
}
