import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/create_service_response.dart';
import 'package:solomas/model/delete_public_feed_model.dart';
import 'package:solomas/model/feed_like_model.dart';
import 'package:solomas/model/service_category_response.dart';
import 'package:solomas/model/service_list_response.dart';
import 'package:solomas/model/services_continent_model.dart';
import 'package:solomas/model/un_like_public_feed.dart';

import '../bloc.dart';

class ServicesBloc extends Object implements Bloc {
  var _apiHelper = ApiHelper();

  BehaviorSubject<CreateServiceResponse> _createServiceSubject =
  BehaviorSubject<CreateServiceResponse>();
  BehaviorSubject<CreateServiceResponse> _updateServiceSubject =
  BehaviorSubject<CreateServiceResponse>();

  BehaviorSubject<ServiceCategoryResponse> _serviceCategorySubject =
  BehaviorSubject<ServiceCategoryResponse>();

  final _likeSubject = PublishSubject<FeedLikeModel>();

  final _unLikeSubject = PublishSubject<UnLikePublicFeedModel>();

  final serviceContinentSubject = PublishSubject<ServicesContinentModel>();


  Stream<ServiceCategoryResponse> get serviceCategoryList => _serviceCategorySubject.stream;

  final _serviceSubject = PublishSubject<ServiceListResponse>();

  Stream<ServiceListResponse> get serviceList => _serviceSubject.stream;
  final _deleteServiceSubject = PublishSubject<DeletePublicFeedModel>();

  final _serviceParticularSubject = PublishSubject<ServiceListResponse>();


  Stream<ServiceListResponse> get serviceDetail => _serviceParticularSubject.stream;

  Stream<FeedLikeModel> get likeFeedList => _likeSubject.stream;

  Stream<ServicesContinentModel> get serviceContinentList =>
      serviceContinentSubject.stream;


  Future<dynamic> getService(String authToken, String text,String lat,String lng, String serviceContinent, String service) async {
    try {
      ServiceListResponse serviceListResponse = await _apiHelper.getService(authToken,text,lat,lng,serviceContinent,service);

      if (serviceListResponse.statusCode == 200) {
        _serviceSubject.sink.add(serviceListResponse);
      } else {
        _serviceSubject.sink.addError(serviceListResponse.data.toString());
      }
    } catch (error) {
      _serviceSubject.sink.addError("Something Error");
    }
  }

  Future<CreateServiceResponse> createService(
      String authToken, String reqBody) async {
    try {
      CreateServiceResponse createServiceResponse =
      await _apiHelper.createService(authToken, reqBody);

      if (createServiceResponse.statusCode == 200) {
        _createServiceSubject.sink.add(createServiceResponse);
        return createServiceResponse;
      } else {
        _createServiceSubject.sink.addError(createServiceResponse.data.toString());
        return createServiceResponse;
      }
    } catch (error) {
      _createServiceSubject.sink.addError("Something Error");
      return "" as CreateServiceResponse;
    }
  }

  Future<CreateServiceResponse> updateService(
      String authToken, String reqBody) async {
    try {
      CreateServiceResponse updateServiceResponse =
      await _apiHelper.updateService(authToken, reqBody);

      if (updateServiceResponse.statusCode == 200) {
        _updateServiceSubject.sink.add(updateServiceResponse);
        return updateServiceResponse;
      } else {
        _updateServiceSubject.sink.addError(updateServiceResponse.data.toString());
        return updateServiceResponse;
      }
    } catch (error) {
      _updateServiceSubject.sink.addError("Something Error");
      return "" as CreateServiceResponse;
    }
  }

  Future<ServiceCategoryResponse> getServiceCategory(String authToken) async {
    try {
      ServiceCategoryResponse serviceCategoryResponse =
      await _apiHelper.getServiceCategory(authToken);

      if (serviceCategoryResponse.statusCode == 200) {
        return serviceCategoryResponse;
      } else {
        return serviceCategoryResponse;
      }
    } catch (error) {
      _serviceCategorySubject.sink.addError("Something Error");
      return "" as ServiceCategoryResponse;
    }
  }

  Future<dynamic> getSearchedSearch(String authToken, String text) async {
    try {
      ServiceListResponse serviceResponse = await _apiHelper.getSearchedService(authToken,text);

      if (serviceResponse.statusCode == 200) {
        _serviceSubject.sink.add(serviceResponse);
      } else {
        _serviceSubject.sink.addError(serviceResponse.data.toString());
      }
    } catch (error) {
      _serviceSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> deleteService(String authToken, String eventId) async {
    try {
      DeletePublicFeedModel deleteFeedModel =
      await _apiHelper.deleteService(authToken, eventId);

      if (deleteFeedModel.statusCode == 200) {
        _deleteServiceSubject.sink.add(deleteFeedModel);
      } else {
        _deleteServiceSubject.sink.addError(deleteFeedModel.data.toString());
      }
    } catch (error) {
      _deleteServiceSubject.sink.addError("Something Error");
    }
  }

  Future<ServiceListResponse> getServiceDetail(
      String authToken, String eventId) async {
    try {
      ServiceListResponse particularEventDetails =
      await _apiHelper.getServiceDetail(authToken, eventId);

      if (particularEventDetails.statusCode == 200) {
        _serviceParticularSubject.sink.add(particularEventDetails);

        return particularEventDetails;
      } else {
        _serviceParticularSubject.sink.addError(particularEventDetails.data.toString());

        return particularEventDetails;
      }
    } catch (error) {
      _serviceParticularSubject.sink.addError("Something Error");

      return "" as ServiceListResponse;
    }
  }

  Future<dynamic> serviceLike(String body, String authToken) async {

    try {

      FeedLikeModel likeFeedModel = await _apiHelper.serviceLike(body, authToken);

      if (likeFeedModel.statusCode == 200) {

        _likeSubject.sink.add(likeFeedModel);

      } else {

        _likeSubject.sink.addError(likeFeedModel.data.toString());
      }

    } catch (error) {

      _likeSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> serviceUnLike(String body, String authToken) async {

    try {

      UnLikePublicFeedModel unLikeFeedModel = await _apiHelper.servcieUnLike(body, authToken);

      if (unLikeFeedModel.statusCode == 200) {

        _unLikeSubject.sink.add(unLikeFeedModel);

      } else {

        _unLikeSubject.sink.addError(unLikeFeedModel.data.toString());
      }

    } catch (error) {

      _unLikeSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> getServiceContinentList(String authToken) async {
    try {
      ServicesContinentModel _serviceContinentResponse =
      await _apiHelper.getServicesContinent(authToken);

      if (_serviceContinentResponse.statusCode == 200) {
        serviceContinentSubject.sink.add(_serviceContinentResponse);
      } else {
        serviceContinentSubject.sink.addError(_serviceContinentResponse.data.toString());
      }
    } catch (error) {
      serviceContinentSubject.sink.addError("Something Error");
    }
  }


  @override
  void dispose() {
    _createServiceSubject.close();
    _updateServiceSubject.close();
    _serviceCategorySubject.close();
    _serviceSubject.close();
    _deleteServiceSubject.close();
    _serviceParticularSubject.close();
    _likeSubject.close();
    _unLikeSubject.close();
    serviceContinentSubject.close();

  }
}