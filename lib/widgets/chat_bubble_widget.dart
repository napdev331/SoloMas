import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/widgets/full_photo_view_widget.dart';

import '../resources_helper/common_widget.dart';

class Bubble extends StatelessWidget {
  Bubble(
      {this.message,
      this.type,
      this.time,
      this.delivered,
      this.isMe,
      this.screenWidth});

  final String? message, time, type;

  final delivered, isMe;

  final double? screenWidth;

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? SoloColor.pink : SoloColor.white;
    final align = isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final icon = delivered ? Icons.done_all : Icons.done;

    final radius = isMe
        ? BorderRadius.only(
            topRight: Radius.circular(DimensHelper.sidesMargin),
            topLeft: Radius.circular(DimensHelper.sidesMargin),
            bottomLeft: Radius.circular(DimensHelper.sidesMargin),
          )
        : BorderRadius.only(
            topRight: Radius.circular(DimensHelper.sidesMargin),
            topLeft: Radius.circular(DimensHelper.sidesMargin),
            bottomRight: Radius.circular(DimensHelper.sidesMargin),
          );

    return Column(
      crossAxisAlignment: align,
      children: [
        Align(
          alignment: isMe ? Alignment.topRight : Alignment.topLeft,
          child: Container(
            constraints:
                BoxConstraints(minWidth: 100, maxWidth: screenWidth! * .7),
            margin: const EdgeInsets.only(
                left: DimensHelper.sidesMargin,
                right: DimensHelper.sidesMargin,
                top: DimensHelper.halfSides,
                bottom: DimensHelper.halfSides),
            padding: type == "image"
                ? const EdgeInsets.all(DimensHelper.tinySides)
                : const EdgeInsets.all(DimensHelper.halfSides),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(
                color: SoloColor.graniteGray.withOpacity(0.1),
              ),
              borderRadius: radius,
            ),
            child: type == "image"
                ? Container(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FullPhotoWidget(url: message.toString())));
                      },
                      child: Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => imagePlaceHolder(),
                          errorWidget: (context, url, error) =>
                              imagePlaceHolder(),
                          imageUrl: message.toString(),
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: radius,
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 80),
                        child: Text(
                          message.toString() + "\n",
                          style: TextStyle(
                              color: isMe ? SoloColor.white : SoloColor.black),
                        ),
                      ),
                      Positioned(
                        bottom: 0.0,
                        right: 0.0,
                        child: Row(
                          children: [
                            Text(time.toString(),
                                style: TextStyle(
                                  color:
                                      isMe ? SoloColor.white : SoloColor.black,
                                  fontSize: Constants.FONT_LOW,
                                )),
                            SizedBox(width: DimensHelper.smallSides)

                            /*Icon(icon, size: 12.0,
                          color: isMe ? Colors.white : Colors.black)*/
                          ],
                        ),
                      )
                    ],
                  ),
          ),
        )
      ],
    );
  }
}
