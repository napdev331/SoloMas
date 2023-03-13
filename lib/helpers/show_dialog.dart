import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:solomas/helpers/profile_dialog.dart';

import '../model/public_feeds_model.dart';
import '../model/user_profile_model.dart';
import 'choice_xender_dialog.dart';
import 'feed_dialog.dart';

class ShowDialog {
  static showFeedDialog(
    BuildContext context, {
    List<PublicFeedList>? imgUrl,
    List<Photo>? photoList,
    int? indexSearch,
    int? indexPro,
    required bool isHome,
    CarouselController? controller,
  }) {
    showDialog(
        context: context,
        builder: (context) => FeedDialog(
              imgUrl: imgUrl,
              indexSearch: indexSearch,
              indexPro: indexPro,
              controller: controller,
              isHome: isHome,
              photoList: photoList,
            ));
  }

  static showChoiceGender(
    BuildContext context, {
       required int groupValue,
    required final Function() backOnTap,
    required final Function() nextOnTap,
  }) {
    showDialog(
        context: context,
        builder: (context) => ChoiceGenderDialog(
          groupValue: groupValue,
              backOnTap: backOnTap,
              nextOnTap: nextOnTap,
            ));

  }
  static showProfileDialog(BuildContext context,{required  String imgUrl}) {
    showDialog(context: context, builder: (context) => ProfileDialog(imgUrl:imgUrl ,));
}
}
