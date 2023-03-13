import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/events_like_model.dart';
import 'package:solomas/model/feed_like_list_model.dart';
import 'package:solomas/model/service_like_list_model.dart';

import '../bloc.dart';

class EventsLikeListBloc extends Object implements Bloc {
  
  final _likeSubject = PublishSubject<EventsLikeModel>();
  
  var _apiHelper = ApiHelper();

  Stream<EventsLikeModel> get likeFeedList => _likeSubject.stream;
  
  Future<dynamic> eventsLike(String authToken, String publicFeedId) async {
    
    try {

      EventsLikeModel likeFeedModel = await _apiHelper.getEventLikeList(authToken, publicFeedId);
      
      if (likeFeedModel.statusCode == 200) {
    
        _likeSubject.sink.add(likeFeedModel);
    
      } else {
    
        _likeSubject.sink.addError(likeFeedModel.data.toString());
      }
    
    } catch (error) {

      _likeSubject.sink.addError("Something Error");
    }
  }
  
  @override
  void dispose() {
    
    _likeSubject.close();
  }
}