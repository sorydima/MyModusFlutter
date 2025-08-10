import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Product {
  final String id;
  final String title;
  final String description;
  final int price;
  final int? oldPrice;
  final int? discount;
  final String imageUrl;
  final String productUrl;
  final String brand;
  final String category;
  final String? sku;
  final Map<String, dynamic>? specifications;
  final int stock;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String source; // 'wildberries', 'ozon', 'lamoda', etc.
  final String sourceId; // Original ID from the source

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.oldPrice,
    this.discount,
    required this.imageUrl,
    required this.productUrl,
    required this.brand,
    required this.category,
    this.sku,
    this.specifications,
    required this.stock,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
    required this.source,
    required this.sourceId,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable()
class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? parentId;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.parentId,
    required this.productCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final int totalAmount;
  final int? discountAmount;
  final String status; // 'pending', 'processing', 'shipped', 'delivered', 'cancelled'
  final String? paymentMethod;
  final String? shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    this.discountAmount,
    required this.status,
    this.paymentMethod,
    this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable()
class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final int price;
  final String? size;
  final String? color;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.size,
    this.color,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

@JsonSerializable()
class CartItem {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}

@JsonSerializable()
class Favorite {
  final String id;
  final String userId;
  final String productId;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => _$FavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteToJson(this);
}

@JsonSerializable()
class Review {
  final String id;
  final String userId;
  final String productId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}

@JsonSerializable()
class ScrapingJob {
  final String id;
  final String source; // 'wildberries', 'ozon', 'lamoda'
  final String status; // 'pending', 'running', 'completed', 'failed'
  final int productsScraped;
  final int? productsUpdated;
  final String? error;
  final DateTime startedAt;
  final DateTime? completedAt;

  ScrapingJob({
    required this.id,
    required this.source,
    required this.status,
    required this.productsScraped,
    this.productsUpdated,
    this.error,
    required this.startedAt,
    this.completedAt,
  });

  factory ScrapingJob.fromJson(Map<String, dynamic> json) => _$ScrapingJobFromJson(json);
  Map<String, dynamic> toJson() => _$ScrapingJobToJson(this);
}