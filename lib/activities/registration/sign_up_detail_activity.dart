import 'dart:collection';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:solomas/blocs/login/login_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/space.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../../widgets/btn_widget.dart';
import '../../widgets/text_field_widget.dart';
import 'add_location_activity.dart';

class SignUpDetailActivity extends StatefulWidget {
  final Map<String, dynamic>? socialBody;

  SignUpDetailActivity({this.socialBody});

  @override
  _SignUpDetailActivityState createState() => _SignUpDetailActivityState();
}

class _SignUpDetailActivityState extends State<SignUpDetailActivity> {
//============================================================
// ** Properties **
//============================================================
  bool _progressShow = false;
  var _ageController = TextEditingController(),
      _referralController = TextEditingController(),
      _addressController = TextEditingController();
  var _referralFocusNode = FocusNode();
  int userAge = 0;
  DateTime selectedDate = DateTime.now();
  CommonHelper? _commonHelper;
  HashMap<String, Object>? locationDetail;
  LoginBloc? _loginBloc;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();

    _loginBloc = LoginBloc();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      body: mainBody(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget mainBody() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: SoloColor.electricPink,
          ),
        ),
        Container(
          height: _commonHelper?.screenHeight,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (Platform.isIOS)
                  Padding(
                    padding: const EdgeInsets.only(top: 20, right: 10),
                    child: appBackButton(onTap: () {
                      Navigator.pop(context);
                    }),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                      top: Platform.isIOS ? 0 : 45,
                      bottom: Platform.isIOS ? 30 : 45),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(StringHelper.alMostDone.toUpperCase(),
                          style: SoloStyle.whiteW900extraLarge),
                      Align(
                        alignment: Alignment.center,
                        child: Text(StringHelper.alMostContinue,
                            style: SoloStyle.whiteW400medium),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          space(height: 20),
                          Image.asset(
                            IconsHelper.logo_Icon,
                            width: 110,
                            height: 110,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                StringHelper.age,
                                style: SoloStyle.lightGrey200,
                              ),
                              Container(
                                child: GestureDetector(
                                  onTap: () {
                                    _hideKeyBoard();
                                    _selectDate(context);
                                  },
                                  child: AbsorbPointer(
                                    child: TextFieldWidget(
                                        screenWidth: _commonHelper?.screenWidth,
                                        title: 'Your Age',
                                        keyboardType: TextInputType.text,
                                        autoFocus: false,
                                        iconPath: "assets/images/ic_age.png",
                                        editingEnable: true,
                                        editingController: _ageController,
                                        inputAction: TextInputAction.done),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          space(height: 20),
                          GestureDetector(
                            onTap: () {
                              _hideKeyBoard();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddLocationActivity()),
                              ).then((value) {
                                _hideKeyBoard();

                                if (value != null) {
                                  locationDetail = value;
                                  _addressController.text =
                                      locationDetail!['locationName']
                                          .toString();
                                }
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  StringHelper.location,
                                  style: SoloStyle.lightGrey200,
                                ),
                                AbsorbPointer(
                                  child: TextFieldWidget(
                                      screenWidth: _commonHelper?.screenWidth,
                                      title: 'Location',
                                      iconPath: "assets/images/ic_location.png",
                                      keyboardType: TextInputType.text,
                                      autoFocus: false,
                                      maxLines: 2,
                                      editingController: _addressController,
                                      inputAction: TextInputAction.done,
                                      marginTop: 20),
                                ),
                              ],
                            ),
                          ),
                          space(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(StringHelper.referralCode,
                                  style: SoloStyle.lightGrey200),
                              TextFieldWidget(
                                  screenWidth: _commonHelper?.screenWidth,
                                  title: 'Referral Code (Optional)',
                                  focusNode: _referralFocusNode,
                                  keyboardType: TextInputType.text,
                                  autoFocus: false,
                                  inputFormatter: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp('[\\ ]'))
                                  ],
                                  iconPath: "assets/images/ic_referral.png",
                                  editingController: _referralController,
                                  inputAction: TextInputAction.done),
                            ],
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: ButtonWidget(
                              height: _commonHelper?.screenHeight,
                              width: _commonHelper?.screenWidth * .7,
                              onPressed: () {
                                _hideKeyBoard();

                                _onSignUpButtonTap();
                              },
                              btnText: StringHelper.submit.toUpperCase(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
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

//============================================================
// ** Helper Functions **
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

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }

  void _socialLogin() {
    _showProgress();
    _loginBloc
        ?.socialLogin(_commonHelper as CommonHelper, _addSocialSignUpData())
        .then((onSuccess) {
      _hideProgress();
    }).catchError((onError) {
      _hideProgress();
    });
  }

  void _onSignUpButtonTap() {
    if (checkValues()) {
      FocusScope.of(context).unfocus();
      _commonHelper?.isInternetAvailable().then((available) {
        if (available) {
          _socialLogin();
        } else {
          _commonHelper?.showAlert(
              StringHelper.noInternetTitle, StringHelper.noInternetMsg);
        }
      });
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
                primaryColor: SoloColor.blue,
                buttonColor: SoloColor.blue,
                colorScheme: ColorScheme.light(primary: SoloColor.blue),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
                accentColor: SoloColor.blue),
            child: child as Widget,
          );
        },
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;

        int age = _commonHelper!.calculateAge(selectedDate);

        if (age >= 18) {
          userAge = age;

          _ageController.text = DateFormat('MM/dd/yyyy').format(selectedDate);
        } else {
          _commonHelper?.showAlert("Age", "Your age must be 18+");
        }
      });
  }

  bool checkValues() {
    if (_ageController.text.isEmpty) {
      _commonHelper?.showAlert("Age", "Please enter a valid age");

      return false;
    }
    return true;
  }

  String _addSocialSignUpData() {
    var isFacebookLogin, id;
    if (widget.socialBody?['userType'] == "facebook") {
      id = 'facebookId';

      isFacebookLogin = true;
    } else if (widget.socialBody?['userType'] == "google") {
      id = 'googleId';

      isFacebookLogin = false;
    } else {
      id = 'appleId';

      isFacebookLogin = null;
    }
    var body = json.encode({
      "userType": widget.socialBody?['userType'],
      "fullName": widget.socialBody?['fullName'],
      "email": widget.socialBody?['email'],
      "profilePic": widget.socialBody?['profilePic'],
      "deviceToken": widget.socialBody?['deviceToken'],
      'age': userAge,
      id: isFacebookLogin == null
          ? widget.socialBody!['appleId']
          : isFacebookLogin
              ? widget.socialBody!['facebookId']
              : widget.socialBody?['googleId'] ?? []
    });
    var reqBody = jsonDecode(body);
    if (_addressController.text.toString().isNotEmpty) {
      Map<String, dynamic> locationMap =
          json.decode(locationDetail!['location'].toString());

      reqBody['locationName'] = _addressController.text.toString();

      reqBody['location'] = locationMap;
    }
    if (_referralController.text.trim().toString().isNotEmpty) {
      reqBody["referralCode"] = _referralController.text.trim().toString();
    }
    return jsonEncode(reqBody).toString();
  }

  Map<String, dynamic> _addSignUpData() {
    var isFacebookLogin, id;
    if (widget.socialBody?['userType'] == "facebook") {
      id = 'facebookId';

      isFacebookLogin = true;
    } else if (widget.socialBody?['userType'] == "google") {
      id = 'googleId';

      isFacebookLogin = false;
    } else {
      id = 'appleId';

      isFacebookLogin = null;
    }
    Map<String, dynamic> signUpBody = {
      'fullName': widget.socialBody?['fullName'],
      'email': widget.socialBody?['email'],
      'deviceToken': widget.socialBody?['deviceToken'],
      'userType': widget.socialBody?['userType'],
      'age': userAge,
      "profilePic": widget.socialBody?['profilePic'],
      id: isFacebookLogin == null
          ? widget.socialBody!['appleId']
          : isFacebookLogin
              ? widget.socialBody!['facebookId']
              : widget.socialBody?['googleId']
    };
    if (_addressController.text.toString().isNotEmpty) {
      Map<String, dynamic> locationMap =
          json.decode(locationDetail!['location'].toString());

      signUpBody['locationName'] = _addressController.text.toString();

      signUpBody['location'] = locationMap;
    }
    if (_referralController.text.trim().toString().isNotEmpty) {
      signUpBody["referralCode"] = _referralController.text.trim().toString();
    }
    return signUpBody;
  }
// ============================================================
// ** Firebase Helper **
//============================================================

}
