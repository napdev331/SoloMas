import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solomas/activities/home_activity.dart';
import 'package:solomas/activities/introduction/intro_activity.dart';
import 'package:solomas/activities/registration/forgot_password_activity.dart';
import 'package:solomas/activities/registration/sign_up_activity.dart';
import 'package:solomas/activities/registration/sign_up_detail_activity.dart';
import 'package:solomas/blocs/login/login_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/apple_login_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/firebase_notificatons.dart';
import 'package:solomas/helpers/google_helper.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/verify_user_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../../helpers/progress_indicator.dart';
import '../../helpers/space.dart';
import '../../resources_helper/dimens.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../../widgets/btn_widget.dart';
import '../../widgets/text_field_widget.dart';

class LoginActivity extends StatefulWidget {
  static const routeName = "/";
  @override
  _MyAppState createState() => _MyAppState();
}

/*FbLoginListener*/
class _MyAppState extends State<LoginActivity>
    implements GoogleLoginListener, AppleLoginListener {
//============================================================
// ** Properties **
//============================================================

  var _emailController = TextEditingController(),
      _passwordController = TextEditingController();
  var _emailFocusNode = FocusNode(), _passwordFocusNode = FocusNode();
  final Future<bool> _isAvailableFuture = TheAppleSignIn.isAvailable();
  var scrollController = ScrollController();
  bool isLogged = false, _progressShow = false, _passwordVisible = true;
  CommonHelper? _commonHelper;
  LoginBloc? _loginBloc;
  String? deviceToken;
  ApiHelper? _apiHelper;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc();
    _apiHelper = ApiHelper();
    var _fireBaseMessaging = FirebaseMessaging.instance;
    _fireBaseMessaging.getToken().then((token) {
      deviceToken = token;
      Constants.printValue("FCM TOKEN: " + deviceToken.toString());
      PrefHelper.setDeviceToken(token.toString()).then((token) {});
    }).catchError((onError) {
      Constants.printValue("FCM TOKEN: ERROR" + onError.toString());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => initializeFcm(context));
  }

  void initializeFcm(BuildContext context) {
    FireBaseNotifications(context);

    PrefHelper.contains(Constants.PREF_INTRODUCTION).then((onValue) {
      if (!onValue) {
        _commonHelper?.startActivity(IntroActivity());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    TextStyle style = SoloStyle.montserrat20;
    final forgotButton = InkWell(
      child: MaterialButton(
        onPressed: () {
          _commonHelper?.startActivity(ForgetPasswordActivity());
        },
        child: Text(StringHelper.forgotPasswordLogin,
            textAlign: TextAlign.right,
            style: style.copyWith(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            )),
      ),
    );

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SoloScaffold(
      body: _mainBody(
          height, width, context, forgotButton, _onLoginTap, loginWithSocial),
    );
  }

  @override
  void dispose() {
    _loginBloc?.dispose();
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _mainBody(double height, double width, BuildContext context,
      InkWell forgotButton, void _onLoginTap(), Widget loginWithSocial()) {
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
              Padding(
                padding: const EdgeInsets.only(top: 45, bottom: 45),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(StringHelper.welcome,
                        style: SoloStyle.whiteW900extraLarge),
                    Align(
                      alignment: Alignment.center,
                      child: Text(StringHelper.logInToContinue,
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
                          stream: _loginBloc?.emailStream,
                          builder: (email, snapshot) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(StringHelper.email,
                                  style: SoloStyle.lightGrey200),
                              TextFieldWidget(
                                  screenWidth: _commonHelper?.screenWidth,
                                  errorText: snapshot.error as String?,
                                  focusNode: _emailFocusNode,
                                  onChangedValue: _loginBloc?.emailChanged,
                                  secondFocus: _passwordFocusNode,
                                  keyboardType: TextInputType.text,
                                  autoFocus: false,
                                  editingController: _emailController,
                                  inputFormatter: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp('[\\ ]'))
                                  ],
                                  inputAction: TextInputAction.next,
                                  marginTop: DimensHelper.sidesMargin),
                            ],
                          ),
                        ),
                        space(height: 20),
                        StreamBuilder(
                          stream: _loginBloc?.passwordStream,
                          builder: (password, snapshot) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(StringHelper.password,
                                  style: SoloStyle.lightGrey200),
                              TextFieldWidget(
                                  screenWidth: _commonHelper?.screenWidth,
                                  errorText: snapshot.error as String?,
                                  focusNode: _passwordFocusNode,
                                  hideText: _passwordVisible,
                                  onChangedValue: _loginBloc?.passwordChanged,
                                  keyboardType: TextInputType.visiblePassword,
                                  autoFocus: false,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: SoloColor.spanishGray,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                  editingController: _passwordController,
                                  inputAction: TextInputAction.done,
                                  marginTop: DimensHelper.sidesMargin),
                            ],
                          ),
                        ),
                        Container(
                            alignment: Alignment.centerRight,
                            child: Column(children: [
                              FittedBox(
                                fit: BoxFit.contain,
                                child: forgotButton,
                              ),
                            ])),
                        StreamBuilder(
                            stream: _loginBloc?.signInCheck,
                            builder: (context, snapshot) => Container(
                                  alignment: Alignment.center,
                                  child: ButtonWidget(
                                    height: _commonHelper?.screenHeight,
                                    width: _commonHelper?.screenWidth * .7,
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();

                                      snapshot.hasData
                                          ? _onLoginTap()
                                          : CommonHelper.alertOk(
                                              StringHelper.error,
                                              StringHelper.requiredFields);
                                    },
                                    btnText: StringHelper.signIn,
                                  ),
                                )),
                        space(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(StringHelper.youCanConnectWith),
                          ],
                        ),
                        space(height: 20),
                        loginWithSocial(),
                        space(height: 40),
                        Center(
                          child: Wrap(
                            children: [
                              Text(
                                StringHelper.donHaveAccount,
                                style: SoloStyle.lightGrey200,
                              ),
                              GestureDetector(
                                onTap: () {
                                  _commonHelper
                                      ?.startActivity(SignUpActivity());
                                },
                                child: Text(
                                  StringHelper.signUp,
                                  style: SoloStyle.electricPink,
                                ),
                              )
                            ],
                          ),
                        ),
                        space(height: 40),
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
    ]);
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget loginWithSocial() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              GoogleHelper(this);
            },
            child: Container(
                height: MediaQuery.of(context).size.height * 0.055,
                width: MediaQuery.of(context).size.width * 0.45,
                decoration: BoxDecoration(
                    color: SoloColor.cultured,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/bt_google.png',
                      height: 20,
                      width: 20,
                    ),
                    space(width: 4),
                    Text(StringHelper.google),
                  ],
                )),
          ),
          // if(Platform.isIOS)
          GestureDetector(
            onTap: () {
              AppleLoginHelper(this);
            },
            child: Container(
                height: MediaQuery.of(context).size.height * 0.055,
                width: MediaQuery.of(context).size.width * 0.45,
                decoration: BoxDecoration(
                    color: SoloColor.black,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      IconsHelper.apple_logo_icon,
                      height: 20,
                      width: 20,
                    ),
                    space(width: 4),
                    Text(
                      StringHelper.apple,
                      style: SoloStyle.white,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget appleLoginWidget() {
    var loginTextWidth = _commonHelper?.screenWidth * 0.6;
    var margin = _commonHelper?.screenWidth * 0.02;
    return FutureBuilder<bool>(
        future: _isAvailableFuture,
        builder: (context, snapshot) {
          return Container(
            width: 5.0 * margin,
            child: Material(
              borderRadius: BorderRadius.circular(10.0),
              child: MaterialButton(
                minWidth: 5.0 * margin,
                height: 5.0 * margin,
                padding: EdgeInsets.only(bottom: margin),
                onPressed: () {
                  // AppleLoginHelper(this);

                  //  FacebookHelper(this);
                },
                child: Image.asset('assets/images/bt_fb.png'),
              ),
            ),
          );
        });
  }

//============================================================
// ** Helper Function **
//============================================================

  void _onLoginTap() {
    FocusScope.of(context).unfocus();
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();
        var body = json.encode({
          "email": _emailController.text.toString(),
          "password": _passwordController.text.toString(),
          'deviceToken': deviceToken.toString()
        });
        _loginBloc?.loginWithEmail(body.toString()).then((onSuccess) {
          _hideProgress();

          _commonHelper?.startActivityAndCloseOther(HomeActivity());
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _verifyUser(String email, Map<String, dynamic> socialSignBody) {
    FocusScope.of(context).unfocus();

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "email": email,
        });

        _apiHelper?.verifyUser(body.toString()).then((onSuccess) {
          _hideProgress();

          VerifyUserModel verifyUserModel = onSuccess;

          if (verifyUserModel.statusCode == 200) {
            _commonHelper?.startActivity(
                SignUpDetailActivity(socialBody: socialSignBody));
          } else if (verifyUserModel.statusCode == 400) {
            _showProgress();

            var socialLoginBody =
                json.encode({"email": email, "deviceToken": deviceToken});

            _loginBloc
                ?.socialLogin(_commonHelper as CommonHelper, socialLoginBody)
                .then((onSuccess) {
              _hideProgress();
            }).catchError((onError) {
              _hideProgress();
            });
          } else {
            CommonHelper.alertOk(verifyUserModel.message, verifyUserModel.data);
          }
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  @override
  onGoogleLogin(isLogin, googleId, email, fullName, photoUrl) {
    if (isLogin) {
      Map<String, dynamic> googleLoginBody = {
        "userType": "google",
        "fullName": fullName,
        "email": email,
        "googleId": googleId,
        "profilePic": photoUrl,
        "deviceToken": deviceToken
      };

      _verifyUser(email, googleLoginBody);
    }
  }

  @override
  onAppleLogin(isLogin, email, fullName, user) {
    if (isLogin) {
      if (fullName == null) fullName = "Apple User";

      _onAppleLoginBtnTap(fullName, email, user);
    }
  }

  void _onAppleLoginBtnTap(fullName, email, user) {
    Map<String, dynamic> appleLoginBody = {
      "userType": "apple",
      "fullName": fullName,
      "email": email,
      "appleId": user,
      "profilePic": "",
      "deviceToken": deviceToken
    };

    _showProgress();

    _verifyUser(email, appleLoginBody);
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
