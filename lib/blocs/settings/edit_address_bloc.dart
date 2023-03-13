import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:solomas/blocs/bloc.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/update_user_data_model.dart';

class EditAddressBloc extends Object  with SignUpValidator implements Bloc {

  final _publicSubject = PublishSubject<UpdateUserModel>();

  var _apiHelper = ApiHelper();

  Stream<UpdateUserModel> get userProfileList => _publicSubject.stream;

  final _nameController = BehaviorSubject<String>();

  final _addressController = BehaviorSubject<String>();

  final _stateController = BehaviorSubject<String>();

  final _cityController = BehaviorSubject<String>();

  final _emailController = BehaviorSubject<String>();

  final _phoneController = BehaviorSubject<String>();

  Function(String) get nameChanged => _nameController.sink.add;

  Function(String) get emailChanged => _emailController.sink.add;

  Function(String) get phoneChanged => _phoneController.sink.add;

  Function(String) get addressChanged => _addressController.sink.add;

  Function(String) get stateChanged => _stateController.sink.add;

  Function(String) get cityChanged => _cityController.sink.add;

  Stream <String> get nameStream =>
    _nameController.stream.transform(_nameValidator);

  Stream <String> get emailStream =>
    _emailController.stream.transform(_emailValidator);

  Stream <String> get phoneStream =>
    _phoneController.stream.transform(_mobileValidator);

  Stream <String> get streetStream =>
    _addressController.stream.transform(_streetValidator);

  Stream <String> get stateStream =>
    _stateController.stream.transform(_stateValidator);

  Stream <String> get cityStream =>
    _cityController.stream.transform(_cityValidator);

  Stream<bool> get saveCheck =>
    Rx.combineLatest6(
      nameStream, emailStream, phoneStream, streetStream, stateStream, cityStream,
        (name, email, phone, address, state, city) => true);

  Future<dynamic> updatePickUpAddress(String authToken, String id) async {

    try {

      UpdateUserModel profileModel = await _apiHelper.updateUserData(id, authToken);

      if (profileModel.statusCode == 200) {

        _publicSubject.sink.add(profileModel);

      } else {

        return Future.error(profileModel.data.toString());
      }

    } catch (error) {

      return Future.error("Something Error");
    }
  }

  @override
  void dispose() {

    _nameController.close();

    _emailController.close();

    _phoneController.close();

    _addressController.close();

    _stateController.close();

    _cityController.close();

    _publicSubject.close();
  }
}

mixin SignUpValidator {

  var _nameValidator = StreamTransformer<String, String>.fromHandlers(

    handleData: (name, sink) {

      if (name.toString().length >= 2) {

        sink.add(name);

      } else if(name.toString().length < 2) {

        sink.addError('Full name must be atleast two character long');

      } else {

        sink.addError('Please enter a valid name');
      }
    }
  );

  var _emailValidator = StreamTransformer<String, String>.fromHandlers(

    handleData: (email, sink) {

      if (RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(email)) {

        sink.add(email);

      } else {

        sink.addError('Please enter a valid email.');
      }
    }
  );

  var _mobileValidator = StreamTransformer<String, String>.fromHandlers(

    handleData: (mobile, sink) {

      if (mobile.toString().length >= 10) {

        sink.add(mobile);

      } else {

        sink.addError('The phone number must be at least 10 character long.');
      }
    }
  );

  var _streetValidator = StreamTransformer<String, String>.fromHandlers(

    handleData: (street, sink) {

      if(street.toString().isEmpty) {

        sink.addError('Please enter a valid street');

      } else if(street.toString().length < 4) {

        sink.addError('Street must be at least four character long');

      } else if (street.toString().length >= 4) {

        sink.add(street);
      }
    }
  );

  var _stateValidator = StreamTransformer<String, String>.fromHandlers(

    handleData: (state, sink) {

      if(state.toString().isEmpty) {

        sink.addError('Please enter a valid state name');

      }  else if(state.toString().length < 4) {

        sink.addError('State Name must be at least four character long');

      } else {

        sink.add(state);
      }
    }
  );

  var _cityValidator = StreamTransformer<String, String>.fromHandlers(

    handleData: (city, sink) {

      if(city.toString().isEmpty) {

        sink.addError('Please enter a valid city name');

      } else if(city.toString().length < 4) {

        sink.addError('City must be at least four character long');

      } else {

        sink.add(city);
      }
    }
  );
}