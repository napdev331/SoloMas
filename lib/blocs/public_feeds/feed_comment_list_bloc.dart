import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/delete_comment_model.dart';
import 'package:solomas/model/feed_comment_list_model.dart';
import 'package:solomas/model/feed_comment_model.dart';

import '../bloc.dart';

class FeedCommentListBloc extends Object implements Bloc {
  final _commentSubject = PublishSubject<FeedCommentListModel>();

  final _addCommentSubject = PublishSubject<FeedCommentModel>();

  final _deleteCommentSubject = PublishSubject<DeleteCommentModel>();

  var _apiHelper = ApiHelper();

  Stream<FeedCommentListModel> get commentFeedList => _commentSubject.stream;

  Future<dynamic> getPublicFeedCommentList(String authToken, String publicFeedId) async {
    try {
      FeedCommentListModel feedCommentsModel =
          await _apiHelper.getPublicFeedsCommentList(authToken, publicFeedId);

      if (feedCommentsModel.statusCode == 200) {
        _commentSubject.sink.add(feedCommentsModel);
      } else {
        _commentSubject.sink.addError(feedCommentsModel.data.toString());
      }
    } catch (error) {
      _commentSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> submitFeedComment(String authToken, String body) async {
    try {
      FeedCommentModel addCommentFeedModel =
          await _apiHelper.addPublicFeedComment(authToken, body);

      if (addCommentFeedModel.statusCode == 200) {
        _addCommentSubject.sink.add(addCommentFeedModel);
      } else {
        _addCommentSubject.sink.addError(addCommentFeedModel.data.toString());
      }
    } catch (error) {
      _addCommentSubject.sink.addError("Something Error");
    }
  }

  Future<bool> deleteComment(String authToken, String commentId) async {
    try {
      DeleteCommentModel deleteCommentModel =
          await _apiHelper.deleteComment(authToken, commentId);

      if (deleteCommentModel.statusCode == 200) {
        _deleteCommentSubject.sink.add(deleteCommentModel);
        return true;
      } else {
        _deleteCommentSubject.sink.addError(deleteCommentModel.data.toString());
        return false;
      }
    } catch (error) {
      _deleteCommentSubject.sink.addError("Something Error");
      return false;
    }
  }

  @override
  void dispose() {
    _addCommentSubject.close();

    _commentSubject.close();

    _deleteCommentSubject.close();
  }
}
