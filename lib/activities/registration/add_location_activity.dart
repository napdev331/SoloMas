import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solomas/activities/home_activity.dart';
import 'package:solomas/blocs/home/update_user_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:solomas/widgets/btn_widget.dart';

import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../common_helpers/app_bar.dart';

class AddLocationActivity extends StatefulWidget {
  final Map<String, dynamic>? data;

  final bool isSocialLogin, isHome;

  AddLocationActivity(
      {this.data, this.isSocialLogin = false, this.isHome = false});

  @override
  State<StatefulWidget> createState() {
    return _LocationState();
  }
}

class _LocationState extends State<AddLocationActivity> {
  Completer<GoogleMapController> _mapController = Completer();

  int _markerIdCounter = 0;

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Constants.API_KEY);

  static String? _currentAddress = '', zipCode, _selectedAddress = '';

  double lat = 0.0, long = 0.0;

  Position? _currentLocation;

  Marker? _locMarker;

  bool _isShowAlert = false, _isShowProgress = false;

  CommonHelper? commonHelper;

  UpdateUserBloc? _updateUserBloc;

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

  @override
  void initState() {
    super.initState();

    _checkPermission();

    //_getCurrentLocation();

    _updateUserBloc = UpdateUserBloc();
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);

    if (_currentLocation.toString().isNotEmpty) {
      _getAddress(lat, long);

      _animateCamera(LatLng(lat, long));

      _updateMarker(LatLng(lat, long));
    }
  }

  void _updateMarker(position) {
    MarkerId markerId = MarkerId(_markerIdVal());

    Marker marker = Marker(
      icon: BitmapDescriptor.defaultMarker,
      markerId: markerId,
      position: position,
      draggable: true,
    );

    setState(() {
      _markers[markerId] = marker;
    });
  }

  void _onSelectBtClick() {
    var locationDetail = HashMap<String, Object>();

    var location = json.encode({'lat': lat, 'lng': long});

    locationDetail['location'] = location;

    locationDetail['locationName'] =
        _currentAddress.toString(); // _selectedAddress.toString();

    Navigator.pop(context, locationDetail);
  }

  void _onChangeLocationTap() {
    if (_selectedAddress!.isEmpty) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => commonHelper!.successBottomSheet(
              "Address", "Please enter a valid address", false));

      return;
    }

    PrefHelper.getAuthToken().then((authToken) {
      if (authToken != null) {
        commonHelper?.isInternetAvailable().then((available) {
          if (available) {
            _showProgress();

            var location = json.encode({'lat': lat, 'lng': long});

            Map<String, dynamic> locationMap = json.decode(location);

            var body = json.encode(
                {"location": locationMap, "locationName": _selectedAddress});

            _updateUserBloc
                ?.updateUser(authToken, body.toString())
                .then((onSuccess) {
              PrefHelper.setUserLocationAddress(_selectedAddress.toString());

              _hideProgress();

              commonHelper?.startActivityAndCloseOther(HomeActivity());
            }).catchError((error) {
              Navigator.pop(context);

              _hideProgress();
            });
          } else {
            commonHelper?.showAlert(
                StringHelper.noInternetTitle, StringHelper.noInternetMsg);
          }
        });
      }
    });
  }

  _getAddress(double latitude, double longitude) async {
    // var coordinates = Coordinates(latitude, longitude);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude); // todo AVI
    // var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    setState(() {
      _currentAddress = placemarks[0].toString();
    });
    var city = "";

    var administrativeArea2 = "";

    if (placemarks.first.administrativeArea?.isNotEmpty == true) {
      administrativeArea2 = "${placemarks.first.administrativeArea}";
    }

    var subLocality = "";

    if (placemarks.first.subLocality?.isNotEmpty == true) {
      subLocality = "${placemarks.first.subLocality}, ";
    }

    var locality = "";

    if (placemarks.first.locality?.isNotEmpty == true) {
      locality = "${placemarks.first.locality}, ";
    }

    if (placemarks.first.locality == null ||
        placemarks.first.locality!.isEmpty) {
      if (placemarks.first.subLocality == null) {
        city = placemarks.first.name.toString();
      } else {
        city = subLocality;
      }
      // city = addresses.first.subLocality;
    } else {
      city = locality;
    }

    if (placemarks.first.administrativeArea == null) {
      _selectedAddress = city + ", ${placemarks.first.name}}";
    } else {
      _selectedAddress = city + administrativeArea2;
    }

    //_selectedAddress = city + ", ${addresses.first.adminArea}";

    // _currentAddress = placemarks.first.addressLine;

    var administrativeArea = "";

    if (placemarks.first.administrativeArea?.isNotEmpty == true) {
      administrativeArea = "${placemarks.first.administrativeArea}, ";
    }

    var postalCode = "";

    if (placemarks.first.postalCode?.isNotEmpty == true) {
      postalCode = "${placemarks.first.postalCode}, ";
    }

    var country = "";

    if (placemarks.first.country?.isNotEmpty == true) {
      country = "${placemarks.first.isoCountryCode}";
    }

    _currentAddress =
        subLocality + locality + postalCode + administrativeArea + country;

    zipCode = placemarks.first.postalCode;

    lat = latitude;

    long = longitude;
    setState(() {});
  }

  _alertLocationPermission() {
    var alert = AlertDialog(
      title: Text('Access to location denied'),
      content: Text('Allow access to the location services for this App'
          ' using the device settings.'),
      actions: [
        TextButton(
          child: Text("SETTINGS"),
          onPressed: () {
            AppSettings.openAppSettings();

            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  _alertTurnOnGps() {
    if (!_isShowAlert) {
      _isShowAlert = true;

      var alert = AlertDialog(
        title: Text('Enable Gps'),
        content: Text('Enable GPS in your setting to use this application.'),
        actions: [
          TextButton(
            child: Text("SETTINGS"),
            onPressed: () {
              AppSettings.openLocationSettings();

              //Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("OK"),
            onPressed: () {
              //Navigator.of(context).pop();
            },
          ),
        ],
      );

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          });
    }
  }

  _animateCamera(position) {
    Future.delayed(Duration(seconds: 1), () async {
      GoogleMapController controller = await _mapController.future;

      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 10.0,
          ),
        ),
      );
    });
  }

  _showSearchBar() async {
    var predict = await PlacesAutocomplete.show(
      context: context,
      apiKey: Constants.API_KEY,
      radius: 10000000000,
      mode: Mode.overlay,
      types: [],
      language: "en",
      strictbounds: false,
      components: [],
    );

    displayPrediction(predict);
  }

  Future<bool> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = position;

      lat = position.latitude;

      long = position.longitude;
    });

    _getAddress(_currentLocation!.latitude, _currentLocation!.longitude);

    _animateCamera(LatLng(lat, long));

    _updateMarker(LatLng(lat, long));

    return true;
  }

  Future<PermissionStatus> _checkPermission() async {
    var requestPermission = await Permission.location.request();

    if (requestPermission.isGranted) {
      _getCurrentLocation();
    }

    return requestPermission;
  }

  Future<Null> displayPrediction(prediction) async {
    if (prediction != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(prediction.placeId);

      double lati = detail.result.geometry!.location.lat;

      double lng = detail.result.geometry!.location.lng;
      //
      // final coordinates = Coordinates(lati, lng);
      //
      // var addresses =
      //     await Geocoder.local.findAddressesFromCoordinates(coordinates);
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      setState(() {
        _currentAddress = placemarks[0].toString();
      });
      print("addresses1:" + placemarks.toString());

      var first = placemarks.first;
      print("first:" + first.toString());

      var city = "";

      var administrativeArea2 = "";

      if (placemarks.first.administrativeArea?.isNotEmpty == true) {
        administrativeArea2 = "${placemarks.first.administrativeArea}";
      }

      var subLocality = "";

      if (placemarks.first.subLocality?.isNotEmpty == true) {
        subLocality = "${placemarks.first.subLocality}, ";
      }

      if (placemarks.first.locality == null ||
          placemarks.first.locality!.isEmpty) {
        if (placemarks.first.subLocality == null) {
          city = placemarks.first.name.toString();
        } else {
          city = subLocality;
        }
      } else {
        city = placemarks.first.name.toString();
      }

      if (placemarks.first.administrativeArea == null) {
        _selectedAddress = city + ", ${placemarks.first.name}";
      } else {
        _selectedAddress = city + administrativeArea2;
      }

      // _selectedAddress = city + ", ${addresses.first.adminArea}";

      // _currentAddress = first.addressLine;

      var locality = "";

      if (placemarks.first.locality?.isNotEmpty == true) {
        locality = "${placemarks.first.locality}, ";
      }

      var administrativeArea = "";

      if (placemarks.first.administrativeArea?.isNotEmpty == true) {
        administrativeArea = "${placemarks.first.administrativeArea}, ";
      }

      var postalCode = "";

      if (placemarks.first.postalCode?.isNotEmpty == true) {
        postalCode = "${placemarks.first.postalCode}, ";
      }

      var country = "";

      if (placemarks.first.country?.isNotEmpty == true) {
        country = "${placemarks.first.country}";
      }

      _currentAddress =
          subLocality + locality + postalCode + administrativeArea + country;
      print("lat:" + lati.toString() + "long" + lng.toString());

      lat = lati;

      long = lng;

      LatLng position = LatLng(lati, lng);

      _animateCamera(position);

      _updateMarker(position);
    }
  }

  String _markerIdVal({bool increment = false}) {
    String val = 'marker_id_$_markerIdCounter';

    if (increment) _markerIdCounter++;

    return val;
  }

  @override
  Widget build(BuildContext context) {
    commonHelper = CommonHelper(context);

    Widget addressBar() {
      return Text(
        _currentAddress.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: SoloColor.white,
            fontWeight: FontWeight.w500,
            fontSize: Constants.FONT_MEDIUM),
      );
    }

    Widget _googleMap() {
      return Stack(children: [
        Container(
          child: GoogleMap(
            markers: Set<Marker>.of(_markers.values),
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, long),
              zoom: 5.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomGesturesEnabled: true,
            padding: EdgeInsets.only(top: 80.0),
            compassEnabled: true,
            onCameraMove: (CameraPosition position) {
              print("on camera move");
              if (_markers.length > 0) {
                MarkerId markerId = MarkerId(_markerIdVal());

                Marker? marker = _markers[markerId];

                Marker? updatedMarker = marker?.copyWith(
                  positionParam: position.target,
                );
                print("updatedMarker" + updatedMarker.toString());

                setState(() {
                  _locMarker = updatedMarker;

                  _markers[markerId] = updatedMarker as Marker;
                });
              }
            },
            onCameraIdle: () {
              _getAddress(_locMarker!.position.latitude,
                  _locMarker!.position.longitude);
            },
          ),
        ),
        Container(
          padding: EdgeInsets.only(
              left: DimensHelper.smallSides, right: DimensHelper.smallSides),
          alignment: Alignment.center,
          color: SoloColor.pink,
          width: commonHelper?.screenWidth,
          height: commonHelper?.screenHeight * .07,
          child: addressBar(),
        ),
        Container(
          width: 300,
          padding: EdgeInsets.only(
              right: DimensHelper.sidesMargin,
              left: DimensHelper.sidesMargin,
              top: DimensHelper.sidesMargin,
              bottom: DimensHelper.sidesMargin),
          alignment: Alignment.bottomCenter,
          child: ButtonWidget(
            height: commonHelper?.screenHeight,
            width: commonHelper?.screenWidth * .35,
            onPressed: () {
              widget.isHome ? _onChangeLocationTap() : _onSelectBtClick();
            },
            btnText: 'SELECT',
          ),
        ),
        Container(
          padding: EdgeInsets.only(
              right: DimensHelper.sidesMargin,
              top: DimensHelper.sidesMargin,
              bottom: DimensHelper.sidesMargin),
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            backgroundColor: SoloColor.white,
            child: Icon(Icons.my_location, color: SoloColor.spanishGray),
            onPressed: () {
              _getAddress(
                  _currentLocation!.latitude, _currentLocation!.longitude);

              LatLng position = LatLng(
                  _currentLocation!.latitude, _currentLocation!.longitude);

              _animateCamera(position);

              _updateMarker(position);
            },
            heroTag: null,
          ),
        ),
        Align(
          child:
              ProgressBarIndicator(commonHelper?.screenSize, _isShowProgress),
          alignment: FractionalOffset.center,
        )
      ]);
    }

    return SoloScaffold(
      backGroundColor: SoloColor.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: _appBar(context),
        ),
      ),
      body: _googleMap(),
    );
  }

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.addLocation,
      iconUrl: IconsHelper.ic_search,
      iconOnTap: () {
        _showSearchBar();
      },
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

  // AppBar _appBar(BuildContext context) {
  //   return AppBar(
  //       elevation: 0,
  //       backgroundColor: SoloColor.blue,
  //       automaticallyImplyLeading: false,
  //       centerTitle: true,
  //       title: Stack(
  //         children: [
  //           Visibility(
  //             visible: !widget.isHome,
  //             child: GestureDetector(
  //               onTap: () {
  //                 Navigator.pop(context, null);
  //               },
  //               child: Container(
  //                 width: 25,
  //                 height: 25,
  //                 alignment: Alignment.centerLeft,
  //                 child: Image.asset('images/back_arrow.png'),
  //               ),
  //             ),
  //           ),
  //           Container(
  //             alignment: Alignment.center,
  //             child: Text(
  //                 widget.isHome
  //                     ? 'Update Address'.toUpperCase()
  //                     : 'Add Location'.toUpperCase(),
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                     color: Colors.white,
  //                     fontFamily: 'Montserrat',
  //                     fontSize: Constants.FONT_APP_TITLE)),
  //           )
  //         ],
  //       ),
  //       actions: [
  //         IconButton(
  //           tooltip: 'Search',
  //           icon: const Icon(Icons.search, color: Colors.white),
  //           onPressed: () {
  //             _showSearchBar();
  //           },
  //         ),
  //       ]);
  // }

  @override
  void dispose() {
    _updateUserBloc?.dispose();

    super.dispose();
  }
}
