
import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart';

class SignallingService{
  Socket? socket;

  SignallingService._();
  static final instance = SignallingService._();

  init({required String websocketUrl, required String selfCallerId}){

    // 소켓 초기화
    socket = io(websocketUrl, {
      "transports": ['websocket'],
      "query" : {"callerId" : selfCallerId}
    });

    // 연결 이벤트
    socket!.onConnect((data) {
      log("Socket connected !!");
      // Event occurs when connected
      socket!.emit('customEvent', {
        'data': 'Hello, server!',
      });
    });

    // 연결 에러 이벤트
    socket!.onConnectError((data) {
      log("Connect Error $data");
    });

    // 소켓 연결
    socket!.connect();
  }
}