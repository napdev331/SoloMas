import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:solomas/helpers/common_helper.dart';

import '../model/public_feeds_model.dart';
import '../model/user_profile_model.dart';
import '../resources_helper/colors.dart';
import '../resources_helper/common_widget.dart';

class FeedDialog extends StatefulWidget {
  final List<PublicFeedList>? imgUrl;
  final List<Photo>? photoList;
  final bool isHome;

  final int? indexSearch;
  final int? indexPro;
  final CarouselController? controller;

  const FeedDialog(
      {Key? key,
      this.imgUrl,
      this.indexSearch,
      this.indexPro,
      required this.controller,
      this.photoList,
      required this.isHome})
      : super(key: key);

  @override
  State<FeedDialog> createState() => _FeedDialogState();
}

class _FeedDialogState extends State<FeedDialog> {
  late CommonHelper _commonHelper;

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Center(
            child: Container(
              alignment: Alignment.center,
              height: _commonHelper.screenHeight * 0.5,
              width: _commonHelper.screenWidth * 0.9,
              child: widget.isHome == true
                  ? widget.imgUrl != null
                      ? widget.imgUrl![widget.indexSearch!].image!.length > 1
                          ? Stack(
                              children: [
                                CarouselSlider.builder(
                                  itemCount: widget.imgUrl![widget.indexSearch!]
                                      .image!.length,
                                  carouselController: widget.controller,
                                  options: CarouselOptions(
                                    aspectRatio: 6 / 12,
                                    autoPlay: false,
                                    viewportFraction: 1.0,
                                    onPageChanged: (index, reason) {
                                      print(
                                          "seeThisGuy1212121212${widget.imgUrl![widget.indexSearch!].sliderPosition}$index");
                                      setState(() {
                                        widget.imgUrl![widget.indexSearch!]
                                            .sliderPosition = index;
                                      });
                                    },
                                  ),
                                  itemBuilder: (BuildContext context, int index,
                                      int realIndex) {
                                    return Container(
                                      child: PhotoView(
                                        minScale: 0.3,
                                        maxScale: 2.5,
                                        backgroundDecoration: BoxDecoration(
                                            color: SoloColor.trans),
                                        imageProvider: NetworkImage(
                                          widget.imgUrl![widget.indexSearch!]
                                              .image![index],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Visibility(
                                    visible: widget.imgUrl![widget.indexSearch!]
                                            .image!.length >
                                        1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: widget
                                          .imgUrl![widget.indexSearch!].image!
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        return GestureDetector(
                                          onTap: () {
                                            var res = widget
                                                    .imgUrl![
                                                        widget.indexSearch!]
                                                    .sliderPosition ==
                                                entry.key;
                                            print("valueoftheres$res");
                                            widget.controller
                                                ?.animateToPage(entry.key);
                                          },
                                          child: Container(
                                            width: 8.0,
                                            height: 8.0,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 8.0, horizontal: 4.0),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: widget
                                                            .imgUrl![widget
                                                                .indexSearch!]
                                                            .sliderPosition ==
                                                        entry.key
                                                    ? Colors.black
                                                    : Colors.white),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              child: PhotoView(
                                minScale: 0.3,
                                maxScale: 2.5,
                                backgroundDecoration:
                                    BoxDecoration(color: SoloColor.trans),
                                imageProvider: NetworkImage(widget
                                    .imgUrl![widget.indexSearch!].image![0]),
                              ),
                            )
                      : Container()
                  : widget.photoList != null
                      ? widget.photoList![widget.indexPro!].image!.length > 1
                          ? Stack(
                              children: [
                                CarouselSlider.builder(
                                  itemCount: widget.photoList![widget.indexPro!]
                                      .image!.length,
                                  carouselController: widget.controller,
                                  options: CarouselOptions(
                                    aspectRatio: 6 / 12,
                                    autoPlay: false,
                                    viewportFraction: 1.0,
                                    onPageChanged: (index, reason) {
                                      print(
                                          "seethisguy${widget.photoList![widget.indexPro!].sliderPosition}${index}");
                                      setState(() {
                                        widget.photoList![widget.indexPro!]
                                            .sliderPosition = index;
                                      });
                                    },
                                  ),
                                  itemBuilder: (BuildContext context, int index,
                                      int realIndex) {
                                    return Container(
                                      child: PinchZoom(
                                        child: CachedNetworkImage(
                                          imageUrl: widget
                                              .photoList![widget.indexPro!]
                                              .image![index],
                                          errorWidget: (context, url, error) =>
                                              imagePlaceHolder(),
                                          placeholder: (context, url) =>
                                              CupertinoActivityIndicator(
                                            color: SoloColor.white,
                                          ),
                                        ),
                                        resetDuration:
                                            const Duration(milliseconds: 100),
                                        maxScale: 2.5,
                                        onZoomStart: () {
                                          print('Start zooming');
                                        },
                                        onZoomEnd: () {
                                          print('Stop zooming');
                                        },
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Visibility(
                                    visible: widget.photoList![widget.indexPro!]
                                            .image!.length >
                                        1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: widget
                                          .photoList![widget.indexPro!].image!
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        return GestureDetector(
                                          onTap: () {
                                            var res = widget
                                                    .photoList![
                                                        widget.indexPro!]
                                                    .sliderPosition ==
                                                entry.key;
                                            print("valueoftheresss$res");
                                            widget.controller
                                                ?.animateToPage(entry.key);
                                          },
                                          child: Container(
                                            width: 8.0,
                                            height: 8.0,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 8.0, horizontal: 4.0),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: widget
                                                            .photoList![widget
                                                                .indexPro!]
                                                            .sliderPosition ==
                                                        entry.key
                                                    ? Colors.black
                                                    : Colors.white),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              child: PhotoView(
                                minScale: 0.3,
                                maxScale: 2.5,
                                imageProvider: NetworkImage(widget
                                    .photoList![widget.indexPro!].image![0]),
                              ),
                            )
                      : Container(),
            ),
          ),
        ),
      ),
    );
  }
}
