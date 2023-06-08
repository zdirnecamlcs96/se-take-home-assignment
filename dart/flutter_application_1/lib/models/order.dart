import 'package:flutter_application_1/models/bot.dart';

class Order {
  int uniqueId;
  bool vip;
  DateTime? completedAt;
  Bot? bot;

  Order(this.uniqueId, this.vip);

}