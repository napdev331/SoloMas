import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:solomas/blocs/settings/notification_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/notification_list_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../common_helpers/app_bar.dart';

class NotificationActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Notification();
  }
}

class _Notification extends State<NotificationActivity> {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  NotificationBloc? _notificationBloc;
  String? authToken;
  List<NotificationList> _aList = [];

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _notificationBloc = NotificationBloc();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getNotificationList());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    Widget notificationDetail(NotificationList aList) {
      return InkWell(
        onTap: () {
          Map msgMap = Map<String, dynamic>();

          msgMap['id'] = aList.id;

          _commonHelper?.initIntent(aList.type.toString(), msgMap);
        },
        child: Container(
          padding: EdgeInsets.only(
              left: DimensHelper.sidesMargin,
              right: DimensHelper.sidesMargin,
              top: DimensHelper.tinySides,
              bottom: DimensHelper.tinySides),
          child: Row(
            children: [
              ClipOval(
                  child: CachedNetworkImage(
                      imageUrl: aList.senderProfilePic.toString(),
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => imagePlaceHolder(),
                      errorWidget: (context, url, error) =>
                          imagePlaceHolder())),
              Container(
                  width: _commonHelper?.screenWidth * .7,
                  margin: EdgeInsets.only(
                      left: DimensHelper.halfSides,
                      right: DimensHelper.halfSides),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: RichText(
                          maxLines: 2,
                          text: TextSpan(
                            text: '${aList.senderName.toString()}',
                            style: TextStyle(
                                fontSize: Constants.FONT_MEDIUM,
                                color: SoloColor.electricPink,
                                fontWeight: FontWeight.w500),
                            children: <TextSpan>[
                              TextSpan(
                                  text: aList.message
                                      .toString()
                                      .split(aList.senderName.toString())
                                      .last,
                                  style: TextStyle(
                                      fontSize: Constants.FONT_MEDIUM,
                                      color: SoloColor.black,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: DimensHelper.smallSides),
                        child: Text(
                          _commonHelper!
                              .getTimeDifference(aList.creationDate ?? 0),
                          style: TextStyle(
                              color: Colors.grey, fontSize: Constants.FONT_LOW),
                        ),
                      )
                    ],
                  )),
              // Spacer(),
              // Container(
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       // Visibility(
              //       //   visible: aList.senderId!.isNotEmpty,
              //       //   child: GestureDetector(
              //       //     onTap: () {
              //       //
              //       //       _commonHelper?.startActivity(
              //       //           ChatActivity(aList.senderName.toString(), aList.senderId.toString()));
              //       //
              //       //     },
              //       //     child: Image.asset(
              //       //       "assets/images/ic_chat_black.png",
              //       //       height: 28,
              //       //       width: 28,
              //       //     ),
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      );
    }

    Widget _noNotificationWarning() {
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(DimensHelper.btnTopMargin),
          child: Text(StringHelper.noNotificationMsg,
              style: TextStyle(
                  fontSize: Constants.FONT_MEDIUM,
                  fontWeight: FontWeight.normal,
                  color: SoloColor.spanishGray)));
    }

    Widget _mainItem() {
      return _aList.isNotEmpty
          ? Container(
              width: _commonHelper?.screenWidth,
              height: _commonHelper?.screenHeight,
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(
                          color: SoloColor.platinum,
                        ),
                      ),
                  itemCount: _aList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return notificationDetail(_aList[index]);
                  }),
            )
          : _noNotificationWarning();
    }

    return SoloScaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: _appBar(),
          ),
        ),
        body: _mainBody(_mainItem));
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _mainBody(Widget _mainItem()) {
    return StreamBuilder(
        stream: _notificationBloc?.notificationList,
        builder: (context, AsyncSnapshot<NotificationListModel> snapshot) {
          if (snapshot.hasData) {
            if (_aList.isEmpty) {
              _aList = snapshot.data?.data?.notificationList ?? [];
            }

            return _mainItem();
          } else if (snapshot.hasError) {
            return Container();
          }

          return Center(child: CircularProgressIndicator());
        });
  }

  Widget _appBar() {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.notification,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

//============================================================
// ** Helper Function **
//============================================================

  void _getNotificationList() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _notificationBloc?.getNotification(token.toString());
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }
}
