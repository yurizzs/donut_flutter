import 'category_model.dart';

class DonutModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final int stock;
  final CategoryModel category;

  DonutModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
    required this.stock,
    required this.category,
  });

  factory DonutModel.fromJson(Map<String, dynamic> json) {
    return DonutModel(
      // Map API fields (e.g., 'donut_id') to model fields (e.g., 'id')
      id: json['donut_id'] ?? 0,
      name: json['donut_name'] ?? 'Unknown Donut',
      description: json['description'],
      // Price is returned as a String from the API
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['image'],
      stock: json['stock'] ?? 0,
      // Map API field 'category' -> 'category_name'
      category: CategoryModel(
        id: json['category']['category_id'] ?? 0,
        name: json['category']['category_name'] ?? 'Uncategorized',
      ),
    );
  }
}
