import 'def.dart';

abstract class SlideListener {
  int indexInList = DEFAULT_INDEX_IN_LIST;

  bool needReverse(int index) {
    return (index ?? DEFAULT_SLIDING_INDEX) == indexInList;
  }
}
