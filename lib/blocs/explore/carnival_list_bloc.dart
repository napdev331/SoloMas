import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/carnival_continent_model.dart';
import 'package:solomas/model/carnival_list_model.dart';
import 'package:solomas/model/carnival_photos_list.dart';
import 'package:solomas/model/carnival_review_list.dart';
import 'package:solomas/model/check_in_carnival_model.dart';
import 'package:solomas/model/delete_public_feed_model.dart';
import 'package:solomas/model/feed_like_model.dart';
import 'package:solomas/model/un_like_public_feed.dart';

import '../bloc.dart';

class CarnivalListBloc extends Object implements Bloc {
  final _publicSubject = PublishSubject<CarnivalListModel>();

  final _checkInSubject = PublishSubject<CheckInCarnivalModel>();

  final _continentSubject = PublishSubject<ContinentsModel>();
  final _searchContinentSubject = PublishSubject<ContinentsModel>();

  final _carnivalPhotosSubject = PublishSubject<CarnivalPhotosList>();

  final _carnivalreviewSubject = PublishSubject<CarnivalsReviewList>();

  final _likeSubject = PublishSubject<FeedLikeModel>();

  final _unLikeSubject = PublishSubject<UnLikePublicFeedModel>();

  final _deleteEventSubject = PublishSubject<DeletePublicFeedModel>();

  var _apiHelper = ApiHelper();

  Stream<CarnivalListModel> get carnivalList => _publicSubject.stream;

  Stream<CheckInCarnivalModel> get checkInList => _checkInSubject.stream;

  Stream<ContinentsModel> get continentList => _continentSubject.stream;
  Stream<ContinentsModel> get searchContinentList =>
      _searchContinentSubject.stream;

  Stream<CarnivalPhotosList> get carnivalPhotosList =>
      _carnivalPhotosSubject.stream;

  Stream<CarnivalsReviewList> get carnivalReviewList =>
      _carnivalreviewSubject.stream;

  Future<dynamic> getCarnivalList(String authToken, String carnivalId,
      String distance, String continent) async {
    try {
      CarnivalListModel carnivalModel = await _apiHelper.getCarnivalsList(
          authToken, carnivalId, distance, continent);

      if (carnivalModel.statusCode == 200) {
        _publicSubject.sink.add(carnivalModel);
      } else {
        _publicSubject.sink.addError(carnivalModel.data.toString());
      }
    } catch (error) {
      _publicSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> checkInOnCarnival(String authToken, String reqBody) async {
    try {
      CheckInCarnivalModel checkInModel =
          await _apiHelper.checkInCarnival(reqBody, authToken);

      if (checkInModel.statusCode == 200) {
        _checkInSubject.sink.add(checkInModel);
      } else {
        _checkInSubject.sink.addError(checkInModel.data.toString());
      }
    } catch (error) {
      _checkInSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> getCarnivalsContinentList(String authToken) async {
    try {
      ContinentsModel continentsModel =
          await _apiHelper.getCarnivalsContinent(authToken);

      if (continentsModel.statusCode == 200) {
        _continentSubject.sink.add(continentsModel);
      } else {
        _continentSubject.sink.addError(continentsModel.data.toString());
      }
    } catch (error) {
      _continentSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> getCarnivalPhotos(String authToken, String carnivalId) async {
    try {
      CarnivalPhotosList carnivalPhotos =
          await _apiHelper.getCarnivalsPhotos(authToken, carnivalId);

      if (carnivalPhotos.statusCode == 200) {
        _carnivalPhotosSubject.sink.add(carnivalPhotos);
      } else {
        _carnivalPhotosSubject.sink.addError(carnivalPhotos.data.toString());
      }
    } catch (error) {
      _carnivalPhotosSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> getCarnivalReviews(
      String authToken, String carnivalId) async {
    try {
      CarnivalsReviewList carnivalReviewList =
          await _apiHelper.getReviewsList(authToken, carnivalId);

      if (carnivalReviewList.statusCode == 200) {
        _carnivalreviewSubject.sink.add(carnivalReviewList);
      } else {
        _carnivalreviewSubject.sink
            .addError(carnivalReviewList.data.toString());
      }
    } catch (error) {
      _carnivalreviewSubject.sink.addError("Something Error");
    }
  }

  Future<DeletePublicFeedModel> deleteCarnivalReview(
      String authToken, String eventId) async {
    try {
      DeletePublicFeedModel deleteCarnivalReview =
          await _apiHelper.deleteReview(authToken, eventId);

      if (deleteCarnivalReview.statusCode == 200) {
        return deleteCarnivalReview;
      } else {
        return deleteCarnivalReview;
      }
    } catch (error) {
      return "error" as DeletePublicFeedModel;
    }
  }

  Future<dynamic> carnivalPhotoLike(String body, String authToken) async {
    try {
      FeedLikeModel likeFeedModel =
          await _apiHelper.carnivalPhotoLike(body, authToken);

      if (likeFeedModel.statusCode == 200) {
        _likeSubject.sink.add(likeFeedModel);
      } else {
        _likeSubject.sink.addError(likeFeedModel.data.toString());
      }
    } catch (error) {
      _likeSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> carnivalPhotoUnLike(String body, String authToken) async {
    try {
      UnLikePublicFeedModel unLikeFeedModel =
          await _apiHelper.carnivalPhotoUnLike(body, authToken);

      if (unLikeFeedModel.statusCode == 200) {
        _unLikeSubject.sink.add(unLikeFeedModel);
      } else {
        _unLikeSubject.sink.addError(unLikeFeedModel.data.toString());
      }
    } catch (error) {
      _unLikeSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> deletePhoto(String authToken, String eventId) async {
    try {
      DeletePublicFeedModel deleteFeedModel =
          await _apiHelper.deleteCarnivalPhoto(authToken, eventId);

      if (deleteFeedModel.statusCode == 200) {
        _deleteEventSubject.sink.add(deleteFeedModel);
      } else {
        _deleteEventSubject.sink.addError(deleteFeedModel.data.toString());
      }
    } catch (error) {
      _deleteEventSubject.sink.addError("Something Error");
    }
  }

  @override
  void dispose() {
    _publicSubject.close();

    _checkInSubject.close();

    _continentSubject.close();

    _carnivalPhotosSubject.close();

    _carnivalreviewSubject.close();

    _likeSubject.close();

    _unLikeSubject.close();

    _deleteEventSubject.close();
  }
}
