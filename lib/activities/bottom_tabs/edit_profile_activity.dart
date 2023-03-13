import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solomas/blocs/home/update_user_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/upload_image_model.dart';
import 'package:solomas/model/user_profile_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../blocs/home/user_profile_bloc.dart';
import '../../helpers/progress_indicator.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../widgets/btn_widget.dart';
import '../../widgets/text_field_widget.dart';
import '../common_helpers/app_bar.dart';
import '../registration/add_location_activity.dart';

class EditProfileActivity extends StatefulWidget {
  final Response? userResponse;

  EditProfileActivity({this.userResponse});

  @override
  State<StatefulWidget> createState() {
    return _EditProfileState();
  }
}

class _EditProfileState extends State<EditProfileActivity> {
  //============================================================
// ** Properties **
//============================================================
  CommonHelper? _commonHelper;
  bool _progressShow = false, refreshData = false;

  File? _profileImage;
  File? _coverImage;
  bool isCoverImage = false;
  String? authToken, profilePicUrl = "", mineUserName = "", coverPicUrl = "";
  HashMap<String, Object> locationDetail = HashMap();
  int? userAge, _radioValue = 0;
  bool isRefresh = false;
  DateTime selectedDate = DateTime.now();
  UserProfileBloc? _userProfileBloc;
  var _nameController = TextEditingController(),
      _ageController = TextEditingController(),
      _addressController = TextEditingController();
  var _nameFocusNode = FocusNode();
  ApiHelper? _apiHelper;
  Data? _aList;
  UpdateUserBloc? _updateUserBloc;
  ImagePicker _imagePicker = ImagePicker();
  //============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    _userProfileBloc = UserProfileBloc();
    _getUserData();
    super.initState();

    PrefHelper.getAuthToken().then((onValue) {
      setState(() {
        authToken = onValue;
      });
    });

    profilePicUrl = widget.userResponse?.profilePic;
    coverPicUrl = widget.userResponse?.coverImage;

    _nameController.text = widget.userResponse?.fullName ?? '';

    userAge = widget.userResponse?.age;

    _ageController.text = widget.userResponse!.age.toString();

    _addressController.text = widget.userResponse?.locationName ?? '';

    _radioValue = widget.userResponse?.gender == "male" ? 0 : 1;

    _apiHelper = ApiHelper();

    _updateUserBloc = UpdateUserBloc();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    void _onUpdateTap(String reqBody) {
      _commonHelper?.isInternetAvailable().then((available) {
        if (available) {
          _showProgress();

          _updateUserBloc
              ?.updateUser(authToken.toString(), reqBody)
              .then((onValue) {
            Map mapData = json.decode(reqBody);

            if (mapData.containsKey("profilePic"))
              PrefHelper.setUserProfilePic(mapData['profilePic']);

            if (mapData.containsKey("age"))
              PrefHelper.setUserAge(mapData['age'].toString());

            if (mapData.containsKey("fullName"))
              PrefHelper.setUserName(mapData['fullName']);

            refreshData = true;
            Navigator.pop(context, mapData);
          }).catchError((onError) {
            _hideProgress();
          });
        } else {
          _commonHelper?.showAlert(
              StringHelper.noInternetTitle, StringHelper.noInternetMsg);
        }
      });
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
                    ? Text("Allow Solomas to take pictures and record video?")
                    : Text(
                        "Allow Solomas to access photos, media and files on your device?")),
            actions: [
              TextButton(
                child: Text('Cancel', style: TextStyle(color: SoloColor.blue)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child:
                    Text('Settings', style: TextStyle(color: SoloColor.blue)),
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

    Future<Null> _cropImage(imageFile, coverFile) async {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: isCoverImage ? coverFile.path : imageFile.path,
          compressQuality: 30,
          cropStyle: isCoverImage ? CropStyle.rectangle : CropStyle.circle,
          aspectRatioPresets: Platform.isAndroid
              ? [CropAspectRatioPreset.square]
              : [CropAspectRatioPreset.square],
          aspectRatio: isCoverImage
              ? CropAspectRatio(ratioX: 1, ratioY: 1)
              : CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: isCoverImage ? 'Cover Pic' : 'Profile Pic',
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
        isCoverImage
            ? coverFile = File(croppedFile.path)
            : imageFile = File(croppedFile.path);

        _showProgress();

        _apiHelper
            ?.uploadFile(isCoverImage ? coverFile : imageFile)
            .then((onSuccess) {
          UploadImageModel imageModel = onSuccess;
          setState(() {
            isCoverImage
                ? coverPicUrl = imageModel.data?.url
                : profilePicUrl = imageModel.data?.url;
          });
          _hideProgress();
        }).catchError((onError) {
          _hideProgress();
        });
      }
    }

    Future<Null> _pickImage(isCamera) async {
      var pickedFile = isCamera
          ? await _imagePicker.pickImage(source: ImageSource.camera)
          : await _imagePicker.pickImage(source: ImageSource.gallery);

      isCoverImage
          ? _coverImage = File(pickedFile!.path)
          : _profileImage = File(pickedFile!.path);

      if (_profileImage == null || _coverImage == null) {
        _hideProgress();
      }

      // if (_profileImage == null || _coverImage != null) {
      setState(() {
        _progressShow = false;

        _cropImage(_profileImage, _coverImage);
      });
      // }
    }

    Future<void> requestPermission(Permission pPermission, bool status) async {
      var requestPermission = await pPermission.request();

      if (requestPermission.isGranted) {
        //  _progressShow = true;
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

    Widget _showGetPictureSheet() {
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
                    : _pickImage(false);
                // : requestPermission(Permission.photos, false);
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

    Widget profileImage() {
      return Container(
        height: _commonHelper?.screenHeight * .135,
        width: _commonHelper?.screenHeight * .12,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: _commonHelper?.screenHeight * .12,
              width: _commonHelper?.screenHeight * .12,
              decoration: new BoxDecoration(
                  shape: BoxShape.circle, color: SoloColor.white),
              child: Padding(
                padding: const EdgeInsets.all(1.5),
                child: ClipOval(
                    child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  height: _commonHelper?.screenHeight * .1,
                  width: _commonHelper?.screenHeight * .1,
                  imageUrl: profilePicUrl.toString(),
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => imagePlaceHolder(),
                )),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  isCoverImage = false;
                  showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) =>
                          _showGetPictureSheet());
                },
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(DimensHelper.sidesMarginDouble)),
                      color: SoloColor.black),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SvgPicture.asset(IconsHelper.camera,
                        color: SoloColor.white),
                  ),
                  // Image.asset('images/ic_camera_white.png')
                ),
              ),
            ),
          ],
        ),
      );
    }

    void _onContinueTap() {
      var location = json.encode({
        'lat': widget.userResponse?.location?.lat,
        'lng': widget.userResponse?.location?.lng
      });

      Map<String, dynamic> locationMap;

      if (locationDetail.containsKey("location"))
        locationMap = json.decode(locationDetail['location'].toString());
      else
        locationMap = json.decode(location);

      var body = json.encode({
        "profilePic": profilePicUrl,
        "fullName": _nameController.text.trim().toString(),
        'age': userAge,
        'gender': _radioValue == 1 ? "female" : "male",
        "locationName": _addressController.text.trim().toString(),
        "location": locationMap,
        "coverImage": coverPicUrl,
      });
      print("body${body}");
      _onUpdateTap(body);
    }

    return WillPopScope(
        onWillPop: _willPopCallback,
        child: SoloScaffold(
          body: _mainBody(
              context, _showGetPictureSheet, profileImage, _onContinueTap),
        ));
  }

  @override
  void dispose() {
    _updateUserBloc?.dispose();

    super.dispose();
  }

//============================================================
// ** Main Widget **
//============================================================
  Widget _appBar({void Function()? onTap}) {
    return SoloAppBar(
      appBarType: StringHelper.backWithEditAppBar,
      appbarTitle: StringHelper.editProfile,
      backOnTap: () {
        _commonHelper?.closeActivity();
      },
      iconUrl: IconsHelper.pencil,
      iconOnTap: onTap,
    );
  }

  Widget _mainBody(BuildContext context, Widget _showGetPictureSheet(),
      Widget profileImage(), void _onContinueTap()) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SafeArea(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: _commonHelper?.screenHeight * .2,
                        child: CachedNetworkImage(
                          width: _commonHelper?.screenWidth,
                          imageUrl: coverPicUrl.toString(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Container(color: SoloColor.waterBlue),
                        ),
                      ),
                      Container(
                        width: _commonHelper?.screenWidth,
                        child: _appBar(onTap: () {
                          isCoverImage = true;
                          showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) =>
                                  _showGetPictureSheet());
                        }),
                      ),
                      Container(
                          margin: EdgeInsets.only(
                              top: _commonHelper?.screenHeight * .14,
                              left: _commonHelper?.screenHeight * .013,
                              right: _commonHelper?.screenHeight * .013),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              profileImage(),
                              Container(
                                margin: EdgeInsets.only(
                                    top: DimensHelper.sidesMarginDouble),
                                child: TextFieldWidget(
                                    tabColor: SoloColor.blue,
                                    etBgColor:
                                        Color.fromRGBO(246, 252, 254, 100),
                                    screenWidth: _commonHelper?.screenWidth,
                                    title: StringHelper.name,
                                    hintText: StringHelper.enterName,
                                    focusNode: _nameFocusNode,
                                    maxLines: 1,
                                    keyboardType: TextInputType.text,
                                    autoFocus: false,
                                    iconPath: "assets/images/ic_user.png",
                                    inputFormatter: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[a-zA-Z -]")),
                                      LengthLimitingTextInputFormatter(30),
                                    ],
                                    editingController: _nameController,
                                    inputAction: TextInputAction.next),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _hideKeyBoard();

                                  _selectDate(context);
                                },
                                child: AbsorbPointer(
                                  child: TextFieldWidget(
                                      screenWidth: _commonHelper?.screenWidth,
                                      title: StringHelper.yourAge,
                                      tabColor: SoloColor.middleBluePurple,
                                      hintText: StringHelper.enterAge,
                                      etBgColor:
                                          Color.fromRGBO(250, 249, 252, 100),
                                      keyboardType: TextInputType.text,
                                      autoFocus: false,
                                      iconPath: "assets/images/ic_age.png",
                                      editingController: _ageController,
                                      inputAction: TextInputAction.done),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _hideKeyBoard();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddLocationActivity()),
                                  ).then((value) {
                                    _hideKeyBoard();

                                    if (value != null) {
                                      locationDetail = value;

                                      _addressController.text =
                                          locationDetail['locationName']
                                              .toString();
                                    }
                                  });
                                },
                                child: AbsorbPointer(
                                  child: TextFieldWidget(
                                      screenWidth: _commonHelper?.screenWidth,
                                      title: StringHelper.location,
                                      tabColor: SoloColor.denimBlue,
                                      hintText: StringHelper.enterLocation,
                                      etBgColor:
                                          Color.fromRGBO(245, 247, 250, 100),
                                      keyboardType: TextInputType.text,
                                      autoFocus: false,
                                      maxLines: 2,
                                      iconPath: "assets/images/ic_location.png",
                                      editingController: _addressController,
                                      inputAction: TextInputAction.done),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: DimensHelper.sidesMargin),
                                height: _commonHelper?.screenHeight * .05,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: maleCheckBox(),
                                    ),
                                    Expanded(
                                      child: femaleCheckBox(),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: DimensHelper.sidesMargin),
                                alignment: Alignment.center,
                                child: ButtonWidget(
                                  height: _commonHelper?.screenHeight,
                                  width: _commonHelper?.screenWidth * .7,
                                  onPressed: () {
                                    _hideKeyBoard();

                                    if (checkValues()) {
                                      _onContinueTap();
                                    }
                                  },
                                  btnText: StringHelper.cont,
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          child: ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
          alignment: FractionalOffset.center,
        ),
      ],
    );
  }
//============================================================
// ** Helper Widget **
//============================================================

  Widget femaleCheckBox() {
    return RadioListTile<int>(
      title: Text(StringHelper.female,
          style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.normal)),
      value: 1,
      activeColor: SoloColor.pink,
      groupValue: _radioValue,
      onChanged: _handleRadioValueChange,
    );
  }

  Widget maleCheckBox() {
    return RadioListTile<int>(
      title: Text(StringHelper.male,
          style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.normal)),
      value: 0,
      activeColor: SoloColor.pink,
      groupValue: _radioValue,
      onChanged: _handleRadioValueChange,
    );
  }
  //============================================================
// ** Helper Function **
//============================================================

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }

  void _handleRadioValueChange(int? value) {
    setState(() {
      _radioValue = value;
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

  bool checkValues() {
    if (_nameController.text.isEmpty) {
      _commonHelper?.showAlert(
        StringHelper.name,
        StringHelper.nameValidator,
      );

      return false;
    } else if (_ageController.text.isEmpty) {
      _commonHelper?.showAlert(StringHelper.age, StringHelper.ageValidator);

      return false;
    } else if (_addressController.text.isEmpty) {
      _commonHelper?.showAlert(StringHelper.address, StringHelper.addValidator);

      return false;
    }
    return true;
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
                primaryColor: SoloColor.blue,
                buttonColor: SoloColor.blue,
                colorScheme: ColorScheme.light(primary: SoloColor.blue),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
                accentColor: SoloColor.blue),
            child: child as Widget,
          );
        },
        lastDate: DateTime.now());

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;

        int age = _commonHelper!.calculateAge(selectedDate);

        if (age >= 18) {
          userAge = age;

          _ageController.text = userAge.toString();
        } else {
          _commonHelper?.showAlert(StringHelper.age, StringHelper.agValidator);
        }
      });
  }

  Future<bool> _willPopCallback() async {
    Navigator.pop(context, refreshData);

    return false;
  }

  // Future<void> requestPermission(Permission pPermission, bool status) async {
  //   var requestPermission = await pPermission.request();
  //
  //   if (requestPermission.isGranted) {
  //     _progressShow = true;
  //
  //     _pickImage(status);
  //   } else if (requestPermission.isDenied) {
  //     _asyncInputDialog(context, status);
  //   } else if (requestPermission.isRestricted) {
  //     _asyncInputDialog(context, status);
  //   }
  // }

  // Future<Null> _pickImage(isCamera) async {
  //   var pickedFile = isCamera
  //       ? await _imagePicker.pickImage(source: ImageSource.camera)
  //       : await _imagePicker.pickImage(source: ImageSource.gallery);
  //
  //   _profileImage = File(pickedFile!.path);
  //
  //   if (_profileImage == null) {
  //     _hideProgress();
  //   }
  //
  //   if (_profileImage != null) {
  //     setState(() {
  //       _progressShow = false;
  //
  //       _cropImage(_profileImage);
  //     });
  //   }
  // }

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
                  ? Text("Allow Solomas to take pictures and record video?")
                  : Text(
                      "Allow Solomas to access photos, media and files on your device?")),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: SoloColor.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Settings', style: TextStyle(color: SoloColor.blue)),
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

  // Future<Null> _cropImage(imageFile) async {
  //   CroppedFile? croppedFile = await ImageCropper().cropImage(
  //       sourcePath: imageFile.path,
  //       compressQuality: 30,
  //       cropStyle: isCoverImage ? CropStyle.rectangle : CropStyle.circle,
  //       aspectRatioPresets: Platform.isAndroid
  //           ? [CropAspectRatioPreset.square]
  //           : [CropAspectRatioPreset.square],
  //       aspectRatio: isCoverImage
  //           ? CropAspectRatio(ratioX: 1, ratioY: 1)
  //           : CropAspectRatio(ratioX: 1, ratioY: 1),
  //       uiSettings: [
  //         AndroidUiSettings(
  //             toolbarTitle: isCoverImage ? 'Cover Pic' : 'Profile Pic',
  //             toolbarColor: Colors.white,
  //             showCropGrid: false,
  //             hideBottomControls: true,
  //             cropFrameColor: Colors.transparent,
  //             toolbarWidgetColor: SoloColor.blue,
  //             initAspectRatio: CropAspectRatioPreset.original,
  //             lockAspectRatio: true),
  //         IOSUiSettings(
  //           rotateButtonsHidden: true,
  //           minimumAspectRatio: 1.0,
  //         )
  //       ]);
  //
  //   if (croppedFile != null) {
  //     imageFile = File(croppedFile.path);
  //
  //     _showProgress();
  //
  //     _apiHelper?.uploadFile(imageFile).then((onSuccess) {
  //       UploadImageModel imageModel = onSuccess;
  //
  //       var imageKey = isCoverImage ? "coverImage" : "profilePic";
  //
  //       var body = json.encode({imageKey: imageModel.data!.url});
  //
  //       _onUpdateTap(body);
  //     }).catchError((onError) {
  //       _hideProgress();
  //     });
  //   }
  // }

  // void _onUpdateTap(String reqBody) {
  //   _commonHelper?.isInternetAvailable().then((available) {
  //     if (available) {
  //       _showProgress();
  //
  //       _updateUserBloc
  //           ?.updateUser(authToken.toString(), reqBody)
  //           .then((onValue) {
  //         if (!isCoverImage) {
  //           Map mapData = json.decode(reqBody);
  //
  //           PrefHelper.setUserProfilePic(mapData['profilePic']);
  //         }
  //         isRefresh = true;
  //         _aList = null;
  //         _getUserData();
  //       }).catchError((onError) {
  //         _hideProgress();
  //       });
  //     } else {
  //       _commonHelper?.showAlert(
  //           StringHelper.noInternetTitle, StringHelper.noInternetMsg);
  //     }
  //   });
  // }

  void _getUserData() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;
          print("apihello" + authToken.toString());

          _userProfileBloc
              ?.getUserProfileData(token.toString(), "")
              .then((onValue) {
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
// ** Firebase Function **
//============================================================
}
