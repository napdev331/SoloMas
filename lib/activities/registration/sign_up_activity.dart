import 'dart:collection';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:solomas/activities/registration/verify_otp_activity.dart';
import 'package:solomas/blocs/login/sign_up_bloc.dart';
import 'package:solomas/helpers/api_constants.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/progress_indicator.dart';
import '../../helpers/space.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../../widgets/btn_widget.dart';
import '../../widgets/text_field_widget.dart';
import 'add_location_activity.dart';
import 'login_activity.dart';

class SignUpActivity extends StatefulWidget {
  @override
  _MyAppStateSignUp createState() => _MyAppStateSignUp();
}

class _MyAppStateSignUp extends State<SignUpActivity> {
//============================================================
// ** Properties **
//============================================================

  var _emailController = TextEditingController(),
      _passwordController = TextEditingController(),
      _ageController = TextEditingController(),
      _fullNameController = TextEditingController(),
      _referralController = TextEditingController(),
      _addressController = TextEditingController();
  var _emailFocusNode = FocusNode(),
      _passwordFocusNode = FocusNode(),
      _referralFocusNode = FocusNode(),
      _fullNameFocusNode = FocusNode();
  DateTime selectedDate = DateTime.now();
  bool _progressShow = false, isLogged = false;
  bool _passwordVisible = true;
  CommonHelper? _commonHelper;
  SignUpBloc? _signUpBloc;
  String? deviceToken, selectedGender = "";
  int? userAge, _radioValue = 0;
  HashMap<String, Object>? locationDetail;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _signUpBloc = SignUpBloc();
    PrefHelper.getDeviceToken().then((token) {
      deviceToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SoloScaffold(
      body: _mainBody(context),
    );
  }

  @override
  void dispose() {
    _signUpBloc?.dispose();
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _mainBody(BuildContext context) {
    return Stack(children: [
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
                  padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                  child: appBackButton(onTap: () {
                    _commonHelper?.startActivity(LoginActivity());
                  }),
                ),
              Padding(
                padding: EdgeInsets.only(
                    top: Platform.isIOS ? 0 : 45,
                    bottom: Platform.isIOS ? 30 : 45),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(StringHelper.letStart,
                        style: SoloStyle.whiteW900extraLarge),
                    Align(
                      alignment: Alignment.center,
                      child: Text(StringHelper.signUpToContinue,
                          style: SoloStyle.whiteW400medium),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20))),
                      child: SingleChildScrollView(
                        reverse: true,
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
                            space(height: 20),
                            StreamBuilder(
                              stream: _signUpBloc?.nameStream,
                              builder: (name, snapshot) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(StringHelper.name,
                                      style: SoloStyle.lightGrey200),
                                  TextFieldWidget(
                                      screenWidth: _commonHelper?.screenWidth,
                                      errorText: snapshot.error as String?,
                                      focusNode: _fullNameFocusNode,
                                      maxLines: 1,
                                      secondFocus: _emailFocusNode,
                                      onChangedValue: _signUpBloc?.nameChanged,
                                      keyboardType: TextInputType.text,
                                      autoFocus: false,
                                      inputFormatter: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp("[a-zA-Z -]")),
                                        LengthLimitingTextInputFormatter(30),
                                      ],
                                      editingController: _fullNameController,
                                      inputAction: TextInputAction.next),
                                ],
                              ),
                            ),
                            space(height: 20),
                            StreamBuilder(
                                stream: _signUpBloc?.emailStream,
                                builder: (email, snapshot) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(StringHelper.email,
                                            style: SoloStyle.lightGrey200),
                                        TextFieldWidget(
                                            screenWidth:
                                                _commonHelper?.screenWidth,
                                            focusNode: _emailFocusNode,
                                            secondFocus: _passwordFocusNode,
                                            errorText:
                                                snapshot.error as String?,
                                            keyboardType: TextInputType.text,
                                            inputFormatter: [
                                              FilteringTextInputFormatter.deny(
                                                  RegExp('[\\ ]'))
                                            ],
                                            onChangedValue:
                                                _signUpBloc?.emailChanged,
                                            autoFocus: false,
                                            editingController: _emailController,
                                            inputAction: TextInputAction.next),
                                      ],
                                    )),
                            space(height: 20),
                            StreamBuilder(
                              stream: _signUpBloc?.passwordStream,
                              builder: (password, snapshot) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(StringHelper.password,
                                      style: SoloStyle.lightGrey200),
                                  TextFieldWidget(
                                      screenWidth: _commonHelper?.screenWidth,
                                      focusNode: _passwordFocusNode,
                                      secondFocus: _referralFocusNode,
                                      hideText: _passwordVisible,
                                      errorText: snapshot.error as String?,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      autoFocus: false,
                                      inputFormatter: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp('[\\ ]'))
                                      ],
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _passwordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: SoloColor.spanishGray,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _passwordVisible =
                                                !_passwordVisible;
                                          });
                                        },
                                      ),
                                      onChangedValue:
                                          _signUpBloc?.passwordChanged,
                                      editingController: _passwordController,
                                      inputAction: TextInputAction.next),
                                ],
                              ),
                            ),
                            space(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: GestureDetector(
                                    onTap: () {
                                      _hideKeyBoard();
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddLocationActivity()))
                                          .then((value) {
                                        _hideKeyBoard();

                                        if (value != null) {
                                          locationDetail = value;
                                          // Todo uvesh
                                          _addressController.text =
                                              locationDetail!['locationName']
                                                  .toString();
                                        }
                                      });
                                    },
                                    child: AbsorbPointer(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            StringHelper.location,
                                            style: SoloStyle.lightGrey200,
                                          ),
                                          TextFieldWidget(
                                              screenWidth:
                                                  _commonHelper?.screenWidth,
                                              keyboardType: TextInputType.text,
                                              autoFocus: false,
                                              maxLines: 2,
                                              editingController:
                                                  _addressController,
                                              inputAction:
                                                  TextInputAction.done),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: GestureDetector(
                                    onTap: () {
                                      _hideKeyBoard();

                                      _selectDate();
                                    },
                                    child: AbsorbPointer(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            StringHelper.age,
                                            style: SoloStyle.lightGrey200,
                                          ),
                                          TextFieldWidget(
                                              screenWidth:
                                                  _commonHelper?.screenWidth,
                                              keyboardType: TextInputType.text,
                                              autoFocus: false,
                                              editingController: _ageController,
                                              inputAction:
                                                  TextInputAction.done),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            space(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(StringHelper.referralCode,
                                    style: SoloStyle.lightGrey200),
                                TextFieldWidget(
                                    screenWidth: _commonHelper?.screenWidth,
                                    focusNode: _referralFocusNode,
                                    keyboardType: TextInputType.text,
                                    autoFocus: false,
                                    inputFormatter: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp('[\\ ]'))
                                    ],
                                    editingController: _referralController,
                                    inputAction: TextInputAction.done),
                              ],
                            ),
                            space(height: 20),
                            termsAndConditionCheckBox(),
                            StreamBuilder(
                              stream: _signUpBloc?.signInCheck,
                              builder: (context, snapshot) => Container(
                                alignment: Alignment.center,
                                child: ButtonWidget(
                                  height: _commonHelper?.screenHeight,
                                  width: _commonHelper?.screenWidth * .7,
                                  onPressed: () {
                                    _hideKeyBoard();
                                    if (snapshot.hasData) {
                                      if (checkValues()) {
                                        _verifyUser();
                                      }
                                    } else {
                                      CommonHelper.alertOk(StringHelper.error,
                                          StringHelper.requiredFields);
                                    }
                                  },
                                  btnText: StringHelper.signUpTitle,
                                ),
                              ),
                            ),
                            space(height: 40),
                            Center(
                              child: Wrap(
                                children: [
                                  Text(
                                    StringHelper.haveAnAccount,
                                    style: SoloStyle.lightGrey200,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _commonHelper
                                          ?.startActivity(LoginActivity());
                                    },
                                    child: Text(
                                      StringHelper.logIn,
                                      style: SoloStyle.electricPink,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            space(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
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
    ]);
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget termsAndConditionCheckBox() {
    return Row(
      children: [
        StreamBuilder<dynamic>(
            stream: _signUpBloc?.termsConditionsStream,
            builder: (context, snapshot) {
              return Checkbox(
                value: _signUpBloc?.agree,
                checkColor: Colors.white,
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return SoloColor.pink;
                  } else {
                    return SoloColor.lightGrey200;
                  }
                }),
                onChanged: (value) {
                  _signUpBloc?.changeValue();
                },
              );
            }),
        SizedBox(width: 3),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: RichText(
                text: TextSpan(children: [
              new TextSpan(
                text: StringHelper.privacyPolicyDec,
                style: SoloStyle.lightGrey200,
              ),
              new TextSpan(
                text: StringHelper.termsOfUse,
                style: SoloStyle.electricPink,
                recognizer: new TapGestureRecognizer()
                  ..onTap = () {
                    launch(ApiConstants.API_TERMS);
                  },
              ),
              new TextSpan(
                text: StringHelper.and,
                style: SoloStyle.lightGrey200,
              ),
              new TextSpan(
                text: StringHelper.privacyPolicy,
                style: SoloStyle.electricPink,
                recognizer: new TapGestureRecognizer()
                  ..onTap = () {
                    launch(ApiConstants.API_PRIVACY);
                  },
              ),
            ])),
          ),
        )
      ],
    );
  }

//============================================================
// ** Helper Function **
//============================================================

  Future<Null> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
                primaryColor: SoloColor.electricPink,
                buttonColor: SoloColor.electricPink,
                colorScheme: ColorScheme.light(primary: SoloColor.electricPink),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
                accentColor: SoloColor.electricPink),
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
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      return false;
    }

    if (_ageController.text.isEmpty) {
      _commonHelper?.showAlert("Age", "Please enter a valid age");
      return false;
    }
    if (_signUpBloc?.agree == false) {
      _commonHelper?.showAlert(
          "", "Please accept Terms & Conditions and Privacy Policy");
      return false;
    }

    return true;
  }

  Map<String, dynamic> _addSignUpData() {
    Map<String, dynamic> signUpBody = {
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'deviceToken': deviceToken.toString(),
      'userType': 'app',
      'age': userAge
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

  void _verifyUser() {
    if (checkValues()) {
      FocusScope.of(context).unfocus();

      _commonHelper?.isInternetAvailable().then((available) {
        if (available) {
          _showProgress();

          var verifyUserBody =
              json.encode({"email": _emailController.text.toString()});

          _signUpBloc?.verifyUser(verifyUserBody.toString()).then((onSuccess) {
            _hideProgress();
            _onSignUpTap();
          }).catchError((onError) {
            _hideProgress();
          });
        } else {
          _commonHelper?.showAlert(
              StringHelper.noInternetTitle, StringHelper.noInternetMsg);
        }
      });
    }
  }

  void _onSignUpTap() {
    if (checkValues()) {
      _hideKeyBoard();

      _commonHelper?.isInternetAvailable().then((available) {
        if (available) {
          _showProgress();

          var createOtpBody = json.encode({
            "email": _emailController.text.toString(),
            "type": Constants.TYPE_NEW_USER
          });

          _signUpBloc?.createOtp(createOtpBody.toString()).then((onSuccess) {
            _hideProgress();

            _commonHelper?.startActivity(VerifyOtpActivity(
                emailId: _emailController.text.toString(),
                type: Constants.TYPE_NEW_USER,
                data: _addSignUpData()));
          }).catchError((onError) {
            _hideProgress();
          });
        } else {
          _commonHelper?.showAlert(
              StringHelper.noInternetTitle, StringHelper.noInternetMsg);
        }
      });
    }
  }

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }

  void _handleRadioValueChange(int? value) {
    setState(() {
      _radioValue = value;

      if (_radioValue == 1) {
        selectedGender = "female";
      } else {
        selectedGender = "male";
      }
    });
  }

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
}
