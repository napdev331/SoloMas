import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/messages_model.dart';

import '../bloc.dart';

class MessagesBloc extends Object implements Bloc {
  
  final _publicSubject = PublishSubject<MessagesModel>();
  
  var _apiHelper = ApiHelper();

  Stream<MessagesModel> get messagesList => _publicSubject.stream;
  
  Future<dynamic> getMessagesList(String authToken) async {
    
    try {
  
      MessagesModel messageModel = await _apiHelper.getMessagesList(authToken);
      
      if (messageModel.statusCode == 200) {

        _publicSubject.sink.add(messageModel);

      } else {

        _publicSubject.sink.addError(messageModel.data.toString());
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