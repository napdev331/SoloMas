import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/blocs/event_details/events_like_list_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/events_like_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../common_helpers/app_bar.dart';

class EventsLikeActivity extends StatefulWidget {
  final String eventId;

  EventsLikeActivity(this.eventId);

  @override
  State<StatefulWidget> createState() {
    return _LikesState();
  }
}

class _LikesState extends State<EventsLikeActivity> {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  EventsLikeListBloc? _eventsLikeListBloc;
  List<EventLikeList>? _aList;
  List<EventLikeList>? _searchList = [];
  String? authToken, mineUserId;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();

    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });

    _eventsLikeListBloc = EventsLikeListBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getFeedLikeList());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: _appBar(),
        ),
      ),
      body: _mainBody(_likeListData),
    );
  }

  @override
  void dispose() {
    _eventsLikeListBloc?.dispose();
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _mainBody(Widget _likeListData()) {
    return StreamBuilder(
        stream: _eventsLikeListBloc?.likeFeedList,
        builder: (context, AsyncSnapshot<EventsLikeModel> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              if (_aList == null) {
                _aList = snapshot.data?.data?.eventLikeList;

                _searchList?.addAll(_aList ?? []);
              }
            }

            return _likeListData();
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
      appbarTitle: StringHelper.likes,
      backOnTap: () {
        Navigator.pop(context);
      },
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
          hintText: StringHelper.search,
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
              if (_searchList?[index].userId == mineUserId) {
                _commonHelper?.startActivity(ProfileTab(isFromHome: true));
              } else {
                _commonHelper?.startActivity(UserProfileActivity(
                    userId: _searchList![index].userId.toString()));
              }
            },
            child: ClipOval(
                child: CachedNetworkImage(
                    imageUrl: _searchList![index].userProfilePic.toString(),
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
            child: Text(_searchList![index].userName.toString(),
                style: TextStyle(fontSize: Constants.FONT_MEDIUM)),
          ),
          Spacer(),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(left: DimensHelper.halfSides),
            child: SvgPicture.asset(
              IconsHelper.like,
              height: 15,
              width: 15,
              color: SoloColor.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _likeListData() {
    return Stack(
      children: [
        ListView(
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
              visible: _searchList!.isEmpty && _aList!.isNotEmpty,
              child: Container(
                height: _commonHelper?.screenHeight * .75,
                child: Center(
                  child: Text(StringHelper.noUserFoundMsg,
                      style: TextStyle(
                          color: SoloColor.black,
                          fontSize: Constants.FONT_MEDIUM,
                          fontWeight: FontWeight.normal)),
                ),
              ),
            ),
            Visibility(
              visible: _aList!.isEmpty,
              child: Container(
                height: _commonHelper?.screenHeight * .75,
                child: Center(
                  child: Text(StringHelper.noLikeEventMsg,
                      style: TextStyle(
                          color: SoloColor.black,
                          fontSize: Constants.FONT_MEDIUM,
                          fontWeight: FontWeight.normal)),
                ),
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(top: DimensHelper.halfSides),
                physics: ScrollPhysics(),
                itemCount: _searchList?.length,
                itemBuilder: (BuildContext context, int index) {
                  return mainItem(index);
                })
          ],
        )
      ],
    );
  }

//============================================================
// ** Helper Function **
//============================================================

  void _getFeedLikeList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _eventsLikeListBloc?.eventsLike(token.toString(), widget.eventId);
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  _onSearchTextChanged(String text) async {
    _searchList?.clear();

    if (text.isEmpty) {
      _searchList?.addAll(_aList ?? []);

      setState(() {});

      return;
    }

    _aList?.forEach((carnivalDetail) {
      if (carnivalDetail.userName!.toUpperCase().contains(text.toUpperCase())) {
        _searchList?.add(carnivalDetail);
      }
    });

    setState(() {});
  }
}
