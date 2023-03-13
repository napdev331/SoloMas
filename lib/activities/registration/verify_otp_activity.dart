import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/registration/reset_password_activity.dart';
import 'package:solomas/blocs/login/login_bloc.dart';
import 'package:solomas/blocs/login/verify_mobile_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/model/verify_otp_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:solomas/resources_helper/text_styles.dart';

import '../../helpers/progress_indicator.dart';
import '../../helpers/space.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../widgets/btn_widget.dart';
import '../../widgets/otp_text_field_widget.dart';
import 'forgot_password_activity.dart';

class VerifyOtpActivity extends StatefulWidget {
  final String? emailId, type;

  final Map<String, dynamic>? data;

  final bool isSocialLogin;

  VerifyOtpActivity(
      {this.isSocialLogin = false, this.emailId, this.type, this.data});

  @override
  State<StatefulWidget> createState() {
    return _VerifyOtpState();
  }
}

class _VerifyOtpState extends State<VerifyOtpActivity> {
//============================================================
// ** Properties **
//============================================================

  bool _isResendBtnShow = false, _progressShow = false;
  var _otpController = TextEditingController(),
      _otpTwoController = TextEditingController(),
      _otpThreeController = TextEditingController(),
      _otpFourController = TextEditingController();
  var _otpNode = FocusNode(),
      _otpTwoNode = FocusNode(),
      _otpThreeNode = FocusNode(),
      _otpFourNode = FocusNode();
  VerifyMobileBloc? _verifyMobileBloc;
  LoginBloc? _loginBloc;
  CommonHelper? _commonHelper;
  Timer? _timer;
  int _start = 30;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _verifyMobileBloc = VerifyMobileBloc();
    _loginBloc = LoginBloc();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      body: _mainBody(context, _requestFocus, _onSendButtonTap),
    );
  }

  @override
  void dispose() {
    if (_timer != null) _timer?.cancel();

    _verifyMobileBloc?.dispose();

    _loginBloc?.dispose();

    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _mainBody(BuildContext context, void _requestFocus(dynamic focusNode),
      void _onSendButtonTap()) {
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
                    _commonHelper?.startActivity(ForgetPasswordActivity());
                  }),
                ),
              Padding(
                padding: EdgeInsets.only(
                    top: Platform.isIOS ? 0 : 45,
                    bottom: Platform.isIOS ? 30 : 45),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(StringHelper.verifyOtpTitle,
                        style: SoloStyle.whiteW900extraLarge),
                    Align(
                      alignment: Alignment.center,
                      child: Text(StringHelper.verifyOtpDec,
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
                        space(height: 40),
                        Image.asset(
                          IconsHelper.logo_Icon,
                          width: 110,
                          height: 110,
                        ),
                        space(height: 10),
                        Container(
                          width: _commonHelper?.screenWidth * 0.8,
                          child: Text(
                            "We have sent an OTP to your email id i.e ${widget.emailId}, enter below to verify.",
                            style: SoloStyle.greyNormalTopRoboto,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(top: 60),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    OtpTextFieldWidget(
                                        screenWidth: _commonHelper?.screenWidth,
                                        autoFocus: false,
                                        focusNode: _otpNode,
                                        secondFocus: _otpTwoNode,
                                        keyboardType: TextInputType.number,
                                        onChangedValue: (value) {
                                          if (value.length == 1) {
                                            _requestFocus(_otpTwoNode);
                                          }
                                        },
                                        editingController: _otpController,
                                        inputAction: TextInputAction.next,
                                        marginTop: DimensHelper.sidesMargin),
                                    OtpTextFieldWidget(
                                        screenWidth: _commonHelper?.screenWidth,
                                        autoFocus: false,
                                        focusNode: _otpTwoNode,
                                        secondFocus: _otpThreeNode,
                                        keyboardType: TextInputType.number,
                                        onChangedValue: (value) {
                                          if (value.length == 1) {
                                            _requestFocus(_otpThreeNode);
                                          } else {
                                            _requestFocus(_otpNode);
                                          }
                                        },
                                        editingController: _otpTwoController,
                                        inputAction: TextInputAction.next,
                                        marginTop: DimensHelper.sidesMargin),
                                    OtpTextFieldWidget(
                                        screenWidth: _commonHelper?.screenWidth,
                                        autoFocus: false,
                                        keyboardType: TextInputType.number,
                                        focusNode: _otpThreeNode,
                                        secondFocus: _otpFourNode,
                                        onChangedValue: (value) {
                                          if (value.length == 1) {
                                            _requestFocus(_otpFourNode);
                                          } else {
                                            _requestFocus(_otpTwoNode);
                                          }
                                        },
                                        editingController: _otpThreeController,
                                        inputAction: TextInputAction.next,
                                        marginTop: DimensHelper.sidesMargin),
                                    OtpTextFieldWidget(
                                        screenWidth: _commonHelper?.screenWidth,
                                        autoFocus: false,
                                        focusNode: _otpFourNode,
                                        alignment: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        onChangedValue: (value) {
                                          if (value.length == 1) {
                                            _otpFourNode.unfocus();
                                          } else {
                                            _requestFocus(_otpThreeNode);
                                          }
                                        },
                                        editingController: _otpFourController,
                                        inputAction: TextInputAction.done,
                                        marginTop: DimensHelper.sidesMargin)
                                  ]),
                            ),
                            Container(
                              alignment: Alignment.center,
                              margin:
                                  EdgeInsets.only(top: DimensHelper.halfSides),
                              child: resendBtn(),
                            ),
                            Container(
                                margin: EdgeInsets.only(
                                    top: DimensHelper.sidesMarginDouble),
                                child: ButtonWidget(
                                  height: _commonHelper?.screenHeight,
                                  width: _commonHelper?.screenWidth * .7,
                                  onPressed: () {
                                    if (_checkValues()) {
                                      _onSendButtonTap();
                                    }
                                  },
                                  btnText: StringHelper.verify,
                                )),
                          ],
                        ),
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

  Widget resendBtn() {
    return Container(
      margin: EdgeInsets.only(top: DimensHelper.halfSides),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            StringHelper.didReceiveTheCode,
            style: SoloStyle.lightGrey200W600Medium,
          ),
          _isResendBtnShow == true
              ? Text(
                  'Please wait 00:${_start.toString().length == 1 ? '0$_start' : _start}',
                  style: SoloStyle.electricPinkNormalMedium,
                )
              : GestureDetector(
                  onTap: () {
                    _start = 30;

                    _onCreateOtpTap();

                    otpTimer();

                    _otpController.clear();

                    _otpTwoController.clear();

                    _otpThreeController.clear();

                    _otpFourController.clear();
                  },
                  child: Text(
                    StringHelper.resendOtp,
                    style: TextStyle(
                        fontSize: Constants.FONT_MEDIUM,
                        color: SoloColor.electricPink,
                        fontWeight: FontWeight.w700),
                  ),
                )
        ],
      ),
    );
  }

//============================================================
// ** Helper Function **
//============================================================

  void otpTimer() {
    setState(() {
      _isResendBtnShow = true;
    });

    const oneSec = const Duration(seconds: 1);

    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            setState(() {
              _isResendBtnShow = false;
            });

            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  bool _checkValues() {
    var otp = _otpController.text.trim() +
        _otpTwoController.text.trim() +
        _otpThreeController.text.trim() +
        _otpFourController.text.trim();

    if (otp.length != 4) {
      _commonHelper?.showAlert("Invalid OTP", "Please enter a valid OTP");

      return false;
    }

    return true;
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

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }

  void _onCreateOtpTap() {
    _hideKeyBoard();

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var createOtpBody =
            json.encode({"email": widget.emailId, "type": widget.type});

        _verifyMobileBloc
            ?.createOtp(createOtpBody.toString())
            .then((onSuccess) {
          _hideProgress();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  String _addSignUpData(int token) {
    var signUpBody = json.encode({
      "userType": "app",
      "fullName": widget.data?['fullName'],
      "email": widget.data?['email'],
      "deviceToken": widget.data?['deviceToken'],
      "password": widget.data?['password'],
      "age": widget.data?['age'],
      "otpToken": token,
    });

    var reqBody = jsonDecode(signUpBody);

    if (widget.data!.containsKey("locationName")) {
      Map<String, dynamic> locationMap = widget.data?['location'];

      reqBody["locationName"] = widget.data?['locationName'];

      reqBody["location"] = locationMap;
    }

    if (widget.data!.containsKey("referralCode")) {
      reqBody['referralCode'] = widget.data?['referralCode'];
    }

    Constants.printValue("SIGN UP REQ BODY: " + reqBody.toString());

    return jsonEncode(reqBody).toString();
  }

  void _registerUser(int token) {
    _showProgress();

    _verifyMobileBloc
        ?.signUpUser(_commonHelper as CommonHelper, _addSignUpData(token))
        .then((onSuccess) {
      _hideProgress();
    }).catchError((onError) {
      _hideProgress();
    });
  }

  void _onSendButtonTap() {
    var otp = _otpController.text.trim() +
        _otpTwoController.text.trim() +
        _otpThreeController.text.trim() +
        _otpFourController.text.trim();

    FocusScope.of(context).unfocus();

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "otp": int.parse(otp),
          "type": widget.type,
          "email": widget.emailId
        });

        _verifyMobileBloc?.verifyOtp(body.toString()).then((onSuccess) {
          _hideProgress();

          VerifyOtpModel verifyOtpModel = onSuccess;

          if (widget.type == Constants.TYPE_NEW_USER) {
            _registerUser(verifyOtpModel.data?.token ?? 0);
          } else if (widget.type == Constants.TYPE_FORGOT_PASSWORD) {
            _commonHelper?.startActivityWithReplacement(ResetPasswordActivity(
                emailId: widget.emailId.toString(),
                otpToken: verifyOtpModel.data?.token ?? 0));
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

  void _requestFocus(focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }
}
