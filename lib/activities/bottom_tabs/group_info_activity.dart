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
import 'explore/group/group_detail_activity.dart';

class GroupInfoActivity extends StatefulWidget {
  final List<GroupList>? groupList;

  GroupInfoActivity({this.groupList});

  @override
  State<StatefulWidget> createState() {
    return _GroupInfoState();
  }
}

class _GroupInfoState extends State<GroupInfoActivity> {
  CommonHelper? _commonHelper;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    Widget groupsDetailCard(GroupList groupList) {
      return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: DimensHelper.halfSides),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(DimensHelper.sidesMargin),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                    onTap: () {
                      _commonHelper?.startActivity(GroupDetailsActivity(
                          groupId: groupList.groupId,
                          groupTitle: groupList.title));
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: DimensHelper.halfSides),
                      child: ClipOval(
                          child: CachedNetworkImage(
                        imageUrl: groupList.groupProfilePic.toString(),
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            imagePlaceHolder(),
                      )),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: _commonHelper?.screenWidth * .5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(groupList.title.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: SoloColor.black,
                                        fontSize: Constants.FONT_TOP)),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: DimensHelper.smallSides),
                                    child: Text(
                                        "${groupList.totalSubscribers} subscribers",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: SoloColor.spanishGray,
                                            fontSize: Constants.FONT_MEDIUM)))
                              ],
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget divider() {
      return Container(
        margin: EdgeInsets.only(
            left: DimensHelper.sidesMargin, right: DimensHelper.sidesMargin),
        child: Divider(color: SoloColor.silverSand, height: 1),
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
              child: Text('Groups Info'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: Constants.FONT_APP_TITLE)),
            )
          ],
        ),
      ),
      body: ListView.separated(
          itemCount: widget.groupList!.length,
          separatorBuilder: (BuildContext context, int index) => divider(),
          itemBuilder: (BuildContext context, int index) {
            return groupsDetailCard(widget.groupList![index]);
          }),
    );
  }
}
