import 'package:flutter/material.dart';

class SoloScaffold extends StatefulWidget {
  final Color? backGroundColor;
  final PreferredSizeWidget? appBar;
  final Widget body;
  const SoloScaffold({
    Key? key,
    this.backGroundColor,
    this.appBar,
    required this.body,
  }) : super(key: key);

  @override
  State<SoloScaffold> createState() => _SoloScaffoldState();
}

class _SoloScaffoldState extends State<SoloScaffold> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: widget.backGroundColor,
        appBar: widget.appBar,
        body: widget.body,
      ),
    );
  }
}
