import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/create_review_event.dart';
import 'package:solomas/model/delete_review.dart';
import 'package:solomas/model/event_review_response.dart';
import 'package:solomas/model/update_event_response.dart';

import '../bloc.dart';

class EventReviewBloc extends Object implements Bloc {
  final _reviewSubject = PublishSubject<ReviewResponse>();
  final _addReviewSubject = PublishSubject<CreatReviewEvent>();
  final _deleteEventReviewSubject = PublishSubject<DeleteReviewEvent>();
  final _updateEventReviewSubject = PublishSubject<UpdateEventResponse>();




  var _apiHelper = ApiHelper();

  Stream<ReviewResponse> get reviewList => _reviewSubject.stream;



  Future<dynamic> getEventReviewList(
      String authToken, String publicFeedId) async {
    try {
      ReviewResponse reviewResponse =
      await _apiHelper.getEventReviewList(authToken, publicFeedId);

      if (reviewResponse.statusCode == 200) {
        _reviewSubject.sink.add(reviewResponse);
      } else {
        _reviewSubject.sink.addError(reviewResponse.data.toString());
      }
    } catch (error) {
      _reviewSubject.sink.addError("Something Error");
    }
  }



  Future<CreatReviewEvent> submitFeedReview(String authToken, String body) async {
    try {
      CreatReviewEvent addReviewModel =
      await _apiHelper.addEventReview(authToken, body);

      if (addReviewModel.statusCode == 200) {
        _addReviewSubject.sink.add(addReviewModel);
        return addReviewModel;
      } else {
        _addReviewSubject.sink.addError(addReviewModel.data.toString());
        return addReviewModel;

      }
    } catch (error) {
      _addReviewSubject.sink.addError("Something Error");
      return "Something Error" as CreatReviewEvent ;

    }
  }


  Future<DeleteReviewEvent> deleteEventReview(String authToken, String eventId) async {
    try {
      DeleteReviewEvent deleteFeedModel =
      await _apiHelper.deleteEventReview( authToken,eventId);

      if (deleteFeedModel.statusCode == 200) {
        _deleteEventReviewSubject.sink.add(deleteFeedModel);
        return deleteFeedModel;
      } else {
        _deleteEventReviewSubject.sink.addError(deleteFeedModel.data.toString());
        return deleteFeedModel;

      }
    } catch (error) {
      _deleteEventReviewSubject.sink.addError("Something Error");
      return "" as DeleteReviewEvent ;
    }
  }


  Future<UpdateEventResponse> updateEventReview(
      String authToken, String reqBody) async {
    try {
      UpdateEventResponse updateReviewResponse =
      await _apiHelper.updateReview(authToken, reqBody);

      if (updateReviewResponse.statusCode == 200) {
        _updateEventReviewSubject.sink.add(updateReviewResponse);
        return updateReviewResponse;
      } else {
        _updateEventReviewSubject.sink.addError(updateReviewResponse.data.toString());
        return updateReviewResponse;
      }
    } catch (error) {
      _updateEventReviewSubject.sink.addError("Something Error");
      return "" as UpdateEventResponse;
    }
  }
  @override
  void dispose() {
    _reviewSubject.close();
    _addReviewSubject.close();
    _deleteEventReviewSubject.close();
    _updateEventReviewSubject.close();


  }
}
