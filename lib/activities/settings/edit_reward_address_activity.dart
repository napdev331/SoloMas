import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solomas/blocs/settings/edit_address_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/resources_helper/strings.dart';
import 'package:solomas/widgets/btn_widget.dart';
import 'package:solomas/widgets/text_field_widget.dart';

import '../../helpers/space.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/text_styles.dart';
import '../common_helpers/app_bar.dart';

class EditAddressArguments {
  String name;
  String email;
  String phoneNumber;
  String street;
  String city;
  String state;

  EditAddressArguments(
      {this.name = "",
      this.email = "",
      this.phoneNumber = "",
      this.street = "",
      this.city = "",
      this.state = ""});
}

class EditRewardAddress extends StatefulWidget {
  final EditAddressArguments? args;
  EditRewardAddress({this.args});
  @override
  State<StatefulWidget> createState() {
    return _EditRewardAddressState();
  }
}

class _EditRewardAddressState extends State<EditRewardAddress> {
//============================================================
// ** Properties **
//============================================================

  CommonHelper? _commonHelper;
  var _emailController = TextEditingController(),
      _stateController = TextEditingController(),
      _phoneController = TextEditingController(),
      _cityController = TextEditingController(),
      _fullNameController = TextEditingController(),
      _streetController = TextEditingController();
  var _emailFocusNode = FocusNode(),
      _stateFocusNode = FocusNode(),
      _phoneFocusNode = FocusNode(),
      _cityFocusNode = FocusNode(),
      _streetFocusNode = FocusNode(),
      _fullNameFocusNode = FocusNode();
  EditAddressBloc? _addressBloc;
  bool _progressShow = false;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
    _addressBloc = EditAddressBloc();
    _emailController.text = widget.args?.email ?? "";
    _stateController.text = widget.args?.state ?? "";
    _phoneController.text = widget.args?.phoneNumber ?? "";
    _cityController.text = widget.args?.city ?? "";
    _fullNameController.text = widget.args?.name ?? "";
    _streetController.text = widget.args?.street ?? "";
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 0),
          child: appBar(),
        ),
      ),
      body: mainBody(),
    );
  }

  @override
  void dispose() {
    _addressBloc?.dispose();

    super.dispose();
  }
//============================================================
// ** Main Widgets **
//============================================================

  Widget appBar() {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.editAddress,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget mainBody() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder(
                  stream: _addressBloc?.nameStream,
                  builder: (name, snapshot) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(StringHelper.rewardName,
                          style: SoloStyle.lightGrey200),
                      TextFieldWidget(
                          errorText: snapshot.error as String?,
                          onChangedValue: _addressBloc?.nameChanged,
                          screenWidth: _commonHelper?.screenWidth,
                          title: StringHelper.rewardName,
                          focusNode: _fullNameFocusNode,
                          maxLines: 1,
                          secondFocus: _emailFocusNode,
                          keyboardType: TextInputType.text,
                          autoFocus: false,
                          iconPath: "assets/images/ic_user.png",
                          inputFormatter: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[a-zA-Z -]")),
                            LengthLimitingTextInputFormatter(30),
                          ],
                          editingController: _fullNameController,
                          inputAction: TextInputAction.next),
                    ],
                  ),
                ),
                space(height: 15),
                StreamBuilder(
                    stream: _addressBloc?.emailStream,
                    builder: (email, snapshot) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(StringHelper.emailAddress,
                                style: SoloStyle.lightGrey200),
                            TextFieldWidget(
                                errorText: snapshot.error as String?,
                                onChangedValue: _addressBloc?.emailChanged,
                                screenWidth: _commonHelper?.screenWidth,
                                title: StringHelper.rewardEmail,
                                focusNode: _emailFocusNode,
                                secondFocus: _phoneFocusNode,
                                keyboardType: TextInputType.text,
                                inputFormatter: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp('[\\ ]'))
                                ],
                                autoFocus: false,
                                iconPath: "assets/images/ic_email.png",
                                editingController: _emailController,
                                inputAction: TextInputAction.next),
                          ],
                        )),
                space(height: 15),
                StreamBuilder(
                    stream: _addressBloc?.phoneStream,
                    builder: (phone, snapshot) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(StringHelper.phoneNumber,
                                style: SoloStyle.lightGrey200),
                            TextFieldWidget(
                                errorText: snapshot.error as String?,
                                onChangedValue: _addressBloc?.phoneChanged,
                                screenWidth: _commonHelper?.screenWidth,
                                title: StringHelper.rewardPhoneNumber,
                                focusNode: _phoneFocusNode,
                                secondFocus: _streetFocusNode,
                                keyboardType: TextInputType.phone,
                                inputFormatter: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  FilteringTextInputFormatter.deny(
                                      RegExp('[\\ ]')),
                                  LengthLimitingTextInputFormatter(10)
                                ],
                                autoFocus: false,
                                iconPath: "assets/images/ic_phone.png",
                                editingController: _phoneController,
                                inputAction: TextInputAction.next),
                          ],
                        )),
                space(height: 15),
                StreamBuilder(
                    stream: _addressBloc?.streetStream,
                    builder: (address, snapshot) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(StringHelper.street,
                                style: SoloStyle.lightGrey200),
                            TextFieldWidget(
                                errorText: snapshot.error as String?,
                                onChangedValue: _addressBloc?.addressChanged,
                                screenWidth: _commonHelper?.screenWidth,
                                title: StringHelper.street,
                                focusNode: _streetFocusNode,
                                maxLines: 1,
                                secondFocus: _stateFocusNode,
                                keyboardType: TextInputType.text,
                                autoFocus: false,
                                iconPath: "assets/images/ic_location.png",
                                inputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z0-9 -]")),
                                  LengthLimitingTextInputFormatter(60),
                                ],
                                editingController: _streetController,
                                inputAction: TextInputAction.next),
                          ],
                        )),
                space(height: 15),
                StreamBuilder(
                    stream: _addressBloc?.cityStream,
                    builder: (city, snapshot) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(StringHelper.city,
                                style: SoloStyle.lightGrey200),
                            TextFieldWidget(
                                errorText: snapshot.error as String?,
                                onChangedValue: _addressBloc?.cityChanged,
                                screenWidth: _commonHelper?.screenWidth,
                                title: StringHelper.city,
                                focusNode: _cityFocusNode,
                                secondFocus: _stateFocusNode,
                                maxLines: 1,
                                keyboardType: TextInputType.text,
                                autoFocus: false,
                                iconPath: "assets/images/ic_location.png",
                                inputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z -]")),
                                  LengthLimitingTextInputFormatter(20),
                                ],
                                editingController: _cityController,
                                inputAction: TextInputAction.next),
                          ],
                        )),
                space(height: 15),
                StreamBuilder(
                    stream: _addressBloc?.stateStream,
                    builder: (state, snapshot) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(StringHelper.state,
                                style: SoloStyle.lightGrey200),
                            TextFieldWidget(
                                errorText: snapshot.error as String?,
                                onChangedValue: _addressBloc?.stateChanged,
                                screenWidth: _commonHelper?.screenWidth,
                                title: StringHelper.state,
                                focusNode: _stateFocusNode,
                                maxLines: 1,
                                keyboardType: TextInputType.text,
                                autoFocus: false,
                                iconPath: "assets/images/ic_location.png",
                                inputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z -]")),
                                  LengthLimitingTextInputFormatter(20),
                                ],
                                editingController: _stateController,
                                inputAction: TextInputAction.done),
                          ],
                        )),
                StreamBuilder(
                    stream: _addressBloc?.saveCheck,
                    builder: (context, snapshot) => Container(
                          alignment: Alignment.center,
                          child: ButtonWidget(
                            height: _commonHelper?.screenHeight,
                            width: _commonHelper?.screenWidth * .7,
                            onPressed: () {
                              FocusScope.of(context).unfocus();

                              snapshot.hasData
                                  ? _onSaveTap()
                                  : CommonHelper.alertOk(StringHelper.error,
                                      StringHelper.requiredFields);
                            },
                            btnText: StringHelper.save.toUpperCase(),
                          ),
                        )),
              ],
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

  void _onSaveTap() {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        PrefHelper.getAuthToken().then((authToken) {
          var address = _streetController.text.toString().trim();

          var resBody = {};

          resBody["name"] = _fullNameController.text.toString().trim();

          resBody["street"] = address;

          resBody["state"] = _stateController.text.toString().trim();

          resBody["city"] = _cityController.text.toString().trim();

          resBody["email"] = _emailController.text.toString().trim();

          resBody["phoneNumber"] =
              Constants.COUNTRY_CODE + _phoneController.text.toString().trim();

          var body = json.encode({'address': resBody});

          _addressBloc
              ?.updatePickUpAddress(authToken.toString(), body)
              .then((onValue) {
            _hideProgress();
            PrefHelper.setUserAddress(json.encode(resBody));

            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => _commonHelper!
                    .successBottomSheet(StringHelper.addressD,
                        "Address Update Successfully", true));
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
// ** Firebase Helper  **
//============================================================

}
