import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

/// Модель пользователя
@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  factory User.fromRow(List<dynamic> row) {
    return User(
      id: row[0].toString(),
      email: row[1] as String,
      name: row[2] as String?,
      phone: row[3] as String?,
      isActive: row[4] as bool,
      createdAt: row[5] as DateTime,
      updatedAt: row[6] as DateTime,
    );
  }
}

/// Модель категории
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

  factory Category.fromRow(List<dynamic> row) {
    return Category(
      id: row[0].toString(),
      name: row[1] as String,
      description: row[2] as String?,
      icon: row[3] as String?,
      parentId: row[4]?.toString(),
      productCount: row[5] as int,
      createdAt: row[6] as DateTime,
      updatedAt: row[7] as DateTime,
    );
  }
}

/// Модель товара
@JsonSerializable()
class Product {
  final String id;
  final String title;
  final String? description;
  final int price;
  final int? oldPrice;
  final int? discount;
  final String imageUrl;
  final String productUrl;
  final String? brand;
  final String? categoryId;
  final String? sku;
  final Map<String, dynamic>? specifications;
  final int stock;
  final double? rating;
  final int reviewCount;
  final String source;
  final String sourceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.oldPrice,
    this.discount,
    required this.imageUrl,
    required this.productUrl,
    this.brand,
    this.categoryId,
    this.sku,
    this.specifications,
    required this.stock,
    this.rating,
    required this.reviewCount,
    required this.source,
    required this.sourceId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  factory Product.fromRow(List<dynamic> row) {
    return Product(
      id: row[0].toString(),
      title: row[1] as String,
      description: row[2] as String?,
      price: row[3] as int,
      oldPrice: row[4] as int?,
      discount: row[5] as int?,
      imageUrl: row[6] as String,
      productUrl: row[7] as String,
      brand: row[8] as String?,
      categoryId: row[9]?.toString(),
      sku: row[10] as String?,
      specifications: row[11] != null ? jsonDecode(row[11] as String) : null,
      stock: row[12] as int,
      rating: row[13] != null ? (row[13] as num).toDouble() : null,
      reviewCount: row[14] as int,
      source: row[15] as String,
      sourceId: row[16] as String,
      createdAt: row[17] as DateTime,
      updatedAt: row[18] as DateTime,
    );
  }
}

/// Модель заказа
@JsonSerializable()
class Order {
  final String id;
  final String userId;
  final int totalAmount;
  final int? discountAmount;
  final String status;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.totalAmount,
    this.discountAmount,
    required this.status,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  factory Order.fromRow(List<dynamic> row) {
    return Order(
      id: row[0].toString(),
      userId: row[1].toString(),
      totalAmount: row[2] as int,
      discountAmount: row[3] as int?,
      status: row[4] as String,
      paymentMethod: row[5] as String?,
      createdAt: row[6] as DateTime,
      updatedAt: row[7] as DateTime,
    );
  }
}

/// Модель поста в соцсети
@JsonSerializable()
class Post {
  final String id;
  final String userId;
  final String? content;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final List<String> hashtags;
  final String? location;
  final bool isStory;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.userId,
    this.content,
    required this.imageUrls,
    required this.videoUrls,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.hashtags,
    this.location,
    required this.isStory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);

  factory Post.fromRow(List<dynamic> row) {
    return Post(
      id: row[0].toString(),
      userId: row[1].toString(),
      content: row[2] as String?,
      imageUrls: (row[3] as List<dynamic>).cast<String>(),
      videoUrls: (row[4] as List<dynamic>).cast<String>(),
      likeCount: row[5] as int,
      commentCount: row[6] as int,
      shareCount: row[7] as int,
      hashtags: (row[8] as List<dynamic>).cast<String>(),
      location: row[9] as String?,
      isStory: row[10] as bool,
      createdAt: row[11] as DateTime,
      updatedAt: row[12] as DateTime,
    );
  }
}

/// Модель комментария
@JsonSerializable()
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String? parentCommentId;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentCommentId,
    required this.likeCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  factory Comment.fromRow(List<dynamic> row) {
    return Comment(
      id: row[0].toString(),
      postId: row[1].toString(),
      userId: row[2].toString(),
      content: row[3] as String,
      parentCommentId: row[4]?.toString(),
      likeCount: row[5] as int,
      createdAt: row[6] as DateTime,
      updatedAt: row[7] as DateTime,
    );
  }
}

/// Модель лайка
@JsonSerializable()
class Like {
  final String id;
  final String userId;
  final String targetId;
  final String targetType; // 'post', 'comment', 'product'
  final DateTime createdAt;

  Like({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) => _$LikeFromJson(json);
  Map<String, dynamic> toJson() => _$LikeToJson(this);

  factory Like.fromRow(List<dynamic> row) {
    return Like(
      id: row[0].toString(),
      userId: row[1].toString(),
      targetId: row[2].toString(),
      targetType: row[3] as String,
      createdAt: row[4] as DateTime,
    );
  }
}

/// Модель подписки
@JsonSerializable()
class Follow {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  Follow({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) => _$FollowFromJson(json);
  Map<String, dynamic> toJson() => _$FollowToJson(this);

  factory Follow.fromRow(List<dynamic> row) {
    return Follow(
      id: row[0].toString(),
      followerId: row[1].toString(),
      followingId: row[2].toString(),
      createdAt: row[3] as DateTime,
    );
  }
}

/// Модель NFT
@JsonSerializable()
class NFT {
  final String id;
  final String tokenId;
  final String contractAddress;
  final String ownerAddress;
  final String tokenURI;
  final String name;
  final String? description;
  final String? imageUrl;
  final Map<String, dynamic>? attributes;
  final String type; // 'badge', 'coupon', 'collectible'
  final DateTime createdAt;
  final DateTime updatedAt;

  NFT({
    required this.id,
    required this.tokenId,
    required this.contractAddress,
    required this.ownerAddress,
    required this.tokenURI,
    required this.name,
    this.description,
    this.imageUrl,
    this.attributes,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NFT.fromJson(Map<String, dynamic> json) => _$NFTFromJson(json);
  Map<String, dynamic> toJson() => _$NFTToJson(this);

  factory NFT.fromRow(List<dynamic> row) {
    return NFT(
      id: row[0].toString(),
      tokenId: row[1].toString(),
      contractAddress: row[2] as String,
      ownerAddress: row[3] as String,
      tokenURI: row[4] as String,
      name: row[5] as String,
      description: row[6] as String?,
      imageUrl: row[7] as String?,
      attributes: row[8] != null ? jsonDecode(row[8] as String) : null,
      type: row[9] as String,
      createdAt: row[10] as DateTime,
      updatedAt: row[11] as DateTime,
    );
  }
}

/// Модель токена лояльности
@JsonSerializable()
class LoyaltyToken {
  final String id;
  final String userId;
  final String contractAddress;
  final String balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoyaltyToken({
    required this.id,
    required this.userId,
    required this.contractAddress,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoyaltyToken.fromJson(Map<String, dynamic> json) => _$LoyaltyTokenFromJson(json);
  Map<String, dynamic> toJson() => _$LoyaltyTokenToJson(this);

  factory LoyaltyToken.fromRow(List<dynamic> row) {
    return LoyaltyToken(
      id: row[0].toString(),
      userId: row[1].toString(),
      contractAddress: row[2] as String,
      balance: row[3] as String,
      createdAt: row[4] as DateTime,
      updatedAt: row[5] as DateTime,
    );
  }
}