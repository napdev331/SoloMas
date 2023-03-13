import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/get_people_model.dart';

import '../bloc.dart';

class GetNearbyPeoplesBloc extends Object implements Bloc {
  
  final _publicSubject = PublishSubject<GetPeoplesModel>();
  
  var _apiHelper = ApiHelper();

  Stream<GetPeoplesModel> get peopleList => _publicSubject.stream;
  
  Future<dynamic> getPeoplesList(String authToken, double latitude, double longitude, String distance) async {
    
    try {
  
      GetPeoplesModel peopleModel = await _apiHelper.getNearByPeoples(authToken, latitude, longitude, distance);
      
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