import 'package:flutter/material.dart';

import '../helpers/common_helper.dart';

Widget roundButton(BuildContext context, {String? path, Function()? onTap}) {
  return InkWell(
      onTap: onTap,
      child:
          Image.asset(path!, width: CommonHelper(context).screenWidth * 0.09));
}

Widget imagePlaceHolder( {double? height, double? width}) {
  return Image.asset(
    'assets/image/image_place_holder.png',
    height: height,
    width:width,
    fit: BoxFit.cover,
  );
}
