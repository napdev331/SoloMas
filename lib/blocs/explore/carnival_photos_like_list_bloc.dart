import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/blog_comment_blog.dart';
import 'package:solomas/model/carnival_comment_model.dart';
import 'package:solomas/model/carnival_comment_photos.dart';
import 'package:solomas/model/carnival_photos_like_listing.dart';
import 'package:solomas/model/carnival_photos_post_comment.dart';
import 'package:solomas/model/delete_comment_model.dart';
import 'package:solomas/model/feed_like_list_model.dart';
import 'package:solomas/model/post_service_comment.dart';
import 'package:solomas/model/service_like_list_model.dart';

import '../bloc.dart';

class CarnivalPhotosLikeBloc extends Object implements Bloc {
  
  final _likeSubject = PublishSubject<CarnivalPhotosLikeModel>();
  
  var _apiHelper = ApiHelper();

  final _commentSubject = PublishSubject<CarnivalCommentPhotosModel>();

  final _addCommentSubject = PublishSubject<CarnivalPostCommentModel>();

  final _deleteCommentSubject = PublishSubject<DeleteCommentModel>();

  Stream<CarnivalPhotosLikeModel> get likeFeedList => _likeSubject.stream;

  Stream<CarnivalCommentPhotosModel> get commentList => _commentSubject.stream;


  Future<dynamic> carnivalPhotoLike(String authToken, String publicFeedId) async {
    
    try {

      CarnivalPhotosLikeModel likeFeedModel = await _apiHelper.getCarnivalPhotosLikeList(authToken, publicFeedId);
      
      if (likeFeedModel.statusCode == 200) {
    
        _likeSubject.sink.add(likeFeedModel);
    
      } else {
    
        _likeSubject.sink.addError(likeFeedModel.data.toString());
      }
    
    } catch (error) {

      _likeSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> getPhotosCommentList(String authToken, String carnivalPhotoId) async {
    try {
      CarnivalCommentPhotosModel carnivalCommentModel =
      await _apiHelper.getCarnivalCommentList(authToken, carnivalPhotoId);

      if (carnivalCommentModel.statusCode == 200) {
        _commentSubject.sink.add(carnivalCommentModel);
      } else {
        _commentSubject.sink.addError(carnivalCommentModel.data.toString());
      }
    } catch (error) {
      _commentSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> submitPhotoComment(String authToken, String body) async {
    try {
      CarnivalPostCommentModel addCommentModel =
      await _apiHelper.addCarnivalCommentComment(authToken, body);

      if (addCommentModel.statusCode == 200) {
        _addCommentSubject.sink.add(addCommentModel);
      } else {
        _addCommentSubject.sink.addError(addCommentModel.data.toString());
      }
    } catch (error) {
      _addCommentSubject.sink.addError("Something Error");
    }
  }

  Future<bool> deletePhotoComment(String authToken, String commentId) async {
    try {
      DeleteCommentModel deleteCommentModel =
      await _apiHelper.deletePhotoComment(authToken, commentId);

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
    
    _likeSubject.close();

    _commentSubject.close();

    _addCommentSubject.close();

    _deleteCommentSubject.close();
  }
}