import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/notification_list_model.dart';

import '../bloc.dart';

class NotificationBloc extends Bloc {
  
  final _publicSubject = PublishSubject<NotificationListModel>();
  
  var _apiHelper = ApiHelper();

  Stream<NotificationListModel> get notificationList => _publicSubject.stream;
  
  Future<dynamic> getNotification(String authToken) async {
    
    try {
  
      NotificationListModel peopleModel = await _apiHelper.getNotificationList(authToken);
      
      if (peopleModel.statusCode == 200) {
        
        _publicSubject.sink.add(peopleModel);
        
      } else {
        
        _publicSubject.sink.addError(peopleModel.data.toString());
      }
      
    } catch (error) {
      
      _publicSubject.sink.addError("Something Error");
    }
  }
  
  @override
  void dispose() {
    
    _publicSubject.close();
  }
}