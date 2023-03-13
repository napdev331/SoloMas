import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/delete_public_feed_model.dart';
import 'package:solomas/model/feed_like_model.dart';
import 'package:solomas/model/public_feeds_model.dart';
import 'package:solomas/model/un_like_public_feed.dart';
import 'package:solomas/model/user_location_update_model.dart';

import '../bloc.dart';

class HomeBloc extends Object implements Bloc {
  BehaviorSubject<UserLocationUpdateModel> locationUpdateSubject =
      BehaviorSubject<UserLocationUpdateModel>();

  BehaviorSubject<UserLocationUpdateModel> get subject => locationUpdateSubject;

  double lat = 0.0, long = 0.0;
  Position? _currentLocation;

  final _publicSubject = PublishSubject<PublicFeedsModel>();

  final _likeSubject = PublishSubject<FeedLikeModel>();

  final _unLikeSubject = PublishSubject<UnLikePublicFeedModel>();

  final _deleteFeedSubject = PublishSubject<DeletePublicFeedModel>();

  var _apiHelper = ApiHelper();

  Stream<PublicFeedsModel> get publicFeedList => _publicSubject.stream;

  Stream<FeedLikeModel> get likeFeedList => _likeSubject.stream;

  Future<dynamic> getPublicFeeds(String authToken) async {
    try {
      PublicFeedsModel publicFeedsModel =
          await _apiHelper.getPublicFeeds(authToken);

      if (publicFeedsModel.statusCode == 200) {
        _publicSubject.sink.add(publicFeedsModel);
      } else {
        _publicSubject.sink.addError(publicFeedsModel.data.toString());
      }
    } catch (error) {
      print(error);
      _publicSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> likeFeed(String body, String authToken) async {
    try {
      FeedLikeModel likeFeedModel = await _apiHelper.feedLike(body, authToken);

      if (likeFeedModel.statusCode == 200) {
        _likeSubject.sink.add(likeFeedModel);
      } else {
        _likeSubject.sink.addError(likeFeedModel.data.toString());
      }
    } catch (error) {
      _likeSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> unLikeFeed(String body, String authToken) async {
    try {
      UnLikePublicFeedModel unLikeFeedModel =
          await _apiHelper.feedUnLike(body, authToken);

      if (unLikeFeedModel.statusCode == 200) {
        _unLikeSubject.sink.add(unLikeFeedModel);
      } else {
        _unLikeSubject.sink.addError(unLikeFeedModel.data.toString());
      }
    } catch (error) {
      _unLikeSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> deleteFeed(String authToken, String publicFeedId) async {
    try {
      DeletePublicFeedModel deleteFeedModel =
          await _apiHelper.deletePublicFeed(authToken, publicFeedId);

      if (deleteFeedModel.statusCode == 200) {
        _deleteFeedSubject.sink.add(deleteFeedModel);
      } else {
        _deleteFeedSubject.sink.addError(deleteFeedModel.data.toString());
      }
    } catch (error) {
      _deleteFeedSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> updateLocation(String authToken) async {
    try {
      UserLocationUpdateModel response = await _apiHelper.updateLocation(
          json.encode({
            'currentLocation': {'lat': lat.toString(), 'lng': long.toString()},
          }),
          authToken);
      if (response.statusCode == 200) {
        locationUpdateSubject.sink.add(response);
      } else {
        return Future.error(response.data.toString());
      }
    } catch (e) {
      return Future.error("Something Error");
    }
  }

  Future<bool> getCurrentLocation(String authToken) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentLocation = position;

    lat = position.latitude;
    long = position.longitude;
    if (lat != null && long != null) {
      updateLocation(authToken);
    } else {
      print("lat and long are null");
    }
    return true;
  }

  @override
  void dispose() {
    _deleteFeedSubject.close();

    _likeSubject.close();

    _publicSubject.close();

    _unLikeSubject.close();

    locationUpdateSubject.close();
  }
}
