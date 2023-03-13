import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/blocs/settings/get_rewards_bloc.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/reward_items_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/widgets/btn_widget.dart';

import '../../helpers/common_helper.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/strings.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';
import '../common_helpers/app_button.dart';
import 'edit_reward_address_activity.dart';

class RewardAddressActivity extends StatefulWidget {
  final RewardItem? rewardItemDetails;
  final String? totalPoints;

  RewardAddressActivity({this.rewardItemDetails, this.totalPoints});

  @override
  State<StatefulWidget> createState() {
    return _RewardAddressState();
  }
}

class _RewardAddressState extends State<RewardAddressActivity> {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  bool _progressShow = false;
  GetRewardsBloc? _rewardsBloc;
  String balancePoints = "";
  var mineUserAddress;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    PrefHelper.getUserAddress().then((onValue) {
      setState(() {
        var address = json.decode(onValue.toString());
        mineUserAddress = address;
      });
    });
    _rewardsBloc = GetRewardsBloc();
    balancePoints = (int.parse(widget.totalPoints.toString()).toInt() -
            widget.rewardItemDetails!.pricePoint!.toInt())
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SafeArea(
      child: SoloScaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 0),
            child: _appBar(),
          ),
        ),
        body: Stack(
          children: [
            ListView(
              children: [
                addressDetails(),
                selectedItemDetails(),
                balancePoint(),
                Container(
                  alignment: Alignment.center,
                  child: ButtonWidget(
                    height: _commonHelper?.screenHeight,
                    width: _commonHelper?.screenWidth * .7,
                    onPressed: () {
                      FocusScope.of(context).unfocus();

                      _onContinueTap();
                    },
                    btnText: StringHelper.Continue.toUpperCase(),
                  ),
                )
              ],
            ),
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
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _appBar() {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.addressD.toUpperCase(),
      backOnTap: () {
        _commonHelper?.closeActivity();
      },
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget addressDetails() {
    return Container(
      margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
      padding: EdgeInsets.all(DimensHelper.sidesMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Visibility(
            visible: mineUserAddress != null && mineUserAddress['name'] != null,
            child: Container(
              alignment: Alignment.centerLeft,
              width: _commonHelper?.screenWidth * .5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      (mineUserAddress != null &&
                              mineUserAddress['name'] != null)
                          ? mineUserAddress['name']
                          : "",
                      textAlign: TextAlign.left,
                      style: SoloStyle.blackW500FontAppTitle),
                  Padding(
                    padding: EdgeInsets.only(top: DimensHelper.sidesMargin),
                    child: RichText(
                      text: TextSpan(
                        text: (mineUserAddress != null &&
                                mineUserAddress['phoneNumber'] != null)
                            ? StringHelper.address + StringHelper.semi
                            : "",
                        style: SoloStyle.spanishGrayBoldFontMedium,
                        children: <TextSpan>[
                          TextSpan(
                              text: (mineUserAddress != null &&
                                      mineUserAddress['street'] != null &&
                                      mineUserAddress['city'] != null &&
                                      mineUserAddress['state'] != null)
                                  ? mineUserAddress['street'] +
                                      " " +
                                      mineUserAddress['city'] +
                                      " " +
                                      mineUserAddress['state']
                                  : "",
                              style: SoloStyle.spanishGrayNormalFontMedium),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: DimensHelper.smallSides),
                    child: RichText(
                      text: TextSpan(
                        text: (mineUserAddress != null &&
                                mineUserAddress['phoneNumber'] != null)
                            ? StringHelper.rewardPhoneNumber
                            : "",
                        style: SoloStyle.spanishGrayBoldFontMedium,
                        children: <TextSpan>[
                          TextSpan(
                              text: (mineUserAddress != null &&
                                      mineUserAddress['phoneNumber'] != null)
                                  ? mineUserAddress['phoneNumber']
                                      .replaceAll("+1", "")
                                  : "",
                              style: SoloStyle.spanishGrayNormalFontMedium),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: DimensHelper.smallSides),
                    child: RichText(
                      text: TextSpan(
                        text: (mineUserAddress != null &&
                                mineUserAddress['phoneNumber'] != null)
                            ? StringHelper.rewardEmail
                            : "",
                        style: SoloStyle.spanishGrayBoldFontMedium,
                        children: <TextSpan>[
                          TextSpan(
                              text: (mineUserAddress != null &&
                                      mineUserAddress['email'] != null)
                                  ? mineUserAddress['email']
                                  : "",
                              style: SoloStyle.spanishGrayNormalFontMedium),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          AppButton(
            color: SoloColor.batteryChargedBlue,
            height: _commonHelper?.screenHeight * 0.045,
            width: _commonHelper?.screenWidth * 0.35,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditRewardAddress(
                            args: EditAddressArguments(
                                name: mineUserAddress['name'] ?? "",
                                city: mineUserAddress['city'] ?? "",
                                phoneNumber:
                                    mineUserAddress['phoneNumber'] ?? "",
                                email: mineUserAddress['email'] ?? "",
                                state: mineUserAddress['state'] ?? "",
                                street: mineUserAddress['street'] ?? ""),
                          ))).then((value) {
                PrefHelper.getUserAddress().then((onValue) {
                  setState(() {
                    var address = json.decode(onValue.toString());

                    mineUserAddress = address;
                  });
                });
              });
            },
            text: (mineUserAddress != null && mineUserAddress['name'] != null)
                ? StringHelper.editAddress
                : StringHelper.addAddress,
          ),
        ],
      ),
    );
  }

  Widget divider() {
    return Container(
      margin: EdgeInsets.only(
          left: DimensHelper.sidesMargin, right: DimensHelper.sidesMargin),
      child: Divider(
        height: 1,
        color: SoloColor.spanishGray.withOpacity(0.2),
      ),
    );
  }

  Widget selectedItemDetails() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.white),
        child: Container(
          decoration: BoxDecoration(
              color: SoloColor.lightYellow,
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: SoloColor.graniteGray.withOpacity(0.2))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CachedNetworkImage(
                        imageUrl: widget.rewardItemDetails!.icon.toString(),
                        // height: _commonHelper?.screenHeight * 0.08,
                        // width: _commonHelper?.screenWidth * 0.14,
                        height: 48,
                        width: 48,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Image.asset(
                            'images/dummy_profile.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover),
                      ),
                    ),
                    Container(
                      width: _commonHelper?.screenWidth * 0.5,
                      padding: EdgeInsets.only(left: DimensHelper.halfSides),
                      child: Text(widget.rewardItemDetails!.name.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: SoloStyle.blackLower),
                    )
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: SvgPicture.asset(IconsHelper.starReward,
                                width: 22),
                          ),
                          Container(
                            width: _commonHelper?.screenWidth * 0.08,
                            child: Text(
                              widget.rewardItemDetails!.pricePoint.toString(),
                              style: SoloStyle.blackBoldLow,
                            ),
                          ),
                        ],
                      ),
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

  Widget balancePoint() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 150,
        width: _commonHelper?.screenWidth,
        decoration: BoxDecoration(boxShadow: []),
        child: Stack(children: [
          Image.asset(
            ImagesHelper.reward_back_ground,
            fit: BoxFit.cover,
            width: _commonHelper?.screenWidth,
          ),
          Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    balancePoints.toString(),
                    style: SoloStyle.blackW900BMedium,
                  ),
                  Text(
                    StringHelper.TotalBalance,
                    style: SoloStyle.blackW700Blow,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

//============================================================
// ** Helper Function **
//============================================================

  void _onContinueTap() {
    if (mineUserAddress['name'] == null) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _commonHelper!.successBottomSheet(
              "Add Address", "Please add pick up address to continue.", false));

      return;
    } else if (mineUserAddress['state'] == null) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _commonHelper!.successBottomSheet(
              "Add State", "Please add valid state to continue.", false));

      return;
    } else if (mineUserAddress['street'] == null) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _commonHelper!.successBottomSheet(
              "Add Street",
              "Please add valid street name to continue.",
              false));

      return;
    }

    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var addressDetails = json.encode({
          'name': mineUserAddress['name'] ?? "",
          'street': mineUserAddress['street'] ?? "",
          'city': mineUserAddress['city'] ?? "",
          'state': mineUserAddress['state'] ?? "",
          'phoneNumber': mineUserAddress['phoneNumber'] ?? "",
          'email': mineUserAddress['email'] ?? ""
        });

        var body = json.encode({
          "rewardItemId": widget.rewardItemDetails?.sId,
          "address": addressDetails.toString(),
        });

        PrefHelper.getAuthToken().then((authToken) {
          _rewardsBloc
              ?.buyRewardItem(body.toString(), authToken.toString())
              .then((onSuccess) {
            _hideProgress();

            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _commonHelper!
                    .successBottomSheet("Get Reward Item",
                        "Reward Item order is placed successfully", true));
          }).catchError((onError) {
            _hideProgress();
          });
        });
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
