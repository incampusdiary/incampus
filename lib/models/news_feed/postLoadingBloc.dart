import 'dart:async';

class PostLoadingBloc {
  final stateStreamController = StreamController<bool>();

  StreamSink<bool> get postLoadingSink =>
      stateStreamController.sink;

  Stream<bool> get postLoadingStream =>
      stateStreamController.stream;

  void closeStream() {
    stateStreamController.close();
  }
}