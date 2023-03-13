import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solomas/activities/home/add_video/video_trimmer.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/widgets/border_text_field.dart';
import 'package:solomas/widgets/btn_widget.dart';

import '../../../resources_helper/screen_area/scaffold.dart';
import '../../../resources_helper/strings.dart';

enum ImageSourceType { camera, gallery }

class AddVideo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddVideoState();
  }
}

class AddVideoState extends State<AddVideo> {
  CommonHelper? _commonHelper;

  bool _progressShow = false;

  var _titleController = TextEditingController();

  var _titleFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  String? _fileName;
  String? _saveAsFileName;
  List<PlatformFile>? _paths;
  String? _directoryPath;
  String? _extension;
  bool _isLoading = false;
  bool _userAborted = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.custom;
  void _handleURLButtonPress(BuildContext context, var type) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => VideoEditor(type: type)));
  }

  void _pickFiles() async {
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: true,
        allowCompression: true,
        onFileLoading: (FilePickerStatus status) => print(status),
        allowedExtensions: ['mp4'],
      ))
          ?.files;
    } on PlatformException catch (e) {
      _logException('Unsupported operation' + e.toString());
    } catch (e) {
      _logException(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _fileName =
          _paths != null ? _paths!.map((e) => e.name).toString() : '...';
      _userAborted = _paths == null;
    });
  }

  void _logException(String message) {
    print(message);
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
            _handleURLButtonPress(context, ImageSourceType.camera);
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
            _pickFiles();
            //  _handleURLButtonPress(context, ImageSourceType.gallery);
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

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

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
              child: Text(StringHelper.shareMo.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: Constants.FONT_APP_TITLE)),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              GestureDetector(
                onTap: () {
                  showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) =>
                          _showCreateFeedBottomSheet());
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DimensHelper.halfSides),
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
                          child: SvgPicture.asset('assets/images/Add Video.svg',
                              color: SoloColor.spanishGray)),
                      Container(
                        child: Text(
                          StringHelper.addVideo,
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
                  },
                  btnText: StringHelper.share.toUpperCase(),
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
