import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/chat/messages_actvity.dart';
import 'package:solomas/activities/registration/login_activity.dart';
import 'package:solomas/activities/settings/notification_activity.dart';
import 'package:solomas/activities/settings/rewards_activity.dart';
import 'package:solomas/activities/settings/setting_activity.dart';
import 'package:solomas/blocs/settings/logout_bloc.dart';
import 'package:solomas/helpers/api_constants.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/web_view_helper.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../blocs/home/user_profile_bloc.dart';
import '../../helpers/space.dart';
import '../../model/user_profile_model.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/text_styles.dart';

class DrawerManu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MenuPage();
}

class _MenuPage extends State<DrawerManu> {
//============================================================
// ** Properties **
//============================================================

  get children => null;
  LogoutBloc? _logoutBloc;
  String? mineReferralCode,
      mineProfilePic = "",
      mineUserName = "",
      mineUserStatus = "",
      ageUser = "";
  bool progressShow = false;
  bool isFirstTimeDetails = false;
  var statusTitle;
  CommonHelper? _commonHelper;
  UserProfileBloc? _userProfileBloc;
  Data? _aList;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _userProfileBloc = UserProfileBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getUserData());

    _getProfileData();

    PrefHelper.getReferralCode().then((onValue) {
      setState(() {
        mineReferralCode = onValue;
      });
    });
    PrefHelper.getUserProfilePic().then((picture) {
      setState(() {
        mineProfilePic = picture;
      });
    });

    PrefHelper.getUserName().then((onValue) {
      setState(() {
        Constants.printValue("value: " + onValue.toString());
        mineUserName = onValue;
      });
    });

    PrefHelper.getUserStatus().then((onValue) {
      setState(() {
        Constants.printValue("value: " + onValue.toString());
        mineUserStatus = onValue;
      });
    });

    PrefHelper.getUserAge().then((onValue) {
      setState(() {
        Constants.printValue("value: " + onValue.toString());

        ageUser = onValue;
      });
    });
    _logoutBloc = LogoutBloc();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return _mainBody(context);
  }

  @override
  void dispose() {
    _logoutBloc?.dispose();
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _mainBody(BuildContext context) {
    return SizedBox(
      width: _commonHelper?.screenWidth * 0.75,
      child: Drawer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Container(
                      height: _commonHelper?.screenHeight * 0.09,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: SoloColor.graniteGray.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(50),
                        color: SoloColor.cultured,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            new MaterialPageRoute(
                                builder: (_) =>
                                    new ProfileTab(isFromHome: true)),
                          )
                              .then((mapData) {
                            _getProfileData();
                            setState(() {});
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 7, horizontal: 7),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: mineProfilePic.toString(),
                                  height: _commonHelper?.screenHeight * 0.07,
                                  width: _commonHelper?.screenHeight * 0.07,
                                  placeholder: (context, url) =>
                                      imagePlaceHolder(),
                                  errorWidget: (context, url, error) =>
                                      imagePlaceHolder(
                                    height: _commonHelper?.screenWidth * 0.15,
                                    width: _commonHelper?.screenWidth * 0.15,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: _commonHelper?.screenWidth * 0.02),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      mineUserName == null
                                          ? ""
                                          : mineUserName.toString(),
                                      style: SoloStyle.blackBoldMedium),
                                  space(height: 2),
                                  StreamBuilder(
                                      stream: _userProfileBloc?.userProfileList,
                                      builder: (context,
                                          AsyncSnapshot<UserProfileModel>
                                              snapshot) {
                                        if (snapshot.hasData) {
                                          if (_aList == null) {
                                            _aList = snapshot.data?.data;

                                            statusTitle =
                                                _aList?.response?.statusTitle;
                                          }
                                          return Text(
                                              statusTitle == null
                                                  ? ""
                                                  : statusTitle
                                                      .toString()
                                                      .toUpperCase(),
                                              style: SoloStyle.grayBold);
                                        } else if (snapshot.hasError) {
                                          return Container();
                                        }

                                        return Container();
                                      })
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: _commonHelper?.screenHeight * 0.015,
                    ),
                    _drawerList(
                        icon: IconsHelper.inbox,
                        title: "Inbox",
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MessagesActivity()));
                        }),
                    _drawerList(
                        icon: IconsHelper.notification,
                        title: "Notification",
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NotificationActivity()));
                        }),
                    _drawerList(
                        icon: IconsHelper.cart,
                        title: "Local Shop",
                        onTap: () {
                          _commonHelper?.startActivity(WebViewHelper(
                              _commonHelper as CommonHelper,
                              ApiConstants.API_WV_SHOP,
                              'Shop'.toUpperCase()));
                        }),
                    _drawerList(
                        icon: IconsHelper.starReward,
                        title: "Reward Points",
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => RewardsActivity()));
                        }),
                    _drawerList(
                        icon: IconsHelper.setting,
                        title: "Settings",
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SettingActivity()));
                        }),
                    _drawerList(
                        icon: IconsHelper.logout,
                        title: "Log Out",
                        onTap: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) =>
                                  _showBottomSheet());
                        }),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: InkWell(
                  onTap: () {
                    Share.share(
                        "No travel buddy? No problem! Use the Solo Mas app to find "
                        "solo masqueraders on the road! Use the referral code $mineReferralCode"
                        " when signing up to redeem your reward points! \n\n"
                        " https://apps.apple.com/us/app/solo-mas/id1522424256 \n\n"
                        "https://play.google.com/store/apps/details?id=com.solomas1.android",
                        subject: 'Invite');
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(IconsHelper.share,
                          width: _commonHelper?.screenWidth * 0.065),
                      SizedBox(
                        width: _commonHelper?.screenWidth * 0.056,
                      ),
                      Text("Share", style: SoloStyle.blackBold),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget _showBottomSheet() {
    return CupertinoActionSheet(
      title: Text("Log Out",
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(
        'Are you sure you want to logout?',
        style: TextStyle(
            color: SoloColor.spanishGray,
            fontSize: Constants.FONT_MEDIUM,
            fontWeight: FontWeight.w400),
      ),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Logout",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _onLogoutTap();
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancel",
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

  Widget _drawerList({String? icon, String? title, Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SvgPicture.asset(icon!, width: _commonHelper?.screenWidth * 0.08),
            const SizedBox(
              width: 15,
            ),
            Text(title!, style: SoloStyle.blackBold),
          ],
        ),
      ),
    );
  }

  Widget _showSupportBottomSheet() {
    return CupertinoActionSheet(
      title: Text("Solo Mas Support",
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text("If you have any query tap on contact support?",
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Contact Support",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _sendMail();
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: SoloColor.black,
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
  _getProfileData() {
    _hideProgress();
    PrefHelper.getUserProfilePic().then((picture) {
      setState(() {
        mineProfilePic = picture;
      });
    });

    PrefHelper.getUserName().then((onValue) {
      setState(() {
        Constants.printValue("value: " + onValue.toString());
        mineUserName = onValue;
      });
    });

    PrefHelper.getUserAge().then((onValue) {
      setState(() {
        Constants.printValue("value: " + onValue.toString());

        ageUser = onValue;
      });
    });
  }

  void _showProgress() {
    setState(() {
      progressShow = true;
    });
  }

  void _hideProgress() {
    setState(() {
      progressShow = false;
    });
  }

  _sendMail() async {
    final Uri _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'info@solomasapp.com',
        queryParameters: {'subject': ''});

    launch(_emailLaunchUri.toString());
  }

  void _onLogoutTap() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        PrefHelper.getAuthToken().then((token) {
          _logoutBloc?.userLogout('', token.toString()).then((onSuccess) {
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

  void _getUserData() {
    String? authToken, mineUserId;

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          print("apihello" + authToken.toString());
          _userProfileBloc
              ?.getUserProfileData(token.toString(), "")
              .then((onValue) {
            _hideProgress();
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
}
//============================================================
// ** Firebase Function **
//============================================================
