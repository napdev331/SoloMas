import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solomas/blocs/explore/participants_list_bloc.dart';
import 'package:solomas/helpers/common_helper.dart';
import 'package:solomas/helpers/constants.dart';
import 'package:solomas/helpers/pref_helper.dart';
import 'package:solomas/helpers/progress_indicator.dart';
import 'package:solomas/model/participant_list_model.dart';
import 'package:solomas/resources_helper/colors.dart';
import 'package:solomas/resources_helper/dimens.dart';
import 'package:solomas/resources_helper/strings.dart';

import '../../resources_helper/common_widget.dart';
import '../../resources_helper/screen_area/scaffold.dart';
import '../common_helpers/app_bar.dart';

class ParticipantListActivity extends StatefulWidget {
  final String? type, contestId;

  ParticipantListActivity({this.type, this.contestId});

  @override
  State<StatefulWidget> createState() {
    return _ParticipantState();
  }
}

class _ParticipantState extends State<ParticipantListActivity> {
  //============================================================
// ** Properties **
//============================================================
  ParticipantsListBloc? _participantsListBloc;
  CommonHelper? _commonHelper;
  List<RoadKingQueenList> _aList = [];
  List<RoadKingQueenList> _searchList = [];
  bool _progressShow = false;
  String? authToken;
  var _searchController = TextEditingController();

  //============================================================
// ** Flutter Build Cycle **
//============================================================

  @override
  void initState() {
    super.initState();

    _participantsListBloc = ParticipantsListBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) => _getParticipants());
  }

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    _onSearchTextChanged(String text) async {
      _searchList.clear();

      if (text.isEmpty) {
        _searchList.addAll(_aList);

        setState(() {});

        return;
      }

      _aList.forEach((carnivalDetail) {
        if (carnivalDetail.userName!
            .toUpperCase()
            .contains(text.toUpperCase())) {
          _searchList.add(carnivalDetail);
        }
      });

      setState(() {});
    }

    Widget _noUserWarning() {
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(DimensHelper.btnTopMargin),
          child: Text("No User Found",
              style: TextStyle(
                  fontSize: Constants.FONT_MEDIUM,
                  fontWeight: FontWeight.normal,
                  color: SoloColor.spanishGray)));
    }

    Widget _noParticipationWarning() {
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(DimensHelper.btnTopMargin),
          child: Text("No one is participating in this contest yet",
              style: TextStyle(
                  fontSize: Constants.FONT_MEDIUM,
                  fontWeight: FontWeight.normal,
                  color: SoloColor.spanishGray)));
    }

    Widget searchBar() {
      return Container(
        margin: EdgeInsets.only(
            left: DimensHelper.sidesMargin,
            right: DimensHelper.sidesMargin,
            top: DimensHelper.sidesMargin),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(DimensHelper.sidesMarginDouble))),
          child: Row(
            children: [
              Expanded(
                  child: Container(
                padding: EdgeInsets.all(DimensHelper.searchBarMargin),
                margin: EdgeInsets.only(left: DimensHelper.sidesMargin),
                child: TextFormField(
                  onFieldSubmitted: (value) {},
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  maxLines: 1,
                  minLines: 1,
                  onChanged: _onSearchTextChanged,
                  autofocus: false,
                  controller: _searchController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z -]")),
                    LengthLimitingTextInputFormatter(30),
                  ],
                  decoration: InputDecoration.collapsed(
                      hintText: 'Search here...',
                      hintStyle: TextStyle(
                        fontSize: Constants.FONT_MEDIUM,
                      )),
                ),
              )),
              Container(
                padding: EdgeInsets.only(
                  left: DimensHelper.halfSides,
                  right: DimensHelper.sidesMargin,
                ),
                child: Image.asset(
                  'images/ic_lg_bag.png',
                  height: 20,
                  width: 20,
                ),
              ),
            ],
          ),
        ),
      );
    }

    PreferredSizeWidget topAppBar() {
      return PreferredSize(
        child: Container(
            decoration: BoxDecoration(color: SoloColor.blue),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Container(
                  padding: EdgeInsets.only(
                      left: DimensHelper.sidesMargin,
                      right: DimensHelper.sidesMargin,
                      top: DimensHelper.sidesMargin),
                  child: Stack(
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
                        child: Text('Participant List'.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Constants.FONT_APP_TITLE)),
                      )
                    ],
                  ),
                ),
                searchBar()
              ],
            )),
        preferredSize: Size(_commonHelper?.screenWidth, 120),
      );
    }

    Widget _mainItem() {
      return Stack(
        children: [
          _searchList.isNotEmpty
              ? GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(DimensHelper.halfSides),
                  children: List<Widget>.generate(_searchList.length, (index) {
                    return Stack(
                      children: [
                        Positioned.fill(
                            bottom: 0.0,
                            child: GridTile(
                              child: Container(
                                  margin:
                                      EdgeInsets.all(DimensHelper.halfSides),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        DimensHelper.sidesMargin),
                                    color: Colors.transparent,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        DimensHelper.sidesMargin),
                                    child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl:
                                            _searchList[index].image.toString(),
                                        placeholder: (context, url) =>
                                            imagePlaceHolder(),
                                        errorWidget: (context, url, error) =>
                                            imagePlaceHolder()),
                                  )),
                            )),
                        Positioned.fill(
                            child: Container(
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    padding: EdgeInsets.all(
                                        DimensHelper.sidesMargin),
                                    width: _commonHelper?.screenWidth * .6,
                                    margin: EdgeInsets.only(
                                        left: DimensHelper.smallSides),
                                    child: Text(
                                      'VOTE',
                                      style: TextStyle(
                                          color: SoloColor.white,
                                          fontSize: Constants.FONT_TOP,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )),
                              GestureDetector(
                                onTap: () {},
                                child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: DimensHelper.halfSides,
                                          bottom: DimensHelper.smallSides),
                                      child: IconButton(
                                          icon: Icon(Icons.thumb_up, size: 20),
                                          color:
                                              _searchList[index].isVote == true
                                                  ? SoloColor.pink
                                                  : SoloColor.white,
                                          onPressed: () {
                                            if (_searchList[index].isVote ==
                                                true) {
                                              showCupertinoModalPopup(
                                                  context: context,
                                                  builder: (BuildContext
                                                          context) =>
                                                      _showBottomSheet(
                                                          _searchList[index]
                                                              .roadKingQueenId
                                                              .toString()));
                                            } else {
                                              _commonHelper?.showToast(
                                                  "You have voted already");
                                            }
                                          }),
                                    )),
                              )
                            ],
                          ),
                        )),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            alignment: Alignment.center,
                            width: 25.0,
                            height: 25.0,
                            margin: EdgeInsets.all(DimensHelper.sidesMargin),
                            decoration: BoxDecoration(
                              color: SoloColor.pink,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              _searchList[index].totalVotes.toString(),
                              style: TextStyle(
                                  color: SoloColor.white,
                                  fontSize: Constants.FONT_LOW),
                            ),
                          ),
                        ),
                      ],
                    );
                  }))
              : _aList.isEmpty
                  ? _noParticipationWarning()
                  : _noUserWarning(),
          Align(
            child:
                ProgressBarIndicator(_commonHelper?.screenSize, _progressShow),
            alignment: FractionalOffset.center,
          ),
        ],
      );
    }

    return SoloScaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(130), child: _appBar()),
      // topAppBar(),
      body: StreamBuilder(
          stream: _participantsListBloc?.participantsList,
          builder: (context, AsyncSnapshot<ParticipantListModel> snapshot) {
            if (snapshot.hasData) {
              if (_aList.isEmpty) {
                _aList = snapshot.data?.data?.roadKingQueenList ?? [];

                _searchList.addAll(_aList);
              }

              return _mainItem();
            } else if (snapshot.hasError) {
              return Container();
            }

            return Center(child: CircularProgressIndicator());
          }),
    );
  }

//============================================================
// ** Main Widgets **
//============================================================
  Widget _appBar() {
    return SoloAppBar(
      appBarType: StringHelper.searchBarWithTrilling,
      appbarTitle: StringHelper.participantList.toUpperCase(),
      hintText: StringHelper.search,
      leadingTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _showBottomSheet(String id) {
    return CupertinoActionSheet(
      message: Text("Do you want to vote for this masquerader?",
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_MEDIUM,
              fontWeight: FontWeight.normal)),
      title: Text("Vote",
          style: TextStyle(
              color: SoloColor.black,
              fontSize: Constants.FONT_TOP,
              fontWeight: FontWeight.w500)),
      actions: [
        CupertinoActionSheetAction(
          child: Text("Yes",
              style: TextStyle(
                  color: SoloColor.black,
                  fontSize: Constants.FONT_TOP,
                  fontWeight: FontWeight.w500)),
          onPressed: () {
            Navigator.pop(context);

            _onVoteTap(id);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancel",
            style: TextStyle(
                color: SoloColor.black,
                fontSize: Constants.FONT_TOP,
                fontWeight: FontWeight.w500)),
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

//============================================================
// ** Helper Function **
//============================================================
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

  void _getParticipants() async {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        PrefHelper.getAuthToken().then((token) {
          authToken = token;

          _participantsListBloc
              ?.getParticipantList(token.toString(),
                  widget.contestId.toString(), widget.type.toString())
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

  void _onVoteTap(String id) {
    _commonHelper?.isInternetAvailable().then((available) {
      if (available) {
        _showProgress();

        var likeBody = json.encode({
          "roadKingQueenId": id,
          "type": widget.type,
        });

        _participantsListBloc
            ?.voteRoadKingQueen(authToken.toString(), likeBody)
            .then((onValue) {
          _searchList.clear();

          _aList.clear();

          _getParticipants();
        }).catchError((onError) {
          _hideProgress();
        });
      } else {
        _commonHelper?.showAlert(
            StringHelper.noInternetTitle, StringHelper.noInternetMsg);
      }
    });
  }
}
