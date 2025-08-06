class Product {
  final String title;
  final int? price;
  final int? oldPrice;
  final int? discount;
  final String? image;
  final String link;

  Product({
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.image,
    required this.link,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['title'],
      price: json['price'],
      oldPrice: json['oldPrice'],
      discount: json['discount'],
      image: json['image'],
      link: json['link'],
    );
  }

  factory Product.fromWildberriesJson(Map<String, dynamic> json) {
    final price = json['salePriceU'] != null ? (json['salePriceU'] / 100).round() : null;
    final oldPrice = json['priceU'] != null ? (json['priceU'] / 100).round() : null;
    final discount = oldPrice != null && price != null ? ((oldPrice - price) / oldPrice * 100).round() : null;
    
    // Wildberries image URL construction
    final imageId = json['id'];
    final imageUrl = imageId != null 
        ? "https://images.wbstatic.net/c246x328/new/$imageId-1.jpg"
        : null;
    
    // Wildberries product link construction
    final productId = json['id'];
    final productLink = productId != null 
        ? "https://www.wildberries.ru/catalog/$productId/detail.aspx"
        : "https://www.wildberries.ru/brands/311036101-my-modus";

    return Product(
      title: json['name'] ?? json['title'] ?? 'My Modus Product',
      price: price,
      oldPrice: oldPrice,
      discount: discount,
      image: imageUrl,
      link: productLink,
    );
  }
} 