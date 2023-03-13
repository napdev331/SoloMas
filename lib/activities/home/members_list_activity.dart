import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/activities/chat/chat_activity.dart';
import 'package:solomas/activities/home/user_profile_activity.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/model/carnival_list_model.dart';
import 'package:solomas/resources_helper/dimens.dart';

import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/strings.dart';
import '../common_helpers/app_bar.dart';
import '../common_helpers/members_card.dart';

class MembersListActivity extends StatefulWidget {
  final List<MembersList>? membersList;

  MembersListActivity({this.membersList});

  @override
  State<StatefulWidget> createState() {
    return _MembersListState();
  }
}

class _MembersListState extends State<MembersListActivity> {
//============================================================
// ** Properties **
//============================================================
  CommonHelper? _commonHelper;
  String? mineUserId;

//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  void initState() {
    super.initState();

    PrefHelper.getUserId().then((onValue) {
      setState(() {
        mineUserId = onValue;
      });
    });
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
      body: Stack(
        children: [
          ListView.builder(
              itemCount: widget.membersList?.length,
              padding: EdgeInsets.only(
                  top: DimensHelper.halfSides, bottom: DimensHelper.halfSides),
              itemBuilder: (BuildContext context, int index) {
                return peopleDetailCard(index);
              })
        ],
      ),
    );
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
      appbarTitle: StringHelper.members.toUpperCase(),
      backOnTap: () {
        _commonHelper?.closeActivity();
      },
    );
  }

  Widget peopleDetailCard(int index) {
    return MembersCard(
      memberProfile: widget.membersList![index].userProfilePic.toString(),
      profileOnTap: () {
        if (widget.membersList?[index].userId == mineUserId) {
          _commonHelper?.startActivity(ProfileTab(isFromHome: true));
        } else {
          _commonHelper?.startActivity(UserProfileActivity(
              userId: widget.membersList![index].userId.toString()));
        }
      },
      memberName: widget.membersList![index].userName!.toUpperCase(),
      memberBand: widget.membersList![index].userBand.toString(),
      chatOnTap: () {
        _commonHelper?.startActivity(ChatActivity(
          widget.membersList![index].userName.toString(),
          widget.membersList![index].userId.toString(),
          widget.membersList![index].userProfilePic.toString(),
        ));
      },
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

//============================================================
// ** Helper Functions **
//============================================================

//============================================================
// ** Firebase Function **
//============================================================

}
