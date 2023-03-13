import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:solomas/activities/bottom_tabs/profile_tab.dart';
import 'package:solomas/helpers/space.dart';

import '../../helpers/common_helper.dart';
import '../../resources_helper/colors.dart';
import '../../resources_helper/common_widget.dart';
import '../../resources_helper/dimens.dart';
import '../../resources_helper/images.dart';
import '../../resources_helper/strings.dart';
import '../../resources_helper/text_styles.dart';
import '../home/search_people_activity.dart';

class SoloAppBar extends StatefulWidget {
  final String? appBarType;
  final Function()? leadingTap;
  final Function()? trailingTap;
  final String? hintText;
  final Function(String)? onSearchBarTextChanged;
  final bool? isMore;
  final bool? backWithMore;
  final Function()? onSingleIconClick;
  void Function(String)? onFieldSubmitted;
  final Function()? postOnTap;
  final Function()? searchOnTap;
  final Function()? profileOnTap;
  final String? appbarTitle;
  final Function()? backOnTap;
  final Function()? iconOnTap;
  final String? profileImage;
  final String? iconUrl;
  final bool? isLocation;
  final Function()? locationOnTap;
  final Function()? onTapMore;
  final String? locationText;
  final Function()? addOnTap;
  final Function()? navigationOnTap;
  final Widget? child;
  final Widget? distanceWidget;
  final TextEditingController? textEditController;

  SoloAppBar({
    Key? key,
    this.appBarType,
    this.leadingTap,
    this.iconUrl,
    this.hintText,
    this.onSearchBarTextChanged,
    this.isMore = false,
    this.backWithMore = false,
    this.onSingleIconClick,
    this.postOnTap,
    this.onFieldSubmitted,
    this.isLocation = false,
    this.searchOnTap,
    this.profileOnTap,
    this.iconOnTap,
    this.textEditController,
    this.profileImage,
    this.appbarTitle,
    this.backOnTap,
    this.locationOnTap,
    this.locationText,
    this.trailingTap,
    this.child,
    this.distanceWidget,
    this.onTapMore,
    this.addOnTap,
    this.navigationOnTap,
  }) : super(key: key);

  @override
  State<SoloAppBar> createState() => _SoloAppBarState();
}

class _SoloAppBarState extends State<SoloAppBar> {
  late CommonHelper _commonHelper;

  @override
  Widget build(BuildContext context) {
    _commonHelper = CommonHelper(context);

    switch (widget.appBarType) {
      case StringHelper.drawerWithSearchbar:
        return SafeArea(
          child: drawerWithSearchBar(
              isLocation: widget.isLocation ?? false,
              drawerOnTap: widget.leadingTap ?? () {},
              hintText: widget.hintText ?? "",
              textEditController: widget.textEditController,
              onSearchBarTextChanged:
                  widget.onSearchBarTextChanged ?? (string) {}),
        );

      case StringHelper.searchBarWithBackNavigation:
        return SafeArea(
          child: searchBarWithBackNavigation(
              onFieldSubmitted: widget.onFieldSubmitted ?? (value) {},
              hintText: widget.hintText ?? "",
              onSearchBarTextChanged:
                  widget.onSearchBarTextChanged ?? (string) {},
              backTap: widget.leadingTap ??
                  () {
                    Navigator.pop(context);
                  }),
        );

      case StringHelper.searchBarWithTrilling:
        return SafeArea(child: _searchBarWithTrilling());

      case StringHelper.backBar:
        return SafeArea(child: appBarWithBack());

      case StringHelper.drawerWithSearchBarAndIcon:
        return SafeArea(
          child: drawerWithSearchBarAndIcon(
              drawerOnTap: widget.leadingTap ?? () {},
              hintText: widget.hintText ?? "",
              onSearchBarTextChanged:
                  widget.onSearchBarTextChanged ?? (string) {},
              isMore: widget.isMore ?? false,
              onSingleIconClick: widget.onSingleIconClick ?? () {}),
        );

      case StringHelper.backWithText:
        return SafeArea(
          child: backWithText(
            backWithMore: widget.backWithMore ?? false,
            appbarTittle: widget.appbarTitle ?? "",
            iconUrl: widget.iconUrl ?? "",
            backOnTap: widget.backOnTap ?? () {},
            iconOnTap: widget.iconOnTap ?? () {},
          ),
        );
      case StringHelper.backWithEditAppBar:
        return SafeArea(
          child: backWithEditAppBar(
            appbarTittle: widget.appbarTitle ?? "",
            iconUrl: widget.iconUrl ?? "",
            backOnTap: widget.backOnTap ?? () {},
            iconOnTap: widget.iconOnTap ?? () {},
          ),
        );
      case StringHelper.backWithReportIcon:
        return SafeArea(
          child: backWithReportIcon(onTapMore: widget.onTapMore),
        );

      case StringHelper.withCenterWidget:
        return SafeArea(child: _withCenterWidget());

      case StringHelper.searchBar:
        return searchAppBar(
            hintText: widget.hintText ?? "",
            onSearchBarTextChanged:
                widget.onSearchBarTextChanged ?? (string) {});

      case StringHelper.addNavigationAppBar:
        return addNavigationAppBar(
          addOnTap: widget.addOnTap,
          navigationOnTap: widget.navigationOnTap,
          onSearchBarTextChanged: widget.onSearchBarTextChanged,
        );

      default:
        return normalAppBar(
            profileImage: widget.profileImage ?? "",
            drawerOnTap: widget.leadingTap ?? () {},
            postOnTap: widget.postOnTap ?? () {},
            profileOnTap: widget.profileOnTap ?? () {},
            searchOnTap: widget.searchOnTap ?? () {});
    }
  }

  Widget drawerWithSearchBar(
      {required Function() drawerOnTap,
      required String hintText,
      bool isLocation = false,
      TextEditingController? textEditController,
      required Function(String) onSearchBarTextChanged}) {
    return Row(
      children: [
        GestureDetector(
          onTap: drawerOnTap,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: SvgPicture.asset(IconsHelper.drawerIcon,
                width: CommonHelper(context).screenWidth * 0.089),
          ),
        ),
        space(width: 10),
        Expanded(
          child: Container(
            child: searchBar(
                hintText: hintText,
                textEditController: textEditController,
                onSearchBarTextChanged: onSearchBarTextChanged),
          ),
        ),
        space(width: 5),
        isLocation
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(IconsHelper.nevigation,
                      width: CommonHelper(context).screenWidth * 0.09),
                  GestureDetector(
                    onTap: widget.locationOnTap,
                    child: SizedBox(
                      width: 60,
                      child: Text(widget.locationText ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: SoloStyle.titleNevBlack),
                    ),
                  ),
                ],
              )
            : SizedBox.shrink()
      ],
    );
  }

  Widget backWithReportIcon({void Function()? onTapMore}) {
    return Container(
      child: Stack(
        children: [
          Visibility(
            visible: true,
            child: GestureDetector(
              onTap: () {
                //_commonHelper.closeActivity();
                Navigator.pop(context, true);
              },
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 50,
                    width: 50,
                    padding: EdgeInsets.only(
                      left: DimensHelper.sidesMargin,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Image.asset(IconsHelper.back_with_whightbg),
                  )),
            ),
          ),
          GestureDetector(
            onTap: onTapMore,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                  height: 50,
                  width: 50,
                  padding: EdgeInsets.only(right: DimensHelper.sidesMargin),
                  alignment: Alignment.centerRight,
                  child: Image.asset(IconsHelper.ic_more)),
            ),
          )
        ],
      ),
    );
  }

  Widget appBarWithBack() {
    return Container(
      child: Stack(
        children: [
          Visibility(
            visible: true,
            child: GestureDetector(
              onTap: () {
                //_commonHelper.closeActivity();
                Navigator.pop(context, true);
              },
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 50,
                    width: 50,
                    padding: EdgeInsets.only(
                      left: DimensHelper.sidesMargin,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Image.asset(IconsHelper.back_with_whightbg),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget drawerWithSearchBarAndIcon({
    required Function() drawerOnTap,
    required String hintText,
    required Function(String) onSearchBarTextChanged,
    required bool isMore,
    required Function() onSingleIconClick,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: drawerOnTap,
              child: SvgPicture.asset(IconsHelper.drawerIcon,
                  width: CommonHelper(context).screenWidth * 0.09),
            ),
            space(width: 11),
            Container(
              width: isMore
                  ? _commonHelper.screenWidth * 0.71
                  : _commonHelper.screenWidth * 0.74,
              child: Row(
                children: [
                  Expanded(
                      child: searchBar(
                          hintText: hintText,
                          onSearchBarTextChanged: onSearchBarTextChanged)),
                ],
              ),
            ),
          ],
        ),
        InkWell(
            onTap: onSingleIconClick ??
                () {
                  CommonHelper(context).startActivity(SearchPeopleActivity());
                },
            child: isMore
                ? Image.asset(IconsHelper.ic_more_with_border,
                    width: CommonHelper(context).screenWidth * 0.1)
                : Image.asset(IconsHelper.ic_bell,
                    width: CommonHelper(context).screenWidth * 0.065))
      ],
    );
  }

  Widget searchBarWithBackNavigation({
    required String hintText,
    Function(String)? onSearchBarTextChanged,
    required Function(String) onFieldSubmitted,
    required Function() backTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: backTap,
          child: SvgPicture.asset(IconsHelper.backwardBackArrow,
              width: CommonHelper(context).screenWidth * 0.089),
        ),
        space(width: 10),
        Expanded(
            child: Container(
          child: searchBar(
              hintText: hintText,
              onFieldSubmitted: onFieldSubmitted,
              onSearchBarTextChanged: onSearchBarTextChanged ?? (value) {}),
        )),
        space(width: 5),
        SvgPicture.asset(IconsHelper.ic_plus,
            width: CommonHelper(context).screenWidth * 0.0),
        space(width: 5),
        SvgPicture.asset(IconsHelper.nevigation,
            width: CommonHelper(context).screenWidth * 0.0),
      ],
    );
  }

  Widget backWithText(
      {required String appbarTittle,
      required Function() backOnTap,
      required bool backWithMore,
      required iconUrl,
      required Function() iconOnTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: backOnTap,
              child: SvgPicture.asset(IconsHelper.backwardBackArrow,
                  width: CommonHelper(context).screenWidth * 0.089),
            ),
            space(width: _commonHelper.screenWidth * 0.025),
            Container(
              width: _commonHelper.screenWidth * 0.72,
              child: Text(
                appbarTittle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SoloStyle.darkBlackW700MaxTitle,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: iconOnTap,
          child: backWithMore
              ? Image.asset(iconUrl ?? IconsHelper.ic_more_with_border,
                  color: SoloColor.black,
                  width: CommonHelper(context).screenWidth * 0.09)
              : SizedBox.shrink(),
        )
      ],
    );
  }

  Widget backWithEditAppBar(
      {String? appbarTittle,
      required Function() backOnTap,
      required iconUrl,
      required Function() iconOnTap}) {
    return Padding(
      padding: EdgeInsets.only(top: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: backOnTap,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: CommonHelper(context).screenWidth * 0.12,
                      width: CommonHelper(context).screenWidth * 0.12,
                      padding: EdgeInsets.only(
                        left: _commonHelper?.screenHeight * .013,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Image.asset(IconsHelper.back_with_whightbg),
                    )),
              ),
              space(width: _commonHelper.screenWidth * 0.025),
              Container(
                width: _commonHelper.screenWidth * 0.72,
                child: Text(
                  appbarTittle ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SoloStyle.whiteW700MaxTitle,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              right: _commonHelper?.screenHeight * .013,
            ),
            child: GestureDetector(
              onTap: iconOnTap,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: CommonHelper(context).screenWidth * 0.09,
                  width: CommonHelper(context).screenWidth * 0.09,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: SoloColor.white,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    IconsHelper.edit,
                    color: SoloColor.black.withOpacity(0.7),
                  ),
                  // Image.asset(
                  //   IconsHelper.edit,
                  //   color: SoloColor.black.withOpacity(0.7),
                  // )
                ),
              ),
            ),
          ),
          // InkWell(
          //     onTap: iconOnTap,
          //     child: Image.asset(iconUrl ?? IconsHelper.ic_more_with_border,
          //         color: SoloColor.black,
          //         width: CommonHelper(context).screenWidth * 0.09))
        ],
      ),
    );
  }

  Widget _withCenterWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            InkWell(
              onTap: widget.leadingTap,
              child: SvgPicture.asset(IconsHelper.backwardBackArrow,
                  width: CommonHelper(context).screenWidth * 0.089),
            ),
            widget.child ?? SizedBox.shrink(),
          ],
        ),
        InkWell(
          onTap: widget.trailingTap,
          child: Container(
            width: 35,
            height: 35,
            alignment: Alignment.centerLeft,
            child: Image.asset('assets/icons/more_dots.png',
                width: CommonHelper(context).screenWidth * 0.10),
          ),
        ),
      ],
    );
  }

  Widget _searchBarWithTrilling() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: widget.leadingTap,
                    child: SvgPicture.asset(IconsHelper.backwardBackArrow,
                        width: CommonHelper(context).screenWidth * 0.089),
                  ),
                  space(width: _commonHelper.screenWidth * 0.025),
                  Container(
                    width: _commonHelper.screenWidth * 0.52,
                    child: Text(
                      widget.appbarTitle ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: SoloStyle.darkBlackW700MaxTitle,
                    ),
                  ),
                ],
              ),
              widget.child ?? SizedBox.shrink(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: widget.distanceWidget ?? SizedBox.shrink(),
          ),
          searchBar(
              hintText: widget.hintText ?? "",
              onSearchBarTextChanged: widget.onSearchBarTextChanged ?? (v) {}),
        ],
      ),
    );
  }

  Widget searchAppBar(
      {required String hintText,
      required Function(String) onSearchBarTextChanged}) {
    return Container(
      child: searchBar(
          hintText: hintText, onSearchBarTextChanged: onSearchBarTextChanged),
    );
  }

  Widget normalAppBar({
    required Function() drawerOnTap,
    required Function() postOnTap,
    required Function() searchOnTap,
    required Function() profileOnTap,
    required String profileImage,
  }) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: drawerOnTap,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: SvgPicture.asset(IconsHelper.drawerIcon,
                  width: CommonHelper(context).screenWidth * 0.089),
            ),
          ),
          Container(
            height: 40,
            child: Padding(
              padding: EdgeInsets.only(
                  left: CommonHelper(context).screenWidth * 0.09),
              child: Image.asset(IconsHelper.soloMassLogo1,
                  width: CommonHelper(context).screenWidth * 0.25),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: postOnTap,
                child: SvgPicture.asset(IconsHelper.ic_plus,
                    width: CommonHelper(context).screenWidth * 0.08),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: InkWell(
                  onTap: searchOnTap ??
                      () {
                        CommonHelper(context)
                            .startActivity(SearchPeopleActivity());
                      },
                  child: SvgPicture.asset(IconsHelper.ic_search,
                      width: CommonHelper(context).screenWidth * 0.08),
                ),
              ),
              InkWell(
                  onTap: profileOnTap ??
                      () {
                        CommonHelper(context)
                            .startActivity(ProfileTab(isFromHome: true));
                      },
                  child: ClipOval(
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: CommonHelper(context).screenWidth * 0.085,
                        height: CommonHelper(context).screenWidth * 0.085,
                        imageUrl: profileImage,
                        placeholder: (context, url) => imagePlaceHolder(),
                        errorWidget: (context, url, error) =>
                            imagePlaceHolder()),
                  )
                  // Image.network(profileImage ?? IconsHelper.ic_user,
                  //     width: CommonHelper(context).screenWidth * 0.08),
                  ),
            ],
          )
        ],
      ),
    );
  }

  Widget searchBar({
    required String hintText,
    TextEditingController? textEditController,
    required Function(String) onSearchBarTextChanged,
    Function(String)? onFieldSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: SoloColor.cultured, borderRadius: BorderRadius.circular(10)),
      height: 40,
      child: TextFormField(
        controller: textEditController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        maxLines: 1,
        minLines: 1,
        autofocus: false,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onSearchBarTextChanged,
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
          hintText: hintText ?? 'Search',
          hintStyle: SoloStyle.lightGrey200W500Top,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(width: 0.5, color: SoloColor.gainsBoro),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: SoloColor.gainsBoro, width: 0.5)),
        ),
      ),
    );
  }

  Widget addNavigationAppBar(
      {Function()? addOnTap,
      Function()? navigationOnTap,
      dynamic Function(String)? onSearchBarTextChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: _commonHelper?.screenWidth * 0.15,
            width: _commonHelper?.screenWidth * 0.089,
            child: SvgPicture.asset(
              IconsHelper.backwardBackArrow,
            ),
          ),
        ),
        SizedBox(
          width: _commonHelper?.screenWidth * 0.70,
          child: SoloAppBar(
            appBarType: StringHelper.searchBar,
            onSearchBarTextChanged: onSearchBarTextChanged,
            hintText: StringHelper.searchEvents,
            leadingTap: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        GestureDetector(
          onTap: addOnTap,
          child: SvgPicture.asset(IconsHelper.ic_plus,
              width: CommonHelper(context).screenWidth * 0.08),
        ),
        GestureDetector(
          onTap: navigationOnTap,
          child: SvgPicture.asset(IconsHelper.nevigation,
              width: CommonHelper(context).screenWidth * 0.08),
        ),
      ],
    );
  }
}
