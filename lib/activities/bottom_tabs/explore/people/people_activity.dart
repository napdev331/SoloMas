import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gLocator;
import 'package:geolocator/geolocator.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/blocs/explore/get_nearby_peoples_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/get_people_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../../../resources_helper/common_widget.dart';
import '../../../../resources_helper/screen_area/scaffold.dart';
import '../../../common_helpers/festival_card.dart';
import 'people_details_list.dart';

class PeopleActivity extends StatefulWidget {
  final dynamic Function(String)? onExploreData;
  const PeopleActivity({Key? key, this.onExploreData}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PeopleState();
  }
}

class PeopleState extends State<PeopleActivity> {
  //============================================================
// ** Properties **
//============================================================
  CommonHelper? _commonHelper;
  GetNearbyPeoplesBloc? _nearbyPeoples;
  String? authToken;
  List<GroupDataList> _aList = [];
  List<GroupDataList> _searchList = [];
  bool _isShowProgress = false;
  GlobalKey<PeopleDetailsListState> _PeopleDetailsListState = GlobalKey();
//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();

    _nearbyPeoples = GetNearbyPeoplesBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getNearbyPeoples(""));
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      body: StreamBuilder(
          stream: _nearbyPeoples?.peopleList,
          builder: (context, AsyncSnapshot<GetPeoplesModel> snapshot) {
            if (snapshot.hasData) {
              if (_aList.isEmpty) {
                _aList = snapshot.data?.data ?? [];
                _searchList.clear();
                _searchList.addAll(_aList);
              }

              return listExplore(
                context,
                isData: _searchList.isNotEmpty ? true : false,
                title: StringHelper.peopleUpperCamelcase,
                itemCount: _searchList.length,
                itemListBuilder: (BuildContext context, int index) {
                  return listCard(context, index,
                      countryTitle:
                          _searchList[index].fullName.toString().toUpperCase(),
                      image: _searchList[index].profilePic.toString(),
                      onAllTap: () {
                    _commonHelper?.startActivity(UserProfileActivity(
                        userId: _searchList[index].userId.toString()));
                  });
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (
                      context,
                    ) =>
                            PeopleDetailsList(
                              key: _PeopleDetailsListState,
                              onExploreData: _onSearchTextChanged,
                            )
                        // ExploreAllScreen(
                        //   onExploreData: widget.onExploreData,
                        //   itemListBuilder:
                        //       (BuildContext context, int index) {
                        //     return listCard(context, index,
                        //         countryTitle:
                        //             _searchList[index].fullName.toString(),
                        //         image: _searchList[index]
                        //             .profilePic
                        //             .toString(), onAllTap: () {
                        //       _commonHelper?.startActivity(
                        //           UserProfileActivity(
                        //               userId: _searchList[index]
                        //                   .userId
                        //                   .toString()));
                        //     },
                        //         padding: EdgeInsets.only(top: 10.0),
                        //         isWidth: true);
                        //   },
                        //   itemListCount: _searchList?.length,
                        //   headerName: StringHelper.peopleUpperCamelcase,
                        // )
                        ),
                  );
                },
                warningText: StringHelper.peopleWarning,
              );
            } else if (snapshot.hasError) {
              return Container();
            }

            return Container();
          }),
    );
  }

  @override
  void dispose() {
    _nearbyPeoples?.dispose();

    super.dispose();
  }

  //============================================================
// ** Main Widgets **
//============================================================

//============================================================
// ** Helper Widgets **
//============================================================
  Widget profileImage(int index) {
    return Container(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              _commonHelper?.startActivity(UserProfileActivity(
                  userId: _searchList[index].userId.toString()));
            },
            child: Align(
              alignment: Alignment.center,
              child: ClipOval(
                  child: CachedNetworkImage(
                fit: BoxFit.cover,
                height: 90,
                width: 90,
                placeholder: (context, url) => imagePlaceHolder(),
                imageUrl: _searchList[index].profilePic.toString(),
                errorWidget: (context, url, error) => imagePlaceHolder(),
              )),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                  height: 30,
                  width: 30,
                  margin: EdgeInsets.only(
                      bottom: DimensHelper.sidesMarginDouble,
                      right: DimensHelper.halfSides),
                  child: Image.asset('images/usa_flag.png')),
            ),
          )
        ],
      ),
    );
  }

  Widget _noPeopleWarning() {
    return Center(
      child: Container(
        child: Text(
          "No people found near your location.",
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
            ? GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                padding: EdgeInsets.all(DimensHelper.halfSides),
                children: List<Widget>.generate(_searchList.length, (index) {
                  return profileImage(index);
                }))
            : _noPeopleWarning(),
        Align(
          child:
              ProgressBarIndicator(_commonHelper?.screenSize, _isShowProgress),
          alignment: FractionalOffset.center,
        )
      ],
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

  Future<gLocator.Position> locateUser() async {
    return gLocator.Geolocator.getCurrentPosition(
        desiredAccuracy: gLocator.LocationAccuracy.high);
  }

  void _getNearbyPeoples(String distance) async {
    bool serviceEnabled;

    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      _commonHelper?.showToast('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      _commonHelper?.showToast(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _commonHelper?.showToast(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    var currentLocation = await locateUser();

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _nearbyPeoples
              ?.getPeoplesList(token.toString(), currentLocation.latitude,
                  currentLocation.longitude, distance)
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
      if (carnivalDetail.fullName!
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

    _getNearbyPeoples(distanceValue);
  }

  _onSearchTextChanged(String text) async {
    _PeopleDetailsListState.currentState?.searchData(text);
  }

//============================================================
// ** Firebase Function **
//============================================================
}
