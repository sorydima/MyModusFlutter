// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toInt(),
      oldPrice: (json['oldPrice'] as num?)?.toInt(),
      discount: (json['discount'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String,
      brand: json['brand'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      category: json['category'] as String,
      sizes: (json['sizes'] as List<dynamic>).map((e) => e as String).toList(),
      colors:
          (json['colors'] as List<dynamic>).map((e) => e as String).toList(),
      description: json['description'] as String,
      inStock: json['inStock'] as bool,
      isNew: json['isNew'] as bool,
      isSale: json['isSale'] as bool,
      isFavorite: json['isFavorite'] as bool? ?? false,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price': instance.price,
      'oldPrice': instance.oldPrice,
      'discount': instance.discount,
      'imageUrl': instance.imageUrl,
      'brand': instance.brand,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'category': instance.category,
      'sizes': instance.sizes,
      'colors': instance.colors,
      'description': instance.description,
      'inStock': instance.inStock,
      'isNew': instance.isNew,
      'isSale': instance.isSale,
      'isFavorite': instance.isFavorite,
      'quantity': instance.quantity,
    };
