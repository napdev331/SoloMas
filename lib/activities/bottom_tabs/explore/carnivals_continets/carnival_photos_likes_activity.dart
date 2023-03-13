import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/blocs/explore/carnival_photos_like_list_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/carnival_photos_like_listing.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../../../resources_helper/common_widget.dart';
import '../../../../resources_helper/screen_area/scaffold.dart';

class CarnivalPhotosLikeActivity extends StatefulWidget {
  final String carnivalPhotoId;

  CarnivalPhotosLikeActivity(this.carnivalPhotoId);

  @override
  State<StatefulWidget> createState() {
    return _LikesState();
  }
}

class _LikesState extends State<CarnivalPhotosLikeActivity> {
  CommonHelper? _commonHelper;

  CarnivalPhotosLikeBloc? _carnivalPhotosLikeBloc;

  List<CarnivalPhotoLikeList>? _aList;

  List<CarnivalPhotoLikeList>? _searchList = [];

  String? authToken, mineUserId;

  _onSearchTextChanged(String text) async {
    _searchList?.clear();

    if (text.isEmpty) {
      _searchList?.addAll(_aList!);

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

  @override
  void initState() {
    super.initState();

    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });

    _carnivalPhotosLikeBloc = CarnivalPhotosLikeBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getFeedLikeList());
  }

  void _getFeedLikeList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _carnivalPhotosLikeBloc?.carnivalPhotoLike(
              token.toString(), widget.carnivalPhotoId);
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

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
                borderSide:
                    BorderSide(color: SoloColor.silverSand, width: 0.0)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(DimensHelper.sidesMarginDouble)),
                borderSide:
                    BorderSide(color: SoloColor.silverSand, width: 0.0))),
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
                errorWidget: (context, url, error) => imagePlaceHolder(),
              )),
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
              child: Image.asset(
                'images/likeWhite.png',
                height: 15,
                width: 15,
                color: SoloColor.blue,
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
                    child: Text(StringHelper.noLikePostMsg,
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

    return SoloScaffold(
      appBar: AppBar(
        backgroundColor: SoloColor.blue,
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            GestureDetector(
              onTap: () {
                _commonHelper?.closeActivity();
              },
              child: Container(
                width: 25,
                height: 25,
                alignment: Alignment.centerLeft,
                child: Image.asset('images/back_arrow.png'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(StringHelper.likes,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontSize: Constants.FONT_APP_TITLE)),
            )
          ],
        ),
      ),
      body: StreamBuilder(
          stream: _carnivalPhotosLikeBloc?.likeFeedList,
          builder: (context, AsyncSnapshot<CarnivalPhotosLikeModel> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                if (_aList == null) {
                  _aList = snapshot.data?.data?.carnivalPhotoLikeList;

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
          }),
    );
  }

  @override
  void dispose() {
    _carnivalPhotosLikeBloc?.dispose();

    super.dispose();
  }
}
