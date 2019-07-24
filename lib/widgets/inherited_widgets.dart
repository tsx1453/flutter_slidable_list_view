import 'package:flutter/material.dart';

class SlidingIndexData extends InheritedWidget {
  final int slidedIndex;

  SlidingIndexData(this.slidedIndex, {Widget child}) :super(child: child);

  @override
  bool updateShouldNotify(SlidingIndexData oldWidget) {
    return oldWidget.slidedIndex != slidedIndex;
  }

  static SlidingIndexData of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(SlidingIndexData);
  }
}

