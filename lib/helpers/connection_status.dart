import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectionStatus {
  
  static final ConnectionStatus _singleton = ConnectionStatus.internal();
  
  ConnectionStatus.internal();
  
  static ConnectionStatus getInstance() => _singleton;
  
  bool hasConnection = false;
  
  Future<bool> isInternetAvailable() async {
   
    var connectivityResult = await (Connectivity().checkConnectivity());
    
    if (connectivityResult == ConnectivityResult.mobile) {
   
      return true;
   
    } else if (connectivityResult == ConnectivityResult.wifi) {
   
      return true;
    }
    
    return false;
  }
  
  StreamController connectionChangeController = StreamController.broadcast();
  
  final Connectivity _connectivity = Connectivity();
  
  void initialize() {
   
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    
    checkConnection();
  }
  
  Stream get connectionChange => connectionChangeController.stream;
  
  void dispose() {
   
    connectionChangeController.close();
  }
  
  void _connectionChange(ConnectivityResult result) {
    
    checkConnection();
  }
  
  Future<bool> checkConnection() async {
    
    bool previousConnection = hasConnection;
    
    try {
    
      final result = await InternetAddress.lookup('google.com');
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    
        hasConnection = true;
    
      } else {
    
        hasConnection = false;
      }
    
    } on SocketException catch (_) {
    
      hasConnection = false;
    }
    
    if (previousConnection != hasConnection) {
    
      connectionChangeController.add(hasConnection);
    }
    
    return hasConnection;
  }
}