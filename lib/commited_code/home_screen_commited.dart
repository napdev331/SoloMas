// FeedCard(
// userProfile: _searchList![index].userProfilePic.toString(),
// userName: _searchList![index].userName.toString(),
// userLocation:
// _commonHelper!.getTimeDifference(_searchList?[index].insertDate ?? 0),
// userDetailsOnTap: () {
// if (_searchList?[index].userId == mineUserId) {
// //_commonHelper.startActivity(ProfileTab(isFromHome: true));
//
// Navigator.of(context)
//     .push(
// new MaterialPageRoute(
// builder: (_) => new ProfileTab(isFromHome: true)),
// )
//     .then((mapData) {
// if (mapData != null && mapData) {
// _searchList?.clear();
// _aList?.clear();
// _showProgress();
// _getPublicFeeds();
// }
// });
// } else {
// _commonHelper?.startActivity(UserProfileActivity(
// userId: _searchList![index].userId.toString()));
// }
// },
// moreTap: () {
// showCupertinoModalPopup(
// context: context,
// builder: (BuildContext context) {
// return _searchList?[index].userId == mineUserId
// ? _showBottomSheetEditDel(
// _searchList![index].publicFeedId.toString(),
// _searchList![index])
//     : _showBottomSheet(_searchList![index].userId.toString(),
// _searchList![index].publicFeedId.toString());
// });
// },
// feedImage: _searchList![index].image!.toString(),
// feedTap: () {
// if (_searchList?[index].userId == mineUserId) {
// Navigator.of(context)
//     .push(
// new MaterialPageRoute(
// builder: (_) => new ProfileTab(isFromHome: true)),
// )
//     .then((mapData) {
// if (mapData != null && mapData) {
// _searchList?.clear();
// _aList?.clear();
// _showProgress();
// _getPublicFeeds();
// }
// });
// } else {
// _commonHelper?.startActivity(UserProfileActivity(
// userId: _searchList![index].userId.toString()));
// }
// },
// likeImage: IconsHelper.like,
// likeCount: "2.4K",
// likeOnTap: () {},
// commentCount: "658",
// commentOnTap: () {},
// countDown: "3h ago",
// content: StringHelper.dummyHomeText,
// );
