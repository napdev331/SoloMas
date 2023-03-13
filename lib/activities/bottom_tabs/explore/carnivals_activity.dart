import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:solomas/activities/home/carnival_detail_activity.dart';
import 'package:solomas/blocs/explore/carnival_list_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/carnival_list_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../../resources_helper/common_widget.dart';
import '../../../resources_helper/screen_area/scaffold.dart';
import '../../../resources_helper/text_styles.dart';
import '../../common_helpers/app_bar.dart';
import '../../common_helpers/festival_card.dart';
import 'carnivals_continets/carnival_reviews.dart';

class CarnivalsActivity extends StatefulWidget {
  final String? carnivalContinent;

  const CarnivalsActivity({Key? key, this.carnivalContinent}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CarnivalsState();
  }
}

class CarnivalsState extends State<CarnivalsActivity> {
  bool isVisible = false, _progressShow = false;

  CommonHelper? _commonHelper;

  List<CarnivalList> _aList = [];

  List<CarnivalList> _searchList = [];

  CarnivalListBloc? _carnivalListBloc;

  void _showProgress() {
    setState(() {
      _progressShow = true;
    });
  }

  void _hideProgress() {
    setState(() {
      _progressShow = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _carnivalListBloc = CarnivalListBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getCarnivalList(""));

    print("dataIsCalled");
  }

  void _getCarnivalList(String distance) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          _carnivalListBloc
              ?.getCarnivalList(token.toString(), "", distance,
                  widget.carnivalContinent.toString())
              .then((onValue) {
            _hideProgress();
          }).catchError((onError) {
            _hideProgress();
          });
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }

  Widget carnivalCard(int index) {
    return Container(
      margin: EdgeInsets.only(
          left: DimensHelper.sidesMargin,
          right: DimensHelper.sidesMargin,
          bottom: DimensHelper.sidesMargin),
      child: Card(
        elevation: DimensHelper.tinySides,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(DimensHelper.sidesMargin)),
        ),
        child: InkWell(
          onTap: () {
            _commonHelper?.startActivity(CarnivalDetailActivity(
                carnivalId: _searchList[index].carnivalId.toString()));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                child: CachedNetworkImage(
                  height: _commonHelper?.screenHeight * .4,
                  imageUrl: _searchList[index].coverImageUrl.toString(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => imagePlaceHolder(),
                  errorWidget: (context, url, error) => imagePlaceHolder(),
                ),
                padding: EdgeInsets.all(DimensHelper.halfSides),
              ),
              ListTile(title: Text(_searchList[index].title.toString())),
            ],
          ),
        ),
      ),
    );
  }

  Widget carnivalCardContinent(int index) {
    return Stack(
      children: [
        Container(
          width: _commonHelper?.screenWidth * 0.5,
          height: _commonHelper?.screenHeight * 0.25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: SoloColor.lightGrey200.withOpacity(0.2),
                blurRadius: 1,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Container(
              height: _commonHelper?.screenHeight * 0.25,
              width: _commonHelper?.screenWidth * 0.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.transparent,
                    SoloColor.black.withOpacity(0.5),
                  ],
                ),
              )),
        ),
        Positioned(
          right: 10,
          left: 5,
          child: Container(
            height: 40,
            child: Center(
                child: Text(
              "Lorem ipsum dolor sit ",
              style: TextStyle(color: SoloColor.white),
            )),
          ),
        ),
        Positioned(
          bottom: _commonHelper?.screenWidth * 0.03,
          left: 5,
          child: Container(
            width: _commonHelper?.screenWidth * 0.3,
            decoration: BoxDecoration(
              color: SoloColor.lightGrey200.withOpacity(0.6),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                child: Text(
                  "country title ",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: SoloStyle.smokeWhiteW70010Rob,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //////////////////////////////////

  Widget _noCarnivalWarning() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(DimensHelper.btnTopMargin),
        child: Text(StringHelper.noCarnival,
            style: TextStyle(
                fontSize: Constants.FONT_MEDIUM,
                fontWeight: FontWeight.normal,
                color: SoloColor.spanishGray)));
  }

  Widget _exploreData() {
    return Stack(
      children: [
        Container(
            margin: EdgeInsets.only(top: DimensHelper.sidesMargin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                _searchList.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                            itemCount: _searchList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return carnivalCard(index);
                            }),
                      )
                    : _noCarnivalWarning()
              ],
            )),
        Align(
          child: ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
          alignment: FractionalOffset.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    return SoloScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
          child: _appBar(context, widget.carnivalContinent),
        ),
      ),
      body: StreamBuilder(
          stream: _carnivalListBloc?.carnivalList,
          builder: (context, AsyncSnapshot<CarnivalListModel> snapshot) {
            if (snapshot.hasData) {
              if (_aList.isEmpty) {
                _aList = snapshot.data?.data?.carnivalList ?? [];

                _searchList.addAll(_aList);
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _searchField(),
                  _searchList.isNotEmpty
                      ? Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              child: GridView.builder(
                                  physics: BouncingScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent:
                                        _commonHelper?.screenWidth * 0.5,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 3 / 3,
                                  ),
                                  itemCount: _searchList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var originalStartDate =
                                        _searchList[index].startDate;

                                    var finalDate =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            originalStartDate! * 1000);
                                    final dateFormat =
                                        new DateFormat('dd-MMM-yyyy-hh-mm-a');
                                    var formatDate =
                                        dateFormat.format(finalDate);

                                    var splitDate =
                                        formatDate.split(RegExp('-'));
                                    var startDate = splitDate[0].toString();
                                    var startMonth =
                                        splitDate[1].toUpperCase().toString();
                                    var startYear = splitDate[2].toString();

                                    return listCard(context, index,
                                        countryTitle:
                                            "$startDate $startMonth $startYear",
                                        onReviewTap: () {
                                          _commonHelper
                                              ?.startActivity(CarnivalReviews(
                                            carnivalId:
                                                _searchList[index].carnivalId,
                                            carnivalName:
                                                _searchList[index].title,
                                          ));
                                        },
                                        onShareTap: () {
                                          var uri = _createDynamicLink(
                                              _searchList[index]
                                                  .carnivalId
                                                  .toString(),
                                              widget.carnivalContinent
                                                  .toString(),
                                              index);
                                        },
                                        image: _searchList[index]
                                            .coverImageUrl
                                            .toString(),
                                        onAllTap: () {
                                          _commonHelper?.startActivity(
                                              CarnivalDetailActivity(
                                                  carnivalId: _searchList[index]
                                                      .carnivalId
                                                      .toString()));
                                        },
                                        gradient: LinearGradient(
                                          begin: FractionalOffset.topCenter,
                                          end: FractionalOffset.bottomCenter,
                                          colors: [
                                            SoloColor.black.withOpacity(0.9),
                                            SoloColor.black.withOpacity(0.7),
                                            SoloColor.black.withOpacity(0.3),
                                            SoloColor.black.withOpacity(0.2),
                                            SoloColor.black.withOpacity(0.1),
                                            SoloColor.black.withOpacity(0.2),
                                            SoloColor.black.withOpacity(0.3),
                                            SoloColor.black.withOpacity(0.7),
                                            SoloColor.black.withOpacity(0.9),
                                          ],
                                        ),
                                        title: _searchList[index].title,
                                        padding: EdgeInsets.only(top: 10.0),
                                        isWidth: true,
                                        isHeight: true);
                                  }),
                            ),
                          ),
                        )
                      : _noCarnivalWarning()
                ],
              );
            } else if (snapshot.hasError) {
              return _exploreData();
            }

            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)));
          }),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 12,
        top: DimensHelper.searchBarMargin,
      ),
      child: Container(
        decoration: BoxDecoration(
            color: SoloColor.cultured, borderRadius: BorderRadius.circular(10)),
        height: 40,
        child: TextFormField(
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          maxLines: 1,
          minLines: 1,
          autofocus: false,
          onChanged: (value) {
            searchData(value);
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z -]")),
            LengthLimitingTextInputFormatter(30),
          ],
          decoration: InputDecoration(
            fillColor: SoloColor.cultured,
            prefixIcon: Icon(Icons.search, size: 25, color: SoloColor.jet),
            contentPadding: EdgeInsets.symmetric(
              vertical: 8,
            ),
            hintText: StringHelper.search,
            hintStyle: SoloStyle.lightGrey200W500Top,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(width: 0.5, color: SoloColor.gainsBoro),
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: SoloColor.gainsBoro, width: 0.5)),
          ),
        ),
      ),
    );
  }

  void searchData(String searchQuery) {
    _searchList.clear();

    if (searchQuery.isEmpty) {
      _searchList.addAll(_aList);

      setState(() {});

      return;
    }

    _aList.forEach((carnivalDetail) {
      if (carnivalDetail.title!
          .toUpperCase()
          .contains(searchQuery.toUpperCase())) {
        _searchList.add(carnivalDetail);
      }
    });

    setState(() {});
  }

  void updateData(String distanceValue) {
    _showProgress();

    _aList.clear();

    _searchList.clear();

    _getCarnivalList(distanceValue);
  }

  Widget _loadingProgressBar() {
    return Container(
      width: 70,
      height: 70,
      child: Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(SoloColor.blue)),
      ),
    );
  }

  @override
  void dispose() {
    _carnivalListBloc?.dispose();

    super.dispose();
  }

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  Future<Uri?> _createDynamicLink(
      String carnivalId, String carnivalContinent, int index) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://solomasdeeplink.page.link',
      link: Uri.parse('https://solomasdeeplink.page.link?' +
          "CarnivalId=" +
          carnivalId +
          "&Continent=" +
          carnivalContinent),
      androidParameters: AndroidParameters(
        packageName: 'com.solomas1.android',
        minimumVersion: 0,
      ),
      /*dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),*/

      iosParameters: IOSParameters(
          bundleId: 'com.solomas1.ios',
          minimumVersion: '0',
          appStoreId: "1522424256"),
    );
    //Todo now
    /*iosParameters: IosParameters(
          bundleId: 'com.solomas1.ios',
          minimumVersion: '0',
          appStoreId: "1522424256"),
    );
*/
    var url = await dynamicLinks.buildLink(parameters);
    //Todo now
    //var url = await parameters.buildUrl();

    Share.share(
        "Carnival  \n\n" +
            _searchList[index].coverImageUrl.toString() +
            "\n\n" +
            _searchList[index].description.toString() +
            "\n\n" +
            "click Here to Open App" +
            "\n\n" +
            url.toString(),
        subject: 'Carnival');
    return url;
  }

  Widget _appBar(BuildContext context, String? carnivalContinent) {
    return SoloAppBar(
      appBarType: StringHelper.backWithText,
      appbarTitle: StringHelper.carnivalIn + carnivalContinent!,
      backOnTap: () {
        Navigator.pop(context);
      },
    );
  }
}
