import 'package:flutter/material.dart';

import '../../resources_helper/screen_area/scaffold.dart';

class UndefinedScreen extends StatelessWidget {
  static const routeName = '/undefined';
  const UndefinedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SoloScaffold(
      body: Center(
        child: Text('Route is not defined'),
      ),
    );
  }
}
