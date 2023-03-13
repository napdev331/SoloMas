import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/model/user_profile_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/strings.dart';

class ContestWonActivity extends StatefulWidget {
  final String? profilePic, userName;

  final List<ContestWon>? contestWonList;

  ContestWonActivity({this.profilePic, this.userName, this.contestWonList});

  @override
  State<StatefulWidget> createState() {
    return _ContestWonState();
  }
}

class _ContestWonState extends State<ContestWonActivity> {
  CommonHelper? _commonHelper;

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    Widget contestWonCard(ContestWon contestWonList) {
      return Container(
        margin: EdgeInsets.only(
            left: DimensHelper.sidesMargin,
            right: DimensHelper.sidesMargin,
            bottom: DimensHelper.halfSides),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: DimensHelper.halfSides),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DimensHelper.sidesMargin)),
                elevation: 3.0,
                child: Container(
                  margin: EdgeInsets.only(left: 80),
                  padding: EdgeInsets.all(DimensHelper.sidesMargin),
                  child: Row(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: _commonHelper?.screenWidth * .49,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.userName!.toUpperCase(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: SoloColor.black,
                                            fontSize: Constants.FONT_TOP)),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: DimensHelper.smallSides),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            WidgetSpan(
                                              child: Image.asset(
                                                  "assets/images/ic_queen.png",
                                                  height: 20,
                                                  color: SoloColor.black),
                                            ),
                                            TextSpan(
                                                text: contestWonList
                                                            .contestName ==
                                                        null
                                                    ? ""
                                                    : "  ${contestWonList.contestName}",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color:
                                                        SoloColor.spanishGray,
                                                    fontSize:
                                                        Constants.FONT_MEDIUM)),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: DimensHelper.sidesMargin,
                  right: DimensHelper.sidesMargin),
              child: GestureDetector(
                onTap: () {
                  /*_commonHelper.startActivity(UserProfileActivity(userId: _aList[index].userId));*/
                },
                child: ClipOval(
                    child: CachedNetworkImage(
                  imageUrl: widget.profilePic.toString(),
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => imagePlaceHolder(),
                  errorWidget: (context, url, error) => imagePlaceHolder(),
                )),
              ),
            ),
          ],
        ),
      );
    }

    return SoloScaffold(
      appBar: AppBar(
        backgroundColor: SoloColor.blue,
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            GestureDetector(
              onTap: () {
                _commonHelper?.closeActivity();
              },
              child: Container(
                width: 25,
                height: 25,
                alignment: Alignment.centerLeft,
                child: Image.asset('images/back_arrow.png'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(StringHelper.competitions.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: Constants.FONT_APP_TITLE)),
            )
          ],
        ),
      ),
      body: ListView.builder(
          itemCount: widget.contestWonList?.length,
          padding: EdgeInsets.only(top: DimensHelper.sidesMargin),
          itemBuilder: (BuildContext context, int index) {
            return contestWonCard(widget.contestWonList![index]);
          }),
    );
  }
}
