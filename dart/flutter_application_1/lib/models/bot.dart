import 'dart:async';

import 'package:flutter_application_1/models/order.dart';

class Bot {
  int uniqueId;
  int? orderId;
  Timer? timer;
  int? remaining;
  Order? order;

  Bot(this.uniqueId, [this.orderId, this.timer, this.remaining = 0]);
}