import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/model/get_groups_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';

import '../../../../resources_helper/common_widget.dart';
import '../../../../resources_helper/screen_area/scaffold.dart';
import '../../../../resources_helper/strings.dart';
import '../../../common_helpers/app_bar.dart';

class GroupMembersActivity extends StatefulWidget {
  final List<SubscriberList>? subsList;

  final String? groupName;

  GroupMembersActivity({this.subsList, this.groupName});

  @override
  State<StatefulWidget> createState() {
    return _GroupFeedState();
  }
}

class _GroupFeedState extends State<GroupMembersActivity> {
  //============================================================
// ** Properties **
//============================================================
  CommonHelper? _commonHelper;

//============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(115),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 0),
            child: appBar(),
          ),
        ),
        body: mainBody());
  }

  @override
  void dispose() {
    super.dispose();
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget appBar() {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.Members.toUpperCase(),
      backOnTap: () {
        _commonHelper?.closeActivity();
      },
    );
  }

  Widget mainBody() {
    return ListView(
      children: [
        ListView.separated(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: widget.subsList!.length,
            separatorBuilder: (BuildContext context, int index) => divider(),
            padding: EdgeInsets.only(bottom: DimensHelper.halfSides),
            itemBuilder: (BuildContext context, int index) {
              return members(index);
            })
      ],
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget divider() {
    return Container(
      margin: EdgeInsets.only(
          left: DimensHelper.sidesMargin, right: DimensHelper.sidesMargin),
      child: Divider(color: SoloColor.silverSand, height: 1),
    );
  }

  Widget profileImage(String userProfilePic) {
    return ClipOval(
        child: CachedNetworkImage(
      imageUrl: userProfilePic,
      height: 50,
      width: 50,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => imagePlaceHolder(),
    ));
  }

  Widget members(int index) {
    return Container(
      padding: EdgeInsets.all(DimensHelper.sidesMargin),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          GestureDetector(
            onTap: () {
              _commonHelper?.startActivity(UserProfileActivity(
                  userId: widget.subsList![index].userId.toString()));
            },
            child: Container(
              margin: EdgeInsets.only(right: DimensHelper.halfSides),
              child: profileImage(
                  widget.subsList![index].userProfilePic.toString()),
            ),
          ),
          Text(widget.subsList![index].userName.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP)),
        ],
      ),
    );
  }

//============================================================
// ** Helper Functions **
//============================================================

//============================================================
// ** Firebase Function **
//============================================================

}
