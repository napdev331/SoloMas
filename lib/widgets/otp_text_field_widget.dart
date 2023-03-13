import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';

class OtpTextFieldWidget extends StatelessWidget {
  final bool? autoFocus, hideText;
  final FocusNode? focusNode, secondFocus;
  final String? title, errorText;
  final TextInputAction? inputAction;
  final TextInputType? keyboardType;
  final TextEditingController? editingController;
  final double? marginTop, tfHeight, letterSpace, screenWidth;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatter;
  final TextAlign alignment;
  final ValueChanged<String>? onChangedValue;
  OtpTextFieldWidget(
      {this.title,
      this.keyboardType,
      this.inputAction,
      this.autoFocus,
      this.focusNode,
      this.editingController,
      this.marginTop,
      this.secondFocus,
      this.inputFormatter,
      this.hideText = false,
      this.maxLines = 1,
      this.tfHeight = Constants.TF_SIZE,
      this.alignment = TextAlign.start,
      this.letterSpace = 0.0,
      this.errorText,
      this.onChangedValue,
      this.screenWidth});

  _fieldFocusChange(
      BuildContext context, FocusNode? currentFocus, FocusNode? nextFocus) {
    currentFocus?.unfocus();

    if (nextFocus != null) {
      FocusScope.of(context).requestFocus(nextFocus);

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: screenWidth! * .13,
          margin: const EdgeInsets.only(
              top: DimensHelper.smallSides,
              left: DimensHelper.sidesMargin,
              right: DimensHelper.sidesMargin),
          child: TextFormField(
            onFieldSubmitted: (val) {
              _fieldFocusChange(context, focusNode, secondFocus);
            },
            style: TextStyle(
                fontSize: Constants.FONT_TOP,
                color: SoloColor.black,
                letterSpacing: letterSpace),
            keyboardType: keyboardType,
            textInputAction: inputAction,
            autofocus: autoFocus!,
            controller: editingController,
            focusNode: focusNode,
            maxLines: maxLines,
            obscureText: hideText!,
            textAlign: TextAlign.center,
            onChanged: onChangedValue,
            cursorColor: SoloColor.blue,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              FilteringTextInputFormatter.deny(RegExp('[\\ ]')),
              LengthLimitingTextInputFormatter(1)
            ],
            decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: DimensHelper.sidesMargin,
                    horizontal: DimensHelper.sidesMargin),
                border: new OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(DimensHelper.halfSides)),
                    borderSide: new BorderSide(
                        color: SoloColor.spanishGray, width: 1.0)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(DimensHelper.halfSides)),
                    borderSide:
                        new BorderSide(color: SoloColor.blue, width: 1.0)),
                errorText: errorText),
          ),
        )
      ],
    );
  }
}
