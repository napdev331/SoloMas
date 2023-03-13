import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/upload_image_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/widgets/border_text_field.dart';
import 'package:solomas/widgets/btn_widget.dart';

import '../../../../resources_helper/screen_area/scaffold.dart';
import '../../../../resources_helper/strings.dart';
import '../../../common_helpers/app_bar.dart';

class ShareMomentReviewActivity extends StatefulWidget {
  final String? carnivalId;

  const ShareMomentReviewActivity({key, this.carnivalId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ShareMomentState();
  }
}

class _ShareMomentState extends State<ShareMomentReviewActivity> {
  CommonHelper? _commonHelper;

  bool _progressShow = false;

  String _authToken = "";

  String postImageUrl = "";

  ApiHelper? _apiHelper;

  File? _profileImage;

  ImagePicker _imagePicker = ImagePicker();

  var _titleController = TextEditingController();

  var _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _apiHelper = ApiHelper();

    PrefHelper.getAuthToken().then((onValue) {
      setState(() {
        _authToken = onValue.toString();
      });
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

  void _onShareBtnTap() {
    _showProgress();

    String body;

    if (postImageUrl.isEmpty) {
      body = json.encode({
        "review": _titleController.text.toString(),
        "carnivalId": widget.carnivalId,
      });
    } else {
      body = json.encode({
        "image": postImageUrl,
        "review": _titleController.text.toString().trim(),
        "carnivalId": widget.carnivalId,
      });
    }

    _apiHelper?.createCarnivalReview(body, _authToken).then((onValue) {
      if (onValue != null) {
        if (onValue.statusCode == 200) {
          Navigator.of(context).pop(true);
          _hideProgress();
        } else {
          // _commonHelper.showAlertIntent("Review Not Allowed to be empty", onValue.data);
          _hideProgress();
        }
      }
    }).catchError((onError) {
      _hideProgress();
    });
  }

  bool _checkValues() {
    /*if (_descriptionController.text.trim().length < 150) {

      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) =>
              _commonHelper.successBottomSheet("Description",
                  "Please enter a at least 150 character long description to share a moment.",
                  false));


      return false;
    }*/

    return true;
  }

  Future<Null> _cropImage(imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressQuality: 80,
        cropStyle: CropStyle.rectangle,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: StringHelper.shareMomentText,
              toolbarColor: Colors.white,
              showCropGrid: false,
              hideBottomControls: true,
              cropFrameColor: Colors.transparent,
              toolbarWidgetColor: SoloColor.blue,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true),
          IOSUiSettings(
            rotateButtonsHidden: true,
            minimumAspectRatio: 1.0,
          )
        ]);

    if (croppedFile != null) {
      imageFile = File(croppedFile.path);

      _showProgress();

      _apiHelper?.uploadFile(imageFile).then((onSuccess) {
        _hideProgress();

        UploadImageModel imageModel = onSuccess;

        setState(() {
          postImageUrl = imageModel.data!.url.toString();
        });
      }).catchError((onError) {
        _hideProgress();
      });
    }
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
      setState(() {
        _progressShow = false;

        _cropImage(_profileImage);
      });
    }
  }

  Future<String?> _asyncInputDialog(
      BuildContext context, bool isAndroid) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            StringHelper.appPermission,
          ),
          content: Container(
              child: isAndroid
                  ? Text(
                      StringHelper.AllowSoloMassToAddPermission,
                    )
                  : Text(
                      StringHelper.AllowSoloMassToAddMedia,
                    )),
          actions: [
            TextButton(
              child: Text(
                StringHelper.cancel,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                StringHelper.settings,
              ),
              onPressed: () {
                openAppSettings();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> requestPermission(Permission pPermission, bool status) async {
    var requestPermission = await pPermission.request();

    if (requestPermission.isGranted) {
      _progressShow = true;

      _pickImage(status);
    } else if (requestPermission.isDenied) {
      _asyncInputDialog(context, status);
    } else if (requestPermission.isRestricted) {
      _asyncInputDialog(context, status);
    }
  }

  Widget _showCreateFeedBottomSheet() {
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
                  :
                  // requestPermission(Permission.photos, false);
                  _pickImage(false);
            });
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

  Widget _loadingProgressBar() {
    return Container(
      width: 70,
      height: 70,
      child: Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
          child: SoloAppBar(
              appBarType: StringHelper.backWithText,
              appbarTitle: StringHelper.addReview,
              backOnTap: () {
                Navigator.pop(context, false);
              }),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Visibility(
                visible: postImageUrl.isNotEmpty,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(DimensHelper.halfSides))),
                  height: _commonHelper?.screenHeight * .3,
                  margin: EdgeInsets.only(
                      left: DimensHelper.sidesMargin,
                      right: DimensHelper.sidesMargin,
                      top: DimensHelper.sidesBtnDouble),
                  child: Stack(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: DimensHelper.halfSides),
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(
                                Radius.circular(DimensHelper.halfSides)),
                            child: CachedNetworkImage(
                                imageUrl: postImageUrl,
                                width: _commonHelper?.screenWidth,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Center(
                                    child: CircularProgressIndicator()))),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            postImageUrl = "";
                          });
                        },
                        child: Container(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            radius: DimensHelper.sidesMargin,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: postImageUrl.isEmpty,
                child: GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) =>
                            _showCreateFeedBottomSheet());
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(DimensHelper.halfSides),
                      border:
                          Border.all(color: SoloColor.spanishGray, width: 0.5),
                    ),
                    width: _commonHelper?.screenWidth,
                    margin: EdgeInsets.only(
                        left: DimensHelper.sidesMargin,
                        right: DimensHelper.sidesMargin,
                        top: DimensHelper.sidesBtnDouble),
                    height: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          child: Image.asset('images/ic_add_image.png',
                              color: SoloColor.spanishGray),
                        ),
                        Container(
                          child: Text(
                            StringHelper.addImage,
                            style: TextStyle(
                              color: SoloColor.spanishGray,
                              fontSize: Constants.FONT_MEDIUM,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
                child: BorderTextFieldWidget(
                    title: '',
                    hintText: StringHelper.writeSomething,
                    keyboardType: TextInputType.text,
                    autoFocus: false,
                    maxLines: 7,
                    maxTextLength: 200,
                    focusNode: _titleFocusNode,
                    tfHeight: 30.0,
                    editingController: _titleController,
                    inputAction: TextInputAction.done,
                    marginTop: DimensHelper.tinySides),
              ),
              Container(
                margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
                alignment: Alignment.center,
                child: ButtonWidget(
                  height: _commonHelper?.screenHeight,
                  width: _commonHelper?.screenWidth * .7,
                  onPressed: () {
                    FocusScope.of(context).unfocus();

                    if (_checkValues()) {
                      _onShareBtnTap();
                    }
                  },
                  btnText: StringHelper.add,
                ),
              )
            ],
          ),
          Align(
            child:
                ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
            alignment: FractionalOffset.center,
          )
        ],
      ),
    );
  }
}
