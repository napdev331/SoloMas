import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/activities/settings/reward_address_activity.dart';
import 'package:solomas/blocs/settings/get_rewards_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/reward_items_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';

class RewardsActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RewardState();
  }
}

class _RewardState extends State<RewardsActivity> {
//============================================================
// ** Properties **
//============================================================

  bool _progressShow = false, _isStatusTap = false;
  int totalEarnedPoints = 0, totalStatusPoints = 0;
  String? authToken, statusTitle = "";
  List<RewardItem> _aList = [];
  CommonHelper? _commonHelper;
  GetRewardsBloc? _rewardsBloc;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();

    _rewardsBloc = GetRewardsBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getRewardItemData());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
          child: _appBar(context),
        ),
      ),
      body: StreamBuilder(
          stream: _rewardsBloc?.rewardItemList,
          builder: (context, AsyncSnapshot<RewardItemModel> snapshot) {
            if (snapshot.hasData) {
              if (_aList.isEmpty) {
                totalEarnedPoints = snapshot.data?.data?.totalRewardPoint ?? 0;

                totalStatusPoints = snapshot.data?.data?.totalStatusPoint ?? 0;

                statusTitle = snapshot.data?.data?.statusTitle.toString();

                _aList = snapshot.data?.data?.rewardItem ?? [];
              }

              return mainItem();
            } else if (snapshot.hasError) {
              return Container();
            }

            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
          }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget mainItem() {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              //                   <--- left side
              color: Colors.black,
              width: 0.2,
            ))),
            child: TabBar(
                indicatorColor: Colors.black,
                unselectedLabelColor: const Color(0xff969696),
                labelColor: Colors.black,
                tabs: <Widget>[
                  commonTab(StringHelper.Reward.toUpperCase()),
                  commonTab(StringHelper.Balance.toUpperCase()),
                ]),
          ),
          Expanded(
            child: TabBarView(
              children: [_reward(), _balance()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.RewardPoints,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget totalPoints(String point, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 150,
        width: _commonHelper?.screenWidth,
        decoration: BoxDecoration(boxShadow: [
          // BoxShadow(
          //     color: Color(0xffe8e8e8),
          //     blurRadius: 5,
          //     spreadRadius: 0.50,
          //     offset: Offset(1, 1)),
        ]),
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
                    point,
                    style: SoloStyle.blackW900BMedium,
                  ),
                  Text(
                    title,
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

  Widget earnedPointDetails(RewardItem aList) {
    return Padding(
      padding: EdgeInsets.only(top: _commonHelper?.screenHeight * 0.01),
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
                          imageUrl: aList.icon.toString(),
                          // height: _commonHelper?.screenHeight * 0.08,
                          // width: _commonHelper?.screenWidth * 0.14,
                          height: 48,
                          width: 48,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => imagePlaceHolder(),
                          errorWidget: (context, url, error) =>
                              imagePlaceHolder()),
                    ),
                    Container(
                      width: _commonHelper?.screenWidth * 0.40,
                      padding: EdgeInsets.only(left: DimensHelper.halfSides),
                      child: Text(aList.name.toString(),
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
                              aList.pricePoint.toString(),
                              style: SoloStyle.blackBoldLow,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: SizedBox(
                        width: _commonHelper?.screenWidth * 0.18,
                        height: _commonHelper?.screenHeight * 0.040,
                        child: ElevatedButton(
                          onPressed: () {
                            if (aList.isUnlock == true) {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RewardAddressActivity(
                                                  rewardItemDetails: aList,
                                                  totalPoints: totalEarnedPoints
                                                      .toString())))
                                  .then((onValue) {
                                _showProgress();

                                _aList.clear();

                                _getRewardItemData();
                              });
                            } else {
                              showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      _commonHelper!.successBottomSheet(
                                          "Reward Points",
                                          "You don't have enough reward points to buy this item.",
                                          false));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SoloColor.blueAssent,
                            padding: const EdgeInsets.all(4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: Text(
                            StringHelper.buyNow.toUpperCase(),
                            style: SoloStyle.whiteSmall,
                          ),
                        ),
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

  Widget commonTab(String tabText) {
    return Tab(
      child: Text(
        tabText,
        style: SoloStyle.blackLetterSpacing,
      ),
    );
  }

  Padding _balance() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 15, right: 10, bottom: 5),
      child: SingleChildScrollView(
          child: totalPoints(
        totalStatusPoints.toString(),
        StringHelper.TotalBalance,
      )),
    );
  }

  Padding _reward() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 15, right: 10, bottom: 5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            totalPoints(totalEarnedPoints.toString(), StringHelper.yourPoints),
            _aList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: _aList.length,
                    itemBuilder: (context, index) {
                      return earnedPointDetails(_aList[index]);
                    },
                  ),
          ],
        ),
      ),
    );
  }

//============================================================
// ** Helper Functions **
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

  void _getRewardItemData() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _rewardsBloc?.getRewardItems(token.toString()).then((onValue) {
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

//============================================================
// ** Firebase Functions **
//============================================================
}
