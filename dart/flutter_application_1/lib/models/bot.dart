import 'dart:async';

class Bot {
  int uniqueId;
  int? orderId;
  Timer? timer;
  int? remaining;

  Bot(this.uniqueId, [this.orderId, this.timer, this.remaining]);
}