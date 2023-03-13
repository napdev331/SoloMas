import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';

import '../resources_helper/text_styles.dart';

class TextFieldWidget extends StatefulWidget {
  final bool? autoFocus, hideText, editingEnable;
  final FocusNode? focusNode, secondFocus;
  final String? title, errorText, iconPath, hintText;
  final TextInputAction? inputAction;
  final TextInputType? keyboardType;
  final TextEditingController? editingController;
  final double? marginTop, tfHeight, letterSpace;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatter;
  final TextAlign alignment;
  final ValueChanged<String>? onChangedValue;
  final double? screenWidth;
  final Color? tabColor, etBgColor;
  final GestureTapCallback? onPressed;
  final Widget? suffixIcon;
  TextFieldWidget(
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
      this.screenWidth,
      this.tabColor,
      this.etBgColor,
      this.iconPath,
      this.onPressed,
      this.editingEnable = false,
      this.suffixIcon,
      this.hintText});

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
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
          width: widget.screenWidth! * .9,
          color: widget.etBgColor,

          alignment: Alignment.center,
          child: TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (val) {
              _fieldFocusChange(context, widget.focusNode, widget.secondFocus);
            },
            style: TextStyle(
                fontSize: Constants.FONT_TOP,
                color: SoloColor.black,
                letterSpacing: widget.letterSpace),
            keyboardType: widget.keyboardType,
            textInputAction: widget.inputAction,
            autofocus: widget.autoFocus!,
            onTap: widget.onPressed,
            controller: widget.editingController,
            focusNode: widget.focusNode,
            maxLines: widget.maxLines,
            minLines: 1,
            obscureText: widget.hideText!,
            readOnly: widget.editingEnable!,
            textAlign: widget.alignment,
            onChanged: widget.onChangedValue,
            inputFormatters: widget.inputFormatter,
            decoration: InputDecoration(
              errorText: widget.errorText,
              labelStyle: TextStyle(color: SoloColor.lightGrey200),
              suffixIcon: widget.suffixIcon,
              hintText: widget.hintText,
              hintStyle: SoloStyle.lightGrey200normalTop,
            ),
          ),
        ),
      ],
    );
  }
}
