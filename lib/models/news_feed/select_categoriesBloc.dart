import 'dart:async';

class SelectCategoryBloc {
  final stateStreamController = StreamController<String>();

  StreamSink<String> get selectCategorySink =>
      stateStreamController.sink;

  Stream<String> get selectCategoryStream =>
      stateStreamController.stream;

  void closeStream() {
    stateStreamController.close();
  }
}