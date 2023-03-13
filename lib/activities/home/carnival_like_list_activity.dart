import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/blocs/group/group_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/carnival_feed_like_list_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';

class CarnivalLikeListActivity extends StatefulWidget {
  final String carnivalFeedId;

  CarnivalLikeListActivity(this.carnivalFeedId);

  @override
  State<StatefulWidget> createState() {
    return _CarnivalLikeListState();
  }
}

class _CarnivalLikeListState extends State<CarnivalLikeListActivity> {
//============================================================
// ** Properties **
//============================================================
  CommonHelper? _commonHelper;
  String? authToken, mineUserId;
  GroupBloc? _groupBloc;
  List<CarnivalLikeList>? _aList;
  List<CarnivalLikeList> _searchList = [];

//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  void initState() {
    super.initState();
    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });
    _groupBloc = GroupBloc();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getFeedLikeList());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 0),
          child: appBar(),
        ),
      ),
      body: StreamBuilder(
          stream: _groupBloc?.carnivalLikeList,
          builder: (context, AsyncSnapshot<CarnivalLikeListModel> snapshot) {
            if (snapshot.hasData) {
              if (_aList == null) {
                _aList = snapshot.data?.data?.carnivalLikeList;
                _searchList.addAll(_aList ?? []);
              }
              return _likeListData();
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
    _groupBloc?.dispose();
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================
  Widget appBar() {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      backOnTap: () {
        _commonHelper?.closeActivity();
      },
      appbarTitle: StringHelper.likes,
    );
  }

  Widget _likeListData() {
    return Stack(
      children: [
        ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Container(
              height: 45,
              width: _commonHelper?.screenWidth,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                  top: DimensHelper.sidesMargin,
                  left: DimensHelper.sidesMargin,
                  right: DimensHelper.sidesMargin),
              child: searchBar(),
            ),
            Visibility(
              visible: _searchList.isEmpty && _aList!.isNotEmpty,
              child: Container(
                height: _commonHelper?.screenHeight * .75,
                child: Center(
                  child: Text(StringHelper.noUserFoundMsg,
                      style: SoloStyle.blackNormalMedium),
                ),
              ),
            ),
            Visibility(
              visible: _aList!.isEmpty,
              child: Container(
                height: _commonHelper?.screenHeight * .7,
                child: Center(
                  child: Text(StringHelper.noLikePostMsg,
                      style: SoloStyle.blackNormalMedium),
                ),
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(top: DimensHelper.halfSides),
                physics: ScrollPhysics(),
                itemCount: _searchList.length,
                itemBuilder: (BuildContext context, int index) {
                  return mainItem(index);
                })
          ],
        )
      ],
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================
  Widget searchBar() {
    return TextFormField(
      style: TextStyle(
          fontSize: Constants.FONT_MEDIUM, color: SoloColor.spanishGray),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      maxLines: 1,
      minLines: 1,
      scrollPadding: EdgeInsets.zero,
      autofocus: false,
      onChanged: _onSearchTextChanged,
      cursorColor: SoloColor.blue,
      decoration: InputDecoration(
          hintText: StringHelper.searchLike,
          fillColor: SoloColor.lotion,
          filled: true,
          contentPadding: EdgeInsets.symmetric(),
          prefixIcon:
              Icon(Icons.search, color: SoloColor.spanishGray, size: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(DimensHelper.sidesMarginDouble)),
            borderSide: BorderSide(color: SoloColor.silverSand, width: 0.0),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(DimensHelper.sidesMarginDouble)),
              borderSide: BorderSide(color: SoloColor.silverSand, width: 0.0)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(DimensHelper.sidesMarginDouble)),
              borderSide: BorderSide(color: SoloColor.silverSand, width: 0.0))),
    );
  }

  Widget mainItem(int index) {
    return Container(
      padding: EdgeInsets.only(
          left: DimensHelper.sidesMargin,
          right: DimensHelper.sidesMargin,
          top: DimensHelper.halfSides,
          bottom: DimensHelper.halfSides),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_searchList[index].userId == mineUserId) {
                _commonHelper?.startActivity(ProfileTab(isFromHome: true));
              } else {
                _commonHelper?.startActivity(UserProfileActivity(
                    userId: _searchList[index].userId.toString()));
              }
            },
            child: ClipOval(
                child: CachedNetworkImage(
                    imageUrl: _searchList[index].userProfilePic.toString(),
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => imagePlaceHolder(),
                    errorWidget: (context, url, error) => imagePlaceHolder())),
          ),
          Container(
            width: _commonHelper?.screenWidth * .65,
            padding: EdgeInsets.only(
                left: DimensHelper.halfSides,
                right: DimensHelper.sidesMarginDouble),
            child: Text(_searchList[index].userName.toString(),
                style: SoloStyle.blackNormalMedium),
          ),
          Spacer(),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(left: DimensHelper.halfSides),
            child: SvgPicture.asset(
              IconsHelper.like,
              height: 15,
              width: 15,
              color: SoloColor.blue,
            ),
          ),
        ],
      ),
    );
  }

//============================================================
// ** Helper Functions **
//============================================================
  void _getFeedLikeList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          _groupBloc?.getLikeList(token.toString(), widget.carnivalFeedId);
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _onSearchTextChanged(String text) async {
    _searchList.clear();
    if (text.isEmpty) {
      _searchList.addAll(_aList ?? []);
      setState(() {});
      return;
    }
    _aList?.forEach((carnivalDetail) {
      if (carnivalDetail.userName!.toUpperCase().contains(text.toUpperCase())) {
        _searchList.add(carnivalDetail);
      }
    });
    setState(() {});
  }
//============================================================
// ** Firebase Function **
//============================================================

}
