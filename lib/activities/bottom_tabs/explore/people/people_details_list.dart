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
import 'package:solomas/model/get_people_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../../../helpers/progress_indicator.dart';
import '../../../../resources_helper/common_widget.dart';
import '../../../../resources_helper/screen_area/scaffold.dart';
import '../../../../resources_helper/text_styles.dart';
import '../../../common_helpers/app_bar.dart';
import '../../../common_helpers/festival_card.dart';

class PeopleDetailsList extends StatefulWidget {
  final dynamic Function(String)? onExploreData;
  const PeopleDetailsList({Key? key, this.onExploreData}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PeopleDetailsListState();
  }
}

class PeopleDetailsListState extends State<PeopleDetailsList> {
  //============================================================
// ** Properties **
//============================================================
  bool isVisible = false;
  double appBarHeight = 120;
  CommonHelper? _commonHelper;

  GetNearbyPeoplesBloc? _nearbyPeoples;

  String? authToken;

  List<GroupDataList> _aList = [];
  String distanceValue = '10';

  List<GroupDataList> _searchList = [];

  bool _isShowProgress = false;
  bool _progressShow = false;
  RangeValues _currentRangeValues = const RangeValues(10, 10);

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

    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isVisible ? 185 : 140),
        // preferredSize: Size.fromHeight(isVisible ? 165 : 120),
        child: _appBar(),
      ),
      body: Stack(children: [
        StreamBuilder(
            stream: _nearbyPeoples?.peopleList,
            builder: (context, AsyncSnapshot<GetPeoplesModel> snapshot) {
              if (snapshot.hasData) {
                if (_aList.isEmpty) {
                  _aList = snapshot.data?.data ?? [];
                  _searchList.clear();
                  _searchList.addAll(_aList);
                }

                return _peopleContinents();
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
    _nearbyPeoples?.dispose();

    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _appBar() {
    return SoloAppBar(
      onSearchBarTextChanged: widget.onExploreData,
      appBarType: StringHelper.searchBarWithTrilling,
      appbarTitle: StringHelper.yourNearPeople,
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

  Widget _peopleContinents() {
    return Stack(
      children: [
        Container(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: _searchList.isNotEmpty
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: _commonHelper?.screenWidth * 0.4,
                          // maxCrossAxisExtent: _commonHelper?.screenWidth * 0.5,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.4 / 3,
                        ),
                        itemCount: _searchList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return listCard(context, index,
                              countryTitle:
                                  _searchList[index].fullName.toString(),
                              image: _searchList[index].profilePic.toString(),
                              onAllTap: () {
                            _commonHelper?.startActivity(UserProfileActivity(
                                userId: _searchList[index].userId.toString()));
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
        child: Text("No people found near your location",
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

  void _getDistanceData(String distanceValue) {
    updateData(distanceValue);
  }

//============================================================
// ** Firebase Function **
//============================================================
}

class SliderThumbShape extends SliderComponentShape {
  /// Create a slider thumb that draws a circle.

  const SliderThumbShape({
    this.enabledThumbRadius = 8.0,
    this.disabledThumbRadius = 0,
    this.elevation = 1.0,
    this.pressedElevation = 6.0,
  });

  /// The preferred radius of the round thumb shape when the slider is enabled.
  ///
  /// If it is not provided, then the material default of 10 is used.
  final double enabledThumbRadius;

  /// The preferred radius of the round thumb shape when the slider is disabled.
  ///
  /// If no disabledRadius is provided, then it is equal to the
  /// [enabledThumbRadius]
  final double disabledThumbRadius;
  double get _disabledThumbRadius => disabledThumbRadius ?? enabledThumbRadius;

  /// The resting elevation adds shadow to the unpressed thumb.
  ///
  /// The default is 1.
  ///
  /// Use 0 for no shadow. The higher the value, the larger the shadow. For
  /// example, a value of 12 will create a very large shadow.
  ///
  final double elevation;

  /// The pressed elevation adds shadow to the pressed thumb.
  ///
  /// The default is 6.
  ///
  /// Use 0 for no shadow. The higher the value, the larger the shadow. For
  /// example, a value of 12 will create a very large shadow.
  final double pressedElevation;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
        isEnabled == true ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    assert(context != null);
    assert(center != null);
    assert(enableAnimation != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);
    assert(!sizeWithOverflow.isEmpty);

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );

    final double radius = radiusTween.evaluate(enableAnimation);

    final Tween<double> elevationTween = Tween<double>(
      begin: elevation,
      end: pressedElevation,
    );

    final double evaluatedElevation =
        elevationTween.evaluate(activationAnimation);

    {
      final Path path = Path()
        ..addArc(
            Rect.fromCenter(
                center: center, width: 1 * radius, height: 1 * radius),
            0,
            2);

      Paint paint = Paint()..color = Colors.blue;
      paint.strokeWidth = 5;
      paint.style = PaintingStyle.stroke;
      canvas.drawCircle(
        center,
        radius,
        paint,
      );
      {
        Paint paint = Paint()..color = Colors.white;
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
          center,
          radius,
          paint,
        );
      }
    }
  }
}
