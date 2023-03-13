import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';

class ImageExpandedWidget extends StatelessWidget {
  final String? imgPath;
  final bool? progress;
  final double? sWidth, sHeight;
  final GestureTapCallback? onTapDownload, onTapClose;
  final bool isRotated;
  ImageExpandedWidget(
      {this.sHeight,
      this.sWidth,
      this.imgPath,
      this.onTapClose,
      this.progress,
      this.onTapDownload,
      required this.isRotated});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SoloColor.black.withOpacity(0.65),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 320,
              height: 400,
              child: Stack(
                children: [
                  Container(
                    width: 300,
                    height: 400,
                    child: PhotoView(
                      backgroundDecoration:
                          BoxDecoration(color: Colors.transparent),
                      imageProvider: CachedNetworkImageProvider(
                        imgPath.toString(),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: DimensHelper.halfSides,
                            bottom: DimensHelper.halfSides,
                            top: DimensHelper.sidesMargin),
                        child: InkWell(
                          onTap: onTapClose,
                          child: Container(
                            decoration: BoxDecoration(
                                color: SoloColor.blue,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close_rounded,
                                color: SoloColor.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
