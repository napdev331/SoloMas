import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';

class BorderTextFieldWidget extends StatelessWidget {
  BorderTextFieldWidget(
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
      this.maxTextLength,
      this.hintText});

  final bool? autoFocus, hideText;

  final FocusNode? focusNode, secondFocus;

  final String? title, errorText, hintText;

  final TextInputAction? inputAction;

  final TextInputType? keyboardType;

  final TextEditingController? editingController;

  final double? marginTop, tfHeight, letterSpace;

  final int? maxLines, maxTextLength;

  final List<TextInputFormatter>? inputFormatter;

  final TextAlign alignment;

  final ValueChanged<String>? onChangedValue;

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
            maxLength: maxTextLength,
            textAlign: alignment,
            onChanged: onChangedValue,
            cursorColor: SoloColor.black,
            inputFormatters: inputFormatter,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(DimensHelper.halfSides)),
                    borderSide:
                        BorderSide(color: SoloColor.spanishGray, width: 0.5)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(DimensHelper.halfSides)),
                    borderSide:
                        BorderSide(color: SoloColor.spanishGray, width: 0.5)),
                contentPadding: EdgeInsets.symmetric(
                    vertical: DimensHelper.sidesMargin,
                    horizontal: DimensHelper.sidesMargin),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(DimensHelper.halfSides)),
                    borderSide:
                        BorderSide(color: SoloColor.spanishGray, width: 0.5)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(DimensHelper.halfSides)),
                    borderSide:
                        BorderSide(color: SoloColor.spanishGray, width: 0.5)),
                errorText: errorText,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: Constants.FONT_MEDIUM,
                  color: SoloColor.spanishGray,
                  fontStyle: FontStyle.normal,
                ),
                errorStyle: TextStyle(
                  fontSize: Constants.FONT_LOW,
                  color: SoloColor.sunsetRed,
                  fontStyle: FontStyle.normal,
                )),
          ),
        )
      ],
    );
  }
}
