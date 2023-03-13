import 'dart:io';

import 'package:solomas/model/block_user_model.dart';
import 'package:solomas/model/block_users_model.dart';
import 'package:solomas/model/blog_comment_blog.dart';
import 'package:solomas/model/blog_list_model.dart';
import 'package:solomas/model/buy_reward_item_model.dart';
import 'package:solomas/model/carnival_comment_list_model.dart';
import 'package:solomas/model/carnival_comment_model.dart';
import 'package:solomas/model/carnival_comment_photos.dart';
import 'package:solomas/model/carnival_continent_model.dart';
import 'package:solomas/model/carnival_feed_like_list_model.dart';
import 'package:solomas/model/carnival_feed_like_model.dart';
import 'package:solomas/model/carnival_feed_un_like_model.dart';
import 'package:solomas/model/carnival_list_model.dart';
import 'package:solomas/model/carnival_photos_like_listing.dart';
import 'package:solomas/model/carnival_photos_list.dart';
import 'package:solomas/model/carnival_photos_post_comment.dart';
import 'package:solomas/model/carnival_review_list.dart';
import 'package:solomas/model/carnival_tiles_response.dart';
import 'package:solomas/model/carnival_upload_photos.dart';
import 'package:solomas/model/change_password_model.dart';
import 'package:solomas/model/chat_individual_model.dart';
import 'package:solomas/model/check_in_carnival_model.dart';
import 'package:solomas/model/contest_list_model.dart';
import 'package:solomas/model/create_carnival_feed_model.dart';
import 'package:solomas/model/create_event_response.dart';
import 'package:solomas/model/create_public_feed_model.dart';
import 'package:solomas/model/create_review_event.dart';
import 'package:solomas/model/create_service_response.dart';
import 'package:solomas/model/delete_account_model.dart';
import 'package:solomas/model/delete_carnival_feed_model.dart';
import 'package:solomas/model/delete_chat_model.dart';
import 'package:solomas/model/delete_comment_model.dart';
import 'package:solomas/model/delete_public_feed_model.dart';
import 'package:solomas/model/delete_review.dart';
import 'package:solomas/model/dis_join_carnival_model.dart';
import 'package:solomas/model/event_review_response.dart';
import 'package:solomas/model/events_comment_response.dart';
import 'package:solomas/model/events_continent_model.dart';
import 'package:solomas/model/events_like_model.dart';
import 'package:solomas/model/events_members_response.dart';
import 'package:solomas/model/events_response.dart';
import 'package:solomas/model/feed_comment_list_model.dart';
import 'package:solomas/model/feed_comment_model.dart';
import 'package:solomas/model/feed_like_list_model.dart';
import 'package:solomas/model/feed_like_model.dart';
import 'package:solomas/model/get_events_category.dart';
import 'package:solomas/model/get_groups_model.dart';
import 'package:solomas/model/get_people_model.dart';
import 'package:solomas/model/group_feed_model.dart';
import 'package:solomas/model/image_upload_model.dart';
import 'package:solomas/model/join_carnival_model.dart';
import 'package:solomas/model/join_group_model.dart';
import 'package:solomas/model/login_model.dart';
import 'package:solomas/model/logout_model.dart';
import 'package:solomas/model/messages_model.dart';
import 'package:solomas/model/notification_list_model.dart';
import 'package:solomas/model/participant_list_model.dart';
import 'package:solomas/model/participate_model.dart';
import 'package:solomas/model/particular_event_detail.dart';
import 'package:solomas/model/post_service_comment.dart';
import 'package:solomas/model/public_feeds_model.dart';
import 'package:solomas/model/report_feed_model.dart';
import 'package:solomas/model/reset_password_model.dart';
import 'package:solomas/model/reward_items_model.dart';
import 'package:solomas/model/road_king_queen_vote_model.dart';
import 'package:solomas/model/search_user_model.dart';
import 'package:solomas/model/service_category_response.dart';
import 'package:solomas/model/service_comment_response.dart';
import 'package:solomas/model/service_like_list_model.dart';
import 'package:solomas/model/service_list_response.dart';
import 'package:solomas/model/services_continent_model.dart';
import 'package:solomas/model/share_blog_response.dart';
import 'package:solomas/model/sign_up_model.dart';
import 'package:solomas/model/social_login_model.dart';
import 'package:solomas/model/un_block_user_model.dart';
import 'package:solomas/model/update_carnival_feed_model.dart';
import 'package:solomas/model/update_event_response.dart';
import 'package:solomas/model/update_mobile_model.dart';
import 'package:solomas/model/update_user_data_model.dart';
import 'package:solomas/model/upload_image_model.dart';
import 'package:solomas/model/user_location_update_model.dart';
import 'package:solomas/model/user_profile_model.dart';
import 'package:solomas/model/verify_otp_model.dart';
import 'package:solomas/model/verify_user_model.dart';

import '../model/un_like_public_feed.dart';
import 'api_constants.dart';
import 'http_helper.dart';

class ApiHelper {
  static final ApiHelper _getInstance = ApiHelper._internal();

  ApiHelper._internal();

  factory ApiHelper() {
    return _getInstance;
  }

  HttpHelper _httpHelper = HttpHelper();

  Future<dynamic> signUp(String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_REGISTER_USER, body: reqBody);
    if (result == null) {
      throw ("Some Arbitrary Error");
    }
    print("Some Arbitrary");
    return SignUpModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> login(String reqBody) async {
    final result =
        await _httpHelper.post(url: ApiConstants.API_POST_LOGIN, body: reqBody);
    if (result == null) {
      throw ("Some Arbitrary Error");
    }
    return LoginModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> verifyUser(String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_VERIFY_USER, body: reqBody);
    if (result == null) {
      throw ("Some Arbitrary Error");
    }
    return VerifyUserModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> socialLogin(String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_SOCIAL_LOGIN, body: reqBody);
    if (result == null) {
      throw ("Some Arbitrary Error");
    }
    return SocialLoginModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> forgotPassword(String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_FORGOT_PASSWORD, body: reqBody);
    if (result == null) {
      throw ("Some Arbitrary Error");
    }
    return CreateOtpModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> createOtp(String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CREATE_OTP, body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }
    return CreateOtpModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> verifyOtp(String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_VERIFY_OTP, body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return VerifyOtpModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> resetPassword(String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_RESET_PASSWORD, body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ResetPasswordModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> deleteAccount(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_DELETE_ACCOUNT,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }
    return DeleteAccountModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> feedLike(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_FEED_LIKE, body: reqBody, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return FeedLikeModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> feedUnLike(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_FEED_UNLIKE,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UnLikePublicFeedModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getCarnivalsList(String token, String carnivalId,
      String distance, String continent) async {
    var result;

    if (carnivalId.isNotEmpty) {
      result = await _httpHelper.get(
          url: ApiConstants.API_GET_CARNIVALS + "?carnivalId=$carnivalId",
          authToken: token);
    } else if (distance.isNotEmpty) {
      result = await _httpHelper.get(
          url: ApiConstants.API_GET_CARNIVALS + "?distance=$distance",
          authToken: token);
    } else {
      result = await _httpHelper.get(
          url: ApiConstants.API_GET_CARNIVALS + "?continent=" + continent,
          authToken: token);
    }

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CarnivalListModel.fromJson(result);
  }

  Future<dynamic> getCarnivalsLikeList(String token, String feedId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_CARNIVAL_FEED_LIKE_LIST +
            "?carnivalFeedId=$feedId",
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CarnivalLikeListModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> carnivalFeedLike(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CARNIVAL_FEED_LIKE,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CarnivalFeedLikeModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> carnivalFeedUnLike(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CARNIVAL_FEED_UN_LIKE,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CarnivalFeedUnLikeModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getCarnivalsCommentList(String token, String feedId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_CARNIVAL_COMMENT_LIST +
            "?carnivalFeedId=$feedId",
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CarnivalCommentListModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getPublicFeeds(String token) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_PUBLIC_FEEDS, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return PublicFeedsModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getPublicFeedsLikeList(
      String token, String publicFeedId) async {
    final result = await _httpHelper.get(
        url:
            ApiConstants.API_GET_FEED_LIKE_LIST + '?publicFeedId=$publicFeedId',
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return FeedLikeListModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getPublicFeedsCommentList(
      String token, String publicFeedId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_PUBLIC_FEED_COMMENT_LIST +
            '?publicFeedId=$publicFeedId',
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return FeedCommentListModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getMessagesList(String token) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_CHAT_SUMMARY, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return MessagesModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getGroups(
      String authToken, String groupId, String distance) async {
    var result;

    if (groupId.isEmpty) {
      result = await _httpHelper.get(
          url: ApiConstants.API_GET_GROUPS + "?distance=$distance",
          authToken: authToken);
    } else {
      result = await _httpHelper.get(
          url: ApiConstants.API_GET_GROUPS + "?groupId=$groupId",
          authToken: authToken);
    }

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return GetGroupsModel.fromJson(result);
  }

  Future<dynamic> addPublicFeedComment(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_PUBLIC_FEED_COMMENT,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return FeedCommentModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> addCarnivalFeedComment(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CARNIVAL_COMMENT,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CarnivalCommentModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> userLogout(String reqBody, String token) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_PUT_USER_LOGOUT, authToken: token, body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return LogoutModel.fromJson(result);
  }

  Future<dynamic> updateCarnivalFeed(String reqBody, String token) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_PUT_CARNIVAL_FEED,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UpdateCarnivalFeedModel.fromJson(result);
  }

  Future<dynamic> uploadFile(File imageFile) async {
    final result = await _httpHelper.uploadImage(imageFile);

    if (result == null) {
      return Future.error("Failed to upload image on server.");
    }

    return UploadImageModel.fromJson(result);
  }

  Future<ImageUploadModel> uploadImages(List<File> imageList) async {
    final result = await _httpHelper.uploadMultipleImage(imageList);
    if (result == null) {
      return Future.error("Failed to upload images on server");
    }
    return ImageUploadModel.fromJson(result);
  }

  Future<dynamic> changedPassword(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CHANGE_PASSWORD,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ChangedPasswordModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> buyItems(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_BUY_ITEMS, body: reqBody, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return BuyRewardItemModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> checkInCarnival(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CHECK_IN, body: reqBody, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CheckInCarnivalModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> createPublicFeed(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CREATE_PUBLIC_FEED,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CreatePublicFeedModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> updatePublicFeed(String reqBody, String token) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_POST_CREATE_PUBLIC_FEED,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CreatePublicFeedModel.fromJson(result);
  }

  Future<dynamic> joinCarnival(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_JOIN_CARNIVAL,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return JoinCarnivalModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> disJoinCarnival(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_DIS_JOIN_CARNIVAL,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return DisJoinCarnivalModel.fromJson(result as Map<String, dynamic>);
  }

  Future<DeletePublicFeedModel> deletePublicFeed(
      String authToken, String publicFeedId) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_DELETE_PUBLIC_FEED + publicFeedId,
        authToken: authToken);

    return DeletePublicFeedModel.fromJson(result);
  }

  Future<dynamic> createCarnivalFeed(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CREATE_CARNIVAL_FEED,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CreateCarnivalFeedModel.fromJson(result as Map<String, dynamic>);
  }

  Future<DeleteCarnivalFeedModel> deleteCarnivalFeed(
      String authToken, String feedId) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_DELETE_CARNIVAL_FEED + feedId,
        authToken: authToken);

    return DeleteCarnivalFeedModel.fromJson(result);
  }

  Future<ChatIndividualModel> getChatIndividual(
      String authToken, String userId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_CHAT_INDIVIDUAL + userId,
        authToken: authToken);

    return ChatIndividualModel.fromJson(result as Map<String, dynamic>);
  }

  Future<SearchUserModel> searchPeoples(
      String authToken, String fullName) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_SEARCH_USER + fullName, authToken: authToken);

    return SearchUserModel.fromJson(result as Map<String, dynamic>);
  }

  Future<UserProfileModel> getUserProfile(String authToken, String id) async {
    var result;

    print("userprofilefile");
    if (id.isEmpty) {
      result = await _httpHelper.get(
          url: ApiConstants.API_GET_USER_PROFILE, authToken: authToken);
    } else {
      result = await _httpHelper.get(
          url: ApiConstants.API_GET_USER_PROFILE + "?id=$id",
          authToken: authToken);
    }

    return UserProfileModel.fromJson(result);
  }

  Future<dynamic> getBlockedUsers(String token) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_BLOCKED_USERS, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return BlockedUserModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getRewardItems(String token) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_REWARD_ITEMS, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return RewardItemModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> blockUser(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_BLOCK_USER, body: reqBody, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return BlockUserModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> unBlockUser(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_UN_BLOCK_USER,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UnBlockUserModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> reportFeed(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_REPORT_FEED,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ReportFeedModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> deleteChat(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_DELETE_CHAT,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return DeleteChatModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> joinGroup(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_JOIN_GROUPS,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return JoinGroupModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> disJoinGroup(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_DIS_JOIN_GROUPS,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return DisJoinCarnivalModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getGroupFeed(String token, String groupId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_GROUP_FEED + groupId, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return GroupFeedModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getParticipantsList(
      String token, String carnivalId, String type) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_PARTICIPANTS_LIST +
            "?contestId=$carnivalId&type=$type",
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ParticipantListModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getNotificationList(String token) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_NOTIFICATION_LIST, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return NotificationListModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getContestList(
      String token, String distance, String contestId) async {
    var result;

    if (distance.isEmpty) {
      result = await _httpHelper.get(
          url: ApiConstants.API_GET_CONTEST_LIST + contestId, authToken: token);
    } else {
      result = await _httpHelper.get(
          url: ApiConstants.API_GET_CONTEST_LIST +
              contestId +
              "&distance=$distance",
          authToken: token);
    }

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ContestListModel.fromJson(result);
  }

  Future<dynamic> roadKingQueenVote(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_ROAD_KING_QUEEN_VOTE,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return RoadKingQueenVoteModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> participateRoadKingQueen(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_ROAD_KING_QUEEN_PARTICIPATE,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ParticipateModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getNearByPeoples(
      String token, double latitude, double longitude, String distance) async {
    var result;

    if (distance.isEmpty) {
      result = await _httpHelper.get(
          url: ApiConstants.API_GET_NEARBY_PEOPLES +
              "?lat=$latitude&lng=$longitude",
          authToken: token);
    } else {
      result = await _httpHelper.get(
          url: ApiConstants.API_GET_NEARBY_PEOPLES +
              "?lat=$latitude&lng=$longitude&distance=$distance",
          authToken: token);
    }

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return GetPeoplesModel.fromJson(result);
  }

  Future<dynamic> updateUserData(String reqBody, String token) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_PUT_UPDATE_USER, body: reqBody, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UpdateUserModel.fromJson(result);
  }

  Future<dynamic> deleteComment(String token, String commentId) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_DELETE_COMMENT + commentId, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return DeleteCommentModel.fromJson(result);
  }

  Future<dynamic> deleteCommentCarnival(String token, String commentId) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_DELETE_COMMENT_CARNIVALS + commentId,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return DeleteCommentModel.fromJson(result);
  }

  Future<dynamic> createEvent(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_CREATE_EVENT, body: reqBody, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }
    return CreateEventResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getEventCategory(String token) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_EVENTS_CATEGORY, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return EventCategory.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getEventCarnival(String token) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_EVENTS_CARNIVAL, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CarnivalTilesResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getEvent(String token, String text, String lat, String lng,
      String eventContinent) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_EVENTS +
            "?showActiveOnly=true" +
            "&text=" +
            text +
            "&lat=" +
            lat +
            "&lng=" +
            lng +
            "&continent=" +
            eventContinent,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return EventResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getEventPrevious(String token, String text, String lat,
      String lng, String eventContinent) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_EVENTS +
            "?showExpiredOnly=true" +
            "&text=" +
            text +
            "&lat=" +
            lat +
            "&lng=" +
            lng +
            "&continent=" +
            eventContinent,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return EventResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getEventCommentList(String token, String eventId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_EVENTS_COMMENTS + '?eventId=$eventId',
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return EventCommentResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> addEventComment(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_EVENTS_POST_COMMENT,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return FeedCommentModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> deleteEventComment(String token, String commentId) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_EVENTS_DELETE_COMMENT + commentId,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return DeleteCommentModel.fromJson(result);
  }

  Future<DeletePublicFeedModel> deleteEvent(
      String authToken, String eventId) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_EVENTS_DELETE_Event + eventId + "?isAdmin=true",
        authToken: authToken);

    return DeletePublicFeedModel.fromJson(result);
  }

  Future<dynamic> updateEvent(String token, String reqBody) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_CREATE_EVENT, authToken: token, body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UpdateEventResponse.fromJson(result);
  }

  Future<dynamic> getEventMembersList(String token, String eventId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_EVENTS_MEMBERS + 'eventId=$eventId',
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return EventsMemberResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getEventDetail(String token, String eventId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_EVENTS + "?eventId=$eventId",
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ParticularEventDetails.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> joinEvent(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_JOIN_EVENT, body: reqBody, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return JoinCarnivalModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> disJoinEvent(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_DIS_JOIN_EVENT,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return DisJoinCarnivalModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getSearchedEvent(String token, String text) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_EVENTS + "?showActiveOnly=true&text=" + text,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return EventResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> createService(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_SERVICE_CREATE,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CreateServiceResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> updateService(String token, String reqBody) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_POST_SERVICE_CREATE,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CreateServiceResponse.fromJson(result);
  }

  Future<dynamic> getServiceCategory(String token) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_SERVICE_CATEGORY, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ServiceCategoryResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getService(String token, String text, String lat, String lng,
      String serviceContinent, String service) async {
    if (service == "All") {
      service = "";
    } else {
      service = service;
    }
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_SERVICE_LIST +
            "?text=" +
            text +
            "&lat=" +
            lat +
            "&lng=" +
            lng +
            "&continent=" +
            serviceContinent +
            "&category=" +
            service,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ServiceListResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getSearchedService(String token, String text) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_SERVICE_LIST + "?text=" + text,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ServiceListResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<DeletePublicFeedModel> deleteService(
      String authToken, String serviceId) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_POST_SERVICE_CREATE +
            "/" +
            serviceId +
            "?isAdmin=true",
        authToken: authToken);

    return DeletePublicFeedModel.fromJson(result);
  }

  Future<dynamic> getServiceDetail(String token, String serviceId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_SERVICE_LIST + "?serviceId=$serviceId",
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ServiceListResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getServiceCommentList(String token, String serviceId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_SERVICE_COMMENTS + 'serviceId=$serviceId',
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ServiceCommentResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> addServiceComment(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_SERVICE_COMMENT,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return PostServiceCommentResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> deleteServiceComment(String token, String commentId) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_POST_SERVICE_COMMENT + "/" + commentId,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return DeleteCommentModel.fromJson(result);
  }

  Future<dynamic> serviceLike(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_SERVICE_LIKE,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return FeedLikeModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> eventLike(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_EVENT_LIKE, body: reqBody, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return FeedLikeModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> servcieUnLike(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_SERVICE_UNLIKE,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UnLikePublicFeedModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getPublicServiceLikeList(
      String token, String publicFeedId) async {
    final result = await _httpHelper.get(
        url:
            ApiConstants.API_GET_SERVICE_LIKE_LIST + '?serviceId=$publicFeedId',
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ServiceLikeListModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getBlog(String token) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_BLOG_LIST, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return BlogListResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> shareCount(String token, String reqBody) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_PUT_SHARE_COUNT, authToken: token, body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ShareBlogResponse.fromJson(result);
  }

  Future<dynamic> getBlogCommentList(String token, String blogId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_BLOG_COMMENT_LIST + "?" + 'blogId=$blogId',
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return BlogCommentResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> addBlogComment(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_BLOG_COMMENT,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return PostServiceCommentResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> deleteBlogComment(String token, String commentId) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_POST_BLOG_COMMENT + "/" + commentId,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return DeleteCommentModel.fromJson(result);
  }

  Future<dynamic> blogLike(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_BLOG_LIKE, body: reqBody, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return FeedLikeModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> blogUnLike(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_BLOG_UNLIKE,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UnLikePublicFeedModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getEventReviewList(String token, String eventId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_EVENTS_REVIEW + '?eventId=$eventId',
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ReviewResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> addEventReview(String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_EVENTS_POST_REVIEW,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CreatReviewEvent.fromJson(result as Map<String, dynamic>);
  }

  Future<DeleteReviewEvent> deleteEventReview(
      String authToken, String reviewId) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_EVENTS_DELETE_REVIEW + reviewId,
        authToken: authToken);

    return DeleteReviewEvent.fromJson(result);
  }

  Future<dynamic> updateReview(String token, String reqBody) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_GET_EVENTS_REVIEW,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UpdateEventResponse.fromJson(result);
  }

  Future<dynamic> eventUnLike(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_EVENT_UNLIKE,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UnLikePublicFeedModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getEventLikeList(String token, String publicFeedId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_EVENT_LIKE_LIST + '?eventId=$publicFeedId',
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return EventsLikeModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getCarnivalsContinent(String token) async {
    var result;

    result = await _httpHelper.get(
        url: ApiConstants.API_GET_CARNIVALS_CONTINENT, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ContinentsModel.fromJson(result);
  }

  Future<dynamic> getCarnivalsPhotos(String token, String carnivalId) async {
    var result;

    result = await _httpHelper.get(
        url: ApiConstants.API_GET_CARNIVALS_PHOTOS + "?carnivalId=$carnivalId",
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CarnivalPhotosList.fromJson(result);
  }

  Future<dynamic> createPhotosFeed(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CREATE_CARNIVAL_PHOTOS,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CreatePhotosCarnivalModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getReviewsList(String token, String carnivalId) async {
    var result;

    result = await _httpHelper.get(
        url: ApiConstants.API_GET_CARNIVAL_REVIEWS + "?carnivalId=$carnivalId",
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CarnivalsReviewList.fromJson(result);
  }

  Future<dynamic> createCarnivalReview(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CREATE_CARNIVAL_REVIEW,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CreatePublicFeedModel.fromJson(result as Map<String, dynamic>);
  }

  Future<DeletePublicFeedModel> deleteReview(
      String authToken, String carnivalReviewId) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_DELETE_CARNIVAL_REVIEW + carnivalReviewId,
        authToken: authToken);
    return DeletePublicFeedModel.fromJson(result);
  }

  Future<dynamic> carnivalPhotoLike(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CARNIVAL_PHOTO_LIKE,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return FeedLikeModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> carnivalPhotoUnLike(String reqBody, String token) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CARNIVAL_PHOTO_UNLIKE,
        body: reqBody,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UnLikePublicFeedModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getCarnivalPhotosLikeList(
      String token, String publicFeedId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_CARNIVAL_PHOTOS_LIKE_LIST +
            '?carnivalPhotoId=$publicFeedId',
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CarnivalPhotosLikeModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> getCarnivalCommentList(
      String token, String carnivalPhotoId) async {
    final result = await _httpHelper.get(
        url: ApiConstants.API_GET_CARNIVAL_COMMENT +
            "?" +
            'carnivalPhotoId=$carnivalPhotoId',
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CarnivalCommentPhotosModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> addCarnivalCommentComment(
      String token, String reqBody) async {
    final result = await _httpHelper.post(
        url: ApiConstants.API_POST_CARNIVAL_PHOTOS_COMMENT,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return CarnivalPostCommentModel.fromJson(result as Map<String, dynamic>);
  }

  Future<dynamic> deletePhotoComment(String token, String commentId) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_POST_PHOTO_COMMENT + "/" + commentId,
        authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return DeleteCommentModel.fromJson(result);
  }

  Future<DeletePublicFeedModel> deleteCarnivalPhoto(
      String authToken, String carnivalPhotos) async {
    final result = await _httpHelper.delete(
        url: ApiConstants.API_CARNIVAL_PHOTO_DELETE + carnivalPhotos,
        authToken: authToken);

    return DeletePublicFeedModel.fromJson(result);
  }

  Future<dynamic> getEventsContinent(String token) async {
    var result;

    result = await _httpHelper.get(
        url: ApiConstants.API_GET_EVENTS_CONTINENT, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return EventsContinentModel.fromJson(result);
  }

  Future<dynamic> getServicesContinent(String token) async {
    var result;

    result = await _httpHelper.get(
        url: ApiConstants.API_GET_SERVICES_CONTINENT, authToken: token);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return ServicesContinentModel.fromJson(result);
  }

  Future<dynamic> updateCommentPublicFeed(String reqBody, String token) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_PUT_PUBLIC_FEED, authToken: token, body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UpdateCarnivalFeedModel.fromJson(result);
  }

  Future<dynamic> updateCommentBlog(String reqBody, String token) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_PUT_BLOG_FEED, authToken: token, body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UpdateCarnivalFeedModel.fromJson(result);
  }

  Future<dynamic> updateServiceBlog(String reqBody, String token) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_PUT_SERVICE_FEED,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UpdateCarnivalFeedModel.fromJson(result);
  }

  Future<dynamic> updateNewEventCommentBlog(
      String reqBody, String token) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_PUT_EVENT_COMMENT_FEED,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UpdateCarnivalFeedModel.fromJson(result);
  }

  Future<dynamic> updateCarnivalPhotoCommentBlog(
      String reqBody, String token) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_PUT_CARNIVAL_PHOTO_COMMENT_FEED,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UpdateCarnivalFeedModel.fromJson(result);
  }

  Future<dynamic> updateGroupComment(String reqBody, String token) async {
    final result = await _httpHelper.put(
        url: ApiConstants.API_PUT_CARNIVAL_GROUP_FEED,
        authToken: token,
        body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }

    return UpdateCarnivalFeedModel.fromJson(result);
  }

  Future<dynamic> updateLocation(String reqBody, String token) async {
    final result = await _httpHelper.put(
        url: ApiConstants.UPDATE_LOCATION, authToken: token, body: reqBody);

    if (result == null) {
      throw ("Some Arbitrary Error");
    }
    return UserLocationUpdateModel.fromJson(result);
  }
}
