import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/services/view_service_detail.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/model/user_profile_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';

class MyServicesActivity extends StatefulWidget {
  final List<MyServiceList>? upcomingCarnival;

  MyServicesActivity({this.upcomingCarnival});

  @override
  State<StatefulWidget> createState() {
    return _UpComingCarnivalState();
  }
}

class _UpComingCarnivalState extends State<MyServicesActivity> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _commonHelper = CommonHelper(context);

    Widget mainItem(int index) {
      var carnivalData = widget.upcomingCarnival?[index];

      return GestureDetector(
        onTap: () {
          _commonHelper.startActivity(ServiceDetail(
            serviceId: carnivalData?.serviceId.toString(),
            refresh: false,
            context: this,
          ));
        },
        child: Container(
          height: 150,
          padding: EdgeInsets.only(
              left: DimensHelper.sidesMargin,
              right: DimensHelper.sidesMargin,
              bottom: DimensHelper.sidesMargin),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.zero)),
            elevation: DimensHelper.tinySides,
            child: Row(
              children: [
                Container(
                  height: 150,
                  width: _commonHelper.screenWidth * .44,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: carnivalData!.image.toString(),
                    placeholder: (context, url) => imagePlaceHolder(),
                    errorWidget: (context, url, error) => imagePlaceHolder(),
                  ),
                ),
                Container(
                  height: 150,
                  padding: EdgeInsets.all(DimensHelper.halfSides),
                  width: _commonHelper.screenWidth * .44,
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Text(carnivalData.businessName.toString(),
                          style: TextStyle(
                              fontSize: Constants.FONT_TOP,
                              color: SoloColor.blue,
                              fontWeight: FontWeight.w500)),
                      Padding(
                        padding: EdgeInsets.only(top: DimensHelper.smallSides),
                        child: Text(carnivalData.category.toString(),
                            style: TextStyle(
                                fontSize: Constants.FONT_LOW,
                                color: SoloColor.spanishGray,
                                fontWeight: FontWeight.w500)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: DimensHelper.smallSides),
                        child: Text(carnivalData.email.toString(),
                            style: TextStyle(
                                fontSize: Constants.FONT_MEDIUM,
                                color: SoloColor.spanishGray,
                                fontWeight: FontWeight.w500),
                            maxLines: 3),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: DimensHelper.smallSides),
                        child: Text(carnivalData.phoneNumber.toString(),
                            style: TextStyle(
                                fontSize: Constants.FONT_MEDIUM,
                                color: SoloColor.spanishGray,
                                fontWeight: FontWeight.w500),
                            maxLines: 3),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
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
                _commonHelper.closeActivity();
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
              child: Text('My Services '.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: Constants.FONT_APP_TITLE)),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
            width: _commonHelper.screenWidth,
            height: _commonHelper.screenHeight,
            child: ListView.builder(
                itemCount: widget.upcomingCarnival?.length,
                itemBuilder: (BuildContext context, int index) {
                  return mainItem(index);
                }),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
