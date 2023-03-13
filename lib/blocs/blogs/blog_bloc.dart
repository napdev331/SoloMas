import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/blog_list_model.dart';
import 'package:solomas/model/feed_like_model.dart';
import 'package:solomas/model/share_blog_response.dart';
import 'package:solomas/model/un_like_public_feed.dart';
import '../bloc.dart';

class BlogBLoc extends Object implements Bloc {
  var _apiHelper = ApiHelper();

  final _blogSubject = PublishSubject<BlogListResponse>();
  final _shareCount = PublishSubject<ShareBlogResponse>();
  final _likeSubject = PublishSubject<FeedLikeModel>();

  final _unLikeSubject = PublishSubject<UnLikePublicFeedModel>();

  Stream<FeedLikeModel> get likeFeedList => _likeSubject.stream;

  Stream<BlogListResponse> get blocList => _blogSubject.stream;

  Future<dynamic> getBlog(String authToken) async {
    try {
      BlogListResponse blogResponse = await _apiHelper.getBlog(authToken);

      if (blogResponse.statusCode == 200) {
        _blogSubject.sink.add(blogResponse);
        return Future.value(blogResponse);
      } else {
        _blogSubject.sink.addError(blogResponse.data.toString());
        return Future.error(blogResponse.data.toString());
      }
    } catch (error) {
      _blogSubject.sink.addError("Something Error");
      return Future.error("Something Error");
    }
  }

  Future<ShareBlogResponse?> shareBlog(String authToken, String reqBody) async {
    try {
      ShareBlogResponse shareBlogResponse =
          await _apiHelper.shareCount(authToken, reqBody);

      if (shareBlogResponse.statusCode == 200) {
        _shareCount.sink.add(shareBlogResponse);
      } else {
        _shareCount.sink.addError(shareBlogResponse.data.toString());
      }
    } catch (error) {
      _shareCount.sink.addError("Something Error");
    }
    return null;
  }

  Future<dynamic> blogLike(String body, String authToken) async {
    try {
      FeedLikeModel likeFeedModel = await _apiHelper.blogLike(body, authToken);

      if (likeFeedModel.statusCode == 200) {
        _likeSubject.sink.add(likeFeedModel);
      } else {
        _likeSubject.sink.addError(likeFeedModel.data.toString());
      }
    } catch (error) {
      _likeSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> blogUnLike(String body, String authToken) async {
    try {
      UnLikePublicFeedModel unLikeFeedModel =
          await _apiHelper.blogUnLike(body, authToken);

      if (unLikeFeedModel.statusCode == 200) {
        _unLikeSubject.sink.add(unLikeFeedModel);
      } else {
        _unLikeSubject.sink.addError(unLikeFeedModel.data.toString());
      }
    } catch (error) {
      _unLikeSubject.sink.addError("Something Error");
    }
  }

  @override
  void dispose() {
    _blogSubject.close();
    _likeSubject.close();
    _shareCount.close();
    _unLikeSubject.close();
  }
}
