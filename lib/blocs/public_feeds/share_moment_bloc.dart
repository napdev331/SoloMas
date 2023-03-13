import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:solomas/helpers/api_helper.dart';
import 'package:solomas/model/login_model.dart';

import '../bloc.dart';

class ShareMomentBloc extends Object with ShareMomentValidators implements Bloc {

  BehaviorSubject<LoginModel> _subject = BehaviorSubject<LoginModel>();

  final _titleController = BehaviorSubject<String>();

  final _descriptionController = BehaviorSubject<String>();

  var _apiHelper = ApiHelper();

  Function(String) get titleChanged => _titleController.sink.add;

  Function(String) get descriptionChanged => _descriptionController.sink.add;

  Stream <String> get titleStream =>
      _titleController.stream.transform(_titleValidator);

  Stream <String> get descriptionStream =>
      _descriptionController.stream.transform(_descriptionValidator);

  Stream<bool> get signInCheck =>
      Rx.combineLatest2(
          titleStream, descriptionStream, (email, password) => true);

  BehaviorSubject<LoginModel> get subject => _subject;

  Future<dynamic> loginWithEmail(String body) async {

    try {

      LoginModel response = await _apiHelper.login(body);

      if(response.statusCode == 200) {

        _subject.sink.add(response);

      } else {

        return Future.error(response.data.toString());
      }

    } catch (error) {

      return Future.error("Something Error");
    }
  }

  @override
  void dispose() {

    _subject.close();

    _titleController.close();

    _descriptionController.close();
  }
}

mixin ShareMomentValidators {

  var _titleValidator = StreamTransformer<String, String>.fromHandlers(

      handleData: (title, sink) {

        if (title.toString().length >= 40) {

          sink.add(title);

        } else {

          sink.addError('Please enter at lease 40 characters long description');
        }
      }
  );

  var _descriptionValidator = StreamTransformer<String, String>.fromHandlers(

      handleData: (description, sink) {

        if (description.toString().length >= 100) {

          sink.add(description);

        } else {

          sink.addError('Please enter at lease 100 characters long description');
        }
      }
  );
}