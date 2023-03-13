import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/resources_helper/colors.dart';

class ProgressBarIndicator extends Container {
  ProgressBarIndicator(Size size, bool load)
      : super(
            padding: EdgeInsets.all(0.0),
            child: load
                ? Container(
                    color: Colors.white.withOpacity(0.1),
                    width: size.width, //70.0,
                    height: size.height, //70.0,
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(SoloColor.blue)),
                    ),
                  )
                : Container());
}
