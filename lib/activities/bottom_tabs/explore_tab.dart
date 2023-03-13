// import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:flutter/material.dart';
import 'package:solomas/activities/bottom_tabs/explore/contests_activity.dart';
import 'package:solomas/activities/bottom_tabs/explore/group/groups_activity.dart';
import 'package:solomas/activities/bottom_tabs/explore/people/people_activity.dart';
import 'package:solomas/helpers/common_helper.dart';

import '../../resources_helper/screen_area/scaffold.dart';
import '../../resources_helper/strings.dart';
import '../common_helpers/app_bar.dart';
import 'explore/carnivals_continets/continent_activity.dart';

class ExploreTab extends StatefulWidget {
  int? exploreIndexPos;
  Function? getIndexValue;

  ExploreTab({this.exploreIndexPos, this.getIndexValue});

  @override
  State<StatefulWidget> createState() {
    return _ExploreActivityState();
  }
}

class _ExploreActivityState extends State<ExploreTab>
    with SingleTickerProviderStateMixin {
  //============================================================
// ** Properties **
//============================================================
  bool isVisible = false;
  CommonHelper? _commonHelper;
  String distanceValue = '10';
  double appBarHeight = 120;
  TabController? tabController;
  int _currentTabIndex = 0;
  var searchQuery = "";
  GlobalKey<ContinentActivityState> _carnivalState = GlobalKey();
  GlobalKey<ContestsState> _contestState = GlobalKey();
  GlobalKey<GroupsState> _groupsState = GlobalKey();
  GlobalKey<PeopleState> _peopleState = GlobalKey();
  var mineUserAddress;

  TextEditingController searchController = TextEditingController();
//============================================================
// ** Flutter Build Cycle **
//============================================================
  @override
  void initState() {
    super.initState();
    // getSharedData();

    tabController = TabController(vsync: this, length: 4);
    tabController?.addListener(_getCurrentTab);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.exploreIndexPos != null) {
        setState(() {
          tabController?.index = widget.exploreIndexPos ?? 0;
        });
      } else {
        print("exploreIndexPos value is null");
      }
    });

    /*if (widget.exploreIndexPos == null) {
      _currentTabIndex = 0;
    } else {
      _currentTabIndex = widget.exploreIndexPos;
    }*/
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: _appBar(context),
          ),
        ),
        body: SizedBox(
          height: _commonHelper?.screenHeight,
          child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                        height: _commonHelper?.screenHeight * 0.24,
                        // height: _commonHelper?.screenHeight * 0.25,
                        // height: _commonHelper?.screenHeight * 0.29,
                        child: Center(
                            child: ContinentActivity(
                          data: _carnivalState,
                          key: _carnivalState,
                        ))),
                    Container(
                        height: _commonHelper?.screenHeight * 0.24,
                        color: Colors.yellow,
                        child: Center(
                            child: ContestsActivity(
                          key: _contestState,
                        ))),
                    SizedBox(
                        height: _commonHelper?.screenHeight * 0.24,
                        child: Center(
                            child: GroupsActivity(
                          key: _groupsState,
                        ))),
                    SizedBox(
                        height: _commonHelper?.screenHeight * 0.24,
                        child: Center(
                            child: PeopleActivity(
                          key: _peopleState,
                        ))),
                  ],
                )),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  //============================================================
// ** Main Widgets **
//============================================================

//============================================================
// ** Helper Function **
//============================================================

  Widget _appBar(BuildContext context) {
    return SoloAppBar(
      leadingTap: () {
        Scaffold.of(context).openDrawer();
      },
      appBarType: StringHelper.drawerWithSearchbar,
      isMore: true,
      onSearchBarTextChanged: _onSearchTextChanged,
      hintText: StringHelper.search,
    );
  }

  void _getCurrentTab() {
    setState(() {
      _currentTabIndex = tabController?.index ?? 0;
    });
  }

  void _getDistanceData(String distanceValue) {
    if (_currentTabIndex == 0) {
      _carnivalState.currentState?.updateData(distanceValue);
    } else if (_currentTabIndex == 1) {
      _contestState.currentState?.updateData(distanceValue);
    } else if (_currentTabIndex == 2) {
      _groupsState.currentState?.updateData(distanceValue);
    } else if (_currentTabIndex == 3) {
      _peopleState.currentState?.updateData(distanceValue);
    }
  }

  _onSearchTextChanged(String text) async {
    _carnivalState.currentState?.searchData(text);
    _contestState.currentState?.searchData(text);
    _groupsState.currentState?.searchData(text);
    _peopleState.currentState?.searchData(text);
  }

  // Future<void> getSharedData() async {
  //   await PrefHelper.getSearchData().then((onValue) {
  //     print("hiiigetsearchcall" + searchQuery);
  //     setState(() {
  //       print("hii" + searchQuery);
  //       if (onValue != null) {
  //         searchQuery = onValue;
  //       } else {
  //         searchQuery = " ";
  //         print("finakl" + searchQuery);
  //       }
  //     });
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       searchController.text = "searchQuery";
  //     });
  //   });
  // }
//============================================================
// ** Firebase Function **
//============================================================
}
