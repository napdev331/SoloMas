import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../resources_helper/colors.dart';

space({double? width, double? height}) {
  return SizedBox(
    height: height,
    width: width,
  );
}

appBackButton({required  Function() onTap}){
  return InkWell(
      child: Container(

          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(CupertinoIcons.back,size: 25,color: SoloColor.white),
          )),
      onTap: onTap);
}
