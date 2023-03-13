import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solomas/activities/registration/add_location_activity.dart';
import 'package:solomas/activities/services/view_service_detail.dart';
import 'package:solomas/blocs/event_details/event_bloc.dart';
import 'package:solomas/blocs/serives/ServicesBloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/multi_select_helper.dart';
import 'package:solomas/model/carnival_tiles_response.dart';
import 'package:solomas/model/service_category_response.dart';
import 'package:solomas/model/service_list_response.dart';
import 'package:solomas/model/upload_image_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:solomas/widgets/btn_widget.dart';
import 'package:solomas/widgets/text_field_widget.dart';

import '../../helpers/pref_helper.dart';
import '../../helpers/space.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';

class AddService extends StatefulWidget {
  final ServiceList? serviceList;
  final bool? isFrom;
  final context;

  const AddService({this.serviceList, this.isFrom, this.context});

  @override
  _AddServiceState createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  ApiHelper? _apiHelper;
  ServicesBloc? _servicesBloc;
  EventBloc? _eventBloc;
  HashMap<String, Object> locationDetail = HashMap();
  Map<String, dynamic>? locationMap1;
  var items = <MultiSelectDialogItem<CarnivalList>>[];
  var _phoneController = TextEditingController(),
      _businessNameController = TextEditingController(),
      _emailController = TextEditingController(),
      _websiteController = TextEditingController(),
      _coverImageController = TextEditingController(),
      _addressController = TextEditingController();
  var _phoneFocusNode = FocusNode(),
      _businessNameFocusNide = FocusNode(),
      _coverImageFocus = FocusNode(),
      _categoryFocusNode = FocusNode(),
      _emailFocusNode = FocusNode(),
      _websiteFocusNode = FocusNode();
  File? _profileImage;
  ImagePicker _imagePicker = ImagePicker();
  String profilePicUrl = "",
      serviceId = "",
      _selectCategory = "Select Category",
      _selectCarnival = "Select Carnival",
      _selectCarnivalId = "",
      addServices = "ADD SERVICES";
  var _progressShow = false;
  List<ServiceCategoryList>? _serviceCategory;
  List<CarnivalList>? _eventCarnival;
  List<CarnivalList> selectedCarnivals = [];
  List<String> carnivalsId = [];
  String phoneText = "";

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _apiHelper = ApiHelper();
    _servicesBloc = ServicesBloc();
    _eventBloc = EventBloc();
    _serviceCategory = [];
    _eventCarnival = [];
    if (widget.isFrom == true) {
      addServices = "EDIT SERVICES";

      serviceId = widget.serviceList!.serviceId.toString();

      profilePicUrl = widget.serviceList!.image.toString();
      _coverImageController.text = "image";

      _businessNameController.text =
          widget.serviceList!.businessName.toString();

      _selectCategory = widget.serviceList!.category.toString();
      if (widget.serviceList?.carnivalTitle == null) {
        _selectCarnival = "Select Carnival";
        carnivalsId = [];
      } else {
        //_selectCarnival = widget.serviceList.carnivalTitle;
        carnivalsId = widget.serviceList?.carnivalId ?? [];
      }

      _phoneController.text = widget.serviceList!.phoneNumber.toString();
      _emailController.text = widget.serviceList!.email.toString();
      _websiteController.text = widget.serviceList!.website.toString();
      _addressController.text = widget.serviceList!.locationName.toString();

      var location = json.encode({
        'lat': widget.serviceList?.location?.lat,
        'lng': widget.serviceList?.location?.lng
      });

      locationMap1 = json.decode(location);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getServiceCategory();
      _getEventCarnival();
    });
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: () {
                      _hideKeyBoard();
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) =>
                              _showGetPictureSheet());
                    },
                    child: AbsorbPointer(
                        child: Container(
                      decoration: BoxDecoration(
                        color: SoloColor.cultured,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: SoloColor.spanishGray, width: 0.5),
                      ),
                      width: _commonHelper?.screenWidth,
                      height: 200,
                      child: profilePicUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: profilePicUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Center(child: CircularProgressIndicator()),
                              ))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 35,
                                  height: 35,
                                  child: Image.asset(IconsHelper.add_event_logo,
                                      color: SoloColor.spanishGray),
                                ),
                                space(height: 15),
                                Container(
                                  child: Text(
                                    "Add Service Image",
                                    style: TextStyle(
                                      color: SoloColor.spanishGray,
                                      fontSize: Constants.FONT_MEDIUM,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    )),
                  ),
                  space(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Business Name", style: SoloStyle.lightGrey200),
                      TextFieldWidget(
                          screenWidth: _commonHelper?.screenWidth,
                          keyboardType: TextInputType.text,
                          focusNode: _businessNameFocusNide,
                          secondFocus: _categoryFocusNode,
                          inputFormatter: [
                            LengthLimitingTextInputFormatter(30),
                          ],
                          editingController: _businessNameController,
                          autoFocus: false,
                          inputAction: TextInputAction.next),
                    ],
                  ),
                  space(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Category",
                        style: SoloStyle.lightGrey200,
                      ),
                      Container(
                        child: DropdownButton<ServiceCategoryList>(
                          icon: Icon(Icons.arrow_drop_down,
                              color: SoloColor.spanishGray),
                          iconSize: 24,
                          hint: Text(_selectCategory,
                              style: TextStyle(
                                  color: SoloColor.black, fontSize: 14)),
                          isExpanded: true,
                          items: _serviceCategory
                              ?.map((ServiceCategoryList serviceCat) {
                            return DropdownMenuItem<ServiceCategoryList>(
                              value: serviceCat,
                              child: Text(toBeginningOfSentenceCase(
                                      serviceCat.serviceCategoryId) ??
                                  ''),
                            );
                          }).toList(),
                          onTap: () {
                            _hideKeyBoard();
                          },
                          onChanged: (val) {
                            setState(() {
                              _selectCategory = toBeginningOfSentenceCase(
                                      val?.serviceCategoryId) ??
                                  '';
                            });
                          },
                          underline: Container(
                            height: 1,
                            color: SoloColor.lightGrey200,
                          ),
                        ),
                      ),
                    ],
                  ),
                  space(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Phone Number",
                        style: SoloStyle.lightGrey200,
                      ),
                      TextFieldWidget(
                          screenWidth: _commonHelper?.screenWidth,
                          focusNode: _phoneFocusNode,
                          secondFocus: _emailFocusNode,
                          keyboardType:
                              TextInputType.numberWithOptions(signed: true),
                          inputFormatter: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[0-9\\-]+$')),
                            // FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(20),
                            // FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$'))
                            // TextInputFormatter.withFunction(
                            //         (oldValue, newValue) => convert(oldValue, newValue))
                          ],
                          autoFocus: false,
                          editingController: _phoneController,
                          inputAction: TextInputAction.next),
                    ],
                  ),
                  space(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email",
                        style: SoloStyle.lightGrey200,
                      ),
                      TextFieldWidget(
                          screenWidth: _commonHelper?.screenWidth,
                          focusNode: _emailFocusNode,
                          secondFocus: _websiteFocusNode,
                          keyboardType: TextInputType.text,
                          autoFocus: false,
                          inputFormatter: [
                            FilteringTextInputFormatter.deny(RegExp('[\\ ]'))
                          ],
                          editingController: _emailController,
                          inputAction: TextInputAction.next),
                    ],
                  ),
                  space(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Website (optional)",
                        style: SoloStyle.lightGrey200,
                      ),
                      TextFieldWidget(
                          screenWidth: _commonHelper?.screenWidth,
                          focusNode: _websiteFocusNode,
                          keyboardType: TextInputType.text,
                          autoFocus: false,
                          inputFormatter: [],
                          editingController: _websiteController,
                          inputAction: TextInputAction.done),
                    ],
                  ),
                  space(height: 15),
                  GestureDetector(
                    onTap: () {
                      _hideKeyBoard();

                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddLocationActivity()))
                          .then((value) {
                        _hideKeyBoard();

                        if (value != null) {
                          locationDetail = value;

                          locationMap1 = json
                              .decode(locationDetail['location'].toString());

                          _addressController.text =
                              locationDetail['locationName'].toString();
                        }
                      });
                    },
                    child: AbsorbPointer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Location",
                            style: SoloStyle.lightGrey200,
                          ),
                          TextFieldWidget(
                              screenWidth: _commonHelper?.screenWidth,
                              keyboardType: TextInputType.text,
                              autoFocus: false,
                              maxLines: 2,
                              editingController: _addressController,
                              inputAction: TextInputAction.done),
                        ],
                      ),
                    ),
                  ),
                  space(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Carnivals",
                        style: SoloStyle.lightGrey200,
                      ),
                      Container(
                        child: MultiSelectDialogField(
                          items: _eventCarnival!
                              .map((serviceCat) => MultiSelectItem<
                                      CarnivalList>(
                                  serviceCat,
                                  toBeginningOfSentenceCase(serviceCat.title) ??
                                      ''))
                              .toList(),
                          initialValue: selectedCarnivals,
                          buttonIcon: Icon(
                            Icons.arrow_drop_down,
                            color: SoloColor.spanishGray,
                          ),
                          // buttonText: Text(
                          //   "Select Carnivals",
                          //   style: TextStyle(
                          //       color: SoloColor.black, fontSize: 14),
                          // ),
                          selectedColor: SoloColor.electricPink,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                            color: Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                          onConfirm: (value) {
                            carnivalsId = [];
                            selectedCarnivals = value as List<CarnivalList>;
                            print("selectedCarnivals=$value");
                            selectedCarnivals.forEach((element) {
                              print(
                                  "selectedCarnivals=foreach=${element.carnivalId}");
                              carnivalsId.add(element.carnivalId.toString());
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  space(height: 15),
                  Container(
                    alignment: Alignment.center,
                    child: ButtonWidget(
                      height: _commonHelper?.screenHeight,
                      width: _commonHelper?.screenWidth * .7,
                      onPressed: () {
                        //_commonHelper.startActivity(EventsDetailsActivity());
                        _hideKeyBoard();

                        if (checkValues()) {
                          addServiceApi();
                        }
                      },
                      btnText: addServices,
                    ),
                  ),
                  space(height: 15),
                ],
              ),
            ),
          ),
          // Align(
          //   child: ProgressBarIndicator(
          //       _commonHelper?.screenSize, _progressShow),
          //   alignment: FractionalOffset.center,
          // ),
        ],
      ),
    );
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _appBar() {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.addService,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

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
                  //: requestPermission(Permission.photos, false);
                  : _pickImage(false);
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

//============================================================
// ** Helper Function **
//============================================================

  bool checkValues() {
    if (_coverImageController.text.isEmpty) {
      _commonHelper?.showAlert("Image", "Image must not be an empty");
      return false;
    } else if (_businessNameController.text.isEmpty) {
      _commonHelper?.showAlert("Business Name", "Title must not be an empty");
      return false;
    } else if (_phoneController.text.isEmpty) {
      _commonHelper?.showAlert(
          "Phone Number", "Phone Number must not be an empty ");

      return false;
    }
    /* if (!RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)')
        .hasMatch(_phoneController.text.toString().replaceAll("-", ""))) {
      _commonHelper.showAlert(
          "Phone Number", 'Please enter a valid Phone Number.');

      return false;
    }*/
    if ((_phoneController.text.toString().replaceAll("-", "")).length < 7) {
      _commonHelper?.showAlert(
          "Phone Number", 'Please enter a valid Phone Number.');

      return false;
    } else if (_emailController.text.isEmpty) {
      _commonHelper?.showAlert("Email", "Email must not be an empty ");

      return false;
    }
    if (!RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(_emailController.text)) {
      _commonHelper?.showAlert("Email", 'Please enter a valid email.');

      return false;
    } else if (_websiteController.text.isNotEmpty) {
      if (!RegExp(
              r'^((?:.|\n)*?)((http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?)')
          .hasMatch(_websiteController.text)) {
        _commonHelper?.showAlert(
            "Website", 'Please enter a valid website url.');

        return false;
      } else if (_addressController.text.isEmpty) {
        _commonHelper?.showAlert("Location", "Location must not be an empty");

        return false;
      }
    } else if (_addressController.text.isEmpty) {
      _commonHelper?.showAlert("Location", "Location must not be an empty");

      return false;
    } else if (selectedCarnivals.isEmpty) {
      _commonHelper?.showAlert("Category", "Please choose category");

      return false;
    }

    return true;
  }

  void _getEventCarnival() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _eventBloc?.getEventCarnival(token.toString()).then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              if (onValue.data!.carnivalList!.isNotEmpty) {
                _eventCarnival = onValue.data?.carnivalList;
              } else {}
            } else {
              _commonHelper?.showAlert(
                  StringHelper.noInternetTitle, "Something Wrong");
            }
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

  convert(TextEditingValue oldValue, TextEditingValue newValue) {
    print("OldValue: ${oldValue.text}, NewValue: ${newValue.text}");
    String newText = newValue.text;

    if (newText.length == 10) {
      // The below code gives a range error if not 10.
      RegExp phone = RegExp(r'(\d{3})(\d{3})(\d{4})');
      var matches = phone.allMatches(newValue.text);
      var match = matches.elementAt(0);
      newText = '${match.group(1)}-${match.group(2)}-${match.group(3)}';
    } else if (newText.length > 10) {
      RegExp phone = RegExp(r'(\d{1})(\d{3})(\d{3})(\d{4})');
      var matches = phone.allMatches(newValue.text);
      var match = matches.elementAt(0);
      newText =
          '(${match.group(1)})-${match.group(2)}-${match.group(3)}-${match.group(4)}';
    }

    // TODO limit text to the length of a formatted phone number?

    setState(() {
      phoneText = newText;
    });

    return TextEditingValue(
        text: newText,
        selection: TextSelection(
            baseOffset: phoneText.length, extentOffset: phoneText.length));
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

  void addServiceApi() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _showProgress();

          if (widget.isFrom == true) {
            var body = json.encode({
              "image": profilePicUrl,
              "businessName": _businessNameController.text.toString(),
              "category": _selectCategory,
              "phoneNumber": _phoneController.text.toString(),
              "email": _emailController.text.toString(),
              "carnivalId": carnivalsId,
              "website": _websiteController.text.toString(),
              "serviceId": serviceId,
              "locationName": _addressController.text.toString(),
              "location": locationMap1,
            });
            _servicesBloc
                ?.updateService(token.toString(), body)
                .then((onValue) {
              _hideProgress();
              if (onValue.statusCode == 200) {
                _commonHelper?.startActivityWithReplacement(ServiceDetail(
                  serviceId: onValue.data?.service?.serviceId,
                  refresh: true,
                  context: widget.context,
                ));
              }
            }).catchError((onError) {
              _hideProgress();
            });
          } else {
            Map<String, dynamic>? locationMap;

            if (locationDetail.containsKey("location"))
              locationMap = json.decode(locationDetail['location'].toString());

            var body = json.encode({
              "image": profilePicUrl,
              "businessName": _businessNameController.text.toString(),
              "category": _selectCategory,
              "phoneNumber": _phoneController.text.toString(),
              "email": _emailController.text.toString(),
              "carnivalId": carnivalsId,
              "website": _websiteController.text.toString(),
              "locationName": _addressController.text.toString(),
              "location": locationMap,
            });
            _servicesBloc
                ?.createService(token.toString(), body)
                .then((onValue) {
              _hideProgress();
              if (onValue.statusCode == 200) {
                _commonHelper?.startActivityWithReplacement(ServiceDetail(
                  serviceId: onValue.data?.service?.serviceId,
                  refresh: true,
                  context: widget.context,
                ));
              }
            }).catchError((onError) {
              _hideProgress();
            });
          }
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  void _getServiceCategory() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _servicesBloc?.getServiceCategory(token.toString()).then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              if (onValue.data!.serviceCategoryList!.isNotEmpty) {
                _serviceCategory = onValue.data?.serviceCategoryList;
              } else {}
            } else {
              _commonHelper?.showAlert(
                  StringHelper.noInternetTitle, "Something Wrong");
            }
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

  Future<Null> _pickImage(isCamera) async {
    var pickedFile = isCamera
        ? await _imagePicker.pickImage(source: ImageSource.camera)
        : await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      _hideProgress();
      print("_hideProgress");
    }

    _profileImage = File(pickedFile!.path);

    if (_profileImage == null) {
      _hideProgress();
    }

    if (_profileImage != null) {
      setState(() {
        _progressShow = false;
        _cropImage(_profileImage);
        profilePicUrl = _profileImage!.path;
      });
    }
  }

  Future<Null> _cropImage(imageFile) async {
    // CroppedFile? croppedFile = await ImageCropper().cropImage(
    //     sourcePath: imageFile.path,
    //     compressQuality: 30,
    //     cropStyle: CropStyle.rectangle,
    //     aspectRatioPresets: Platform.isAndroid
    //         ? [CropAspectRatioPreset.square]
    //         : [CropAspectRatioPreset.square],
    //     aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    //     uiSettings: [
    //       AndroidUiSettings(
    //           toolbarTitle: 'Photo',
    //           toolbarColor: Colors.white,
    //           showCropGrid: false,
    //           hideBottomControls: true,
    //           cropFrameColor: Colors.transparent,
    //           toolbarWidgetColor: SoloColor.blue,
    //           initAspectRatio: CropAspectRatioPreset.original,
    //           lockAspectRatio: true),
    //       IOSUiSettings(
    //         rotateButtonsHidden: true,
    //         minimumAspectRatio: 1.0,
    //       )
    //     ]);

    if (imageFile != null) {
      imageFile = File(imageFile.path);

      _showProgress();

      _apiHelper?.uploadFile(imageFile).then((onSuccess) {
        _hideProgress();

        UploadImageModel imageModel = onSuccess;

        setState(() {
          _coverImageController.text = imageFile.path.split('/').last;

          profilePicUrl = imageModel.data!.url.toString();
          //  _coverImageController.text=profilePicUrl ;
        });
      }).catchError((onError) {
        _hideProgress();
      });
    }
  }

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }
}
