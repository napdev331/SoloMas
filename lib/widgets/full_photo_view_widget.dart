import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/resources_helper/colors.dart';

import '../helpers/common_helper.dart';

class FullPhotoWidget extends StatelessWidget {
  final String? url;

  FullPhotoWidget({Key? key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CommonHelper? _commonHelper;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: SoloColor.white,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/icons/backward.png',
              ),
            ),
          ),
        ),
        title: Container(
          alignment: Alignment.center,
          child: Text(''.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white, fontSize: Constants.FONT_APP_TITLE)),
        ),
      ),
      body: FullPhotoScreen(url: url.toString()),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String? url;

  FullPhotoScreen({Key? key, @required this.url}) : super(key: key);

  @override
  State createState() => FullPhotoScreenState(url: url.toString());
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String? url;

  FullPhotoScreenState({Key? key, @required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(imageProvider: NetworkImage(url.toString())));
  }
}
