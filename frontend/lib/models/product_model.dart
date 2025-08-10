import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
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
  final String source;
  final String sourceId;

  ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    int? price,
    int? oldPrice,
    int? discount,
    String? imageUrl,
    String? productUrl,
    String? brand,
    String? category,
    String? sku,
    Map<String, dynamic>? specifications,
    int? stock,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? source,
    String? sourceId,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      discount: discount ?? this.discount,
      imageUrl: imageUrl ?? this.imageUrl,
      productUrl: productUrl ?? this.productUrl,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      specifications: specifications ?? this.specifications,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
    );
  }

  bool get hasDiscount => oldPrice != null && oldPrice! > price;
  
  String get formattedPrice {
    return '₽${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')}';
  }

  String get formattedOldPrice {
    return oldPrice != null 
        ? '₽${oldPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')}'
        : '';
  }

  String get discountText {
    return discount != null ? '-$discount%' : '';
  }

  String get ratingText {
    return rating.toStringAsFixed(1);
  }

  String get reviewCountText {
    if (reviewCount >= 1000) {
      return '${(reviewCount / 1000).toStringAsFixed(1)}K';
    }
    return reviewCount.toString();
  }

  String get sourceIcon {
    switch (source) {
      case 'wildberries':
        return '🛒';
      case 'ozon':
        return '📦';
      case 'lamoda':
        return '👟';
      default:
        return '🛍️';
    }
  }
}