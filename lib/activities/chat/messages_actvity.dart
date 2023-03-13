import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:solomas/activities/chat/chat_activity.dart';
import 'package:solomas/blocs/chat/messages_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/messages_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';
import '../home/user_profile_activity.dart';

class MessagesActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MessagesState();
  }
}

class _MessagesState extends State<MessagesActivity> {
//============================================================
// ** Properties **
//============================================================

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isShowProgress = false;
  String? authToken, mineUserId;
  List<ChatSummaryList> _searchList = [];
  List<ChatSummaryList>? _aList;
  CommonHelper? _commonHelper;
  MessagesBloc? _messagesBloc;
  ApiHelper? _apiHelper;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();

    _apiHelper = ApiHelper();

    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;
    });

    _messagesBloc = MessagesBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getChatSummary());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: _appBar(context),
        ),
      ),
      body: StreamBuilder(
          stream: _messagesBloc?.messagesList,
          builder: (context, AsyncSnapshot<MessagesModel> snapshot) {
            if (snapshot.hasData) {
              if (_aList == null || _aList!.isEmpty) {
                _aList = snapshot.data?.data?.chatSummaryList;

                _searchList.addAll(_aList ?? []);
              }

              return _mainItem();
            } else if (snapshot.hasError) {
              return _mainItem();
            }

            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
          }),
    );
  }

  @override
  void dispose() {
    _messagesBloc?.dispose();

    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.searchBarWithBackNavigation,
      appbarTitle: StringHelper.blockUser,
      hintText: StringHelper.searchHere,
      backOnTap: () {
        Navigator.pop(context);
      },
      onSearchBarTextChanged: _onSearchTextChanged,
    );
  }

  Widget _mainItem() {
    return Stack(
      children: [
        _searchList.isNotEmpty
            ? RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: Container(
                  height: _commonHelper?.screenHeight,
                  width: _commonHelper?.screenWidth,
                  child: ListView.builder(
                      itemCount: _searchList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return peopleDetailCard(index);
                      }),
                ),
              )
            : _noUserWarning(),
        Align(
          child:
              ProgressBarIndicator(_commonHelper?.screenSize, _isShowProgress),
          alignment: FractionalOffset.center,
        )
      ],
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================
  Widget searchBar() {
    return Container(
      margin: EdgeInsets.only(
          left: DimensHelper.sidesMargin,
          right: DimensHelper.sidesMargin,
          top: DimensHelper.halfSides),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(DimensHelper.sidesMarginDouble))),
        child: Row(
          children: [
            Expanded(
                child: Container(
              padding: EdgeInsets.all(DimensHelper.searchBarMargin),
              margin: EdgeInsets.only(left: DimensHelper.sidesMargin),
              child: TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                maxLines: 1,
                minLines: 1,
                autofocus: false,
                onChanged: _onSearchTextChanged,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z -]")),
                  LengthLimitingTextInputFormatter(30),
                ],
                decoration: InputDecoration.collapsed(
                    hintText: StringHelper.searchHere,
                    hintStyle: TextStyle(
                      fontSize: Constants.FONT_MEDIUM,
                    )),
              ),
            )),
            Container(
              padding: EdgeInsets.only(
                left: DimensHelper.halfSides,
                right: DimensHelper.sidesMargin,
              ),
              child: Image.asset(
                'images/ic_lg_bag.png',
                height: 20,
                width: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileImage(int index) {
    return ClipOval(
        child: CachedNetworkImage(
            imageUrl: _getProfilePic(index),
            height: 70,
            width: 70,
            fit: BoxFit.cover,
            placeholder: (context, url) => imagePlaceHolder(),
            errorWidget: (context, url, error) => imagePlaceHolder()));
  }

  // Widget userDetailsOld(int index){
  //   return Stack(
  //     children: [
  //       Container(
  //         margin: EdgeInsets.only(top: DimensHelper.halfSides),
  //         child: Card(
  //           shape: RoundedRectangleBorder(
  //               borderRadius:
  //               BorderRadius.circular(DimensHelper.sidesMargin)),
  //           elevation: 3.0,
  //           child: Container(
  //             margin: EdgeInsets.only(left: 80),
  //             padding: EdgeInsets.all(20),
  //             child: Row(
  //               children: [
  //                 Align(
  //                     alignment: Alignment.centerLeft,
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         Container(
  //                           width: _commonHelper?.screenWidth * .49,
  //                           child: Column(
  //                             crossAxisAlignment:
  //                             CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                   _getUserName(index).toUpperCase(),
  //                                   style: TextStyle(
  //                                       fontWeight: FontWeight.w500,
  //                                       color: SoloColor.black,
  //                                       fontSize:
  //                                       Constants.FONT_TOP)),
  //                             ],
  //                           ),
  //                         )
  //                       ],
  //                     )),
  //                 Align(
  //                     alignment: Alignment.centerRight,
  //                     child: Container(
  //                       child: Image.asset(
  //                           "assets/images/ic_chat_black.png"),
  //                     ))
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //       Container(
  //         margin: EdgeInsets.only(
  //             left: DimensHelper.sidesMargin,
  //             right: DimensHelper.sidesMargin),
  //         child: profileImage(index),
  //       ),
  //     ],
  //   );
  // }
  Widget userDetails(int index) {
    return Container(
      decoration: BoxDecoration(
          color: SoloColor.lightYellow,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: SoloColor.graniteGray.withOpacity(0.2))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _commonHelper?.startActivity(UserProfileActivity(
                        userId: _getUserId(index).toString()));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                        imageUrl: _getProfilePic(index),
                        height: 48,
                        width: 48,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => imagePlaceHolder(),
                        errorWidget: (context, url, error) =>
                            imagePlaceHolder()),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();

                    _commonHelper?.startActivity(
                      ChatActivity(_getUserName(index), _getUserId(index),
                          _getProfilePic(index)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          padding:
                              EdgeInsets.only(left: DimensHelper.halfSides),
                          child: Text(_getUserName(index),
                              style: SoloStyle.blackBoldMediumRoboto),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _noUserWarning() {
    return Container(
        color: Colors.white,
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text(StringHelper.noChatFound,
            style: TextStyle(
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishGray)));
  }

  Widget peopleDetailCard(int index) {
    return Container(
      margin: EdgeInsets.only(top: DimensHelper.halfSides),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();

            _commonHelper?.startActivity(
              ChatActivity(_getUserName(index), _getUserId(index),
                  _getProfilePic(index)),
            );
          },
          child: Container(
            margin: EdgeInsets.only(
                left: DimensHelper.sidesMargin,
                right: DimensHelper.sidesMargin),
            child: userDetails(index),
          ),
        ),
        secondaryActions: [
          IconSlideAction(
            closeOnTap: true,
            color: Colors.transparent,
            iconWidget:
                Icon(Icons.delete, color: SoloColor.spanishGray, size: 30),
            onTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => _showDeleteBottomSheet(
                      _searchList[index].conversationId.toString()));
            },
          ),
        ],
      ),
    );
  }

  Widget _showDeleteBottomSheet(String conversationId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.deleteChat,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.deleteChatMsg,
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.yes,
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _deleteChatTap(conversationId);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            StringHelper.no,
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

  void _showProgress() {
    setState(() {
      _isShowProgress = true;
    });
  }

  void _hideProgress() {
    setState(() {
      _isShowProgress = false;
    });
  }

  void _getChatSummary() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _messagesBloc?.getMessagesList(token.toString()).then((onValue) {
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

  void _deleteChatTap(String conversationId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "conversationId": conversationId,
        });

        _apiHelper?.deleteChat(body, authToken.toString()).then((onValue) {
          _searchList.clear();

          _aList?.clear();

          _getChatSummary();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  PreferredSizeWidget topAppBar() {
    return PreferredSize(
      child: Container(
          padding: EdgeInsets.only(top: DimensHelper.btnTopMargin),
          decoration: BoxDecoration(color: SoloColor.blue),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _commonHelper?.closeActivity();
                },
                child: Container(
                  margin: EdgeInsets.only(
                    left: DimensHelper.sideDoubleMargin,
                  ),
                  child: Image.asset('images/back_arrow.png',
                      height: 25, width: 25),
                ),
              ),
              searchBar()
            ],
          )),
      preferredSize: Size(_commonHelper?.screenWidth, 120),
    );
  }

  String _getProfilePic(int index) {
    if (_searchList[index].senderId == mineUserId) {
      return _searchList[index].receiverProfilePic.toString();
    } else {
      return _searchList[index].senderProfilePic.toString();
    }
  }

  Future<Null> _refresh() async {
    _showProgress();

    _searchList.clear();

    _aList?.clear();

    _getChatSummary();
  }

  String _getUserName(int index) {
    if (_searchList[index].senderId == mineUserId) {
      return _searchList[index].receiverFullName.toString();
    } else {
      return _searchList[index].senderFullName.toString();
    }
  }

  String _getUserId(int index) {
    if (_searchList[index].senderId == mineUserId)
      return _searchList[index].receiverId.toString();
    else
      return _searchList[index].senderId.toString();
  }

  _onSearchTextChanged(String text) async {
    _searchList.clear();
    if (text.isEmpty) {
      _searchList.addAll(_aList ?? []);
      setState(() {});
      return;
    }
    _aList?.forEach((chatDetail) {
      if (chatDetail.senderId == mineUserId) {
        var name = chatDetail.receiverFullName;

        if (name!.toUpperCase().contains(text.toUpperCase())) {
          _searchList.add(chatDetail);
        }
      } else {
        var name = chatDetail.senderFullName;

        if (name!.toUpperCase().contains(text.toUpperCase())) {
          _searchList.add(chatDetail);
        }
      }
    });

    setState(() {});
  }

//============================================================
// ** Firebase Function **
//============================================================

//============================================================
// ** Helper Class **
//============================================================

}
