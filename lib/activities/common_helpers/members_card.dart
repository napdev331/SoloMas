import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:solomas/resources_helper/text_styles.dart';

import '../../helpers/common_helper.dart';
import '../../helpers/space.dart';
import '../../resources_helper/colors.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/images.dart';

class MembersCard extends StatefulWidget {
  final String memberProfile;
  final Function() profileOnTap;
  final String memberName;
  final String memberBand;
  final Function() chatOnTap;

  const MembersCard(
      {Key? key,
      required this.chatOnTap,
      required this.profileOnTap,
      required this.memberProfile,
      required this.memberBand,
      required this.memberName})
      : super(key: key);

  @override
  State<MembersCard> createState() => _MembersCardState();
}

class _MembersCardState extends State<MembersCard> {
  late CommonHelper _commonHelper;

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: SoloColor.spanishGray.withOpacity(0.4),
            blurRadius: 2.5,
            spreadRadius: 0.7,
          ),
        ], color: SoloColor.white, borderRadius: BorderRadius.circular(8)),
        width: _commonHelper.screenWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
              onTap: widget.profileOnTap,
              child: Row(
                children: [
                  ClipOval(
                      child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          height: _commonHelper.screenHeight * 0.07,
                          width: _commonHelper.screenHeight * 0.07,
                          imageUrl: widget.memberProfile,
                          placeholder: (context, url) => imagePlaceHolder(),
                          errorWidget: (context, url, error) =>
                              imagePlaceHolder())),
                  space(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: _commonHelper.screenWidth * 0.65,
                          child: Text(widget.memberName,
                              overflow: TextOverflow.ellipsis,
                              style: SoloStyle.blackW700Top)),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 3),
                      //   child:  widget.memberBand == "null" ?  SizedBox.shrink():
                      //   Row(
                      //     children: [
                      //       Image.asset(
                      //         IconsHelper.band_user,
                      //         width: 18,
                      //       ),
                      //       Text(widget.memberBand,
                      //               style: SoloStyle.taupeGrayW500MediumXs)
                      //     ],
                      //   ),
                      // )
                    ],
                  )
                ],
              ),
            ),
            InkWell(
              onTap: widget.chatOnTap,
              child: Image.asset(
                IconsHelper.chat_icon,
                width: 22,
              ),
            )
          ]),
        ),
      ),
    );
  }
}
