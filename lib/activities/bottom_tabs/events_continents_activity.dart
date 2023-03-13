import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/bottom_tabs/events_tab.dart';
import 'package:solomas/blocs/event_details/event_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/events_continent_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';
import '../common_helpers/festival_card.dart';
import '../services/search_autocomplete.dart';

class EventsContinentActivity extends StatefulWidget {
  final String? eventContinent;
  const EventsContinentActivity({key, this.eventContinent}) : super(key: key);

  @override
  EventsContinentActivityState createState() => EventsContinentActivityState();
}

class EventsContinentActivityState extends State<EventsContinentActivity> {
//============================================================
// ** Properties **
//============================================================
  bool isVisible = false, _progressShow = false;
  CommonHelper? _commonHelper;
  List<EventList> _aList = [];
  List<EventList> _searchList = [];
  Map<String, dynamic>? locationMap1;
  String locationValue = "Choose Location";
  var locationMap;
  String? location;
  bool isLocation = false;
  var lastInputValue = "";
  var selectedValue = 'Band Launch';
  var lat, lng;
  var _addressController = TextEditingController();
  String? authToken, mineUserId = "", mineProfilePic = "";
  EventBloc? _eventBloc;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

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

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _eventBloc = EventBloc();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _getCarnivalContinentList());
  }

  Future<Null> _refresh() async {
    _showProgress();

    _aList.clear();
    _searchList.clear();
    _getCarnivalContinentList();
  }

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
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: _commonHelper?.screenWidth * 0.4,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.4 / 3,
                          // childAspectRatio: 3 / 3,
                        ),
                        itemCount: _searchList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _cardContinent(index);
                        })
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

  Widget _cardContinent(int index) {
    return GestureDetector(
      onTap: () {
        _commonHelper?.startActivity(EventsTab(
          eventContinent: _searchList[index].continent.toString(),
        ));
      },
      child: listCard(context, index,
          countryTitle: _searchList[index].continent!.toUpperCase(),
          image: _searchList[index].image.toString(),
          // countList: _searchList[index].carnivalCount.toString(),
          isCount: false, onAllTap: () {
        _commonHelper?.startActivity(EventsTab(
          eventContinent: _searchList[index].continent.toString(),
        ));
      }, padding: EdgeInsets.only(top: 10.0), isWidth: true, isHeight: true),
      // Container(
      //   margin: EdgeInsets.all(DimensHelper.sidesMargin),
      //   child: ClipRRect(
      //     borderRadius: BorderRadius.circular(DimensHelper.sidesMargin),
      //     child: Stack(
      //       children: [
      //         Stack(
      //           fit: StackFit.expand,
      //           children: [
      //             CachedNetworkImage(
      //               height: _commonHelper?.screenHeight * .4,
      //               imageUrl: _searchList[index].image.toString(),
      //               fit: BoxFit.cover,
      //                placeholder: (context, url) => imagePlaceHolder(),
      //             errorWidget: (context, url, error) => imagePlaceHolder()
      //             ),
      //           ],
      //         ),
      //         Positioned(
      //           right: 10,
      //           top: 10,
      //           child: Container(
      //             height: 40,
      //             child: Center(
      //                 child: Text(
      //               _searchList[index].carnivalCount.toString(),
      //               style: TextStyle(color: SoloColor.white),
      //             )),
      //           ),
      //         ),
      //         Positioned(
      //           bottom: 0,
      //           left: 0,
      //           right: 0,
      //           child: Container(
      //             color: SoloColor.blue.withOpacity(0.90),
      //             height: 40,
      //             child: Center(
      //                 child: Text(
      //               _searchList[index].continent.toString(),
      //               style: TextStyle(color: SoloColor.white),
      //             )),
      //           ),
      //         )
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  Widget _noCarnivalWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text(StringHelper.noContinent,
            style: SoloStyle.spanishGrayNormalFontMedium));
  }

  void _getCarnivalContinentList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _eventBloc?.getEventsContinentList(token.toString()).then((onValue) {
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
      body: _mainBody(),
    );
  }

//============================================================
// ** Main Widgets **
//============================================================.

  Widget _mainBody() {
    return StreamBuilder(
        stream: _eventBloc?.eventContinentList,
        builder: (context, AsyncSnapshot<EventsContinentModel> snapshot) {
          if (snapshot.hasData) {
            if (_aList.isEmpty) {
              _aList = snapshot.data?.data?.eventList ?? [];
              _searchList.addAll(_aList);
            }
            return _carnivalContinents();
          } else if (snapshot.hasError) {
            return _carnivalContinents();
          }

          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
        });
  }

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      locationOnTap: () {
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
            getEvents(
              lastInputValue == null ? "" : lastInputValue,
              lat.toString(),
              lng.toString(),
              widget.eventContinent.toString(),
            );
            // locationDetail = value;

            //         _addressController.text = locationDetail['locationName'];
          }
        });
      },
      isLocation: true,
      locationText: locationValue,
      appBarType: StringHelper.drawerWithSearchbar,
      onSearchBarTextChanged: _onSearchTextChanged,
      hintText: StringHelper.search,
      leadingTap: () {
        Scaffold.of(context).openDrawer();
      },
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

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

  void getEvents(String text, String lat, String lng, String eventContinent) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _showProgress();
          _eventBloc
              ?.getEvent(token.toString(), text, lat, lng, eventContinent)
              .then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              /* if (onValue.data.eventList.isNotEmpty) {
                aList = onValue.data.eventList;
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
}
