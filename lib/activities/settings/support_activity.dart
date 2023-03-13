import 'package:flutter/material.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/resources_helper/colors.dart';

import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/strings.dart';

class SupportActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SupportActivityState();
  }
}

class _SupportActivityState extends State<SupportActivity> {
  @override
  Widget build(BuildContext context) {
    var _commonHelper = CommonHelper(context);

    var margin = _commonHelper.screenHeight * .010;

    var doubleMargin = _commonHelper.screenHeight * .040;

    return SoloScaffold(
        appBar: AppBar(
          backgroundColor: SoloColor.blue,
          automaticallyImplyLeading: false,
          title: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _commonHelper.closeActivity();
                },
                child: Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.centerLeft,
                  child: Image.asset('images/back_arrow.png'),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(StringHelper.support.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: Constants.FONT_APP_TITLE)),
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.only(
              top: doubleMargin, left: doubleMargin, right: doubleMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: margin, left: margin),
                child: Text(
                  StringHelper.email.toUpperCase(),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: margin, left: margin),
                child: Text(
                  StringHelper.solomasGmail,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: margin),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: doubleMargin, left: margin),
                child: Text(
                  StringHelper.addressD.toUpperCase(),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: margin, left: margin),
                child: Text(
                  StringHelper.albanyNewYork,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: margin),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: doubleMargin, left: margin),
                child: Text(
                  StringHelper.Contact,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: margin, left: margin),
                child: Text(
                  StringHelper.contactNumber,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: margin),
                child: Divider(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        )));
  }
}
