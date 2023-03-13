import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solomas/activities/events/view_events_details.dart';
import 'package:solomas/activities/registration/add_location_activity.dart';
import 'package:solomas/blocs/event_details/event_bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/carnival_tiles_response.dart';
import 'package:solomas/model/events_response.dart';
import 'package:solomas/model/get_events_category.dart';
import 'package:solomas/model/upload_image_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:solomas/widgets/btn_widget.dart';
import 'package:solomas/widgets/text_field_widget.dart';

import '../../helpers/space.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';

class AddEvent extends StatefulWidget {
  final EventList? eventList;
  final bool? isFrom;
  final context;

  const AddEvent({this.eventList, this.isFrom, this.context});

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  ApiHelper? _apiHelper;
  EventBloc? _eventBloc;
  HashMap<String, Object> locationDetail = HashMap();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  var _hostController = TextEditingController(),
      _eventTitleController = TextEditingController(),
      _startDateController = TextEditingController(),
      _endDateController = TextEditingController(),
      _startTimeController = TextEditingController(),
      _endTimeController = TextEditingController(),
      _categoryController = TextEditingController(),
      _carnivalController = TextEditingController(),
      _descriptionController = TextEditingController(),
      _coverImageController = TextEditingController(),
      _addressController = TextEditingController();

  var _carnivalFocusNode = FocusNode(),
      _hostFocusNode = FocusNode(),
      _eventTitleFocusNode = FocusNode(),
      _coverImageFocus = FocusNode(),
      _categoryFocusNode = FocusNode(),
      _startDateFocusNode = FocusNode(),
      _endDateFocusNode = FocusNode(),
      _endTimeFocusNode = FocusNode(),
      _startTimeFocusNode = FocusNode(),
      _descriptionFocusNode = FocusNode();
  File? _profileImage;
  ImagePicker _imagePicker = ImagePicker();
  String profilePicUrl = "",
      eventId = "",
      _selectCategory = "Select Category",
      _selectCarnival = "Select Carnival",
      _selectCarnivalId = "",
      addEvent = "ADD EVENT";
  var _progressShow = false;
  String outputDate = "";
  String outputTime = "";
  String time = "";
  List<EventCategoryList>? _eventCategory;
  List<CarnivalList>? _eventCarnival;
  Object? locationFetchUser;
  Object? locationFetchUserlat;
  Object? locationFetchUserlong;
  Map<String, dynamic>? locationMap1;
  var locationMap;
  String? location;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _apiHelper = ApiHelper();

    _eventBloc = EventBloc();
    _eventCategory = [];
    _eventCarnival = [];
    if (widget.isFrom == true) {
      addEvent = "EDIT EVENT";

      eventId = widget.eventList!.eventId.toString();

      profilePicUrl = widget.eventList!.image.toString();
      _coverImageController.text = "image";

      _eventTitleController.text = widget.eventList!.title.toString();

      _selectCategory = widget.eventList!.category.toString();

      _selectCarnival = widget.eventList!.carnivalTitle.toString();
      _selectCarnivalId = widget.eventList!.carnivalId.toString();

      _hostController.text = widget.eventList!.host.toString();
      _startDateController.text = widget.eventList!.startDate.toString();
      _startTimeController.text = widget.eventList!.startTime.toString();
      _endDateController.text = widget.eventList!.endDate.toString();
      _endTimeController.text = widget.eventList!.endTime.toString();
      _descriptionController.text = widget.eventList!.description.toString();
      _addressController.text = widget.eventList!.locationName.toString();
      location = json.encode({
        'lat': widget.eventList?.location?.lat,
        'lng': widget.eventList?.location?.lng
      });
      locationMap1 = json.decode(location.toString());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getEventCategory();
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
            padding: const EdgeInsets.all(15),
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
                                    placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        Center(
                                            child:
                                                CircularProgressIndicator())))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    child: Image.asset(
                                        IconsHelper.add_event_logo,
                                        color: SoloColor.spanishGray),
                                  ),
                                  space(height: 15),
                                  Container(
                                    child: Text(
                                      StringHelper.addEventImage,
                                      style: SoloStyle.spanishGrayFontMedium,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  space(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(StringHelper.eventTitle,
                          style: SoloStyle.lightGrey200),
                      TextFieldWidget(
                          screenWidth: _commonHelper?.screenWidth,
                          keyboardType: TextInputType.text,
                          focusNode: _eventTitleFocusNode,
                          secondFocus: _categoryFocusNode,
                          inputFormatter: [
                            LengthLimitingTextInputFormatter(30),
                          ],
                          editingController: _eventTitleController,
                          autoFocus: false,
                          inputAction: TextInputAction.next),
                    ],
                  ),
                  space(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 155,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              StringHelper.eventHost,
                              style: SoloStyle.lightGrey200,
                            ),
                            TextFieldWidget(
                                screenWidth: _commonHelper?.screenWidth,
                                focusNode: _hostFocusNode,
                                secondFocus: _startDateFocusNode,
                                keyboardType: TextInputType.text,
                                inputFormatter: [
                                  LengthLimitingTextInputFormatter(30),
                                ],
                                autoFocus: false,
                                editingController: _hostController,
                                inputAction: TextInputAction.next),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 155,
                        child: GestureDetector(
                          onTap: () {
                            _hideKeyBoard();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddLocationActivity())).then((value) {
                              _hideKeyBoard();

                              if (value != null) {
                                locationDetail = value;

                                locationFetchUser = locationDetail['location'];
                                locationMap = json.decode(
                                    locationDetail['location'].toString());
                                locationMap1 = locationMap;

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
                                  StringHelper.eventLocation,
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
                      ),
                    ],
                  ),
                  space(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 155,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              StringHelper.eventSelectCategory,
                              style: SoloStyle.lightGrey200,
                            ),
                            Container(
                              child: DropdownButton<EventCategoryList>(
                                icon: Icon(Icons.arrow_drop_down,
                                    color: SoloColor.spanishGray),
                                iconSize: 24,
                                hint: Text(_selectCategory,
                                    style: SoloStyle.blackLower),
                                isExpanded: true,
                                items: _eventCategory
                                    ?.map((EventCategoryList eventCat) {
                                  return DropdownMenuItem<EventCategoryList>(
                                    alignment: AlignmentDirectional.center,
                                    value: eventCat,
                                    child: Text(
                                      toBeginningOfSentenceCase(
                                              eventCat.eventCategoryId) ??
                                          '',
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }).toList(),
                                onTap: () {
                                  _hideKeyBoard();
                                },
                                onChanged: (val) {
                                  setState(() {
                                    _selectCategory = toBeginningOfSentenceCase(
                                            val?.eventCategoryId) ??
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
                      ),
                      SizedBox(
                        width: 155,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              StringHelper.eventSelectCarnival,
                              style: SoloStyle.lightGrey200,
                            ),
                            Container(
                              child: DropdownButton<CarnivalList>(
                                icon: Icon(Icons.arrow_drop_down,
                                    color: SoloColor.spanishGray),
                                iconSize: 24,
                                hint: Text(_selectCarnival,
                                    style: SoloStyle.blackLower),
                                isExpanded: true,
                                items: _eventCarnival
                                    ?.map((CarnivalList eventCarnival) {
                                  return DropdownMenuItem<CarnivalList>(
                                    value: eventCarnival,
                                    child: Text(toBeginningOfSentenceCase(
                                            eventCarnival.title) ??
                                        ''),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectCarnival =
                                        toBeginningOfSentenceCase(val?.title) ??
                                            '';
                                    _selectCarnivalId =
                                        toBeginningOfSentenceCase(
                                                val?.carnivalId) ??
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
                      ),
                    ],
                  ),
                  space(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 155,
                        child: GestureDetector(
                          onTap: () async {
                            _hideKeyBoard();
                            _startDateController.text =
                                await _selectDate(context);
                          },
                          child: AbsorbPointer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  StringHelper.eventStartDate,
                                  style: SoloStyle.lightGrey200,
                                ),
                                TextFieldWidget(
                                    screenWidth: _commonHelper?.screenWidth,
                                    focusNode: _startDateFocusNode,
                                    secondFocus: _endDateFocusNode,
                                    keyboardType: TextInputType.text,
                                    autoFocus: false,
                                    inputFormatter: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp('[\\ ]'))
                                    ],
                                    editingController: _startDateController,
                                    inputAction: TextInputAction.next),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 155,
                        child: GestureDetector(
                          onTap: () async {
                            _hideKeyBoard();
                            _endDateController.text =
                                await _selectDate(context);
                          },
                          child: AbsorbPointer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  StringHelper.eventEndDate,
                                  style: SoloStyle.lightGrey200,
                                ),
                                TextFieldWidget(
                                    screenWidth: _commonHelper?.screenWidth,
                                    focusNode: _endDateFocusNode,
                                    secondFocus: _startTimeFocusNode,
                                    keyboardType: TextInputType.text,
                                    autoFocus: false,
                                    inputFormatter: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp('[\\ ]'))
                                    ],
                                    editingController: _endDateController,
                                    inputAction: TextInputAction.next),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  space(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 155,
                        child: GestureDetector(
                          onTap: () async {
                            _hideKeyBoard();
                            _startTimeController.text =
                                await _selectTime(context);
                          },
                          child: AbsorbPointer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  StringHelper.eventStartTime,
                                  style: SoloStyle.lightGrey200,
                                ),
                                TextFieldWidget(
                                    screenWidth: _commonHelper?.screenWidth,
                                    focusNode: _startTimeFocusNode,
                                    secondFocus: _endTimeFocusNode,
                                    keyboardType: TextInputType.text,
                                    autoFocus: false,
                                    inputFormatter: [],
                                    editingController: _startTimeController,
                                    inputAction: TextInputAction.next),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 155,
                        child: GestureDetector(
                          onTap: () async {
                            _hideKeyBoard();
                            _endTimeController.text =
                                await _selectTime(context);
                          },
                          child: AbsorbPointer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  StringHelper.eventEndTime,
                                  style: SoloStyle.lightGrey200,
                                ),
                                TextFieldWidget(
                                    screenWidth: _commonHelper?.screenWidth,
                                    focusNode: _endTimeFocusNode,
                                    secondFocus: _descriptionFocusNode,
                                    keyboardType: TextInputType.text,
                                    autoFocus: false,
                                    inputFormatter: [],
                                    editingController: _endTimeController,
                                    inputAction: TextInputAction.next),
                              ],
                            ),
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
                        StringHelper.eventDescription,
                        style: SoloStyle.lightGrey200,
                      ),
                      TextFieldWidget(
                          screenWidth: _commonHelper?.screenWidth,
                          focusNode: _descriptionFocusNode,
                          keyboardType: TextInputType.text,
                          autoFocus: false,
                          inputFormatter: [
                            LengthLimitingTextInputFormatter(100),
                          ],
                          editingController: _descriptionController,
                          inputAction: TextInputAction.next),
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
                          _addEventApi();
                        }
                      },
                      btnText: addEvent,
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
      appbarTitle: StringHelper.addEvent,
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
          child: Text(StringHelper.camera,
              style: SoloStyle.blackW500FontTop),
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
            style: SoloStyle.blackW500FontTop,
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
        child: Text(StringHelper.cancel,
            style: SoloStyle.blackW500FontTop),
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
      _commonHelper?.showAlert(
          StringHelper.eventImage, StringHelper.eventImageMessage);
      return false;
    } else if (_eventTitleController.text.isEmpty) {
      _commonHelper?.showAlert(
          StringHelper.eventTitle, StringHelper.eventTitleMessage);
      return false;
    } else if (_selectCategory == StringHelper.eventSelectCategory) {
      _commonHelper?.showAlert(
          StringHelper.eventCategory, StringHelper.eventCategoryMessage);

      return false;
    } else if (_selectCarnival == StringHelper.eventSelectCarnival) {
      _commonHelper?.showAlert(
          StringHelper.eventCarnival, StringHelper.eventCarnivalMessage);

      return false;
    } else if (_hostController.text.isEmpty) {
      _commonHelper?.showAlert(
          StringHelper.eventHost, StringHelper.eventHostMessage);

      return false;
    } else if (_startDateController.text.isEmpty) {
      _commonHelper?.showAlert(
          StringHelper.eventStartDate, StringHelper.eventStartDateMes);

      return false;
    } else if (_endDateController.text.isEmpty) {
      _commonHelper?.showAlert(
          StringHelper.eventEndDate, StringHelper.eventEndDateMes);

      return false;
    } else if (_commonHelper!
        .checkEvent(_startDateController.text, _endDateController.text)) {
      _commonHelper?.showAlert(StringHelper.alert, StringHelper.alertMessage);

      return false;
    } else if (_startTimeController.text.isEmpty) {
      _commonHelper?.showAlert(
          StringHelper.eventStartTime, StringHelper.eventStartTimeMsg);

      return false;
    } else if (_endTimeController.text.isEmpty) {
      _commonHelper?.showAlert(
          StringHelper.eventEndTime, StringHelper.eventEndTimeMsg);

      return false;
    } else if (_descriptionController.text.isEmpty) {
      _commonHelper?.showAlert(
          StringHelper.eventDescription, StringHelper.eventDescriptionMsg);

      return false;
    } else if (_addressController.text.isEmpty) {
      _commonHelper?.showAlert(
          StringHelper.eventLocation, StringHelper.eventLocationMsg);

      return false;
    }

    return true;
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
          title: Text(StringHelper.appPermission),
          content: Container(
              child: isAndroid
                  ? Text(StringHelper.appPermissionMsg)
                  : Text(StringHelper.appPermissionMessage)),
          actions: [
            TextButton(
              child: Text(StringHelper.cancel,
                  style: SoloStyle.blue),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(StringHelper.settings,
                  style: SoloStyle.blue),
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
    if (imageFile != null) {
      imageFile = File(imageFile.path);
      _showProgress();

      _apiHelper?.uploadFile(imageFile).then((onSuccess) {
        _hideProgress();

        UploadImageModel imageModel = onSuccess;

        setState(() {
          _coverImageController.text = imageFile.path.split('/').last;

          profilePicUrl = imageModel.data?.url ?? '';
          //  _coverImageController.text=profilePicUrl ;
        });
      }).catchError((onError) {
        _hideProgress();
      });
    }
  }

  Future<String> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        lastDate: DateTime(2100),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
                primaryColor: SoloColor.electricPink,
                buttonColor: SoloColor.electricPink,
                colorScheme: ColorScheme.light(primary: SoloColor.electricPink),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
                accentColor: SoloColor.electricPink),
            child: child as Widget,
          );
        },
        firstDate: DateTime.now());

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        final df = new DateFormat('MM/dd/yyyy');
        outputDate = df.format(selectedDate);
      });
    return outputDate;
  }

  Future<String> _selectTime(BuildContext context) async {
    final TimeOfDay? picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child as Widget,
          );
        });

    if (picked_s != null && picked_s != selectedTime)
      setState(() {
        selectedTime = picked_s;
        print(selectedTime);
        time = formatTimeOfDay(selectedTime);
      });
    return time;
  }

  void _hideKeyBoard() {
    FocusScope.of(context).unfocus();
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"

    return format.format(dt);
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

  void _addEventApi() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _showProgress();

          if (widget.isFrom == true) {
            var body = json.encode({
              "image": profilePicUrl,
              "title": _eventTitleController.text.toString(),
              "category": _selectCategory,
              "carnivalId": _selectCarnivalId,
              "host": _hostController.text.toString(),
              "description": _descriptionController.text.toString(),
              "locationName": _addressController.text.toString(),
              "startTime": _startTimeController.text.toString(),
              "startDate": _startDateController.text.toString(),
              "endTime": _endTimeController.text.toString(),
              "endDate": _endDateController.text.toString(),
              "location": locationMap1,
              "eventId": eventId
            });
            _eventBloc?.updateEvent(token.toString(), body).then((onValue) {
              _hideProgress();
              if (onValue.statusCode == 200) {
                _commonHelper
                    ?.startActivityWithReplacement(EventsDetailsActivity(
                  eventId: onValue.data!.event!.eventId.toString(),
                  refresh: true,
                  context: widget.context,
                ));
              }
            }).catchError((onError) {
              _hideProgress();
            });
          } else {
            Map<String, dynamic>? locationMap;

            if (locationDetail.containsKey(StringHelper.eventLocations))
              locationMap = json.decode(
                  locationDetail[StringHelper.eventLocations].toString());

            var body = json.encode({
              "image": profilePicUrl,
              "title": _eventTitleController.text.toString(),
              "category": _selectCategory,
              "carnivalId": _selectCarnivalId,
              "host": _hostController.text.toString(),
              "description": _descriptionController.text.toString(),
              "locationName": _addressController.text.toString(),
              "startTime": _startTimeController.text.toString(),
              "startDate": _startDateController.text.toString(),
              "endTime": _endTimeController.text.toString(),
              "endDate": _endDateController.text.toString(),
              "location": locationMap,
            });
            _eventBloc?.createEvent(token.toString(), body).then((onValue) {
              _hideProgress();
              if (onValue.statusCode == 200) {
                _commonHelper
                    ?.startActivityWithReplacement(EventsDetailsActivity(
                  eventId: onValue.data!.event!.eventId.toString(),
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

  void _getEventCategory() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _eventBloc?.getEventCategory(token.toString()).then((onValue) {
            _hideProgress();
            if (onValue.statusCode == 200) {
              if (onValue.data!.eventCategoryList!.isNotEmpty) {
                _eventCategory = onValue.data?.eventCategoryList;
              } else {}
            } else {
              _commonHelper?.showAlert(
                  StringHelper.noInternetTitle, StringHelper.somethingWrong);
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
                  StringHelper.noInternetTitle, StringHelper.somethingWrong);
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
}
