import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../resources_helper/common_widget.dart';

class ProfileDialog extends StatelessWidget {
  final String imgUrl;
  const ProfileDialog({Key? key, required this.imgUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: CachedNetworkImage(
            imageUrl: imgUrl,
            fit: BoxFit.fill,
            errorWidget: (context, url, error) => imagePlaceHolder(),
            placeholder: (context, url) => imagePlaceHolder(),
          ),
        ),
      ),
    );
  }
}
