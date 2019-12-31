import 'package:flutter/material.dart';
import 'slide_item.dart';
import 'package:flutter_slidable_list_view/support/base_def.dart';
import 'inherited_widgets.dart';
import 'action_widgets.dart';

class SlideListView extends StatefulWidget {
  final List dataList;
  final bool needLoadMore;
  final EdgeInsets padding;
  final double slideProportion;
  final Color itemBackgroundColor;
  final bool supportElasticSliding;
  final Duration animationDuration;
  final ScrollController controller;
  final OnGestureEnd onGestureEnd;
  final RefreshCallback refreshCallback;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder separatorBuilder;
  final ActionWidgetDelegate actionWidgetDelegate;
  final RefreshWidgetBuilder refreshWidgetBuilder;

  const SlideListView(
      {Key key,
      @required this.itemBuilder,
      this.separatorBuilder,
      @required this.dataList,
      @required this.actionWidgetDelegate,
      this.animationDuration =
          const Duration(milliseconds: DEFAULT_ANIMATION_DURATION_MILLISECONDS),
      this.slideProportion = DEFAULT_PROPORTION,
      this.supportElasticSliding = true,
      this.itemBackgroundColor = Colors.white,
      this.refreshCallback,
      this.refreshWidgetBuilder,
      this.needLoadMore = false,
      this.padding,
      this.controller,
      this.onGestureEnd})
      : assert(itemBuilder != null),
        assert(dataList != null),
        assert(actionWidgetDelegate != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SlideListViewState();
  }
}

class SlideListViewState extends State<SlideListView> {
  int slidingIndex = DEFAULT_SLIDING_INDEX;

  @override
  Widget build(BuildContext context) {
    Widget content = SlidingIndexData(
      slidingIndex,
      child: ListView.separated(
          controller: widget.controller,
          physics: slidingIndex == DEFAULT_SLIDING_INDEX
              ? AlwaysScrollableScrollPhysics()
              : NeverScrollableScrollPhysics(),
          itemBuilder: _itemBuilder,
          padding: widget.padding,
          separatorBuilder: _separatorBuilder,
          itemCount: widget.needLoadMore
              ? widget.dataList.length + 1
              : widget.dataList.length),
    );
    return widget.refreshCallback != null
        ? _buildRefreshContent(content)
        : content;
  }

  Widget _buildRefreshContent(Widget content) {
    if (widget.refreshWidgetBuilder != null) {
      return widget.refreshWidgetBuilder(content, widget.refreshCallback);
    }
    return RefreshIndicator(
      child: SlidingIndexData(
        slidingIndex,
        child: ListView.separated(
            physics: slidingIndex == DEFAULT_SLIDING_INDEX
                ? AlwaysScrollableScrollPhysics()
                : NeverScrollableScrollPhysics(),
            itemBuilder: _itemBuilder,
            separatorBuilder: _separatorBuilder,
            itemCount: widget.needLoadMore
                ? widget.dataList.length + 1
                : widget.dataList.length),
      ),
      onRefresh: widget.refreshCallback,
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Widget content = widget.itemBuilder(context, index);
    if (content is UnSlidableWrapper) {
      return content;
    }
    return SlideItem(
      actionWidgetDelegate: widget.actionWidgetDelegate,
      content: content,
      indexInList: index,
      slideBeginCallback: (slideIndex) {
        setState(() {
          slidingIndex = slideIndex;
        });
      },
      slideUpdateCallback: (slideIndex) {
        setState(() {
          slidingIndex = slideIndex;
        });
      },
      itemRemoveCallback: (removeIndex) {
        setState(() {
          widget.dataList.removeAt(removeIndex);
        });
      },
      supportElasticity: widget.supportElasticSliding,
      backgroundColor: widget.itemBackgroundColor,
      animationDuration: widget.animationDuration,
      slideProportion: widget.slideProportion,
      onGestureEnd: widget.onGestureEnd,
    );
  }

  Widget _separatorBuilder(BuildContext context, int index) {
    if (widget.separatorBuilder != null) {
      return widget.separatorBuilder(context, index);
    }
    return Divider(
      height: 1,
    );
  }
}
