import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solomas/activities/registration/verify_otp_activity.dart';
import 'package:solomas/blocs/login/forgot_password_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/progress_indicator.dart';
import '../../helpers/space.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../../widgets/btn_widget.dart';
import '../../widgets/text_field_widget.dart';
import 'login_activity.dart';

class ForgetPasswordActivity extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPasswordActivity> {
//============================================================
// ** Properties **
//============================================================

  var scrollController = ScrollController();
  var _emailController = TextEditingController();
  var _emailFocusNode = FocusNode();
  CommonHelper? _commonHelper;
  ForgotPasswordBloc? _forgotPasswordBloc;
  bool _progressShow = false;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _forgotPasswordBloc = ForgotPasswordBloc();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SoloScaffold(
      body: _mainBody(height, width, context),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _forgotPasswordBloc?.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _mainBody(double height, double width, BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        forgotPassword(),
                        space(height: 5),
                        description(),
                      ],
                    ),
                    if (Platform.isIOS)
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: appBackButton(onTap: () {
                          _commonHelper?.startActivity(LoginActivity());
                        }),
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
                          IconsHelper.forgotPassword_logo,
                          width: 250,
                          height: 300,
                        ),
                        space(height: 20),
                        StreamBuilder(
                            stream: _forgotPasswordBloc?.emailStream,
                            builder: (phone, snapshot) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(StringHelper.email,
                                        style: SoloStyle.lightGrey200),
                                    TextFieldWidget(
                                        screenWidth: _commonHelper?.screenWidth,
                                        focusNode: _emailFocusNode,
                                        errorText: snapshot.error as String?,
                                        keyboardType: TextInputType.text,
                                        inputFormatter: [
                                          FilteringTextInputFormatter.deny(
                                              RegExp('[\\ ]'))
                                        ],
                                        onChangedValue:
                                            _forgotPasswordBloc?.emailChanged,
                                        autoFocus: false,
                                        editingController: _emailController,
                                        inputAction: TextInputAction.done),
                                  ],
                                )),
                        StreamBuilder(
                            stream: _forgotPasswordBloc?.sendCheck,
                            builder: (context, snapshot) => Container(
                                  margin: EdgeInsets.only(
                                      top: DimensHelper.sidesMargin),
                                  alignment: Alignment.center,
                                  child: ButtonWidget(
                                    height: _commonHelper?.screenHeight,
                                    width: _commonHelper?.screenWidth * .7,
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      _onSendButtonTap();
                                      // snapshot.hasData ?  : CommonHelper.alertOk(
                                      //     StringHelper.error, 'Please enter a valid email id.');
                                    },
                                    btnText: StringHelper.send,
                                  ),
                                )),
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

  Widget forgotPassword() {
    return Text(StringHelper.forgotPasswordTitle,
        textAlign: TextAlign.center,
        maxLines: 2,
        style: SoloStyle.whiteW900extraLarge);
  }

  Widget description() {
    return Container(
      child: Text(
        StringHelper.forgotPasswordDecs,
        textAlign: TextAlign.center,
        maxLines: 3,
        style: SoloStyle.white11,
      ),
    );
  }

//============================================================
// ** Helper Function **
//============================================================

  void _onSendButtonTap() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (_emailController.text.isEmpty) {
        _commonHelper?.showAlert("Error", "Please enter a valid email");

        return false;
      }

      if (available) {
        _showProgress();

        var createOtpBody = json.encode({
          "email": _emailController.text.toString(),
          "type": Constants.TYPE_FORGOT_PASSWORD
        });

        _forgotPasswordBloc
            ?.createOtp(createOtpBody.toString())
            .then((onSuccess) {
          _hideProgress();
          if (onSuccess?.statusCode == 200) {
            _commonHelper?.startActivity(VerifyOtpActivity(
                emailId: _emailController.text.toString(),
                type: Constants.TYPE_FORGOT_PASSWORD));
          } else {
            _commonHelper?.showAlert("Failure", onSuccess?.data);
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
