class Product {
  final String id;
  final String title;
  final int? price;
  final int? oldPrice;
  final int? discount;
  final String? image;
  final String link;
  final String? source;
  final String? description;
  final String? location;
  final String? condition;
  final String? sellerType;
  final double? rating;
  final int? reviewCount;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.image,
    required this.link,
    this.source,
    this.description,
    this.location,
    this.condition,
    this.sellerType,
    this.rating,
    this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? json['link'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] is int ? json['price'] : (json['price'] != null ? int.tryParse(json['price'].toString()) : null),
      oldPrice: json['oldPrice'] is int ? json['oldPrice'] : (json['oldPrice'] != null ? int.tryParse(json['oldPrice'].toString()) : null),
      discount: json['discount'] is int ? json['discount'] : (json['discount'] != null ? int.tryParse(json['discount'].toString()) : null),
      image: json['image'],
      link: json['link'] ?? '',
      source: json['source'] ?? json['marketplace'],
      description: json['description'],
      location: json['location'],
      condition: json['condition'],
      sellerType: json['seller_type'],
      rating: json['rating'] is double ? json['rating'] : (json['rating'] != null ? double.tryParse(json['rating'].toString()) : null),
      reviewCount: json['review_count'] is int ? json['review_count'] : (json['review_count'] != null ? int.tryParse(json['review_count'].toString()) : null),
    );
  }

  factory Product.fromAvito(Map<String, dynamic> json) {
    return Product(
      id: json['external_id'] ?? json['url'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] is int ? json['price'] : (json['price'] != null ? int.tryParse(json['price'].toString().replaceAll(RegExp(r'[^\d]'), '')) : null),
      oldPrice: null, // Avito обычно не показывает старую цену
      discount: null,
      image: json['image_url'],
      link: json['url'] ?? '',
      source: 'avito',
      description: json['description'],
      location: json['location'],
      condition: json['condition'],
      sellerType: json['seller_type'],
      rating: null, // Avito не использует рейтинги товаров
      reviewCount: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'oldPrice': oldPrice,
      'discount': discount,
      'image': image,
      'link': link,
      'source': source,
      'description': description,
      'location': location,
      'condition': condition,
      'seller_type': sellerType,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  bool get isFromAvito => source == 'avito';
  
  String get formattedPrice {
    if (price == null) return 'Цена не указана';
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]} ')} ₽';
  }
  
  String get sourceDisplayName {
    switch (source) {
      case 'avito':
        return 'Avito';
      case 'ozon':
        return 'Ozon';
      case 'wildberries':
        return 'Wildberries';
      case 'lamoda':
        return 'Lamoda';
      default:
        return source ?? 'Неизвестно';
    }
  }
}
