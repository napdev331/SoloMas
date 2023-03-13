import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/blocs/settings/blocked_users_model.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/block_users_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/space.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';

class BlockedUserActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BlockedUserState();
  }
}

class _BlockedUserState extends State<BlockedUserActivity> {
//============================================================
// ** Properties **
//============================================================

  String? authToken;
  CommonHelper? _commonHelper;
  BlockedUsersBloc? _blockedUsersBloc;
  bool _progressShow = false;
  List<BlockedUser>? _aList;
  ApiHelper? _apiHelper;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();

    _apiHelper = ApiHelper();

    _blockedUsersBloc = BlockedUsersBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getBlockedUserData());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: _appBar(),
        ),
      ),
      body: _mainBody(_mainItem),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _mainBody(Widget _mainItem()) {
    return StreamBuilder(
        stream: _blockedUsersBloc?.blockedUsersList,
        builder: (context, AsyncSnapshot<BlockedUserModel> snapshot) {
          if (snapshot.hasData) {
            if (_aList == null || _aList!.isEmpty) {
              _aList = snapshot.data?.data?.blockedUser;
            }

            return _mainItem();
          } else if (snapshot.hasError) {
            return Container();
          }

          return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
        });
  }

  Widget _appBar() {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.blockUser,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget profileImage(int index) {
    return ClipOval(
        child: CachedNetworkImage(
            imageUrl: _aList![index].userProfilePic.toString(),
            height: 70,
            width: 70,
            fit: BoxFit.cover,
            placeholder: (context, url) => imagePlaceHolder(),
            errorWidget: (context, url, error) => imagePlaceHolder()));
  }

  Widget peopleDetailCard(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipOval(
                  child: CachedNetworkImage(
                      imageUrl: _aList![index].userProfilePic.toString(),
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => imagePlaceHolder(),
                      errorWidget: (context, url, error) =>
                          imagePlaceHolder())),
              space(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _aList![index].userName.toString(),
                    style: SoloStyle.jetW500SmallMax,
                  ),
                  space(height: 5),
                ],
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {},
            child: unblockButton(index),
          )
        ],
      ),
    );
  }

  Widget _mainItem() {
    return Stack(
      children: [
        _aList!.isNotEmpty
            ? Container(
                height: _commonHelper?.screenHeight,
                width: _commonHelper?.screenWidth,
                child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Divider(
                            color: SoloColor.platinum,
                          ),
                        ),
                    itemCount: _aList!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return peopleDetailCard(index);
                    }),
              )
            : _noBlockedUserWarning(),
        Align(
          child: ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
          alignment: FractionalOffset.center,
        ),
      ],
    );
  }

  Widget unblockButton(index) {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _unBlockConfirmationSheet(
                _aList![index].blockUserId.toString()));
      },
      child: Container(
        height: 35,
        padding: EdgeInsets.only(left: 12, right: 16),
        decoration: BoxDecoration(
          border: Border.all(color: SoloColor.blue),
          borderRadius:
              BorderRadius.all(Radius.circular(DimensHelper.halfSides)),
        ),
        child: Center(
          child: Text(StringHelper.unBlock, style: SoloStyle.blueW500FontLow),
        ),
      ),
    );
  }

  Widget _noBlockedUserWarning() {
    return Container(
        color: Colors.white,
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text(StringHelper.noBlockedUsers,
            style: SoloStyle.spanishGrayNormalFontTop));
  }

  Widget _unBlockConfirmationSheet(String blockUserId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.unBlock, style: SoloStyle.blackW500FontTop),
      message: Text(StringHelper.blockPopUpMessage,
          style: SoloStyle.spanishGrayW400FontMedium),
      actions: [
        CupertinoActionSheetAction(
          child:
              Text(StringHelper.unBlockYes, style: SoloStyle.blackW500FontTop),
          onPressed: () {
            Navigator.pop(context);

            _onUnBlockTap(blockUserId);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            StringHelper.unBlockNo,
            style: SoloStyle.blackW500FontTop,
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

  void _getBlockedUserData() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _blockedUsersBloc?.getUsers(token.toString()).then((onValue) {
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

  void _onUnBlockTap(String userId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({"blockUserId": userId});

        _apiHelper?.unBlockUser(body, authToken.toString()).then((onValue) {
          _aList?.clear();

          _getBlockedUserData();
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
//============================================================
// ** Firebase Function **
//============================================================
}
