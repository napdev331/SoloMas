import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/carnival_tiles_response.dart';
import 'package:solomas/model/create_event_response.dart';
import 'package:solomas/model/delete_public_feed_model.dart';
import 'package:solomas/model/events_continent_model.dart';
import 'package:solomas/model/events_members_response.dart';
import 'package:solomas/model/events_response.dart';
import 'package:solomas/model/feed_like_model.dart';
import 'package:solomas/model/get_events_category.dart';
import 'package:solomas/model/particular_event_detail.dart';
import 'package:solomas/model/un_like_public_feed.dart';
import 'package:solomas/model/update_event_response.dart';

import '../bloc.dart';

class EventBloc extends Object implements Bloc {
  var _apiHelper = ApiHelper();

  BehaviorSubject<CreateEventResponse> _createEventSubject =
      BehaviorSubject<CreateEventResponse>();
  BehaviorSubject<EventCategory> _eventCategorySubject =
      BehaviorSubject<EventCategory>();
  BehaviorSubject<UpdateEventResponse> _updateEventSubject =
      BehaviorSubject<UpdateEventResponse>();

  final eventContinentSubject = PublishSubject<EventsContinentModel>();

  final _likeSubject = PublishSubject<FeedLikeModel>();

  final _unLikeSubject = PublishSubject<UnLikePublicFeedModel>();

  final _eventSubject = PublishSubject<EventResponse>();

  final _deleteEventSubject = PublishSubject<DeletePublicFeedModel>();

  final _eventsMembersSubject = PublishSubject<EventsMemberResponse>();

  final _eventsEventSubject = PublishSubject<ParticularEventDetails>();

  Stream<EventCategory> get eventCategoryList => _eventCategorySubject.stream;

  Stream<EventResponse> get eventList => _eventSubject.stream;

  Stream<ParticularEventDetails> get eventDetail => _eventsEventSubject.stream;

  Stream<EventsContinentModel> get eventContinentList =>
      eventContinentSubject.stream;

  Future<CreateEventResponse> createEvent(
      String authToken, String reqBody) async {
    try {
      CreateEventResponse createEventResponse =
          await _apiHelper.createEvent(authToken, reqBody);

      if (createEventResponse.statusCode == 200) {
        _createEventSubject.sink.add(createEventResponse);
        return createEventResponse;
      } else {
        _createEventSubject.sink.addError(createEventResponse.data.toString());
        return createEventResponse;
      }
    } catch (error) {
      _createEventSubject.sink.addError("Something Error");
      return "" as CreateEventResponse;
    }
  }

  Future<EventCategory> getEventCategory(String authToken) async {
    try {
      EventCategory eventCategory =
          await _apiHelper.getEventCategory(authToken);

      if (eventCategory.statusCode == 200) {
        return eventCategory;
      } else {
        return eventCategory;
      }
    } catch (error) {
      return "" as EventCategory;
    }
  }

  Future<CarnivalTilesResponse> getEventCarnival(String authToken) async {
    try {
      CarnivalTilesResponse carnivalTilesResponse =
          await _apiHelper.getEventCarnival(authToken);

      if (carnivalTilesResponse.statusCode == 200) {
        return carnivalTilesResponse;
      } else {
        return carnivalTilesResponse;
      }
    } catch (error) {
      return "" as CarnivalTilesResponse;
    }
  }

  Future<dynamic> getEvent(
      String authToken, String text, String lat, String lng, String eventContinent) async {
    try {
      EventResponse eventsResponse =
          await _apiHelper.getEvent(authToken, text, lat, lng ,eventContinent);

      if (eventsResponse.statusCode == 200) {
        _eventSubject.sink.add(eventsResponse);
      } else {
        _eventSubject.sink.addError(eventsResponse.data.toString());
      }
    } catch (error) {
      _eventSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> getEventPrevious(
      String authToken, String text, String lat, String lng, String eventContinent) async {
    try {
      EventResponse eventsResponse =
          await _apiHelper.getEventPrevious(authToken, text, lat, lng,eventContinent);

      if (eventsResponse.statusCode == 200) {
        _eventSubject.sink.add(eventsResponse);
      } else {
        _eventSubject.sink.addError(eventsResponse.data.toString());
      }
    } catch (error) {
      _eventSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> deleteEvent(String authToken, String eventId) async {
    try {
      DeletePublicFeedModel deleteFeedModel =
          await _apiHelper.deleteEvent(authToken, eventId);

      if (deleteFeedModel.statusCode == 200) {
        _deleteEventSubject.sink.add(deleteFeedModel);
      } else {
        _deleteEventSubject.sink.addError(deleteFeedModel.data.toString());
      }
    } catch (error) {
      _deleteEventSubject.sink.addError("Something Error");
    }
  }

  Future<UpdateEventResponse> updateEvent(
      String authToken, String reqBody) async {
    try {
      UpdateEventResponse createEventResponse =
          await _apiHelper.updateEvent(authToken, reqBody);

      if (createEventResponse.statusCode == 200) {
        _updateEventSubject.sink.add(createEventResponse);
        return createEventResponse;
      } else {
        _updateEventSubject.sink.addError(createEventResponse.data.toString());
        return createEventResponse;
      }
    } catch (error) {
      _updateEventSubject.sink.addError("Something Error");
      return "" as UpdateEventResponse;
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

  Future<dynamic> getEventDetail(String authToken, String eventId) async {
    try {
      ParticularEventDetails particularEventDetails =
          await _apiHelper.getEventDetail(authToken, eventId);

      if (particularEventDetails.statusCode == 200) {
        _eventsEventSubject.sink.add(particularEventDetails);

        // return particularEventDetails;
      } else {
        _eventsEventSubject.sink.addError(particularEventDetails.data.toString());

        // return particularEventDetails;
      }
    } catch (error) {
      _eventsEventSubject.sink.addError("Something Error");

      //  return "" as ParticularEventDetails;
    }
  }

  Future<dynamic> getSearchedEvent(String authToken, String text) async {
    try {
      EventResponse eventsResponse =
          await _apiHelper.getSearchedEvent(authToken, text);

      if (eventsResponse.statusCode == 200) {
        _eventSubject.sink.add(eventsResponse);
      } else {
        _eventSubject.sink.addError(eventsResponse.data.toString());
      }
    } catch (error) {
      _eventSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> eventLike(String body, String authToken) async {
    try {
      FeedLikeModel likeFeedModel = await _apiHelper.eventLike(body, authToken);

      if (likeFeedModel.statusCode == 200) {
        _likeSubject.sink.add(likeFeedModel);
      } else {
        _likeSubject.sink.addError(likeFeedModel.data.toString());
      }
    } catch (error) {
      _likeSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> eventUnLike(String body, String authToken) async {
    try {
      UnLikePublicFeedModel unLikeFeedModel =
          await _apiHelper.eventUnLike(body, authToken);

      if (unLikeFeedModel.statusCode == 200) {
        _unLikeSubject.sink.add(unLikeFeedModel);
      } else {
        _unLikeSubject.sink.addError(unLikeFeedModel.data.toString());
      }
    } catch (error) {
      _unLikeSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> getEventsContinentList(String authToken) async {
    try {
      EventsContinentModel _eventsContinetResponse =
          await _apiHelper.getEventsContinent(authToken);

      if (_eventsContinetResponse.statusCode == 200) {
        eventContinentSubject.sink.add(_eventsContinetResponse);
      } else {
        eventContinentSubject.sink.addError(_eventsContinetResponse.data.toString());
      }
    } catch (error) {
      eventContinentSubject.sink.addError("Something Error");
    }
  }

  @override
  void dispose() {
    _eventsEventSubject.close();
    _createEventSubject.close();
    _eventCategorySubject.close();
    _updateEventSubject.close();
    _eventSubject.close();
    _deleteEventSubject.close();
    _eventsMembersSubject.close();
    _likeSubject.close();
    _unLikeSubject.close();
    _updateEventSubject.close();
    eventContinentSubject.close();
  }
}
