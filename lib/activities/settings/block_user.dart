import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/common_helpers/app_bar.dart';

import '../../../helpers/space.dart';
import '../../../resources_helper/colors.dart';
import '../../../resources_helper/dimens.dart';
import '../../../resources_helper/images.dart';
import '../../../resources_helper/strings.dart';
import '../../../resources_helper/text_styles.dart';
import '../../resources_helper/screen_area/scaffold.dart';

class BlockUserPage extends StatefulWidget {
  const BlockUserPage({Key? key}) : super(key: key);

  @override
  State<BlockUserPage> createState() => _BlockUserPageState();
}

class _BlockUserPageState extends State<BlockUserPage> {
//============================================================
// ** Properties **
//============================================================

//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  Widget build(BuildContext context) {
    return SoloScaffold(
      backGroundColor: SoloColor.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: _appBar(context),
        ),
      ),
      body: _mainBody(),
    );
  }

//============================================================
// ** Main Widgets **
//============================================================

  Widget _mainBody() {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Divider(
          color: SoloColor.platinum,
        ),
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        image: DecorationImage(
                          image: AssetImage(
                            IconsHelper.group_img,
                          ),
                          fit: BoxFit.fill,
                        )),
                  ),
                  space(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StringHelper.jenniferJohn,
                        style: SoloStyle.jetW500SmallMax,
                      ),
                      space(height: 5),
                    ],
                  ),
                ],
              ),
              Spacer(),
              GestureDetector(
                onTap: () {},
                child: unblockButton(),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.blockUser,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget unblockButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 35,
        padding: EdgeInsets.only(left: 12, right: 16),
        decoration: BoxDecoration(
          border: Border.all(color: SoloColor.blue),
          borderRadius:
              BorderRadius.all(Radius.circular(DimensHelper.halfSides)),
        ),
        child: Center(
          child: Text(StringHelper.unBlock, style: SoloStyle.blueW500FontLow),
        ),
      ),
    );
  }

//============================================================
// ** Helper Function **
//============================================================
}
