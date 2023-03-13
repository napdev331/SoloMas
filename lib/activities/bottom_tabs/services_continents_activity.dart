import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/bottom_tabs/service_tab.dart';
import 'package:solomas/blocs/serives/ServicesBloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/services_continent_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../common_helpers/app_bar.dart';
import '../common_helpers/festival_card.dart';

class ServicesContinentActivity extends StatefulWidget {
  const ServicesContinentActivity({key}) : super(key: key);

  @override
  ServicesContinentActivityState createState() =>
      ServicesContinentActivityState();
}

class ServicesContinentActivityState extends State<ServicesContinentActivity> {
  //============================================================
// ** Properties **
//============================================================
  bool isVisible = false, _progressShow = false;
  CommonHelper? _commonHelper;
  List<ServiceList> _aList = [];
  List<ServiceList> _searchList = [];
  ServicesBloc? _serviceBloc;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  void initState() {
    _serviceBloc = ServicesBloc();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _getCarnivalContinentList());
  }

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
          stream: _serviceBloc?.serviceContinentList,
          builder: (context, AsyncSnapshot<ServicesContinentModel> snapshot) {
            if (snapshot.hasData) {
              if (_aList.isEmpty) {
                _aList = snapshot.data?.data?.serviceList ?? [];

                _searchList.addAll(_aList);
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

  Widget _carnivalContinents() {
    return Stack(
      children: [
        RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Container(
                margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
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
                              // childAspectRatio: 3 / 3,
                            ),
                            itemCount: _searchList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return listCard(
                                context,
                                index,
                                countList:
                                    _searchList[index].carnivalCount.toString(),
                                countryTitle:
                                    _searchList[index].continent!.toUpperCase(),
                                image: _searchList[index].image.toString(),
                                onAllTap: () {
                                  _commonHelper?.startActivity(ServiceTab(
                                    serviceContinent:
                                        _searchList[index].continent.toString(),
                                  ));
                                },
                                isCount: true,
                                isHeight: true,
                                isWidth: true,
                                padding: EdgeInsets.only(top: 10.0),
                              );
                            }),
                      )
                    : _noCarnivalWarning()),
          ),
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

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      leadingTap: () {
        Scaffold.of(context).openDrawer();
      },
      appBarType: StringHelper.drawerWithSearchbar,
      isMore: true,
      onSearchBarTextChanged: _onSearchTextChanged,
      hintText: StringHelper.search,
    );
  }

  Widget _cardContinent(int index) {
    return GestureDetector(
      onTap: () {
        _commonHelper?.startActivity(ServiceTab(
          serviceContinent: _searchList[index].continent.toString(),
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
                    imageUrl: _searchList[index].image.toString(),
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
                    _searchList[index].carnivalCount.toString(),
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
                    _searchList[index].continent.toString(),
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
        child: Text(StringHelper.noDataFound,
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

  Future<Null> _refresh() async {
    _showProgress();

    _aList.clear();
    _searchList.clear();
    _getCarnivalContinentList();
  }

  void _getCarnivalContinentList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _serviceBloc
              ?.getServiceContinentList(token.toString())
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

  _onSearchTextChanged(String searchQuery) {
    _searchList.clear();

    if (searchQuery.isEmpty) {
      _searchList.addAll(_aList);

      setState(() {});

      return;
    }

    _aList.forEach((carnivalDetail) {
      if (carnivalDetail.continent!
          .toUpperCase()
          .contains(searchQuery.toUpperCase())) {
        _searchList.add(carnivalDetail);
      }
    });

    setState(() {});
  }

  void updateData(String distanceValue) {
    _showProgress();

    _aList.clear();

    _searchList.clear();

    // _getCarnivalList(distanceValue);
  }

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }
//============================================================
// ** Firebase Function **
//============================================================
}
