import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/delete_comment_model.dart';
import 'package:solomas/model/events_comment_response.dart';
import 'package:solomas/model/events_members_response.dart';
import 'package:solomas/model/feed_comment_model.dart';
import 'package:solomas/model/particular_event_detail.dart';

import '../bloc.dart';

class EventCommentListBloc extends Object implements Bloc {
  final _commentSubject = PublishSubject<EventCommentResponse>();

  final _addCommentSubject = PublishSubject<FeedCommentModel>();

  final _deleteCommentSubject = PublishSubject<DeleteCommentModel>();
  final _eventsMembersSubject = PublishSubject<EventsMemberResponse>();
  final _eventsEventSubject = PublishSubject<ParticularEventDetails>();


  var _apiHelper = ApiHelper();

  Stream<EventCommentResponse> get commentFeedList => _commentSubject.stream;

  Stream<ParticularEventDetails> get eventDetail => _eventsEventSubject.stream;


  Future<dynamic> getEventCommentList(
      String authToken, String publicFeedId) async {
    try {
      EventCommentResponse feedCommentsModel =
          await _apiHelper.getEventCommentList(authToken, publicFeedId);

      if (feedCommentsModel.statusCode == 200) {
        print("commentData2");
        _commentSubject.sink.add(feedCommentsModel);
      } else {
        print("commentData3");
        _commentSubject.sink.addError(feedCommentsModel.data.toString());
      }
    } catch (error) {
      print("commentData4");
      _commentSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> submitFeedComment(String authToken, String body) async {
    try {
      FeedCommentModel addCommentFeedModel =
          await _apiHelper.addEventComment(authToken, body);

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
          await _apiHelper.deleteEventComment(authToken, commentId);

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

  Future<EventsMemberResponse> getEventMembersList(
      String authToken, String eventId) async {
    try {
      EventsMemberResponse eventMembersList =
      await _apiHelper.getEventMembersList(authToken, eventId);

      if (eventMembersList.statusCode == 200) {
        //_eventsMembersSubject.sink.add(eventMembersList);
        return eventMembersList;
      } else {
        // _eventsMembersSubject.sink.addError(eventMembersList.data);
        return eventMembersList;
      }
    } catch (error) {
      //_eventsMembersSubject.sink.addError("Something Error");
      return "" as EventsMemberResponse;
    }
  }

  Future<ParticularEventDetails?> getEventDetail(
      String authToken, String eventId) async {
    try {
      ParticularEventDetails particularEventDetails =
      await _apiHelper.getEventDetail(authToken, eventId);

      if (particularEventDetails.statusCode == 200) {
        _eventsEventSubject.sink.add(particularEventDetails);

        // return particularEventDetails;
      } else {
        _eventsEventSubject.sink.addError(particularEventDetails.data.toString());

         //return particularEventDetails;
      }
    } catch (error) {
      _eventsEventSubject.sink.addError("Something Error");

        //return "" as ParticularEventDetails;
    }
    return null;
  }






  @override
  void dispose() {
    _addCommentSubject.close();

    _commentSubject.close();

    _deleteCommentSubject.close();

    _eventsMembersSubject.close();

    _eventsEventSubject.close();

  }
}
