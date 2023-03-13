import 'package:flutter/material.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/resources_helper/colors.dart';

import '../../../../resources_helper/screen_area/scaffold.dart';
import '../../../../resources_helper/strings.dart';

class ContinentDetails extends StatefulWidget {
  const ContinentDetails({key}) : super(key: key);

  @override
  _ContinentDetailsState createState() => _ContinentDetailsState();
}

class _ContinentDetailsState extends State<ContinentDetails> {
  @override
  Widget build(BuildContext context) {
    return SoloScaffold(
      appBar: AppBar(
        backgroundColor: SoloColor.blue,
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            GestureDetector(
              onTap: () {
                //_commonHelper.closeActivity();
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
              child: Text(StringHelper.details.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontSize: Constants.FONT_APP_TITLE)),
            )
          ],
        ),
      ),
      body: detailsDescription(),
    );
  }

  Widget detailsDescription() {
    return Expanded(child: Container());
  }
}
