import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/activities/settings/account_settings_activity.dart';
import 'package:solomas/activities/settings/change_password_activity.dart';
import 'package:solomas/blocs/settings/logout_bloc.dart';
import 'package:solomas/helpers/api_constants.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/web_view_helper.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/pdf_view_helper.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/strings.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';
import 'blocked_user_activity.dart';

class SettingActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingActivity> {
//============================================================
// ** Properties **
//============================================================

  bool _progressShow = false, isAppUser = true;
  String? mineReferralCode;

  CommonHelper? _commonHelper;
  LogoutBloc? _logoutBloc;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();

    PrefHelper.getReferralCode().then((onValue) {
      setState(() {
        mineReferralCode = onValue;
      });
    });

    PrefHelper.getUserType().then((onValue) {
      Constants.printValue("value: " + onValue.toString());

      setState(() {
        isAppUser = onValue;
      });
    });

    _logoutBloc = LogoutBloc();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SoloScaffold(
      backGroundColor: SoloColor.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: _appBar(),
        ),
      ),
      body: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: _mainWidget(),
      ),
    );
  }

  @override
  void dispose() {
    _logoutBloc?.dispose();
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _appBar() {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.settings,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _mainWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    _settingList(
                        settingsIcon: IconsHelper.settingAccountIcon,
                        settingsName: StringHelper.account,
                        onClick: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AccountSettingsActivity()));
                        }),
                    _settingList(
                        settingsIcon: IconsHelper.password_Icon_Setting,
                        settingsName: StringHelper.password,
                        onClick: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChangePasswordActivity()));
                        }),
                    _settingList(
                        settingsIcon: IconsHelper.block_Icon_Settings,
                        settingsName: StringHelper.blockedUsers,
                        onClick: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BlockedUserActivity()));
                        }),
                    _settingList(
                        settingsIcon: IconsHelper.help_Icon_Settings,
                        settingsName: StringHelper.support,
                        onClick: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) =>
                                  _showSupportBottomSheet());
                        }),
                    _settingList(
                        settingsIcon: IconsHelper.contestRules_Icon_Setting,
                        settingsName: StringHelper.contestRules,
                        onClick: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => ContestRulesPage()));
                          _commonHelper?.startActivity(PdfViewHelper(
                              _commonHelper!,
                              "https://api.solomasapp.com/api/webview/contestRules",
                              StringHelper.contestRules));
                        }),
                    _settingList(
                        settingsIcon: IconsHelper.description_Icon_Settings,
                        settingsName: StringHelper.termsAndConditions,
                        onClick: () {
                          _commonHelper?.startActivity(WebViewHelper(
                              _commonHelper as CommonHelper,
                              ApiConstants.API_TERMS,
                              StringHelper.termsAndConditions));
                        }),
                    _settingList(
                        settingsIcon: IconsHelper.policy_Icon_Setting,
                        settingsName: StringHelper.privacyPolicy,
                        onClick: () {
                          _commonHelper?.startActivity(WebViewHelper(
                              _commonHelper as CommonHelper,
                              ApiConstants.API_PRIVACY,
                              StringHelper.privacyPolicy));
                        }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget _settingList(
      {String? settingsIcon, String? settingsName, Function()? onClick}) {
    return GestureDetector(
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: SoloColor.cultured,
            boxShadow: [
              BoxShadow(
                color: Color(0xffe8e8e8),
                offset: Offset(0, 2),
              ),
              BoxShadow(color: SoloColor.white, offset: Offset(-5, -5)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 17),
                      child: Container(
                        height: _commonHelper?.screenHeight * 0.075,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40)),
                        child: SvgPicture.asset(
                          settingsIcon!,
                          width: _commonHelper?.screenWidth * 0.09,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: _commonHelper?.screenWidth * 0.37,
                      child:
                          Text(settingsName!, style: SoloStyle.blackBoldMedium),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _showSupportBottomSheet() {
    return CupertinoActionSheet(
      title: Text(StringHelper.soloSupport,
          style: TextStyle(
              color: SoloColor.graniteGray,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.supportMsg,
          style: TextStyle(
              color: SoloColor.spanishLightGrey,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.conSupport,
              style: TextStyle(
                  color: SoloColor.graniteGray,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _sendMail();
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            StringHelper.cancel,
            style: TextStyle(
                color: SoloColor.graniteGray,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

//============================================================
// ** Helper Function **
//============================================================
  _sendMail() async {
    final Uri _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'support@solomasapp.com',
        queryParameters: {'subject': ''});

    launch(_emailLaunchUri.toString());
  }

//============================================================
// ** Firebase Function **
//============================================================

}
//============================================================
// ** Helper Class **
//============================================================
