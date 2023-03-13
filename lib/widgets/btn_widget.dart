import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/resources_helper/dimens.dart';

import '../resources_helper/colors.dart';

class ButtonWidget extends StatelessWidget {
  ButtonWidget({this.btnText, this.height, this.width, this.onPressed});

  final String? btnText;
  final double? height;
  final double? width;
  final GestureTapCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: height! * .03,
          right: DimensHelper.sidesMargin,
          left: DimensHelper.sidesMargin),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: SoloColor.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
        child: Container(
          height: Constants.BTN_SIZE,
          width: 300,
          decoration: BoxDecoration(
              color: SoloColor.batteryChargedBlue,
              borderRadius: BorderRadius.all(Radius.circular(50))),
          child: Center(
            child: Text(btnText.toString(),
                style: TextStyle(
                    fontSize: Constants.FONT_TOP, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
