import 'package:flutter/material.dart';

import '../../../helpers/space.dart';
import '../../../resources_helper/colors.dart';
import '../../../resources_helper/dimens.dart';
import '../../../resources_helper/strings.dart';
import '../../../resources_helper/text_styles.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../common_helpers/app_bar.dart';

class ContestRulesPage extends StatefulWidget {
  const ContestRulesPage({Key? key}) : super(key: key);

  @override
  State<ContestRulesPage> createState() => _ContestRulesPageState();
}

class _ContestRulesPageState extends State<ContestRulesPage> {
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
  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.contestRules,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _mainBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(DimensHelper.sidesMargin),
        child: Column(
          children: [
            contestRules(
              description: StringHelper.contestRulesDesc,
              desc: StringHelper.contestRulesDesc,
            ),
            contestRules(description: StringHelper.contestRulesDesc),
            contestRules(description: StringHelper.contestRulesDescription),
            contestRules(
              description: StringHelper.contestRulesDesc,
            ),
            contestRules(description: StringHelper.contestRulesDescription),
            contestRules(
              description: StringHelper.contestRulesDesc,
            ),
          ],
        ),
      ),
    );
  }

//============================================================
// ** Helper Widgets **
//============================================================

  Widget contestRules({String? description, String? desc}) {
    return Column(
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                StringHelper.contestRulesTitle,
                style: SoloStyle.blackW500Title,
              ),
            ),
            space(height: 4),
          ],
        ),
        Column(
          children: [
            Text(
              description ?? "",
              style: SoloStyle.lightGrey200W400Low,
            ),
            desc != null ? space(height: 7) : space(height: 0),
            Text(
              desc ?? "",
              style: SoloStyle.lightGrey200W400Low,
            ),
            desc != null ? space(height: 4) : space(height: 0),
          ],
        ),
      ],
    );
  }

//============================================================
// ** Helper Function **
//============================================================

}
