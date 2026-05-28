class OrderItemModel {
  final int id;
  final String donutName;
  final String categoryName;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.donutName,
    required this.categoryName,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Handling nested donut structure based on React reference
    final donutData = json['donut'] ?? {};
    final categoryData = donutData['category'] ?? {};

    return OrderItemModel(
      id: json['order_item_id'] ?? 0,
      donutName: donutData['donut_name'] ?? 'Removed Donut',
      categoryName: categoryData['category_name'] ?? 'Specialty',
      quantity: json['quantity'] ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

class OrderModel {
  final int id;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['order_id'] ?? 0,
      status: json['status'] ?? 'Unknown',
      total: double.tryParse(json['total_amount']?.toString() ?? '0.0') ?? 0.0,
      createdAt: DateTime.tryParse(json['order_date'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List?)
              ?.map((i) => OrderItemModel.fromJson(i))
              .toList() ??
          [],
    );
  }
}
