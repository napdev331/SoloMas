import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:geocoder/geocoder.dart';
// import 'package:geocoder/model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/resources_helper/colors.dart';

import '../../resources_helper/dimens.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import 'location_data_params.dart';

class SearchPlaces extends StatefulWidget {
  @override
  StatePlacesState createState() => StatePlacesState();
  bool isAddress = false;

  SearchPlaces({Key? key, this.isAddress = false}) : super(key: key);
}

class StatePlacesState extends State<SearchPlaces> {
  GooglePlace? googlePlace;

  List<AutocompletePrediction> predictions = [];

  var placesController = TextEditingController();

  var locationString = "";
  int count = 0;
  bool isLocationEnable = false;
  bool getCurrentLocation = false;
  String currentAddress = "";

  double? lat;

  double? lng;

  String? currentLocation;

  CommonHelper? _commonHelper;

  @override
  void initState() {
    String apiKey = Constants.API_KEY;
    googlePlace = GooglePlace(apiKey);
    super.initState();
    locationString = "_stringHelper.selectCurrentLocation";

    PrefHelper.getLat().then((onValue) {
      setState(() {
        lat = onValue;
      });
    });

    PrefHelper.getLng().then((onValue) {
      setState(() {
        lng = onValue;
      });
    });

    PrefHelper.getCurrentAddress().then((onValue) {
      setState(() {
        if (onValue != null) {
          currentLocation = onValue;
        } else {
          currentLocation = " ";
        }
      });
    });
    Future.delayed(Duration(milliseconds: 300), () {
      _determinePosition(count);
    });
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return Stack(
      children: [
        SoloScaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(65),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: _commonHelper?.screenWidth * 0.15,
                        width: _commonHelper?.screenWidth * 0.089,
                        child: SvgPicture.asset(
                          IconsHelper.backwardBackArrow,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Container(
                      height: 40,
                      width: _commonHelper?.screenWidth * 0.8,
                      decoration: BoxDecoration(
                          color: SoloColor.cultured,
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.only(left: DimensHelper.sidesMargin),
                      child: TextFormField(
                        controller: placesController,
                        onChanged: _onSearchTextChanged,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          fillColor: SoloColor.cultured,
                          prefixIcon: Icon(Icons.search,
                              size: 25, color: SoloColor.jet),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          hintText: 'Search location...',
                          hintStyle: SoloStyle.lightGrey200W500Top,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                                width: 0.5, color: SoloColor.gainsBoro),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                  color: SoloColor.gainsBoro, width: 0.5)),
                        ),
                        // decoration: InputDecoration.collapsed(
                        //     hintText: 'Search here...',
                        //     hintStyle:
                        //         TextStyle(fontSize: Constants.FONT_MEDIUM),
                        // ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            // appBar: PreferredSize(
            //   preferredSize: Size(_commonHelper?.screenWidth, 100),
            //   child: Container(
            //     padding: EdgeInsets.only(top: DimensHelper.btnTopMargin),
            //     decoration: BoxDecoration(color: SoloColor.blue),
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: <Widget>[
            //         GestureDetector(
            //           onTap: () {
            //             _commonHelper?.closeActivity();
            //           },
            //           child: Container(
            //             margin: EdgeInsets.only(
            //               left: DimensHelper.sideDoubleMargin,
            //             ),
            //             child: Image.asset('images/back_arrow.png',
            //                 height: 25, width: 25),
            //           ),
            //         ),
            //         Container(
            //           margin: EdgeInsets.only(
            //             left: DimensHelper.sidesMargin,
            //             right: DimensHelper.sidesMargin,
            //           ),
            //           child: Card(
            //             shape: RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.all(Radius.circular(
            //                     DimensHelper.sidesMarginDouble))),
            //             child: Row(
            //               children: [
            //                 Expanded(
            //                     child: Container(
            //                   padding:
            //                       EdgeInsets.all(DimensHelper.searchBarMargin),
            //                   margin: EdgeInsets.only(
            //                       left: DimensHelper.sidesMargin),
            //                   child: TextFormField(
            //                     controller: placesController,
            //                     onChanged: _onSearchTextChanged,
            //                     keyboardType: TextInputType.text,
            //                     textInputAction: TextInputAction.search,
            //                     decoration: InputDecoration.collapsed(
            //                         hintText: 'Search here...',
            //                         hintStyle: TextStyle(
            //                             fontSize: Constants.FONT_MEDIUM)),
            //                   ),
            //                 )),
            //                 Container(
            //                   padding: EdgeInsets.only(
            //                       left: DimensHelper.halfSides,
            //                       right: DimensHelper.sidesMargin,
            //                       top: DimensHelper.halfSides,
            //                       bottom: DimensHelper.halfSides),
            //                   child: Image.asset(
            //                     'images/ic_lg_bag.png',
            //                     height: 20,
            //                     width: 20,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                color: SoloColor.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    isLocationEnable == false
                        ? GestureDetector(
                            onTap: () async {
                              _determinePosition(count);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Icon(
                                  Icons.my_location_rounded,
                                  color: SoloColor.black,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  currentLocation.toString(),
                                  style: TextStyle(
                                    color: SoloColor.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : currentAddress.trim().isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {});
                                  print("CURRENT LOCATION: " +
                                      currentLocation.toString());

                                  LocationDataParams data = LocationDataParams(
                                      lat: lat,
                                      lng: lng,
                                      placeName: currentLocation);

                                  Navigator.pop(context, data);
                                },
                                child: setLcoationValue(currentAddress),
                              )
                            : FutureBuilder<String>(
                                future: setCurrentAddress(),
                                // function where you call your api
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  // AsyncSnapshot<Your object type>
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return setLcoationValue(
                                        "Detect Current Location");
                                  } else if (snapshot.hasError) {
                                    return setLcoationValue(
                                        "Unable to Detect Your Current Location");
                                  } else if (snapshot.hasData &&
                                      snapshot.data != null &&
                                      snapshot.data!.trim().isNotEmpty) {
                                    currentAddress = snapshot.data.toString();
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {});
                                        print("CURRENT LOCATION: " +
                                            currentLocation.toString());
                                        LocationDataParams data =
                                            LocationDataParams(
                                          lat: lat,
                                          lng: lng,
                                          placeName: currentLocation,
                                        );
                                        Navigator.pop(context, data);
                                      },
                                      child: setLcoationValue(
                                          snapshot.data.toString()),
                                    );
                                  } else {
                                    return setLcoationValue(
                                        "Unable to Detect Your Current Location");
                                  }
                                },
                              ),
                    SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: SoloColor.black,
                            ),
                            title: Text(predictions[index].description ?? ""),
                            onTap: () {
                              getDetails(predictions[index].placeId ?? "");
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace?.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        if (placesController.text.isEmpty) {
          predictions = [];
        } else {
          predictions = result.predictions ?? [];
        }
      });
    }
  }

  void getDetails(String placeId) async {
    var result = await googlePlace?.details.get(placeId);
    if (result != null && result.result != null && mounted) {
      double lat = result.result?.geometry?.location?.lat ?? 0.0;
      double lng = result.result?.geometry?.location?.lng ?? 0.0;
      String formattedAddress = result.result?.formattedAddress ?? "";
      LocationDataParams data =
          LocationDataParams(lat: lat, lng: lng, placeName: formattedAddress);
      Navigator.pop(context, data);
    }
  }

  _determinePosition(int count) async {
    bool serviceEnabled;
    var permission = await Geolocator.checkPermission();
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showGpsSettings(context);
    } else if (permission == LocationPermission.denied) {
      ++count;
      if (count < 3) {
        await Geolocator.requestPermission();
        _determinePosition(count);
      } else {
        showPermmisionDialog(context);
      }
    } else if (permission == LocationPermission.deniedForever) {
      showPermmisionDialog(context);
    } else {
      setState(() {
        isLocationEnable = true;
      });
    }
  }

  Future<String> setCurrentAddress() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (position != null) {
        if (position.latitude != 0.0 && position.longitude != 0.0) {
          lat = position.latitude;
          lng = position.longitude;

          PrefHelper.setLat(position.latitude);
          PrefHelper.setLng(position.longitude);

          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          if (placemarks != null &&
              placemarks.first != null &&
              placemarks.first.name != null) {
            var address = placemarks.first;
            var updatedAddress = address.subLocality.toString() +
                ", " +
                address.locality.toString() +
                ", " +
                address.postalCode.toString() +
                ", " +
                address.administrativeArea.toString() +
                ", " +
                address.country.toString();

            PrefHelper.setCurrentAddress(updatedAddress);
            currentLocation = updatedAddress;
            return updatedAddress;
          } else {
            return "";
          }
        } else {
          return "";
        }
      } else {
        return "";
      }
    } else {
      return "";
    }
  }

  Widget setLcoationValue(String value) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Icon(
            Icons.my_location_rounded,
            color: SoloColor.black,
          ),
          SizedBox(
            width: 15,
          ),
          Flexible(
              child: Text(
            value,
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: SoloColor.black,
              fontSize: 14,
            ),
          )),
          SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }

  Future<dynamic> showGpsSettings(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Please enable location services",
          ),
          actions: [
            TextButton(
              child: Text("ok"),
              onPressed: () {
                Navigator.pop(context);
                AppSettings.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> showPermmisionDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Permission Required for your current location detection",
          ),
          actions: [
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
                AppSettings.openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  _onSearchTextChanged(String value) async {
    if (value.isNotEmpty) {
      autoCompleteSearch(value);
    } else {
      if (predictions.isNotEmpty && mounted) {
        setState(() {
          predictions = [];
        });
      }
    }
  }
}
