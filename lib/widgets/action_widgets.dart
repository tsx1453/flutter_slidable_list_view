import 'package:flutter/material.dart';
import 'package:flutter_slidable_list_view/support/base_def.dart';

class ActionWidgetDelegate {
  final int actionCount;
  final ActionBuilder actionBuilder;
  final ActionClickCallback clickCallback;
  final List<Color> actionBackgroundColors;

  ActionWidgetDelegate(this.actionCount, this.actionBuilder, this.clickCallback,
      this.actionBackgroundColors)
      : assert(actionBackgroundColors != null),
        assert(actionBackgroundColors.length == actionCount);

  Widget buildActions(double width, BaseSlideItem item, int indexInList) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(actionCount, (actionIndex) {
        return GestureDetector(
          child: Container(
            width: width,
            alignment: Alignment.center,
            color: actionBackgroundColors[actionIndex],
            child: actionBuilder(actionIndex, indexInList),
          ),
          onTap: () async {
            if (clickCallback != null) {
              clickCallback(item.indexInList, actionIndex, item);
            }
          },
        );
      }),
    );
  }
}
