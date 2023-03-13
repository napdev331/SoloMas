import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:solomas/blocs/settings/changed_password_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:solomas/widgets/btn_widget.dart';
import 'package:solomas/widgets/text_field_widget.dart';

import '../../helpers/space.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';

class ChangePasswordActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChangPasswordState();
  }
}

class _ChangPasswordState extends State<ChangePasswordActivity> {
  //============================================================
// ** Properties **
//============================================================
  bool _progressShow = false;
  bool _oldPasswordVisible = true;
  bool _newPasswordVisible = true;
  bool _confirmNewPasswordVisible = true;
  ChangePasswordBloc? _changeBloc;
  var _oldController = TextEditingController(),
      _newController = TextEditingController(),
      _confirmController = TextEditingController();
  var _oldNode = FocusNode(),
      _confirmNode = FocusNode(),
      _newNode = FocusNode();

//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  void initState() {
    super.initState();

    _changeBloc = ChangePasswordBloc();
  }

  @override
  Widget build(BuildContext context) {
    var _commonHelper = CommonHelper(context);

    void _onSubmitTap() {
      _commonHelper.isInternetAvailable().then((available) {
        if (available) {
          _showProgress();

          var body = json.encode({
            "oldPassword": _oldController.text.toString().trim(),
            "newPassword": _newController.text.toString().trim(),
          });

          PrefHelper.getAuthToken().then((authToken) {
            _changeBloc
                ?.changedPassword(
                    _commonHelper, body.toString(), authToken.toString())
                .then((onSuccess) {
              _hideProgress();
            }).catchError((onError) {
              _hideProgress();
            });
          });
        }
      });
    }

    return SoloScaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: _appBar(),
          ),
        ),
        // AppBar(
        //   backgroundColor: SoloColor.blue,
        //   automaticallyImplyLeading: false,
        //   title: Stack(
        //     children: [
        //       GestureDetector(
        //         onTap: () {
        //           _commonHelper.closeActivity();
        //         },
        //         child: Container(
        //           width: 25,
        //           height: 25,
        //           alignment: Alignment.centerLeft,
        //           child: Image.asset('images/back_arrow.png'),
        //         ),
        //       ),
        //       Container(
        //         alignment: Alignment.center,
        //         child: Text('Password'.toUpperCase(),
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //                 color: Colors.white,
        //                 fontFamily: 'Montserrat',
        //                 fontSize: Constants.FONT_APP_TITLE)),
        //       )
        //     ],
        //   ),
        // ),
        body: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                Container(
                  height: _commonHelper.screenHeight * .9,
                  width: _commonHelper.screenWidth,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StreamBuilder(
                          stream: _changeBloc?.oldStream,
                          builder: (password, snapshot) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(StringHelper.oldPassword,
                                  style: SoloStyle.lightGrey200),
                              TextFieldWidget(
                                  screenWidth: _commonHelper.screenWidth,
                                  title: StringHelper.oldPassword,
                                  errorText: snapshot.error as String?,
                                  focusNode: _oldNode,
                                  hideText: _oldPasswordVisible,
                                  secondFocus: _newNode,
                                  onChangedValue: _changeBloc?.oldChanged,
                                  keyboardType: TextInputType.visiblePassword,
                                  autoFocus: false,
                                  iconPath: "assets/images/ic_password.png",
                                  editingController: _oldController,
                                  inputAction: TextInputAction.next,
                                  marginTop: DimensHelper.sidesMargin,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _oldPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: SoloColor.spanishGray,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _oldPasswordVisible =
                                            !_oldPasswordVisible;
                                      });
                                    },
                                  )),
                            ],
                          ),
                        ),
                        space(height: 20),
                        StreamBuilder(
                          stream: _changeBloc?.newPassword,
                          builder: (password, snapshot) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(StringHelper.newPassword,
                                  style: SoloStyle.lightGrey200),
                              TextFieldWidget(
                                  screenWidth: _commonHelper.screenWidth,
                                  title: StringHelper.newPassword,
                                  errorText: snapshot.error as String?,
                                  hideText: _newPasswordVisible,
                                  focusNode: _newNode,
                                  secondFocus: _confirmNode,
                                  onChangedValue: _changeBloc?.newChanged,
                                  keyboardType: TextInputType.visiblePassword,
                                  autoFocus: false,
                                  iconPath: "assets/images/ic_password.png",
                                  editingController: _newController,
                                  inputAction: TextInputAction.done,
                                  marginTop: DimensHelper.sidesMargin,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _newPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: SoloColor.spanishGray,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _newPasswordVisible =
                                            !_newPasswordVisible;
                                      });
                                    },
                                  )),
                            ],
                          ),
                        ),
                        space(height: 20),
                        StreamBuilder(
                          stream: _changeBloc?.confirmPassword,
                          builder: (password, snapshot) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(StringHelper.confirmNewPassword,
                                  style: SoloStyle.lightGrey200),
                              TextFieldWidget(
                                  screenWidth: _commonHelper.screenWidth,
                                  title: StringHelper.confirmNewPassword,
                                  hideText: _confirmNewPasswordVisible,
                                  errorText: snapshot.error as String?,
                                  focusNode: _confirmNode,
                                  onChangedValue: _changeBloc?.confirmChanged,
                                  keyboardType: TextInputType.visiblePassword,
                                  autoFocus: false,
                                  iconPath: "assets/images/ic_password.png",
                                  editingController: _confirmController,
                                  inputAction: TextInputAction.done,
                                  marginTop: DimensHelper.sidesMargin,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _confirmNewPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: SoloColor.spanishGray,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _confirmNewPasswordVisible =
                                            !_confirmNewPasswordVisible;
                                      });
                                    },
                                  )),
                            ],
                          ),
                        ),
                        StreamBuilder(
                          stream: _changeBloc?.saveCheck,
                          builder: (context, snapshot) => Container(
                            margin: EdgeInsets.only(
                                top: DimensHelper.sidesMarginDouble),
                            child: ButtonWidget(
                              height: _commonHelper.screenHeight,
                              width: _commonHelper.screenWidth * .7,
                              onPressed: () {
                                snapshot.hasData
                                    ? _onSubmitTap()
                                    : CommonHelper.alertOk(StringHelper.error,
                                        "Please enter valid input");
                              },
                              btnText: StringHelper.Update.toUpperCase(),
                            ),
                          ),
                        ),
                      ]),
                ),
                Align(
                  child: ProgressBarIndicator(
                      _commonHelper.screenSize, _progressShow),
                  alignment: FractionalOffset.center,
                ),
              ],
            )));
  }

//============================================================
// ** Main Widgets **
//============================================================
  Widget _appBar() {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.password,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

//============================================================
// ** Helper Function **
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
}
