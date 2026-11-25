enum OrderStatus {
  received('received', 'Reçue'),
  preparing('preparing', 'En préparation'),
  ready('ready', 'Prête'),
  collected('collected', 'Récupérée'),
  cancelled('cancelled', 'Annulée');

  const OrderStatus(this.apiValue, this.labelFr);

  final String apiValue;
  final String labelFr;

  // Aliases for compatibility
  static const OrderStatus pending = OrderStatus.received;
  static const OrderStatus served = OrderStatus.collected;

  bool get isPending => this == OrderStatus.received || this == OrderStatus.preparing;
  bool get isReady => this == OrderStatus.ready;
  bool get isCollected => this == OrderStatus.collected;
  bool get isServed => this == OrderStatus.collected;
  bool get isCancelled => this == OrderStatus.cancelled;

  static OrderStatus fromApi(String raw) {
    return OrderStatus.values.firstWhere(
      (e) => e.apiValue == raw,
      orElse: () => switch (raw.toLowerCase()) {
        'pending' => OrderStatus.received,
        'served' => OrderStatus.collected,
        _ => OrderStatus.received,
      },
    );
  }
}
