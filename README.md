# flutter_slidable_list_view

a item slidable listView, the slide item is learn from [flutter_slidable](https://pub.dev/packages/flutter_slidable),
i need some effect that like IOS's list or QQ mobile client's chat list,so this package burn.

## Getting Started

The usage of this Widget is similar to that of ListView.
```dart
        SlideListView(
          itemBuilder: (bc, index) {
            // return your item widget here,no need to consider the click event
          },
          actionWidgetBuilder: ActionWidgetDelegate( $action_count, (index) {
            // return your action widget
          }, (int indexInList, int index, BaseSlideItem item) {
            // deal the action click event here,you can use item.close(),item.remove() to close or remove this item after click action 
          }, [$action_colors]),// action_colors.len need equal to action_count
          dataList: $data_list,
        )
```