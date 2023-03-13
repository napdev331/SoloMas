import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:solomas/resources_helper/text_styles.dart';

import '../activities/common_helpers/app_button.dart';
import '../resources_helper/colors.dart';
import '../resources_helper/dimens.dart';
import 'common_helper.dart';
import 'constants.dart';

class ChoiceGenderDialog extends StatefulWidget {
  final Function() backOnTap;
  final Function() nextOnTap;
  late int groupValue;

  ChoiceGenderDialog(
      {Key? key,
      required this.backOnTap,
      required this.nextOnTap,
      required this.groupValue})
      : super(key: key);

  @override
  State<ChoiceGenderDialog> createState() => _ChoiceGenderDialogState();
}

class _ChoiceGenderDialogState extends State<ChoiceGenderDialog> {
  CommonHelper? _commonHelper;

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DimensHelper.sidesMargin)),
        elevation: 3.0,
        child: Container(
          width: _commonHelper?.screenWidth * .9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             /* Container(
                margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
                height: 60,
                width: 60,
                child: Image.asset("images/ic_lg_bag.png"),
              ),*/
              Container(
                margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
                child: Text(
                  'Please choose your gender',
                  style: TextStyle(
                      color: SoloColor.black,
                      fontWeight: FontWeight.bold,
                      fontSize: Constants.FONT_TOP),
                ),
              ),
              Container(
                height: _commonHelper?.screenHeight * .06,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: RadioListTile<int>(
                        title: Text('Male',
                            style: TextStyle(
                                fontSize: 16.0, fontStyle: FontStyle.normal)),
                        value: 0,
                        activeColor: SoloColor.pink,
                        groupValue: widget.groupValue,
                        onChanged: (value) {
                          setState(() {
                            widget.groupValue = value ?? 0;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        title: Text('Female',
                            style: TextStyle(
                                fontSize: 16.0, fontStyle: FontStyle.normal)),
                        value: 1,
                        activeColor: SoloColor.pink,
                        groupValue: widget.groupValue,
                        onChanged: (value) {
                          setState(() {
                            widget.groupValue = value ?? 0;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppButton(
                        onTap: widget.backOnTap,
                        text: "Back",
                        color: SoloColor.pink,
                        textStyle: SoloStyle.whiteW500Medium,
                        width: _commonHelper!.screenWidth * 0.39,
                        height: _commonHelper!.screenHeight * 0.06,
                      ),
                       AppButton(
                        onTap: widget.nextOnTap,
                        text: "Next",
                        color: SoloColor.blue,
                        textStyle: SoloStyle.whiteW500Medium,
                        width: _commonHelper!.screenWidth * 0.39,
                        height: _commonHelper!.screenHeight * 0.06,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
