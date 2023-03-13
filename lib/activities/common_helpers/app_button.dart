import 'package:flutter/material.dart';

import '../../resources_helper/colors.dart';
import '../../resources_helper/text_styles.dart';

class AppButton extends StatelessWidget {
  final double? width;
  final double? height;
  final void Function() onTap;
  final String text;
  final Color? color;
  final TextStyle? textStyle;
  final BorderRadiusGeometry? borderRadius;
  const AppButton(
      {Key? key,
      this.height,
      this.width,
      required this.onTap,
      required this.text,
      this.textStyle,
      this.borderRadius,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          height: height ?? 32,
          width: width ?? 70,
          decoration: BoxDecoration(
            color: color ?? SoloColor.lightGrey200,
            borderRadius: borderRadius ?? BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: textStyle ?? SoloStyle.whiteW500Low,
            ),
          )),
    );
  }
}
