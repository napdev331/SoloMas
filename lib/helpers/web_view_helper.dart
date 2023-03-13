import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../activities/common_helpers/app_bar.dart';
import '../resources_helper/screen_area/scaffold.dart';
import '../resources_helper/strings.dart';

class WebViewHelper extends StatelessWidget {
  //============================================================
// ** Properties **
//============================================================
  final CommonHelper commonHelper;
  final String url, title;
  final _key = UniqueKey();
  CommonHelper? _commonHelper;
  WebViewHelper(this.commonHelper, this.url, this.title);
//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: _appBar(context),
        ),
      ),
      //     AppBar(
      //   backgroundColor: SoloColor.blue,
      //   automaticallyImplyLeading: false,
      //   title: Stack(
      //     children: [
      //       GestureDetector(
      //         onTap: () {
      //           Navigator.of(context).pop();
      //         },
      //         child: Container(
      //           width: 25,
      //           height: 25,
      //           alignment: Alignment.centerLeft,
      //           child: Image.asset('images/back_arrow.png'),
      //         ),
      //       ),
      //       Container(
      //         alignment: Alignment.center,
      //         child: Text(title.toUpperCase(),
      //             textAlign: TextAlign.center,
      //             style: TextStyle(
      //                 color: Colors.white,
      //                 fontFamily: 'Montserrat',
      //                 fontSize: Constants.FONT_APP_TITLE)),
      //       )
      //     ],
      //   ),
      // ),
      body: Container(
        height: commonHelper.screenHeight,
        width: commonHelper.screenWidth,
        child: WebView(
            initialUrl: url,
            // hidden: true,
            zoomEnabled: true,
            key: _key),
      ),
    );
  }

//============================================================
// ** Main Widgets **
//============================================================
  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: title,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }
}
