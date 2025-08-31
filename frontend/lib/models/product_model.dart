import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String title;
  final String brand;
  final String category;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final bool isNew;
  final bool isSale;
  final String status;
  final int statusColor;
  final String description;
  final Map<String, String> specifications;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final List<String> tags;
  final double weight;
  final String dimensions;
  final String material;
  final String country;
  final String warranty;
  final String deliveryTime;
  final bool freeShipping;
  final String returnPolicy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final int likeCount;
  final bool isFavorite;
  final bool inCart;
  final int cartQuantity;

  const ProductModel({
    required this.id,
    required this.title,
    required this.brand,
    required this.category,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.isNew,
    required this.isSale,
    required this.status,
    required this.statusColor,
    required this.description,
    required this.specifications,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.tags,
    required this.weight,
    required this.dimensions,
    required this.material,
    required this.country,
    required this.warranty,
    required this.deliveryTime,
    required this.freeShipping,
    required this.returnPolicy,
    required this.createdAt,
    required this.updatedAt,
    required this.viewCount,
    required this.likeCount,
    this.isFavorite = false,
    this.inCart = false,
    this.cartQuantity = 0,
  });

  // Геттеры для форматирования
  String get formattedPrice => '${price.toStringAsFixed(0)} ₽';
  String get formattedOldPrice => oldPrice != null ? '${oldPrice!.toStringAsFixed(0)} ₽' : '';
  String get formattedRating => rating.toStringAsFixed(1);
  String get formattedReviewCount => reviewCount.toString();
  String get formattedDiscount => oldPrice != null ? '${((oldPrice! - price) / oldPrice! * 100).toInt()}%' : '';
  
  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  // Копирование с изменениями
  ProductModel copyWith({
    String? id,
    String? title,
    String? brand,
    String? category,
    double? price,
    double? oldPrice,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    bool? inStock,
    bool? isNew,
    bool? isSale,
    String? status,
    int? statusColor,
    String? description,
    Map<String, String>? specifications,
    List<String>? images,
    List<String>? sizes,
    List<String>? colors,
    List<String>? tags,
    double? weight,
    String? dimensions,
    String? material,
    String? country,
    String? warranty,
    String? deliveryTime,
    bool? freeShipping,
    String? returnPolicy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    int? likeCount,
    bool? isFavorite,
    bool? inCart,
    int? cartQuantity,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      isNew: isNew ?? this.isNew,
      isSale: isSale ?? this.isSale,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      description: description ?? this.description,
      specifications: specifications ?? this.specifications,
      images: images ?? this.images,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      tags: tags ?? this.tags,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      material: material ?? this.material,
      country: country ?? this.country,
      warranty: warranty ?? this.warranty,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      freeShipping: freeShipping ?? this.freeShipping,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      isFavorite: isFavorite ?? this.isFavorite,
      inCart: inCart ?? this.inCart,
      cartQuantity: cartQuantity ?? this.cartQuantity,
    );
  }

  // Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'brand': brand,
      'category': category,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'isNew': isNew,
      'isSale': isSale,
      'status': status,
      'statusColor': statusColor,
      'description': description,
      'specifications': specifications,
      'images': images,
      'sizes': sizes,
      'colors': colors,
      'tags': tags,
      'weight': weight,
      'dimensions': dimensions,
      'material': material,
      'country': country,
      'warranty': warranty,
      'deliveryTime': deliveryTime,
      'freeShipping': freeShipping,
      'returnPolicy': returnPolicy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'viewCount': viewCount,
      'likeCount': likeCount,
      'isFavorite': isFavorite,
      'inCart': inCart,
      'cartQuantity': cartQuantity,
    };
  }

  // Создание из JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      oldPrice: json['oldPrice'] != null ? (json['oldPrice'] as num).toDouble() : null,
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      inStock: json['inStock'] ?? true,
      isNew: json['isNew'] ?? false,
      isSale: json['isSale'] ?? false,
      status: json['status'] ?? 'В наличии',
      statusColor: json['statusColor'] ?? 0xFF0000FF,
      description: json['description'] ?? '',
      specifications: Map<String, String>.from(json['specifications'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      weight: (json['weight'] ?? 0).toDouble(),
      dimensions: json['dimensions'] ?? '',
      material: json['material'] ?? '',
      country: json['country'] ?? '',
      warranty: json['warranty'] ?? '',
      deliveryTime: json['deliveryTime'] ?? '',
      freeShipping: json['freeShipping'] ?? false,
      returnPolicy: json['returnPolicy'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      inCart: json['inCart'] ?? false,
      cartQuantity: json['cartQuantity'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductModel(id: $id, title: $title, brand: $brand, price: $price)';
  }
}

class CartProductModel {
  final ProductModel product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final bool isFavorite;

  const CartProductModel({
    required this.product,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    this.isFavorite = false,
  });

  // Геттеры
  double get totalPrice => product.price * quantity;
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(0)} ₽';
  String get formattedQuantity => quantity.toString();

  // Копирование с изменениями
  CartProductModel copyWith({
    ProductModel? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
    bool? isFavorite,
  }) {
    return CartProductModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'isFavorite': isFavorite,
    };
  }

  // Создание из JSON
  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    return CartProductModel(
      product: ProductModel.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      selectedSize: json['selectedSize'],
      selectedColor: json['selectedColor'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartProductModel &&
        other.product.id == product.id &&
        other.selectedSize == selectedSize &&
        other.selectedColor == selectedColor;
  }

  @override
  int get hashCode => Object.hash(product.id, selectedSize, selectedColor);

  @override
  String toString() {
    return 'CartProductModel(product: ${product.title}, quantity: $quantity)';
  }
}