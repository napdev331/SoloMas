import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:solomas/activities/chat/chat_activity.dart';
import 'package:solomas/helpers/api_constants.dart';
import 'package:solomas/helpers/constants.dart';

class SocketHelper {
  String? senderId;
  ChatState? cContext;
  Socket? _socket;

  SocketHelper(context) {
    this.cContext = context;
  }

  Future<void> connectToSocket(String mineUserId) async {
    if (_socket == null || _socket!.disconnected) {
      senderId = mineUserId;
      Map<dynamic, dynamic> queryMap = Map();
      queryMap["userId"] = senderId;
      _socket = io(
          ApiConstants.CHAT_BASE_URL,
          OptionBuilder()
              .setTransports(['websocket'])
              .setQuery({'userId': senderId})
              .disableAutoConnect()
              .build());

      _socket?.connect();
      _onSocketConnected();
      _onReceiveMessage();
      _onSocketError();
      _onSocketDisconnected();
      _onConnectionError();
    }
  }

  void _onSocketConnected() {
    _socket?.onConnect((data) {
      Constants.printValue("connected..." + data.toString());
    });
  }

  void _onSocketDisconnected() {
    _socket?.onDisconnect((data) {
      Constants.printValue("Disconnect...");
    });
  }

  void _onSocketError() {
    _socket?.on(Constants.SOCKET_ERROR, (data) {
      Constants.printValue("On Socket Error...: " + data.toString());
    });
  }

  void _onConnectionError() {
    _socket?.onConnectError((data) {
      Constants.printValue("Connect Error...: " + data.toString());
    });
  }

  void _onReceiveMessage() {
    _socket?.on(Constants.SOCKET_SEND_MESSAGE, (data) {
      print("Message Received...: " + data.toString());
      var encodedMsgData = json.encode(data);
      Map msgData = json.decode(encodedMsgData);
      if (msgData['receiverId'] == senderId) {
        cContext?.onReceiveMsg(msgData);
      }
    });
  }

  void sendMessage(String senderId, String receiverId, String message,
      String senderName, String type, bool isBlocked, String profileImage) {
    if (_socket != null) {
      if (isBlocked) {
        addSendMessageData(
            senderId, receiverId, message, senderName, type, profileImage);

        return;
      }

      _socket?.emit(Constants.SOCKET_SEND_MESSAGE, [
        addSendMessageData(
            senderId, receiverId, message, senderName, type, profileImage)
      ]);
    }
  }

  addSendMessageData(String senderId, String receiverId, String message,
      String senderName, String type, String profileImage) {
    var currentEpochTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    var msgData = {
      "senderId": senderId,
      "receiverId": receiverId,
      "message": message,
      "sentAt": currentEpochTime.toUnsigned(64),
      "userName": senderName,
      "profilePic": profileImage,
      "type": type,
      "additionalData": ""
    };

    var encodedMsgData = json.encode(msgData);
    Map mapData = json.decode(encodedMsgData);
    cContext?.onReceiveMsg(mapData);

    return msgData;
  }

  void disconnectSocket() {
    if (_socket!.connected) {
      _socket?.disconnect();
    }
  }
}
