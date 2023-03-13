import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/registration/login_activity.dart';
import 'package:solomas/blocs/login/reset_password_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:solomas/widgets/btn_widget.dart';
import 'package:solomas/widgets/text_field_widget.dart';

import '../../resources_helper/screen_area/scaffold.dart';

class ResetPasswordActivity extends StatefulWidget {
  final String? emailId;

  final int? otpToken;

  ResetPasswordActivity({this.emailId, this.otpToken});

  @override
  State<StatefulWidget> createState() {
    return _ResetPasswordState();
  }
}

class _ResetPasswordState extends State<ResetPasswordActivity> {
  bool _progressShow = false;

  final _newPasswordTextController = TextEditingController(),
      _confirmPasswordTextController = TextEditingController();

  final _newPasswordFocusNode = FocusNode(),
      _confirmPasswordFocusNode = FocusNode();

  ResetPasswordBloc? _resetPassBloc;

  CommonHelper? _commonHelper;

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

  void _onResetButtonTap() {
    var body = json.encode({
      "email": widget.emailId,
      "newPassword": _newPasswordTextController.text.toString(),
      'otpToken': widget.otpToken
    });

    FocusScope.of(context).unfocus();

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        _resetPassBloc?.resetPassword(body.toString()).then((onSuccess) {
          _hideProgress();

          _commonHelper
              ?.showToast("You password has been changed successfully");

          _commonHelper?.startActivityAndCloseOther(LoginActivity());
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
  void initState() {
    super.initState();

    _resetPassBloc = ResetPasswordBloc();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: _commonHelper?.screenHeight,
              width: _commonHelper?.screenWidth,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage("images/back_img.png"),
                      fit: BoxFit.cover)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Text('Reset Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    margin:
                        EdgeInsets.only(bottom: DimensHelper.sidesMarginDouble),
                  ),
                  StreamBuilder(
                    initialData: null,
                    stream: _resetPassBloc?.newPasswordStream,
                    builder: (password, snapshot) => TextFieldWidget(
                        screenWidth: _commonHelper?.screenWidth,
                        title: 'New Password',
                        errorText: snapshot.error as String?,
                        focusNode: _newPasswordFocusNode,
                        tabColor: SoloColor.pink,
                        secondFocus: _confirmPasswordFocusNode,
                        etBgColor: Color.fromRGBO(255, 246, 250, 100),
                        onChangedValue: _resetPassBloc?.newPasswordChanged,
                        keyboardType: TextInputType.visiblePassword,
                        autoFocus: false,
                        iconPath: "assets/images/ic_password.png",
                        editingController: _newPasswordTextController,
                        inputAction: TextInputAction.next,
                        marginTop: DimensHelper.sidesMargin),
                  ),
                  StreamBuilder(
                    initialData: null,
                    stream: _resetPassBloc?.confirmPassword,
                    builder: (password, snapshot) => TextFieldWidget(
                        screenWidth: _commonHelper?.screenWidth,
                        title: 'Confirm New Password',
                        errorText: snapshot.error as String?,
                        focusNode: _confirmPasswordFocusNode,
                        tabColor: SoloColor.pastelOrange,
                        etBgColor: Color.fromRGBO(255, 252, 248, 100),
                        onChangedValue: _resetPassBloc?.confirmChanged,
                        keyboardType: TextInputType.visiblePassword,
                        autoFocus: false,
                        iconPath: "assets/images/ic_password.png",
                        editingController: _confirmPasswordTextController,
                        inputAction: TextInputAction.done,
                        marginTop: DimensHelper.sidesMargin),
                  ),
                  StreamBuilder(
                    stream: _resetPassBloc?.passwordCheck,
                    builder: (context, snapshot) => ButtonWidget(
                      height: _commonHelper?.screenHeight,
                      width: _commonHelper?.screenWidth * .7,
                      onPressed: () {
                        snapshot.hasData
                            ? _onResetButtonTap()
                            : _commonHelper?.showAlert(StringHelper.error,
                                StringHelper.requiredFields);
                      },
                      btnText: 'RESET PASSWORD',
                    ),
                  ),
                ],
              ),
            ),
            Align(
                child: Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.only(
                  top: _commonHelper?.screenHeight * 0.1 * .5,
                  left: _commonHelper?.screenWidth * .07),
              child: InkWell(
                  onTap: () {
                    _commonHelper?.closeActivity();
                  },
                  child: Container(
                    padding: EdgeInsets.all(DimensHelper.smallSides),
                    child: Image.asset('images/blackarrow_black.png',
                        height: _commonHelper?.screenHeight * 0.1 * .33,
                        width: _commonHelper?.screenWidth * .07),
                  )),
            )),
            Align(
              child: ProgressBarIndicator(
                  _commonHelper?.screenSize, _progressShow),
              alignment: FractionalOffset.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _resetPassBloc?.dispose();
  }
}
