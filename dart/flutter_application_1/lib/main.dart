import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_application_1/models/order.dart';
import 'package:flutter_application_1/models/bot.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

final orderProvider = StateProvider<List<Order>>((_) {
  return [];
});

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class MyListView extends StatefulWidget {
  MyListView(this.title, this.list);

  final List list;
  final String title;
  
  @override
  Widget build(BuildContext context) {

    return Flexible(
      child: Column(
        children: <Widget>[
          Text(title),
          Divider(),
          Container(
            height: MediaQuery.of(context).size.height - 100,
            child: ListView.builder(
              controller: ScrollController(), // Define seperate scroll controller for each listing 
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return ListTile(
                  title: Text("${item is Bot ? 'Bot(s)' : 'Order(s)'} ${item.uniqueId}"),
                  subtitle: item is Order
                    ? Text("${item.vip ? 'VIP' : 'Normal'}")
                    : Text("${item.remaining}"),
                );
              })
          )
        ],
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _orderUniqueId = 0;
  int _botUniqueId = 0;
  List orders = [];
  List bots = [];

  void _addOrder({bool vip = false}) {
    setState(() {
      orders.insert(0, Order(_orderUniqueId, vip));
      _orderUniqueId++;
    });
  }

  void _addBot() {
    setState(() {
      final bot = Bot(_botUniqueId);
      bots.add(bot);
      _botUniqueId++;
      processOrder(bot);
    });
  }

  void processOrder(Bot bot) {
    bot.remaining = 10;
    bot.timer = null;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      bot.remaining = bot.remaining! - 1;
      bot.timer = timer;
      bot.order = orders.firstOrNull;
      if (bot.remaining! <= 0) {
        timer.cancel();
        bot.order?.completedAt = DateTime.now();
      }
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
      body: Row(children: [
        MyListView("Bot(s)", bots),
        MyListView("Pending Order(s)", orders.where((i) => i.completedAt == null).toList()),
        MyListView("Completed Order(s)", orders.where((i) => i.completedAt != null).toList()),
      ])
      ,
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(children: [
        FloatingActionButton(
          onPressed: _addBot,
          tooltip: 'New Bot',
          child: const Icon(Icons.people),
        ),
        FloatingActionButton(
          onPressed: _addOrder,
          tooltip: 'New Order',
          child: const Icon(Icons.add),
        ),
        FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () => _addOrder(vip: true),
          tooltip: 'New VIP Order',
          child: const Icon(Icons.add),
        ),
      ],)
    );
  }
}
