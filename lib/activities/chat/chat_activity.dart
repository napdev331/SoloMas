import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solomas/blocs/chat/chat_individual_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/helpers/socket_helper.dart';
import 'package:solomas/model/block_user_model.dart';
import 'package:solomas/model/chat_individual_model.dart';
import 'package:solomas/model/report_feed_model.dart';
import 'package:solomas/model/upload_image_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../helpers/comment_helper.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../widgets/chat_bubble_widget.dart';
import '../common_helpers/app_bar.dart';
import '../home/user_profile_activity.dart';

class ChatActivity extends StatefulWidget {
  final String userName, userId, imageUrl;

  ChatActivity(
    this.userName,
    this.userId,
    this.imageUrl,
  );

  @override
  State<StatefulWidget> createState() {
    return ChatState();
  }
}

class ChatState extends State<ChatActivity> with WidgetsBindingObserver {
//============================================================
// ** Properties **
//============================================================
  var _sendCommentFocusNode = FocusNode();
  var signUp;
  var _progressShow = false;
  var _sendMessageController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  File? _profileImage;
  String? mineUserId, mineUserName, conversationId = "", authToken;
  Data? chatData;

  List<ChatList> _chatList = [];

  CommonHelper? _commonHelper;
  ScrollController? _scrollController;
  ApiHelper? _apiHelper;
  SocketHelper? _socketHelper;
  ChatIndividualBloc? _chatBloc;
  ImagePicker _imagePicker = ImagePicker();

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _apiHelper = ApiHelper();
    _scrollController = ScrollController();
    _socketHelper = SocketHelper(this);
    _chatBloc = ChatIndividualBloc();
    WidgetsBinding.instance.addObserver(this);
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          color: SoloColor.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: _appBar(),
          ),
        ),
      ),
      body: _mainBody(),
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        break;

      case AppLifecycleState.paused:
        _socketHelper?.disconnectSocket();

        break;

      case AppLifecycleState.detached:
        break;

      case AppLifecycleState.resumed:
        _socketHelper?.connectToSocket(mineUserId.toString());

        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _socketHelper?.disconnectSocket();

    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _appBar() {
    return SoloAppBar(
      appBarType: StringHelper.withCenterWidget,
      appbarTitle: StringHelper.notification,
      leadingTap: () {
        Navigator.pop(context);
      },
      child: InkWell(
        onTap: () {
          _commonHelper
              ?.startActivity(UserProfileActivity(userId: widget.userId));
        },
        child: Row(
          children: [
            profileImage(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(widget.userName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black, fontSize: Constants.FONT_TOP)),
                ),
                // Container(
                //   alignment: Alignment.center,
                //   child: Text("1h ago",
                //       textAlign: TextAlign.center,
                //       style: TextStyle(
                //           color: SoloColor.graniteGray.withOpacity(0.6),
                //           fontSize: Constants.FONT_LOW)),
                // ),
              ],
            ),
          ],
        ),
      ),
      trailingTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => _showBottomSheet());
      },
    );
  }

  StreamBuilder<ChatIndividualModel> _mainBody() {
    return StreamBuilder(
        stream: _chatBloc?.chatList,
        builder: (context, AsyncSnapshot<ChatIndividualModel> snapshot) {
          if (snapshot.hasData) {
            if (_chatList.isEmpty) {
              chatData = snapshot.data?.data;

              if (snapshot.data!.data!.chatList!.isNotEmpty) {
                conversationId =
                    snapshot.data?.data?.chatList?[0].conversationId;
              }

              _chatList = snapshot.data?.data?.chatList ?? [];

              Future.delayed(Duration.zero, () => _animateScrolling());
            }

            return _chatData();
          } else if (snapshot.hasError) {
            return Container();
          }

          return Center(child: CircularProgressIndicator());
        });
  }

//============================================================
// ** Helper Widgets **
//============================================================
  Widget _successBottomSheet(String title, String msg) {
    return CupertinoActionSheet(
      title: Text(title,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(msg,
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.Ok,
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _onReportPostTap() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "feedId": widget.userId,
          "feedType": StringHelper.profile,
        });

        _apiHelper?.reportFeed(body, authToken.toString()).then((onValue) {
          _hideProgress();

          ReportFeedModel _reportModel = onValue;

          if (_reportModel.statusCode == 200)
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _successBottomSheet(
                    StringHelper.success, StringHelper.profileReportSucMsg));
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  Widget _showReportBottomSheet() {
    return CupertinoActionSheet(
      title: Text(StringHelper.report,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.profileReport,
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

            _onReportPostTap();
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

  void _onUnBlockTap(String userId) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({"blockUserId": userId});

        _apiHelper?.unBlockUser(body, authToken.toString()).then((onValue) {
          _chatList.clear();

          _chatBloc
              ?.getChatData(authToken.toString(), widget.userId)
              .then((onValue) {
            _hideProgress();
          }).catchError((onError) {
            _hideProgress();
          });
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  Widget _unBlockSheet(String blockUserId) {
    return CupertinoActionSheet(
      title: Text(StringHelper.unblockUser,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.unblockUserSendMsg,
          style: TextStyle(
              color: SoloColor.spanishGray,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.w400)),
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.unblock,
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _onUnBlockTap(blockUserId);
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            StringHelper.cancel,
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

  bool checkValues() {
    if (chatData?.chatUser?.blockByYou == true) {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => _unBlockSheet(widget.userId));

      return false;
    }

    return true;
  }

  void _sendMessage() {
    if (checkValues()) {
      if (_sendMessageController.text.isNotEmpty &&
          _sendMessageController.text.toString().trim().isNotEmpty) {
        _socketHelper?.sendMessage(
            mineUserId.toString(),
            widget.userId,
            _sendMessageController.text,
            mineUserName.toString(),
            "text",
            chatData?.chatUser?.blockByReceiver == true,
            widget.imageUrl);

        _sendMessageController.text = "";
      }
    }
  }

  Widget _showBlockBottomSheet() {
    return CupertinoActionSheet(
      title: Text(StringHelper.block,
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      message: Text(StringHelper.blockProfileMsg,
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

            _onBlockUserTap();
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

  Widget _showBottomSheet() {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.block,
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _showBlockBottomSheet());
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            StringHelper.report,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500),
          ),
          onPressed: () {
            Navigator.pop(context);
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _showReportBottomSheet());
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(StringHelper.cancel,
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

  Future<Null> _pickImage(isCamera) async {
    var pickedFile = isCamera
        ? await _imagePicker.pickImage(source: ImageSource.camera)
        : await _imagePicker.pickImage(source: ImageSource.gallery);

    _profileImage = File(pickedFile!.path);

    if (_profileImage == null) {
      _hideProgress();
    }

    if (_profileImage != null) {
      _showProgress();

      _apiHelper?.uploadFile(File(_profileImage!.path)).then((onSuccess) {
        _hideProgress();

        UploadImageModel imageModel = onSuccess;

        _socketHelper?.sendMessage(
            mineUserId.toString(),
            widget.userId,
            imageModel.data!.url.toString(),
            mineUserName.toString(),
            "image",
            chatData?.chatUser?.blockByReceiver == true,
            widget.imageUrl);
      }).catchError((onError) {
        _hideProgress();
      });
    }
  }

  Future<String?> _asyncInputDialog(
      BuildContext context, bool isAndroid) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StringHelper.appPermission),
          content: Container(
              child: isAndroid
                  ? Text(StringHelper.AllowSoloMassToAddPermission)
                  : Text(StringHelper.AllowSoloMassToAddMedia)),
          actions: [
            TextButton(
              child: Text(StringHelper.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(StringHelper.settings),
              onPressed: () {
                openAppSettings();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return null;
  }

  Future<void> requestPermission(Permission pPermission, bool status) async {
    var requestPermission = await pPermission.request();

    if (requestPermission.isGranted) {
      _progressShow = false;

      _pickImage(status);
    } else if (requestPermission.isDenied) {
      _asyncInputDialog(context, status);
    } else if (requestPermission.isRestricted) {
      _asyncInputDialog(context, status);
    } else if (requestPermission.isPermanentlyDenied) {
      _asyncInputDialog(context, status);
    } else if (requestPermission.isLimited) {
      _asyncInputDialog(context, status);
    }
  }

  Widget _showSendImageBottomSheet() {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text(StringHelper.camera,
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            setState(() {
              requestPermission(Permission.camera, true);
            });

            _hideKeyBoard();
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            StringHelper.gallery,
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500),
          ),
          onPressed: () {
            Navigator.pop(context);

            setState(() {
              (Platform.isAndroid)
                  ? requestPermission(Permission.storage, false)
                  : requestPermission(Permission.photos, false);
            });

            _hideKeyBoard();
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(StringHelper.cancel,
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

  Widget sendMessageField() {
    return Row(
      children: [
        Expanded(
            child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: DimensHelper.sidesMargin),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                      top: DimensHelper.halfSides,
                      bottom: DimensHelper.halfSides),
                  // margin: EdgeInsets.only(
                  //     left: DimensHelper.sidesMargin,
                  //     right: DimensHelper.sidesMargin),
                  child: TextFormField(
                    style: TextStyle(
                        fontSize: Constants.FONT_MEDIUM,
                        color: SoloColor.black),
                    autofocus: false,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 4,
                    onTap: () {
                      _animateScrolling();
                    },
                    controller: _sendMessageController,
                    cursorColor: SoloColor.pink,
                    decoration: InputDecoration(
                        hintText: StringHelper.typeMessage,
                        prefixIcon: GestureDetector(
                          onTap: () {
                            _hideKeyBoard();

                            if (checkValues()) {
                              showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      _showSendImageBottomSheet());
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                'assets/icons/attach_file.png',
                              ),
                            ),
                          ),
                        ),
                        hintStyle: TextStyle(
                          color: SoloColor.spanishGray.withOpacity(0.6),
                          fontSize: Constants.FONT_MEDIUM,
                        ),
                        fillColor: SoloColor.white,
                        contentPadding: EdgeInsets.only(
                            top: DimensHelper.sidesMargin,
                            bottom: DimensHelper.sidesMargin,
                            left: DimensHelper.sidesMargin,
                            right: DimensHelper.sidesMarginDouble),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: SoloColor.white, width: 1.0),
                        ),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: SoloColor.white, width: 0.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: SoloColor.white, width: 0.0))),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _sendMessage();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/icons/chat_send.png',
                    ),
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget messageCard(int index) {
    return Bubble(
        message: _chatList[index].message,
        type: _chatList[index].type,
        time: _commonHelper?.getTimeDifference(_chatList[index].sentAt ?? 0),
        delivered: false,
        isMe: _chatList[index].senderId == mineUserId ? true : false,
        screenWidth: _commonHelper?.screenWidth);
  }

  Future<Null> _refresh() async {
    _showProgress();

    _apiHelper
        ?.getChatIndividual(authToken.toString(), widget.userId)
        .then((onValue) {
      _hideProgress();

      _chatList.clear();

      _chatList = onValue.data?.chatList ?? [];

      _animateScrolling();
    }).catchError((onError) {
      _hideProgress();
    });
  }

  Widget _chatData() {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: Container(
          width: _commonHelper?.screenWidth,
          color: SoloColor.white,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    right: DimensHelper.sidesMargin,
                    left: DimensHelper.sidesMargin,
                    top: DimensHelper.searchBarMargin,
                    bottom: DimensHelper.BottomBarMargin,
                  ),
                  child: Container(
                    width: _commonHelper?.screenWidth,
                    decoration: BoxDecoration(
                        color: SoloColor.flashWhite.withOpacity(0.5),
                        border: Border.all(
                          color: SoloColor.graniteGray.withOpacity(0.2),
                        ),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    padding: EdgeInsets.only(
                      bottom: DimensHelper.halfSides,
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _chatList.length,
                      padding: EdgeInsets.only(bottom: 56),
                      itemBuilder: (context, index) {
                        return messageCard(index);
                      },
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    color: Colors.white,
                    child: CommentHelper.sendCommentField(context, onSend: () {
                      _sendMessage();
                      _hideKeyBoard();
                    },
                        focusNode: _sendCommentFocusNode,
                        controller: _sendMessageController,
                        hintText: StringHelper.typeMessage,
                        prefixIcon: GestureDetector(
                          onTap: () {
                            if (checkValues()) {
                              showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      _showSendImageBottomSheet());
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                'assets/icons/attach_file.png',
                              ),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
              Align(
                child: ProgressBarIndicator(
                    _commonHelper?.screenSize, _progressShow),
                alignment: FractionalOffset.center,
              )
            ],
          ),
        ));
  }

  Widget profileImage() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 10),
      child: ClipOval(
          child: CachedNetworkImage(
              fit: BoxFit.cover,
              height: 35,
              width: 35,
              imageUrl: widget.imageUrl,
              placeholder: (context, url) => imagePlaceHolder(),
              errorWidget: (context, url, error) => imagePlaceHolder())),
    );
  }

//============================================================
// ** Helper Functions **
//============================================================
  void _onBlockUserTap() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var body = json.encode({
          "blockUserId": widget.userId,
        });

        _apiHelper?.blockUser(body, authToken.toString()).then((onValue) {
          BlockUserModel _blockModel = onValue;

          _hideProgress();

          if (_blockModel.statusCode == 200) {
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _commonHelper!
                    .successBottomSheet(StringHelper.success,
                        StringHelper.blocUserSucMsg, true));
          }
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

  void _animateScrolling() {
    Timer(
        Duration(milliseconds: 500),
        () => _scrollController
            ?.jumpTo(_scrollController!.position.maxScrollExtent));
  }

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }

  void onReceiveMsg(Map msgData) {
    var conversationIdOne =
        msgData["receiverId"].toString() + "." + msgData["senderId"].toString();

    var conversationIdTwo =
        msgData["senderId"].toString() + "." + msgData["receiverId"].toString();

    if (msgData["senderId"] == mineUserId ||
        conversationId == conversationIdOne ||
        conversationId == conversationIdTwo) {
      var updatedChatList = ChatList.fromJson(msgData as Map<String, dynamic>);

      setState(() {
        _chatList.add(updatedChatList);
        _animateScrolling();
      });
    }
  }

  void _getUserData() {
    PrefHelper.getUserId().then((onValue) {
      mineUserId = onValue;

      _socketHelper?.connectToSocket(mineUserId.toString());

      PrefHelper.getAuthToken().then((token) {
        authToken = token;

        _chatBloc?.getChatData(token.toString(), widget.userId);
      });
    });

    PrefHelper.getUserName().then((onValue) {
      mineUserName = onValue;
    });
  }
//============================================================
// ** Firebase Functions **
//============================================================

}
