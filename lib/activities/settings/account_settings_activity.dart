import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/registration/login_activity.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../resources_helper/screen_area/scaffold.dart';
import '../common_helpers/app_bar.dart';

class AccountSettingsActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccountSettingState();
  }
}

class _AccountSettingState extends State<AccountSettingsActivity> {
  //============================================================
// ** Properties **
//============================================================
  CommonHelper? _commonHelper;
  ApiHelper? _apiHelper;
  bool _progressShow = false;

//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  void initState() {
    super.initState();

    _apiHelper = ApiHelper();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    void _onDeleteAccountTap() {
      _commonHelper?.isInternetAvailable().then((available) {
        if (available) {
          _showProgress();

          PrefHelper.getAuthToken().then((token) {
            _apiHelper?.deleteAccount('', token.toString()).then((onValue) {
              _hideProgress();

              var isIntroShown;

              PrefHelper.contains(Constants.PREF_INTRODUCTION).then((onValue) {
                isIntroShown = onValue;
              });

              PrefHelper.clear().then((onSuccess) {
                PrefHelper.setIntroScreenValue(isIntroShown);

                _commonHelper?.startActivityAndCloseOther(LoginActivity());
              });
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

    Widget _showBottomSheet() {
      return CupertinoActionSheet(
        title: Text(StringHelper.deleteAccount,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        message: Text(
          StringHelper.confirmDeleteMsg,
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400),
        ),
        actions: [
          CupertinoActionSheetAction(
            child: Text(StringHelper.delete,
                style: TextStyle(
                    color: SoloColor.black,
                    fontSize: Constants.FONT_TOP,
                    fontWeight: FontWeight.w500)),
            onPressed: () {
              Navigator.pop(context);

              _onDeleteAccountTap();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(StringHelper.cancel,
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    }

    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: _appBar(),
        ),
      ),
      //     AppBar(
      //   backgroundColor: SoloColor.blue,
      //   automaticallyImplyLeading: false,
      //   title: Stack(
      //     children: [
      //       GestureDetector(
      //         onTap: () {
      //           _commonHelper?.closeActivity();
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
      //         child: Text('Account'.toUpperCase(),
      //             textAlign: TextAlign.center,
      //             style: TextStyle(
      //                 color: Colors.white,
      //                 fontSize: Constants.FONT_APP_TITLE)),
      //       )
      //     ],
      //   ),
      // ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => _showBottomSheet());
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(70),
                child: Container(
                  decoration: BoxDecoration(
                      color: SoloColor.pastelOrange,
                      borderRadius: BorderRadius.all(Radius.circular(70))),
                  height: _commonHelper?.screenHeight * .09,
                  width: _commonHelper?.screenWidth,
                  margin: EdgeInsets.all(DimensHelper.sidesMarginDouble),
                  child: Center(
                    child: Text(
                      StringHelper.deleteAccount,
                      style: TextStyle(
                          color: SoloColor.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                )),
          ),
          Align(
            child:
                ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
            alignment: FractionalOffset.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
  //============================================================
// ** Main Widgets **
//============================================================

  Widget _appBar() {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.account,
      backOnTap: () {
        _commonHelper?.closeActivity();
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
