import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';
import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_application_1/models/order.dart';
import 'package:flutter_application_1/models/bot.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

final orderProvider = StateProvider<List<Order?>>((_) {
  return [];
});

final botProvider = StateProvider<List<Bot?>>((_) {
  return [];
});

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class OrderNotifier extends ChangeNotifier {}

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

class MyHomePage extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    var _isPressed = useState(false);
    var _orderUniqueId = useState(0);
    var _botUniqueId = useState(0);

    var orders = useState([]);
    var bots = useState([]);

    void processOrder(Bot? bot) {
      // check if the bot is null
      if (bot == null) return;

      // set the initial remaining value
      bot.remaining = 0;

      // cancel the previous timer if any
      bot.timer?.cancel();

      Order? order = orders.value.firstWhere(
          (n) => n.bot == null && n.completedAt == null,
          orElse: () => null);

      if (order != null) {
        bot.remaining = 10;
        bot.order = order;
        order.bot = bot;
        bot.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          bot.remaining = bot.remaining! - 1;
          if (bot.remaining! <= 0) {
            timer.cancel();
            order.completedAt = DateTime.now();
            bot.order = null;
            processOrder(bot);
          }

          bots.value = [...bots.value];
        });
      }
    }

    void _addOrder({bool vip = false}) {
      if (vip) {
        orders.value = [Order(_orderUniqueId.value, vip), ...orders.value];
      } else {
        orders.value = [...orders.value, Order(_orderUniqueId.value, vip)];
      }
      _orderUniqueId.value++;
      processOrder(
          bots.value.firstWhere((n) => n.order == null, orElse: () => null));
    }

    void _addBot() {
      final bot = Bot(_botUniqueId.value);
      bots.value = [...bots.value, bot];
      _botUniqueId.value++;
      processOrder(bot);
    }

    void _removeBot() {
      Bot? bot = bots.value.isNotEmpty ? bots.value.last : null;

      if (bot == null) {
        return;
      }

      Order? order = bot.order;
      bot.timer?.cancel();
      order?.bot = null;
      bots.value = [...bots.value, bot]..remove(bot);
      processOrder(
          bots.value.firstWhere((n) => n.order == null, orElse: () => null));
    }

    ListTile _listTile(item) {
      return item is Bot
          ? ListTile(
              title: Text('Bot(s) #${item.uniqueId}'),
              subtitle: item.order != null
                  ? Row(children: [
                      Text('Processing Order #${item.order?.uniqueId}'),
                      Text("(${item.remaining}s left)"),
                    ])
                  : null)
          : ListTile(
              title: Text('Order(s) #${item.uniqueId}'),
              subtitle: Text(item.vip ? 'VIP' : 'Normal'),
            );
    }

    Widget _listView(title, list) {
      return Flexible(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            Text(title),
            const SizedBox(height: 10),
            const Divider(),
            SizedBox(
                height: MediaQuery.of(context).size.height - 120,
                child: ListView.builder(
                    controller:
                        ScrollController(), // Define seperate scroll controller for each listing
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return _listTile(list[index]);
                    }))
          ],
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Row(children: [
          _listView("Bot(s)", bots.value),
          _listView("Pending Order(s)",
              orders.value.where((i) => i?.completedAt == null).toList()),
          _listView("Completed Order(s)",
              orders.value.where((i) => i?.completedAt != null).toList()),
        ]),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
          children: [
            FloatingActionButton(
              onPressed: () {
                if (!_isPressed.value) {
                  _isPressed.value = true;
                  _addBot();

                  Future.delayed(const Duration(milliseconds: 500), () {
                    _isPressed.value = false;
                  });
                }
              }, // use arrow function,
              tooltip: 'New Bot',
              child: const Icon(Icons.group_add),
            ),
            FloatingActionButton(
              onPressed: () {
                if (!_isPressed.value) {
                  _isPressed.value = true;
                  _removeBot();

                  Future.delayed(const Duration(milliseconds: 500), () {
                    _isPressed.value = false;
                  });
                }
              }, // use arrow function,
              tooltip: 'Remove Bot',
              backgroundColor: Colors.red,
              child: const Icon(Icons.group_remove),
            ),
            FloatingActionButton(
              onPressed: _addOrder,
              tooltip: 'New Order',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () => _addOrder(vip: true),
              tooltip: 'New VIP Order',
              child: const Icon(Icons.add),
            ),
          ],
        ));
  }
}
