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
## Preview
![](img/screen_record.gif)
## Parameter Description
> SlideListView

|       parameter       |                             type                             |                     description                      |    default value    |
| :-------------------: | :----------------------------------------------------------: | :--------------------------------------------------: | :-----------------: |
|       dataList        |                           List<E>                            |                    the list data                     | no default,required |
|    slideProportion    |                            double                            |        this value determine the action width         |        0.25         |
|  itemBackgroundColor  |                            Color                             | the list item background color,don't use Transparent |        white        |
| supportElasticSliding |                             bool                             |         has elasticsliding effict when slide         |        true         |
|   animationDuration   |                           Duration                           |                the animation duration                |       200 ms        |
|    refreshCallback    |                   Future<void> Function()                    |        if null,list dont support swip refresh        |        null         |
|      itemBuilder      |       Widget Function(BuildContext context, int index)       |                 build the list item                  |      required       |
|   separatorBuilder    |       Widget Function(BuildContext context, int index)       |               build the list separator               | Divider(height: 1)  |
| actionWidgetDelegate  |                     ActionWidgetDelegate                     |               build the action widget                |      required       |
| refreshWidgetBuilder  | Widget Function( Widget content, RefreshCallback refreshCallback) |      you can use your custom refresh indicator       |  RefreshIndicator   |
|onGestureEnd|void Function(DragEndDetails detail, double itemWidth,double translateValue, Function openF, Function closeF)|determine when to close or open action on gesture end|null|
> ActionWidgetDelegate

|       parameter        |                           type                           |                         description                          | default value |
| :--------------------: | :------------------------------------------------------: | :----------------------------------------------------------: | :-----------: |
|      actionCount       |                           int                            |                   the actionButton's count                   |   required    |
|     actionBuilder      |                Widget Function(int actionIndex, int indexInList)                |                   build the action button                    |   required    |
|     clickCallback      | Function(int indexInList, int index, BaseSlideItem item) |                     handle click action                      |     null      |
| actionBackgroundColors |                       List<Color>                        | given the action button background color(this list's length must same with actionCount) |     null      |

