import 'package:flutter/material.dart';
import 'inherited_widgets.dart';
import 'package:flutter_slidable_list_view/support/base_def.dart';
import 'action_widgets.dart';

typedef OnGestureEnd = void Function(DragEndDetails detail, double itemWidth,
    double translateValue, Function openF, Function closeF);

class SlideItem extends StatefulWidget {
  final Widget content;
  final int indexInList;
  final bool supportElasticity;
  final double slideProportion;
  final Color backgroundColor;
  final OnGestureEnd onGestureEnd;
  final Duration animationDuration;
  final IndexCallback slideBeginCallback;
  final IndexCallback slideUpdateCallback;
  final IndexCallback itemRemoveCallback;
  final ActionWidgetDelegate actionWidgetDelegate;

  const SlideItem(
      {Key key,
      this.content,
      this.indexInList,
      this.slideBeginCallback,
      this.slideUpdateCallback,
      this.actionWidgetDelegate,
      this.animationDuration,
      this.slideProportion,
      this.supportElasticity,
      this.itemRemoveCallback,
      this.backgroundColor,
      this.onGestureEnd})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SlideItemState();
  }
}

class SlideItemState extends State<SlideItem>
    with TickerProviderStateMixin
    implements CloseListener {
  bool _needRemove = false;
  double translateValue = 0;

  AnimationController _slideController;
  AnimationController _dismissController;

  Animation<double> _slideAnimation;
  Animation<double> _dismissAnimation;

  Size _size;

  /// 获取当前正在滑动的Item的位置
  int get nowSlidingIndex {
    return SlidingIndexData.of(context)?.slidedIndex ?? DEFAULT_SLIDING_INDEX;
  }

  /// 侧滑按钮的个数
  int get actionCount {
    return widget.actionWidgetDelegate.actionCount;
  }

  /// 实际滑动的距离（即滑动打开侧滑菜单之后会停留的宽度）
  double get trueSlideWidth {
    return -context.size.width * trueSlideProportion;
  }

  /// 最大滑动宽度（弹性滑动打开时会比实际滑动距离大）
  double get maxSlideWidth {
    return -context.size.width * maxSlideProportion;
  }

  double get itemWidth {
    return context.size.width;
  }

  /// 当弹性滑动（拉到标准宽度以后继续减速滑动）打开时，可额外减速滑动一部分距离
  double get maxSlideProportion {
    return widget.supportElasticity
        ? (widget.slideProportion + DEFAULT_ELASTICITY_VALUE) * actionCount
        : trueSlideProportion;
  }

  /// 获取实际的滑动距离与item宽度的比例
  double get trueSlideProportion {
    return widget.slideProportion * widget.actionWidgetDelegate.actionCount;
  }

  @override
  Widget build(BuildContext context) {
    if (nowSlidingIndex == DEFAULT_SLIDING_INDEX || isSelf()) {
      return _buildSlidableItem();
    }
    return _buildUnSlidableItem();
  }

  @override
  int get indexInList => widget.indexInList;

  @override
  void close({bool fromSelf = true}) {
    if (!fromSelf && !isSelf()) {
      return;
    }
    _slideController.fling(velocity: -1).whenComplete(() {
      translateValue = 0;
      widget.slideUpdateCallback(DEFAULT_SLIDING_INDEX);
    });
  }

  @override
  bool isSelf() {
    return indexInList == nowSlidingIndex;
  }

  @override
  void open() {
    _slideController
        .animateTo(trueSlideWidth.abs() / itemWidth,
            curve: Curves.easeIn, duration: widget.animationDuration)
        .whenComplete(() {
      translateValue = trueSlideWidth;
    });
  }

  @override
  void remove() {
    _initAnimation();
    setState(() {
      _needRemove = true;
    });
    _dismissController.forward().whenComplete(() {
      setState(() {
        _needRemove = false;
        translateValue = 0;
        _slideController.value = 0;
      });
      widget.slideUpdateCallback(DEFAULT_SLIDING_INDEX);
      widget.itemRemoveCallback(indexInList);
    });
  }

  @override
  void initState() {
    super.initState();
    _initAnimation();
    CloseNotifyManager().addListener(this);
  }

  @override
  void dispose() {
    CloseNotifyManager().removeListener(this);
    _slideController.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SlideItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRender);
  }

  _onAfterRender(Duration timeStamp) {
    _size = context?.size;
  }

  _slideUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  _initAnimation() {
    _slideController?.removeListener(_slideUpdate);
    _slideController =
        AnimationController(vsync: this, duration: widget.animationDuration)
          ..addListener(_slideUpdate);
    _slideAnimation = CurvedAnimation(
        parent: _slideController, curve: Interval(0.0, maxSlideProportion));
    _dismissController =
        AnimationController(vsync: this, duration: widget.animationDuration);
    _dismissAnimation = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _dismissController, curve: Curves.easeOut));
  }

  Widget _buildSlidableItem() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onTap: () {
        if (translateValue == trueSlideWidth) {
          close();
        }
      },
      child: _needRemove
          ? SizeTransition(
              axis: Axis.vertical,
              sizeFactor: _dismissAnimation,
              child: Material(
                color: Colors.transparent,
                child: SizedBox.fromSize(
                  size: _size,
                ),
              ),
            )
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                Animation<Offset> translateAnimation = Tween<Offset>(
                        begin: Offset.zero, end: Offset(-maxSlideProportion, 0))
                    .animate(_slideAnimation);
                double singleActionAnimationWidth =
                    translateAnimation.value.dx.abs() / actionCount;
                return _SlideItemContainer(
                  absorbing:
                      nowSlidingIndex != -1 || _slideController.value != 0,
                  animation: translateAnimation,
                  child: widget.content,
                  action: widget.actionWidgetDelegate.buildActions(
                      // 当划到设置的标准滑动宽度(trueSlideWidth)时，如果开启了弹性滑动，那么应该一起更新Action的宽度
                      constraints.maxWidth *
                          (widget.slideProportion > singleActionAnimationWidth
                              ? widget.slideProportion
                              : singleActionAnimationWidth),
                      this,
                      indexInList),
                  backgroundColor: widget.backgroundColor,
                );
              },
            ),
    );
  }

  Widget _buildUnSlidableItem() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(
        child: Container(
          child: widget.content,
          color: Colors.white,
        ),
        absorbing: true,
      ),
      onPanDown: (d) {
        CloseNotifyManager().notify();
      },
    );
  }

  _handleDragStart(DragStartDetails detail) {
    if (_slideController.value == 0 || translateValue != trueSlideWidth) {
      translateValue = 0;
    }
    if (_slideController.isAnimating) {
      _slideController.stop();
    }
    widget.slideBeginCallback(indexInList);
  }

  _handleDragUpdate(DragUpdateDetails detail) {
    double newValue = translateValue + detail.primaryDelta;
    if (newValue < trueSlideWidth) {
      translateValue +=
          (1 - newValue.abs() / maxSlideWidth.abs()) * detail.primaryDelta;
    } else {
      translateValue += detail.primaryDelta;
    }
    translateValue = translateValue > 0 ? 0 : translateValue;
    setState(() {
      _slideController.value = translateValue.abs() / itemWidth;
    });
  }

  _handleDragEnd(DragEndDetails detail) {
    if (widget.onGestureEnd != null) {
      widget.onGestureEnd(detail, itemWidth, translateValue, open, close);
    } else {
      if (translateValue.abs() <
              (itemWidth * trueSlideProportion / 2.0).abs() &&
          translateValue != 0) {
        close();
      } else if (translateValue.abs() >
          (itemWidth * trueSlideProportion / 2.0).abs()) {
        open();
      }
    }
  }
}

class _SlideItemContainer extends StatelessWidget {
  final bool absorbing;
  final Widget action;
  final Widget child;
  final Animation<Offset> animation;
  final Color backgroundColor;

  const _SlideItemContainer(
      {Key key,
      this.absorbing,
      this.action,
      this.animation,
      this.backgroundColor,
      this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          Positioned.fill(
              child: Container(
            alignment: Alignment.centerRight,
            child: action,
          )),
          SlideTransition(
            position: animation,
            child: AbsorbPointer(
              child: Container(
                color: backgroundColor ?? Colors.white,
                child: child,
              ),
              absorbing: absorbing,
            ),
          )
        ],
      ),
    );
  }
}

class UnSlidableWrapper extends StatelessWidget {
  final Widget content;

  const UnSlidableWrapper({Key key, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return content;
  }
}
