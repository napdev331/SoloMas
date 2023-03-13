import 'package:flutter/material.dart';

import '../../../helpers/common_helper.dart';
import '../../../model/carnival_continent_model.dart';
import '../../../resources_helper/screen_area/scaffold.dart';

class ExploreAllScreen extends StatefulWidget {
  final String headerName;
  final int? itemListCount;
  final dynamic Function(String)? onExploreData;

  Widget Function(BuildContext, int)? itemListBuilder;
  ExploreAllScreen({
    Key? key,
    required this.headerName,
    required this.itemListBuilder,
    this.itemListCount,
    this.onExploreData,
  }) : super(key: key);

  @override
  State<ExploreAllScreen> createState() => ExploreAllScreenState();
}

class ExploreAllScreenState extends State<ExploreAllScreen> {
  CommonHelper? _commonHelper;
  List<ContinentList>? _searchCarnivalList = [];
  List<ContinentList>? _aCarnivalList = [];
  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);
    return SoloScaffold(
        body: Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
          height: MediaQuery.of(context).size.height,
          child: GridView.builder(
            itemCount: widget.itemListCount,
            // widget.dataGetList.length,
            itemBuilder: widget.itemListBuilder ??
                (BuildContext context, int index) {
                  return Container();
                },
            //     (BuildContext context, int index) {
            //   return listCard(
            //     widget.dataGetList[index],
            //     widget.countryListData[index],
            //   );
            // },
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: _commonHelper?.screenWidth * 0.5,
              crossAxisSpacing: 10,
              childAspectRatio: 3 / 3,
            ),
          )),
    ));
  }

  void searchData(String searchQuery) {
    _searchCarnivalList?.clear();

    if (searchQuery.isEmpty) {
      _searchCarnivalList?.addAll(_aCarnivalList ?? []);

      setState(() {});

      return;
    }

    _aCarnivalList?.forEach((carnivalDetail) {
      if (carnivalDetail.continent!
          .toUpperCase()
          .contains(searchQuery.toUpperCase())) {
        _searchCarnivalList?.add(carnivalDetail);
      }
    });

    setState(() {});
  }
}
