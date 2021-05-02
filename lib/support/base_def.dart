import 'package:flutter/material.dart';

const int DEFAULT_INDEX_IN_LIST = -2;
const int DEFAULT_SLIDING_INDEX = -1;
const int DEFAULT_ANIMATION_DURATION_MILLISECONDS = 200;
const double DEFAULT_ELASTICITY_VALUE = 0.1;
const double DEFAULT_PROPORTION = 0.25;

typedef IndexCallback = void Function(int? index);
typedef ActionBuilder = Widget Function(int actionIndex, int? indexInList);
typedef ActionClickCallback = void Function(
    int? indexInList, int index, BaseSlideItem item);
typedef RefreshWidgetBuilder = Widget Function(
    Widget content, RefreshCallback? refreshCallback);

abstract class BaseSlideItem {
  int? get indexInList;

  void close({bool? fromSelf});

  void open();

  void remove();
}

abstract class CloseListener extends BaseSlideItem {
  bool isSelf();
}

class CloseNotifyManager {
  factory CloseNotifyManager() => _getInstance()!;

  static CloseNotifyManager? get instance => _getInstance();

  static CloseNotifyManager? _instance;

  CloseNotifyManager._internal();

  static CloseNotifyManager? _getInstance() {
    if (_instance == null) {
      _instance = CloseNotifyManager._internal();
    }
    return _instance;
  }

  List<CloseListener> _listeners = [];

  void notify() {
    _listeners.forEach((it) {
      it.close(fromSelf: false);
    });
  }

  void addListener(CloseListener listener) {
    _listeners.add(listener);
  }

  void removeListener(CloseListener listener) {
    _listeners.remove(listener);
  }
}
