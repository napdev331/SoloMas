import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/feed_like_list_model.dart';

import '../bloc.dart';

class FeedLikeListBloc extends Object implements Bloc {
  
  final _likeSubject = PublishSubject<FeedLikeListModel>();
  
  var _apiHelper = ApiHelper();

  Stream<FeedLikeListModel> get likeFeedList => _likeSubject.stream;
  
  Future<dynamic> likeFeed(String authToken, String publicFeedId) async {
    
    try {
  
      FeedLikeListModel likeFeedModel = await _apiHelper.getPublicFeedsLikeList(authToken, publicFeedId);
      
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