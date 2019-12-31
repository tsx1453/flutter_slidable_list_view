import 'package:flutter/material.dart';
import 'package:flutter_slidable_list_view/flutter_slidable_list_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  List<int> data = List();

  @override
  void initState() {
    super.initState();
    data = List.generate(20, (index) {
      return index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        child: SlideListView(
          itemBuilder: (bc, index) {
            return GestureDetector(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Text('child ${data[index]}'),
                    RaisedButton(
                      child: Text('button ${data[index]}'),
                      onPressed: () {
                        print('button click ${data[index]}');
                      },
                    )
                  ],
                ),
              ),
              onTap: () {
                print('tap ${data[index]}');
              },
              behavior: HitTestBehavior.translucent,
            );
          },
          actionWidgetDelegate:
              ActionWidgetDelegate(2, (actionIndex, listIndex) {
            if (actionIndex == 0) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[Icon(Icons.delete), Text('delete')],
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  listIndex > 5 ? Icon(Icons.close) : Icon(Icons.adjust),
                  Text('close')
                ],
              );
            }
          }, (int indexInList, int index, BaseSlideItem item) {
            if (index == 0) {
              item.remove();
            } else {
              item.close();
            }
          }, [Colors.redAccent, Colors.blueAccent]),
          dataList: data,
          refreshCallback: () async {
            await Future.delayed(Duration(seconds: 2));
            return;
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
