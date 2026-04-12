import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,

      // ✅ Support 2 jenis API (name / title)
      name: json['name'] ?? json['title'] ?? 'No Name',

      // ✅ Aman dari null
      price: (json['price'] ?? 0).toDouble(),

      // ✅ Support image_url / thumbnail / images[]
      imageUrl:
          json['image_url'] ??
          json['thumbnail'] ??
          (json['images'] != null && json['images'].isNotEmpty
              ? json['images'][0]
              : ''),

      category: json['category'] ?? 'Unknown',
    );
  }

  @override
  List<Object?> get props => [id, name, price, imageUrl, category];
}
