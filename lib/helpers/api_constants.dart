class ApiConstants {
  //Api Endpoints
  static const String BASE_URL = 'https://api.solomasapp.com/api/';
  static const String CHAT_BASE_URL = 'https://api.solomasapp.com';

  // static const String BASE_URL = 'https://solomas.herokuapp.com/api/'
  // static const String CHAT_BASE_URL = 'https://solomas.herokuapp.com'
  // static const String BASE_URL = 'https://apiuat.solomasapp.com/api/'
  // static const String CHAT_BASE_URL = 'https://apiuat.solomasapp.com';

  //Get Requests
  static const String API_GET_USER_DATA = BASE_URL + 'user';
  static const String API_GET_USER_PROFILE = BASE_URL + 'users/profile';
  static const String API_GET_CARNIVALS = BASE_URL + 'carnivals';
  static const String API_GET_PUBLIC_FEEDS = BASE_URL + 'publicFeeds';
  static const String API_GET_CARNIVAL_FEED_LIKE_LIST =
      BASE_URL + 'carnivalFeeds/liked';
  static const String API_GET_FEED_LIKE_LIST = BASE_URL + 'publicFeeds/liked';
  static const String API_GET_PUBLIC_FEED_COMMENT_LIST =
      BASE_URL + 'publicFeeds/comments';
  static const String API_GET_CARNIVAL_COMMENT_LIST =
      BASE_URL + 'carnivalFeeds/comments';
  static const String API_GET_CHAT_SUMMARY = BASE_URL + 'chats/summary';
  static const String API_GET_CHAT_INDIVIDUAL =
      BASE_URL + 'chats/individual?userId=';
  static const String API_GET_SEARCH_USER =
      BASE_URL + 'users/searchUser?fullName=';
  static const String API_GET_BLOCKED_USERS = BASE_URL + 'blockUsers';
  static const String API_GET_GROUPS = BASE_URL + 'groups';
  static const String API_GET_GROUP_FEED = BASE_URL + 'carnivalFeeds?groupId=';
  static const String API_GET_NEARBY_PEOPLES = BASE_URL + 'users/people';
  static const String API_GET_PARTICIPANTS_LIST = BASE_URL + 'roadKingQueens';
  static const String API_GET_CONTEST_LIST = BASE_URL + 'contests?contestId=';
  static const String API_GET_NOTIFICATION_LIST = BASE_URL + 'notifications';
  static const String API_GET_REWARD_ITEMS = BASE_URL + 'rewardItems';

  //Post Requests
  static const String API_POST_LOGIN = BASE_URL + 'auth/login';
  static const String API_POST_REGISTER_USER = BASE_URL + 'users';
  static const String API_POST_VERIFY_USER = BASE_URL + 'users/verify';
  static const String API_POST_SOCIAL_LOGIN = BASE_URL + 'auth/social/login';
  static const String API_POST_CHANGE_PASSWORD =
      BASE_URL + 'auth/password/change';
  static const String API_POST_FORGOT_PASSWORD =
      BASE_URL + 'auth/forgotPassword/email';
  static const String API_POST_CREATE_OTP = BASE_URL + 'otp/create';
  static const String API_POST_VERIFY_OTP = BASE_URL + 'otp/verify';
  static const String API_POST_UPLOAD_IMAGE =
      BASE_URL + 's3upload/image-upload';
  static const String API_POST_RESET_PASSWORD =
      BASE_URL + 'auth/forgotPassword/email';
  static const String API_POST_DELETE_ACCOUNT = BASE_URL + 'users/delete';
  static const String API_POST_CREATE_PUBLIC_FEED = BASE_URL + 'publicFeeds';
  static const String API_POST_FEED_LIKE = BASE_URL + 'publicFeeds/like';
  static const String API_POST_FEED_UNLIKE = BASE_URL + 'publicFeeds/unlike';
  static const String API_POST_JOIN_CARNIVAL = BASE_URL + 'carnivals/join';
  static const String API_POST_DIS_JOIN_CARNIVAL =
      BASE_URL + 'carnivals/disjoin';
  static const String API_POST_PUBLIC_FEED_COMMENT =
      BASE_URL + 'publicFeeds/comment';
  static const String API_POST_CARNIVAL_COMMENT =
      BASE_URL + 'carnivalFeeds/comment';
  static const String API_POST_CREATE_CARNIVAL_FEED =
      BASE_URL + 'carnivalFeeds';
  static const String API_POST_CARNIVAL_FEED_LIKE =
      BASE_URL + 'carnivalFeeds/like';
  static const String API_POST_CARNIVAL_FEED_UN_LIKE =
      BASE_URL + 'carnivalFeeds/unlike';
  static const String API_POST_BLOCK_USER = BASE_URL + 'blockUsers/block';
  static const String API_POST_UN_BLOCK_USER = BASE_URL + 'blockUsers/unblock';
  static const String API_POST_REPORT_FEED = BASE_URL + 'reportUsers/report';
  static const String API_POST_DELETE_CHAT = BASE_URL + 'chats/deleteBy';
  static const String API_POST_JOIN_GROUPS = BASE_URL + 'groups/join';
  static const String API_POST_DIS_JOIN_GROUPS = BASE_URL + 'groups/disjoin';
  static const String API_POST_ROAD_KING_QUEEN_VOTE =
      BASE_URL + 'roadKingQueens/vote';
  static const String API_POST_ROAD_KING_QUEEN_PARTICIPATE =
      BASE_URL + 'roadKingQueens';
  static const String API_POST_BUY_ITEMS =
      BASE_URL + 'rewardItems/buyRewardItem';
  static const String API_POST_CHECK_IN = BASE_URL + 'carnivals/checkIn';

  //Delete Request
  static const String API_DELETE_PUBLIC_FEED = BASE_URL + 'publicFeeds/';
  static const String API_DELETE_CARNIVAL_FEED = BASE_URL + 'carnivalFeeds/';

  //Put Request
  static const String API_PUT_USER_EDIT = BASE_URL + 'user/edit';
  static const String API_PUT_UPDATE_USER = BASE_URL + 'users';
  static const String API_PUT_USER_LOGOUT = BASE_URL + 'users/logout';
  static const String API_PUT_CARNIVAL_FEED = BASE_URL + 'carnivalFeeds';
  static const String UPDATE_LOCATION = BASE_URL + 'users/current/location';

  //WebViews
  static const String API_WV_SUPPORT = BASE_URL + 'webview/support';
  static const String API_TERMS = BASE_URL + "webview/termsNConditions";
  static const String API_PRIVACY = BASE_URL + "webview/privacyPolicy";
  static const String API_WV_SHOP = 'https://shop.solomasapp.com';
  static const String API_WV_CONTENT_RULES = BASE_URL + 'webview/contestRules';
  static const String API_DELETE_COMMENT = BASE_URL + 'publicFeeds/comment/';
  static const String API_DELETE_COMMENT_CARNIVALS =
      BASE_URL + 'carnivalFeeds/comment/';
  static const String API_CREATE_EVENT = BASE_URL + 'events';
  static const String API_EVENTS_CATEGORY = BASE_URL + 'events/categories';
  static const String API_EVENTS_CARNIVAL = BASE_URL + 'carnivals/titles';
  static const String API_GET_EVENTS = BASE_URL + 'events/list';
  static const String API_EVENTS_POST_COMMENT = BASE_URL + 'events/comment/';
  static const String API_EVENTS_DELETE_COMMENT = BASE_URL + 'events/comment/';
  static const String API_GET_EVENTS_COMMENTS = BASE_URL + 'events/comments';
  static const String API_EVENTS_DELETE_Event = BASE_URL + 'events/';
  static const String API_GET_EVENTS_MEMBERS = BASE_URL + 'events/membersList?';
  static const String API_POST_JOIN_EVENT = BASE_URL + 'events/join';
  static const String API_POST_DIS_JOIN_EVENT = BASE_URL + 'events/leave';
  static const String API_GET_SERVICE_LIST = BASE_URL + 'services/list';
  static const String API_GET_SERVICE_CATEGORY =
      BASE_URL + 'services/categories';
  static const String API_GET_SERVICE_COMMENTS =
      BASE_URL + 'services/comments?';
  static const String API_GET_SERVICE_LIKES = BASE_URL + 'services/liked';
  static const String API_POST_SERVICE_CREATE = BASE_URL + 'services';
  static const String API_POST_SERVICE_COMMENT = BASE_URL + 'services/comment';
  static const String API_POST_SERVICE_LIKE = BASE_URL + 'services/like';
  static const String API_POST_SERVICE_UNLIKE = BASE_URL + 'services/unlike';
  static const String API_GET_SERVICE_LIKE_LIST = BASE_URL + 'services/liked';
  static const String API_GET_BLOG_LIST = BASE_URL + 'blogs/list';
  static const String API_GET_BLOG_COMMENT_LIST = BASE_URL + 'blogs/comments';
  static const String API_POST_BLOG_COMMENT = BASE_URL + 'blogs/comment';
  static const String API_PUT_SHARE_COUNT = BASE_URL + 'blogs/inc/share/count';
  static const String API_POST_BLOG_LIKE = BASE_URL + 'blogs/like';
  static const String API_POST_BLOG_UNLIKE = BASE_URL + 'blogs/unlike';
  static const String API_GET_EVENTS_REVIEW = BASE_URL + 'events/reviews';
  static const String API_EVENTS_POST_REVIEW = BASE_URL + 'events/reviews';
  static const String API_EVENTS_DELETE_REVIEW = BASE_URL + 'events/reviews/';
  static const String API_POST_EVENT_LIKE = BASE_URL + 'events/like';
  static const String API_POST_EVENT_UNLIKE = BASE_URL + 'events/unlike';
  static const String API_GET_EVENT_LIKE_LIST = BASE_URL + 'events/liked';
  static const String API_GET_CARNIVALS_CONTINENT =
      BASE_URL + 'carnivals/continent';
  static const String API_GET_CARNIVALS_PHOTOS =
      BASE_URL + 'carnivalPhotos/list';
  static const String API_GET_MULTIPLE_IMAGES =
      BASE_URL + 's3upload/files-upload';
  static const String API_POST_CREATE_CARNIVAL_PHOTOS =
      BASE_URL + 'carnivalPhotos';
  static const String API_GET_CARNIVAL_REVIEWS =
      BASE_URL + 'carnivalReviews/list';
  static const String API_POST_CREATE_CARNIVAL_REVIEW =
      BASE_URL + 'carnivalReviews';
  static const String API_DELETE_CARNIVAL_REVIEW =
      BASE_URL + 'carnivalReviews/';
  static const String API_POST_CARNIVAL_PHOTO_LIKE =
      BASE_URL + 'carnivalPhotos/like';
  static const String API_POST_CARNIVAL_PHOTO_UNLIKE =
      BASE_URL + 'carnivalPhotos/unlike';
  static const String API_GET_CARNIVAL_PHOTOS_LIKE_LIST =
      BASE_URL + 'carnivalPhotos/liked';
  static const String API_GET_CARNIVAL_COMMENT =
      BASE_URL + 'carnivalPhotos/comments';
  static const String API_POST_CARNIVAL_PHOTOS_COMMENT =
      BASE_URL + 'carnivalPhotos/comment';
  static const String API_POST_PHOTO_COMMENT =
      BASE_URL + 'carnivalPhotos/comment';
  static const String API_CARNIVAL_PHOTO_DELETE = BASE_URL + 'carnivalPhotos/';
  static const String API_GET_EVENTS_CONTINENT = BASE_URL + 'events/continent';
  static const String API_GET_SERVICES_CONTINENT =
      BASE_URL + 'services/continent';
  static const String API_PUT_PUBLIC_FEED = BASE_URL + 'publicFeeds/comment/';
  static const String API_PUT_BLOG_FEED = BASE_URL + 'blogs/comment/';
  static const String API_PUT_SERVICE_FEED = BASE_URL + 'services/comment/';
  static const String API_PUT_EVENT_COMMENT_FEED = BASE_URL + 'events/comment/';
  static const String API_PUT_CARNIVAL_PHOTO_COMMENT_FEED =
      BASE_URL + 'carnivalPhotos/comment/';
  static const String API_PUT_CARNIVAL_GROUP_FEED =
      BASE_URL + 'carnivalFeeds/comment/';
}
