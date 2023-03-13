import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/delete_comment_model.dart';
import 'package:solomas/model/post_service_comment.dart';
import 'package:solomas/model/service_comment_response.dart';

import '../bloc.dart';

class ServiceCommentBloc extends Object implements Bloc {
  final _commentSubject = PublishSubject<ServiceCommentResponse>();

  final _addCommentSubject = PublishSubject<PostServiceCommentResponse>();

  final _deleteCommentSubject = PublishSubject<DeleteCommentModel>();

  var _apiHelper = ApiHelper();

  Stream<ServiceCommentResponse> get commentList => _commentSubject.stream;

  Future<dynamic> getServiceCommentList(
      String authToken, String serviceId) async {
    try {
      ServiceCommentResponse serviceCommentResponse =
      await _apiHelper.getServiceCommentList(authToken, serviceId);

      if (serviceCommentResponse.statusCode == 200) {
        _commentSubject.sink.add(serviceCommentResponse);
      } else {
        _commentSubject.sink.addError(serviceCommentResponse.data.toString());
      }
    } catch (error) {
      _commentSubject.sink.addError("Something Error");
    }
  }

  Future<dynamic> submitFeedComment(String authToken, String body) async {
    try {
      PostServiceCommentResponse addCommentModel =
      await _apiHelper.addServiceComment(authToken, body);

      if (addCommentModel.statusCode == 200) {
        _addCommentSubject.sink.add(addCommentModel);
      } else {
        _addCommentSubject.sink.addError(addCommentModel.data.toString());
      }
    } catch (error) {
      _addCommentSubject.sink.addError("Something Error");
    }
  }

  Future<bool> deleteService(String authToken, String commentId) async {
    try {
      DeleteCommentModel deleteCommentModel =
      await _apiHelper.deleteServiceComment(authToken, commentId);

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
    _addCommentSubject.close();

    _commentSubject.close();

    _deleteCommentSubject.close();


  }
}
