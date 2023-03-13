import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solomas/activities/home_activity.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/image_upload_model.dart';
import 'package:solomas/model/upload_image_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/widgets/btn_widget.dart';

import '../../resources_helper/screen_area/scaffold.dart';

class ShareMomentActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ShareMomentState();
  }
}

class _ShareMomentState extends State<ShareMomentActivity> {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  bool _progressShow = false;
  String _authToken = "";
  String postImageUrl = "";
  ApiHelper? _apiHelper;
  File? _profileImage;
  ImagePicker _imagePicker = ImagePicker();
  var _titleController = TextEditingController();
  var _titleFocusNode = FocusNode();
  List<Url> url = [];
  List<String> urlList = [];
  List<XFile> images = <XFile>[];
  List<File> imageFileList = <File>[];

//============================================================
// ** Flutter Build Cycle **
//============================================================

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

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      appBar: _appBar(),
      body: _mainBody(context),
    );
  }

//============================================================
// ** Main Widgets **
//============================================================

  AppBar _appBar() {
    return AppBar(
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
            child: Text('Share a Moment'.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: Constants.FONT_APP_TITLE)),
          )
        ],
      ),
    );
  }

  Widget _mainBody(BuildContext context) {
    return Stack(
      children: [
        ListView(
          children: [
            // _momentView(),
            // Visibility(
            //   visible: postImageUrl.isEmpty,
            //   child: GestureDetector(
            //     onTap: () {
            //       showCupertinoModalPopup(
            //           context: context,
            //           builder: (BuildContext context) =>
            //               _showCreateFeedBottomSheet());
            //     },
            //     child: Container(
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(DimensHelper.halfSides),
            //         border:
            //             Border.all(color: SoloColor.spanishGray, width: 0.5),
            //       ),
            //       width: _commonHelper?.screenWidth,
            //       margin: EdgeInsets.only(
            //           left: DimensHelper.sidesMargin,
            //           right: DimensHelper.sidesMargin,
            //           top: DimensHelper.sidesBtnDouble),
            //       height: 150,
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Container(
            //             width: 50,
            //             height: 50,
            //             child: Image.asset('images/ic_add_image.png',
            //                 color: SoloColor.spanishGray),
            //           ),
            //           Container(
            //             child: Text(
            //               "Add Image",
            //               style: TextStyle(
            //                 color: SoloColor.spanishGray,
            //                 fontSize: Constants.FONT_MEDIUM,
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            // Container(
            //   margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
            //   child: BorderTextFieldWidget(
            //       title: '',
            //       hintText: "Write Something...",
            //       keyboardType: TextInputType.text,
            //       autoFocus: false,
            //       maxLines: 7,
            //       maxTextLength: 200,
            //       focusNode: _titleFocusNode,
            //       tfHeight: 30.0,
            //       editingController: _titleController,
            //       inputAction: TextInputAction.done,
            //       marginTop: DimensHelper.tinySides),
            // ),
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
                btnText: 'SHARE',
              ),
            )
          ],
        ),
        Align(
          child: ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
          alignment: FractionalOffset.center,
        )
      ],
    );
  }

  Visibility _momentView() {
    return Visibility(
      visible: postImageUrl.isNotEmpty,
      child: Container(
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(DimensHelper.halfSides))),
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
                borderRadius:
                    BorderRadius.all(Radius.circular(DimensHelper.halfSides)),
                child: CachedNetworkImage(
                  imageUrl: postImageUrl,
                  width: _commonHelper?.screenWidth,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _loadingProgressBar(),
                ),
              ),
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
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget _showCreateFeedBottomSheet() {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text("Camera",
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
            "Gallery",
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
        child: Text("Cancel",
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

  void _onShareBtnTap() {
    _showProgress();

    String body;

    if (postImageUrl.isEmpty) {
      body = json.encode({
        "title": _titleController.text.toString(),
      });
    } else if (_titleController.text.toString().trim().isEmpty) {
      body = json.encode({
        "image": postImageUrl,
      });
    } else {
      body = json.encode({
        "image": postImageUrl,
        "title": _titleController.text.toString().trim(),
      });
    }

    _apiHelper?.createPublicFeed(body, _authToken).then((onValue) {
      _commonHelper?.startActivityAndCloseOther(HomeActivity());
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
              toolbarTitle: 'Share Moment',
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
          url.clear();
          url.add(Url(url: postImageUrl));
          urlList.clear();
          urlList.add(postImageUrl);
        });
      }).catchError((onError) {
        _hideProgress();
      });
    }
  }

  Future<Null> _pickImage(isCamera) async {
    if (isCamera) {
      var pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);

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
    } else {
      imagesSelect();
    }
  }

  void imageUpload(List<File> image) {
    _apiHelper?.uploadImages(image).then((value) {
      if (value.statusCode == 200) {
        _hideProgress();

        setState(() {
          url = value.data?.url ?? [];
          urlList.clear();

          url.forEach((element) {
            urlList.add(element.url.toString());
          });
          // urlList.add(url.);
        });

        print("image : $image");
        print("image upload success");
      } else {
        print("image upload failed");
      }
    });
  }

  Future<void> imagesSelect() async {
    List<XFile>? resultList = <XFile>[];
    try {
      resultList =
          await _imagePicker.pickMultiImage(maxWidth: 5.0, maxHeight: 2.0);
    } on Exception catch (e) {
      print(e.toString());
    }
    setState(() {
      if (resultList!.isNotEmpty) {
        images = resultList;
      }
      getFileList();
    });
  }

  void getFileList() async {
    imageFileList.clear();
    for (int i = 0; i <= images.length - 1; i++) {
      var file = await getImageFileFromAssets(images[i]);
      print(file);
      imageFileList.add(file);
      print("imageFileList: $imageFileList");
    }
    if (imageFileList.isNotEmpty) {
      imageUpload(imageFileList);
    }
  }

  Future<File> getImageFileFromAssets(XFile asset) async {
    final byteData = await asset.readAsBytes();

    final tempFile =
        File("${(await getTemporaryDirectory()).path}/${asset.name}");
    final file = await tempFile.writeAsBytes(
      byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
    return file;
  }

  Future<String?> _asyncInputDialog(
      BuildContext context, bool isAndroid) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('App Permission'),
          content: Container(
              child: isAndroid
                  ? Text("Allow Solo Mas to take pictures and record video?")
                  : Text(
                      "Allow Solo Mas to access photos, media and files on your device?")),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Settings'),
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
}
