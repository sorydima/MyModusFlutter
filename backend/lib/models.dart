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

/// Модель пользовательских предпочтений
@JsonSerializable()
class UserPreferences {
  final String id;
  final String userId;
  final Map<String, double> categoryPreferences;
  final Map<String, double> brandPreferences;
  final Map<String, int> priceRange; // min, max
  final Map<String, String> sizePreferences;
  final List<String> colorPreferences;
  final List<String> stylePreferences;
  final Map<String, String> seasonalPreferences;
  final Map<String, int> shoppingFrequency;
  final int budgetMonthly;
  final List<String> preferredMarketplaces;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.id,
    required this.userId,
    required this.categoryPreferences,
    required this.brandPreferences,
    required this.priceRange,
    required this.sizePreferences,
    required this.colorPreferences,
    required this.stylePreferences,
    required this.seasonalPreferences,
    required this.shoppingFrequency,
    required this.budgetMonthly,
    required this.preferredMarketplaces,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  factory UserPreferences.fromRow(List<dynamic> row) {
    return UserPreferences(
      id: row[0].toString(),
      userId: row[1].toString(),
      categoryPreferences: Map<String, double>.from(jsonDecode(row[2] as String? ?? '{}')),
      brandPreferences: Map<String, double>.from(jsonDecode(row[3] as String? ?? '{}')),
      priceRange: Map<String, int>.from(jsonDecode(row[4] as String? ?? '{"min": 0, "max": 1000000}')),
      sizePreferences: Map<String, String>.from(jsonDecode(row[5] as String? ?? '{}')),
      colorPreferences: List<String>.from(row[6] as List? ?? []),
      stylePreferences: List<String>.from(row[7] as List? ?? []),
      seasonalPreferences: Map<String, String>.from(jsonDecode(row[8] as String? ?? '{}')),
      shoppingFrequency: Map<String, int>.from(jsonDecode(row[9] as String? ?? '{}')),
      budgetMonthly: row[10] as int? ?? 0,
      preferredMarketplaces: List<String>.from(row[11] as List? ?? []),
      createdAt: row[12] as DateTime,
      updatedAt: row[13] as DateTime,
    );
  }
}

/// Модель просмотра товара
@JsonSerializable()
class UserProductView {
  final String id;
  final String userId;
  final String productId;
  final String productTitle;
  final int productPrice;
  final String? productCategory;
  final String? productBrand;
  final String productSource;
  final int viewDuration;
  final bool clickedDetails;
  final bool addedToWishlist;
  final DateTime viewedAt;

  UserProductView({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    this.productCategory,
    this.productBrand,
    required this.productSource,
    required this.viewDuration,
    required this.clickedDetails,
    required this.addedToWishlist,
    required this.viewedAt,
  });

  factory UserProductView.fromJson(Map<String, dynamic> json) => _$UserProductViewFromJson(json);
  Map<String, dynamic> toJson() => _$UserProductViewToJson(this);

  factory UserProductView.fromRow(List<dynamic> row) {
    return UserProductView(
      id: row[0].toString(),
      userId: row[1].toString(),
      productId: row[2].toString(),
      productTitle: row[3] as String,
      productPrice: row[4] as int,
      productCategory: row[5] as String?,
      productBrand: row[6] as String?,
      productSource: row[7] as String,
      viewDuration: row[8] as int,
      clickedDetails: row[9] as bool,
      addedToWishlist: row[10] as bool,
      viewedAt: row[11] as DateTime,
    );
  }
}

/// Модель покупки пользователя
@JsonSerializable()
class UserPurchase {
  final String id;
  final String userId;
  final String productId;
  final String productTitle;
  final int productPrice;
  final String? productCategory;
  final String? productBrand;
  final String productSource;
  final int quantity;
  final int totalAmount;
  final int? purchaseSatisfaction;
  final String? purchaseReason;
  final DateTime purchasedAt;

  UserPurchase({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    this.productCategory,
    this.productBrand,
    required this.productSource,
    required this.quantity,
    required this.totalAmount,
    this.purchaseSatisfaction,
    this.purchaseReason,
    required this.purchasedAt,
  });

  factory UserPurchase.fromJson(Map<String, dynamic> json) => _$UserPurchaseFromJson(json);
  Map<String, dynamic> toJson() => _$UserPurchaseToJson(this);

  factory UserPurchase.fromRow(List<dynamic> row) {
    return UserPurchase(
      id: row[0].toString(),
      userId: row[1].toString(),
      productId: row[2].toString(),
      productTitle: row[3] as String,
      productPrice: row[4] as int,
      productCategory: row[5] as String?,
      productBrand: row[6] as String?,
      productSource: row[7] as String,
      quantity: row[8] as int,
      totalAmount: row[9] as int,
      purchaseSatisfaction: row[10] as int?,
      purchaseReason: row[11] as String?,
      purchasedAt: row[12] as DateTime,
    );
  }
}

/// Модель товара в вишлисте
@JsonSerializable()
class UserWishlistItem {
  final String id;
  final String userId;
  final String productId;
  final String productTitle;
  final int productPrice;
  final String? productCategory;
  final String? productBrand;
  final String productSource;
  final String productUrl;
  final String? productImageUrl;
  final int priority;
  final int? priceAlertThreshold;
  final String? notes;
  final DateTime addedAt;
  final DateTime updatedAt;

  UserWishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    this.productCategory,
    this.productBrand,
    required this.productSource,
    required this.productUrl,
    this.productImageUrl,
    required this.priority,
    this.priceAlertThreshold,
    this.notes,
    required this.addedAt,
    required this.updatedAt,
  });

  factory UserWishlistItem.fromJson(Map<String, dynamic> json) => _$UserWishlistItemFromJson(json);
  Map<String, dynamic> toJson() => _$UserWishlistItemToJson(this);

  factory UserWishlistItem.fromRow(List<dynamic> row) {
    return UserWishlistItem(
      id: row[0].toString(),
      userId: row[1].toString(),
      productId: row[2].toString(),
      productTitle: row[3] as String,
      productPrice: row[4] as int,
      productCategory: row[5] as String?,
      productBrand: row[6] as String?,
      productSource: row[7] as String,
      productUrl: row[8] as String,
      productImageUrl: row[9] as String?,
      priority: row[10] as int,
      priceAlertThreshold: row[11] as int?,
      notes: row[12] as String?,
      addedAt: row[13] as DateTime,
      updatedAt: row[14] as DateTime,
    );
  }
}

/// Модель AI-рекомендации
@JsonSerializable()
class AIRecommendation {
  final String id;
  final String userId;
  final String productId;
  final String productTitle;
  final int productPrice;
  final String? productCategory;
  final String? productBrand;
  final String productSource;
  final String productUrl;
  final String? productImageUrl;
  final double recommendationScore;
  final List<String> recommendationReasons;
  final String recommendationType;
  final bool isViewed;
  final bool isClicked;
  final bool isPurchased;
  final DateTime createdAt;
  final DateTime? expiresAt;

  AIRecommendation({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    this.productCategory,
    this.productBrand,
    required this.productSource,
    required this.productUrl,
    this.productImageUrl,
    required this.recommendationScore,
    required this.recommendationReasons,
    required this.recommendationType,
    required this.isViewed,
    required this.isClicked,
    required this.isPurchased,
    required this.createdAt,
    this.expiresAt,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) => _$AIRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$AIRecommendationToJson(this);

  factory AIRecommendation.fromRow(List<dynamic> row) {
    return AIRecommendation(
      id: row[0].toString(),
      userId: row[1].toString(),
      productId: row[2].toString(),
      productTitle: row[3] as String,
      productPrice: row[4] as int,
      productCategory: row[5] as String?,
      productBrand: row[6] as String?,
      productSource: row[7] as String,
      productUrl: row[8] as String,
      productImageUrl: row[9] as String?,
      recommendationScore: (row[10] as num).toDouble(),
      recommendationReasons: List<String>.from(jsonDecode(row[11] as String? ?? '[]')),
      recommendationType: row[12] as String,
      isViewed: row[13] as bool,
      isClicked: row[14] as bool,
      isPurchased: row[15] as bool,
      createdAt: row[16] as DateTime,
      expiresAt: row[17] as DateTime?,
    );
  }
}

/// Модель анализа пользовательских трендов
@JsonSerializable()
class UserTrendAnalysis {
  final String id;
  final String userId;
  final String analysisType;
  final Map<String, dynamic> analysisData;
  final double confidenceScore;
  final DateTime generatedAt;
  final DateTime? validUntil;

  UserTrendAnalysis({
    required this.id,
    required this.userId,
    required this.analysisType,
    required this.analysisData,
    required this.confidenceScore,
    required this.generatedAt,
    this.validUntil,
  });

  factory UserTrendAnalysis.fromJson(Map<String, dynamic> json) => _$UserTrendAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$UserTrendAnalysisToJson(this);

  factory UserTrendAnalysis.fromRow(List<dynamic> row) {
    return UserTrendAnalysis(
      id: row[0].toString(),
      userId: row[1].toString(),
      analysisType: row[2] as String,
      analysisData: Map<String, dynamic>.from(jsonDecode(row[3] as String)),
      confidenceScore: (row[4] as num).toDouble(),
      generatedAt: row[5] as DateTime,
      validUntil: row[6] as DateTime?,
    );
  }
}

/// Модель профиля лояльности пользователя
@JsonSerializable()
class UserLoyaltyProfile {
  final String id;
  final String userId;
  final String? walletAddress;
  final double loyaltyPoints;
  final String loyaltyTier;
  final double totalSpent;
  final double totalRewardsEarned;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserLoyaltyProfile({
    required this.id,
    required this.userId,
    this.walletAddress,
    required this.loyaltyPoints,
    required this.loyaltyTier,
    required this.totalSpent,
    required this.totalRewardsEarned,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserLoyaltyProfile.fromJson(Map<String, dynamic> json) => _$UserLoyaltyProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserLoyaltyProfileToJson(this);

  factory UserLoyaltyProfile.fromRow(List<dynamic> row) {
    return UserLoyaltyProfile(
      id: row[0].toString(),
      userId: row[1].toString(),
      walletAddress: row[2] as String?,
      loyaltyPoints: (row[3] as num).toDouble(),
      loyaltyTier: row[4] as String,
      totalSpent: (row[5] as num).toDouble(),
      totalRewardsEarned: (row[6] as num).toDouble(),
      createdAt: row[7] as DateTime,
      updatedAt: row[8] as DateTime,
    );
  }
}

/// Модель уровня лояльности
@JsonSerializable()
class LoyaltyTier {
  final String id;
  final String tierName;
  final int minPoints;
  final double minSpent;
  final double rewardMultiplier;
  final Map<String, dynamic> benefits;
  final DateTime createdAt;

  LoyaltyTier({
    required this.id,
    required this.tierName,
    required this.minPoints,
    required this.minSpent,
    required this.rewardMultiplier,
    required this.benefits,
    required this.createdAt,
  });

  factory LoyaltyTier.fromJson(Map<String, dynamic> json) => _$LoyaltyTierFromJson(json);
  Map<String, dynamic> toJson() => _$LoyaltyTierToJson(this);

  factory LoyaltyTier.fromRow(List<dynamic> row) {
    return LoyaltyTier(
      id: row[0].toString(),
      tierName: row[1] as String,
      minPoints: row[2] as int,
      minSpent: (row[3] as num).toDouble(),
      rewardMultiplier: (row[4] as num).toDouble(),
      benefits: Map<String, dynamic>.from(jsonDecode(row[5] as String)),
      createdAt: row[6] as DateTime,
    );
  }
}

/// Модель транзакции лояльности
@JsonSerializable()
class LoyaltyTransaction {
  final String id;
  final String userId;
  final String transactionType;
  final double pointsAmount;
  final double? cryptoAmount;
  final String? description;
  final Map<String, dynamic>? metadata;
  final String? blockchainTxHash;
  final String status;
  final DateTime createdAt;
  final DateTime? confirmedAt;

  LoyaltyTransaction({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.pointsAmount,
    this.cryptoAmount,
    this.description,
    this.metadata,
    this.blockchainTxHash,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) => _$LoyaltyTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$LoyaltyTransactionToJson(this);

  factory LoyaltyTransaction.fromRow(List<dynamic> row) {
    return LoyaltyTransaction(
      id: row[0].toString(),
      userId: row[1].toString(),
      transactionType: row[2] as String,
      pointsAmount: (row[3] as num).toDouble(),
      cryptoAmount: row[4] != null ? (row[4] as num).toDouble() : null,
      description: row[5] as String?,
      metadata: row[6] != null ? Map<String, dynamic>.from(jsonDecode(row[6] as String)) : null,
      blockchainTxHash: row[7] as String?,
      status: row[8] as String,
      createdAt: row[9] as DateTime,
      confirmedAt: row[10] as DateTime?,
    );
  }
}

/// Модель крипто-награды
@JsonSerializable()
class CryptoReward {
  final String id;
  final String rewardType;
  final int pointsRequired;
  final double cryptoAmount;
  final String tokenSymbol;
  final bool isActive;
  final int maxDailyClaims;
  final DateTime createdAt;

  CryptoReward({
    required this.id,
    required this.rewardType,
    required this.pointsRequired,
    required this.cryptoAmount,
    required this.tokenSymbol,
    required this.isActive,
    required this.maxDailyClaims,
    required this.createdAt,
  });

  factory CryptoReward.fromJson(Map<String, dynamic> json) => _$CryptoRewardFromJson(json);
  Map<String, dynamic> toJson() => _$CryptoRewardToJson(this);

  factory CryptoReward.fromRow(List<dynamic> row) {
    return CryptoReward(
      id: row[0].toString(),
      rewardType: row[1] as String,
      pointsRequired: row[2] as int,
      cryptoAmount: (row[3] as num).toDouble(),
      tokenSymbol: row[4] as String,
      isActive: row[5] as bool,
      maxDailyClaims: row[6] as int,
      createdAt: row[7] as DateTime,
    );
  }
}

/// Модель достижения пользователя
@JsonSerializable()
class UserAchievement {
  final String id;
  final String userId;
  final String achievementType;
  final String achievementName;
  final String? description;
  final int pointsRewarded;
  final double? cryptoRewarded;
  final DateTime achievedAt;
  final Map<String, dynamic>? metadata;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementType,
    required this.achievementName,
    this.description,
    required this.pointsRewarded,
    this.cryptoRewarded,
    required this.achievedAt,
    this.metadata,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) => _$UserAchievementFromJson(json);
  Map<String, dynamic> toJson() => _$UserAchievementToJson(this);

  factory UserAchievement.fromRow(List<dynamic> row) {
    return UserAchievement(
      id: row[0].toString(),
      userId: row[1].toString(),
      achievementType: row[2] as String,
      achievementName: row[3] as String,
      description: row[4] as String?,
      pointsRewarded: row[5] as int,
      cryptoRewarded: row[6] != null ? (row[6] as num).toDouble() : null,
      achievedAt: row[7] as DateTime,
      metadata: row[8] != null ? Map<String, dynamic>.from(jsonDecode(row[8] as String)) : null,
    );
  }
}

/// Модель реферальной системы
@JsonSerializable()
class UserReferral {
  final String id;
  final String referrerId;
  final String referredId;
  final String referralCode;
  final String status;
  final int pointsRewarded;
  final double cryptoRewarded;
  final DateTime? completedAt;
  final DateTime createdAt;

  UserReferral({
    required this.id,
    required this.referrerId,
    required this.referredId,
    required this.referralCode,
    required this.status,
    required this.pointsRewarded,
    required this.cryptoRewarded,
    this.completedAt,
    required this.createdAt,
  });

  factory UserReferral.fromJson(Map<String, dynamic> json) => _$UserReferralFromJson(json);
  Map<String, dynamic> toJson() => _$UserReferralToJson(this);

  factory UserReferral.fromRow(List<dynamic> row) {
    return UserReferral(
      id: row[0].toString(),
      referrerId: row[1].toString(),
      referredId: row[2].toString(),
      referralCode: row[3] as String,
      status: row[4] as String,
      pointsRewarded: row[5] as int,
      cryptoRewarded: (row[6] as num).toDouble(),
      completedAt: row[7] as DateTime?,
      createdAt: row[8] as DateTime,
    );
  }
}

/// Модель ежедневных наград за вход
@JsonSerializable()
class DailyLoginReward {
  final String id;
  final String userId;
  final DateTime loginDate;
  final int pointsEarned;
  final double? cryptoEarned;
  final int streakDays;
  final DateTime createdAt;

  DailyLoginReward({
    required this.id,
    required this.userId,
    required this.loginDate,
    required this.pointsEarned,
    this.cryptoEarned,
    required this.streakDays,
    required this.createdAt,
  });

  factory DailyLoginReward.fromJson(Map<String, dynamic> json) => _$DailyLoginRewardFromJson(json);
  Map<String, dynamic> toJson() => _$DailyLoginRewardToJson(this);

  factory DailyLoginReward.fromRow(List<dynamic> row) {
    return DailyLoginReward(
      id: row[0].toString(),
      userId: row[1].toString(),
      loginDate: row[2] as DateTime,
      pointsEarned: row[3] as int,
      cryptoEarned: row[4] != null ? (row[4] as num).toDouble() : null,
      streakDays: row[5] as int,
      createdAt: row[6] as DateTime,
    );
  }
}