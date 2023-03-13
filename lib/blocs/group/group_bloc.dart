import 'package:rxdart/rxdart.dart';
import 'package:solomas/blocs/bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/carnival_comment_list_model.dart';
import 'package:solomas/model/carnival_comment_model.dart';
import 'package:solomas/model/carnival_feed_like_list_model.dart';
import 'package:solomas/model/carnival_feed_like_model.dart';
import 'package:solomas/model/carnival_feed_un_like_model.dart';
import 'package:solomas/model/delete_comment_model.dart';
import 'package:solomas/model/dis_join_model.dart';
import 'package:solomas/model/get_groups_model.dart';
import 'package:solomas/model/group_feed_model.dart';
import 'package:solomas/model/join_group_model.dart';

class GroupBloc extends Object implements Bloc {
  
  final _publicSubject = PublishSubject<GetGroupsModel>();
  
  final _groupFeedSubject = PublishSubject<GroupFeedModel>();
  
  final _joinSubject = PublishSubject<JoinGroupModel>();
  
  final _disJoinSubject = PublishSubject<DisJoinGroupModel>();

  final _likeListSubject = PublishSubject<CarnivalLikeListModel>();

  final _commentListSubject = PublishSubject<CarnivalCommentListModel>();

  final _submitCommentSubject = PublishSubject<CarnivalCommentModel>();

  final _likeFeedSubject = PublishSubject<CarnivalFeedLikeModel>();

  final _unLikeFeedSubject = PublishSubject<CarnivalFeedUnLikeModel>();

  final _deleteCommentCarnivalSubject = PublishSubject<DeleteCommentModel>();

  var _apiHelper = ApiHelper();

  Stream<GetGroupsModel> get groupsList => _publicSubject.stream;

  Stream<GroupFeedModel> get groupsFeedList => _groupFeedSubject.stream;

  Stream<CarnivalLikeListModel> get carnivalLikeList => _likeListSubject.stream;

  Stream<CarnivalCommentListModel> get carnivalCommentList => _commentListSubject.stream;

  Stream<CarnivalCommentModel> get submitCarnivalComment => _submitCommentSubject.stream;

  Stream<CarnivalFeedLikeModel> get likeFeedObserver => _likeFeedSubject.stream;

  Stream<CarnivalFeedUnLikeModel> get unLikeFeedObserver => _unLikeFeedSubject.stream;

  Future<dynamic> getGroupList(String authToken, String groupId, String distance) async {
    
    try {
  
      GetGroupsModel messageModel = await _apiHelper.getGroups(authToken, groupId, distance);
      
      if (messageModel.statusCode == 200) {

        _publicSubject.sink.add(messageModel);
        
      } else {
        
        _publicSubject.sink.addError(messageModel.data.toString());
      }
      
    } catch (error) {
      
      _publicSubject.sink.addError("Something Error");
    }
  }
  
  Future<dynamic> getGroupFeedList(String authToken, String groupId) async {
    
    try {
  
      GroupFeedModel messageModel = await _apiHelper.getGroupFeed(authToken, groupId);
      
      if (messageModel.statusCode == 200) {
  
        _groupFeedSubject.sink.add(messageModel);
        
      } else {
  
        _groupFeedSubject.sink.addError(messageModel.data.toString());
      }
      
    } catch (error) {
  
      _groupFeedSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> joinGroup(String authToken, String reqBody) async {

    try {
  
      JoinGroupModel joinModel = await _apiHelper.joinGroup(authToken, reqBody);

      if (joinModel.statusCode == 200) {

        _joinSubject.sink.add(joinModel);

      } else {
  
        _joinSubject.sink.addError(joinModel.data.toString());
      }
    
    } catch (error) {
  
      _joinSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> disJoinGroup(String authToken, String reqBody) async {

    try {

      DisJoinGroupModel disJoinModel = await _apiHelper.disJoinGroup(authToken, reqBody);
    
      if (disJoinModel.statusCode == 200) {
  
        _disJoinSubject.sink.add(disJoinModel);
      
      } else {
  
        _disJoinSubject.sink.addError(disJoinModel.data.toString());
      }
    
    } catch (error) {
  
      _disJoinSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> getLikeList(String authToken, String feedId) async {
  
    try {
    
      CarnivalLikeListModel carnivalLikeModel = await _apiHelper.getCarnivalsLikeList(authToken, feedId);
    
      if (carnivalLikeModel.statusCode == 200) {
      
        _likeListSubject.sink.add(carnivalLikeModel);
      
      } else {
      
        _likeListSubject.sink.addError(carnivalLikeModel.data.toString());
      }
    
    } catch (error) {
    
      _likeListSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> getCommentList(String authToken, String feedId) async {
  
    try {
    
      CarnivalCommentListModel carnivalCommentModel =
      await _apiHelper.getCarnivalsCommentList(authToken, feedId);
    
      if (carnivalCommentModel.statusCode == 200) {
      
        _commentListSubject.sink.add(carnivalCommentModel);
      
      } else {
      
        _commentListSubject.sink.addError(carnivalCommentModel.data.toString());
      }
    
    } catch (error) {
    
      _commentListSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> submitCarnivalFeedComment(String authToken, String feedId) async {
  
    try {
    
      CarnivalCommentModel carnivalCommentModel = await _apiHelper.addCarnivalFeedComment(authToken, feedId);
    
      if (carnivalCommentModel.statusCode == 200) {
      
        _submitCommentSubject.sink.add(carnivalCommentModel);
      
      } else {
      
        _submitCommentSubject.sink.addError(carnivalCommentModel.data.toString());
      }
    
    } catch (error) {
    
      _submitCommentSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> likeFeed(String authToken, String reqBody) async {
  
    try {
    
      CarnivalFeedLikeModel carnivalFeedLike = await _apiHelper.carnivalFeedLike(authToken, reqBody);
    
      if (carnivalFeedLike.statusCode == 200) {
      
        _likeFeedSubject.sink.add(carnivalFeedLike);
      
      } else {
      
        _likeFeedSubject.sink.addError(carnivalFeedLike.data.toString());
      }
    
    } catch (error) {
    
      _likeFeedSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> unLikeFeed(String authToken, String reqBody) async {
  
    try {
    
      CarnivalFeedUnLikeModel carnivalFeedUnLike = await _apiHelper.carnivalFeedUnLike(authToken, reqBody);
    
      if (carnivalFeedUnLike.statusCode == 200) {
      
        _unLikeFeedSubject.sink.add(carnivalFeedUnLike);
      
      } else {
      
        _unLikeFeedSubject.sink.addError(carnivalFeedUnLike.data.toString());
      }
    
    } catch (error) {
    
      _unLikeFeedSubject.sink.addError("Something Error");
    }
  }

  Future<bool> deleteCommentCarnival(String authToken, String commentId) async {
    try {
      DeleteCommentModel deleteCommentModel =
      await _apiHelper.deleteCommentCarnival(authToken, commentId);

      if (deleteCommentModel.statusCode == 200) {
        _deleteCommentCarnivalSubject.sink.add(deleteCommentModel);
        return true;
      } else {
        _deleteCommentCarnivalSubject.sink.addError(deleteCommentModel.data.toString());
        return false;
      }
    } catch (error) {

      _deleteCommentCarnivalSubject.sink.addError("Something Error");
      return false;
    }
  }


  @override
  void dispose() {
  
    _publicSubject.close();
  
    _groupFeedSubject.close();
  
    _disJoinSubject.close();
    
    _joinSubject.close();

    _likeFeedSubject.close();

    _unLikeFeedSubject.close();

    _submitCommentSubject.close();

    _commentListSubject.close();

    _likeListSubject.close();

    _deleteCommentCarnivalSubject.close();
  }
}