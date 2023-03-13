import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../helpers/common_helper.dart';
import '../../resources_helper/colors.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/dimens.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/read_more_text.dart';
import '../../resources_helper/strings.dart';
import '../../resources_helper/text_styles.dart';
import '../home/carnival_detail_activity.dart';

class ProfileCarnivalCard extends StatefulWidget {
  ProfileCarnivalCard(
      {Key? key,
      required this.index,
      required this.carnivalData,
      this.carnivalsInfo})
      : super(key: key);

  int index;
  dynamic carnivalData;
  final carnivalsInfo;
  @override
  State<ProfileCarnivalCard> createState() => _ProfileCarnivalCardState();
}

class _ProfileCarnivalCardState extends State<ProfileCarnivalCard> {
  CommonHelper? _commonHelper;
  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    print("details${widget.carnivalsInfo}");
    return InkWell(
      onTap: () {
        _commonHelper!.startActivity(
            CarnivalDetailActivity(carnivalId: widget.carnivalData?.sId));
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: _commonHelper?.screenWidth * 0.035,
          right: _commonHelper?.screenWidth * 0.035,
          top: _commonHelper?.screenHeight * 0.02,
        ),
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: SoloColor.spanishGray.withOpacity(0.6),
              blurRadius: 3,
              spreadRadius: 0.5,
            ),
          ], color: SoloColor.white, borderRadius: BorderRadius.circular(20)),
          width: _commonHelper?.screenWidth,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.carnivalData.title.toString(),
                    style: SoloStyle.black54W500SmallMax,
                  ),
                  Text(
                    widget.carnivalData.locationName.toString(),
                    style: SoloStyle.lightGrey200W600MediumXs,
                  )
                ],
              ),
            ),

            widget.carnivalData!.coverImageUrl.toString() != null
                ? Stack(
                    children: [
                      Container(
                        height: _commonHelper!.screenHeight * 0.3,
                        width: _commonHelper!.screenWidth,
                        child: ClipRRect(
                          child: CachedNetworkImage(
                              imageUrl:
                                  widget.carnivalData!.coverImageUrl.toString(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => imagePlaceHolder(),
                              errorWidget: (context, url, error) =>
                                  imagePlaceHolder()),
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),

            // Padding(
            //   padding: const EdgeInsets.only(
            //       right: 10, left: 15, bottom: 15, top: 10),
            //   child: Text(
            //     widget.carnivalData.description.toString(),
            //     style: SoloStyle.lightGrey200W500Low,
            //   ),
            // ),

            Padding(
                padding: const EdgeInsets.only(
                    top: 15, left: 10, right: 10, bottom: 10),
                child: Container(
                  width: _commonHelper!.screenWidth * 0.7,
                  margin: EdgeInsets.only(
                      left: DimensHelper.mediumSides,
                      right: DimensHelper.mediumSides),
                  child: Text(
                    widget.carnivalsInfo ?? "",
                    style: TextStyle(
                        color: SoloColor.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        fontFamily: 'Roboto'),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
                left: 15,
                bottom: 15,
              ),
              child: Container(
                  width: _commonHelper?.screenWidth,
                  child: ReadMoreText(
                    widget.carnivalData.description,
                    trimLength: 110,
                    style: SoloStyle.lightGrey200W500SmallMax,
                    colorClickableText: SoloColor.black,
                    trimMode: TrimMode.Length,
                    trimCollapsedText: StringHelper.readMore,
                    trimExpandedText: StringHelper.readLess,
                  )),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: _commonHelper!.screenWidth * 0.05,
                    child: Image.asset(
                      IconsHelper.ic_calender,
                      width: _commonHelper!.screenWidth * 0.05,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: DimensHelper.mediumSides,
                        right: DimensHelper.mediumSides),
                    child: Text(
                      _commonHelper!.getCarnivalDate(
                              widget.carnivalData.startDate ?? 0) +
                          StringHelper.to +
                          _commonHelper!.getCarnivalDate(
                              widget.carnivalData.endDate ?? 0),
                      style: SoloStyle.darkBlackW70015Rob,
                    ),
                  ),
                ],
              ),
            ),

            Column(children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [],
                    ),
                    // Text(
                    //   widget.countDown ?? "",
                    // )
                  ],
                ),
              ),
            ]),
            // Padding(
            //   padding: const EdgeInsets.only(right: 10, left: 10, bottom: 15),
            //   child: Container(
            //       width: _commonHelper?.screenWidth,
            //       child: ReadMoreText(
            //         "sfsdfsdfsdf" ?? " ",
            //         //StringHelper.dummyHomeText,
            //         trimLines: 2,
            //         style: SoloStyle.lightGrey200W500Low,
            //         colorClickableText: SoloColor.black,
            //         trimMode: TrimMode.Line,
            //         trimCollapsedText: StringHelper.readMore,
            //         trimExpandedText: StringHelper.readLess,
            //       )),
            // )
          ]),
        ),
      ),
    );
  }
}
