import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solomas/activities/home_activity.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/image_upload_model.dart';
import 'package:solomas/model/public_feeds_model.dart';
import 'package:solomas/model/upload_image_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/widgets/border_text_field.dart';
import 'package:solomas/widgets/btn_widget.dart';

import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/strings.dart';
import '../common_helpers/app_bar.dart';

class ShareMomentActivity extends StatefulWidget {
  final String? carnivalId;
  final PublicFeedList? feedList;
  final bool? isFrom;
  final context;

  const ShareMomentActivity(
      {key, this.carnivalId, this.feedList, this.isFrom, this.context})
      : super(key: key);

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
  List<Asset> images = <Asset>[];
  // List<XFile> images = <XFile>[]; //todo Avi
  List<File> imageFileList = <File>[];
  List<Url> url = [];
  List<String> urlList = [];
  int currentPos = 1;

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

    if (widget.isFrom == true) {
      urlList = widget.feedList?.image ?? [];
      _titleController.text = widget.feedList?.title ?? '';
      url.clear();

      urlList.forEach((element) {
        url.add(Url(url: element));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
          child: _appBar(context),
        ),
      ),
      body: _mainBody(context),
    );
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.shareMoment,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _mainBody(BuildContext context) {
    return Stack(
      children: [
        ListView(
          children: [
            _momentView(context),
            _contentView(),
            _shareButton(context)
          ],
        ),
        Align(
          child: ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
          alignment: FractionalOffset.center,
        )
      ],
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget _shareButton(BuildContext context) {
    return Container(
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
    );
  }

  Widget _contentView() {
    return Container(
      margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
      child: BorderTextFieldWidget(
          title: '',
          hintText: "Write Something...",
          keyboardType: TextInputType.text,
          autoFocus: false,
          maxLines: 7,
          maxTextLength: 200,
          focusNode: _titleFocusNode,
          tfHeight: 30.0,
          editingController: _titleController,
          inputAction: TextInputAction.done,
          marginTop: DimensHelper.tinySides),
    );
  }

  Widget _momentView(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: url.isNotEmpty,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(DimensHelper.halfSides))),
                height: _commonHelper?.screenHeight * .3,
                width: _commonHelper?.screenHeight,
                margin: EdgeInsets.only(
                    left: DimensHelper.sidesMargin,
                    right: DimensHelper.sidesMargin,
                    top: DimensHelper.sidesBtnDouble),
                child: CarouselSlider.builder(
                    options: CarouselOptions(
                      autoPlay: false,
                      enableInfiniteScroll: false,
                      height: 335,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          currentPos = index + 1;
                        });
                      },
                    ),
                    itemCount: url.length,
                    itemBuilder:
                        (BuildContext context, int index, int realIndex) {
                      return Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                              top: DimensHelper.halfSides,
                              left: DimensHelper.sidesMargin,
                              right: DimensHelper.sidesMargin,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(DimensHelper.halfSides)),
                              child: CachedNetworkImage(
                                imageUrl: url[index].url.toString(),
                                width: _commonHelper?.screenWidth,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    _loadingProgressBar(),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                print("index" + index.toString());
                                print("urlList" + urlList.toString());
                                postImageUrl = "";
                                url.removeAt(index);
                                print("url" + url.toString());
                                urlList.clear();
                                url.forEach((element) {
                                  urlList.add(element.url.toString());
                                });
                                print("urlList11" + urlList.toString());
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
                          ),
                        ],
                      );
                    }),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0, right: 50),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      color: SoloColor.silverSand,
                      child: Padding(
                        padding: const EdgeInsets.all(DimensHelper.halfSides),
                        child: Text((currentPos).toString() +
                            "/" +
                            url.length.toString()),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: url.isEmpty,
          child: GestureDetector(
            onTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) =>
                      _showCreateFeedBottomSheet());
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DimensHelper.halfSides),
                border: Border.all(color: SoloColor.spanishGray, width: 0.5),
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
                      "Add Image",
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
      ],
    );
  }

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

    if (widget.isFrom == true) {
      if (urlList.isEmpty) {
        body = json.encode({
          "title": _titleController.text.toString(),
          "publicFeedId": widget.feedList?.publicFeedId
        });
      } else if (_titleController.text.toString().trim().isEmpty) {
        body = json.encode(
            {"image": urlList, "publicFeedId": widget.feedList?.publicFeedId});
      } else {
        body = json.encode({
          "image": urlList,
          "title": _titleController.text.toString().trim(),
          "publicFeedId": widget.feedList?.publicFeedId
        });
      }
      _apiHelper?.updatePublicFeed(body, _authToken).then((onValue) {
        if (onValue.statusCode == 200) {
          _commonHelper?.startActivityAndCloseOther(HomeActivity());
        } else {
          _commonHelper?.showAlertIntent(
              onValue.message, "Please fill Details");
          _hideProgress();
        }
      }).catchError((onError) {
        _hideProgress();
      });
    } else {
      if (urlList.isEmpty) {
        body = json.encode({
          "title": _titleController.text.toString(),
        });
      } else if (_titleController.text.toString().trim().isEmpty) {
        body = json.encode({
          "image": urlList,
        });
      } else {
        body = json.encode({
          "image": urlList,
          "title": _titleController.text.toString().trim(),
        });
      }
      _apiHelper?.createPublicFeed(body, _authToken).then((onValue) {
        if (onValue.statusCode == 200) {
          _commonHelper?.startActivityAndCloseOther(HomeActivity());
        } else {
          _commonHelper?.showAlertIntent(
              onValue.message, "Please fill Details");
          _hideProgress();
        }
      }).catchError((onError) {
        _hideProgress();
      });
    }
  }

  bool _checkValues() {
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
          postImageUrl = imageModel.data?.url ?? '';
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
      if (pickedFile == null) {
        _hideProgress();
      }
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
    _showProgress();
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
      } else {
        print("image upload failed");
      }
    });
  }

  Future<void> imagesSelect() async {
    print("galleryData");
    List<Asset> resultList = <Asset>[];
    // List<XFile> resultList = <XFile>[];

    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 5, enableCamera: true, selectedAssets: images);
      if (resultList == null) {
        _hideProgress();
      }
      // resultList = await _imagePicker.pickMultiImage(maxHeight: 5.0, maxWidth: 2.0);
    } on Exception catch (e) {
      _hideProgress();
      print(e.toString());
    }
    setState(() {
      if (resultList.isNotEmpty) {
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

  Future<File> getImageFileFromAssets(Asset asset) async {
    final byteData = await asset.getByteData();

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
