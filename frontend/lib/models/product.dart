class Product {
  final String id;
  final String title;
  final int? price;
  final int? oldPrice;
  final int? discount;
  final String? image;
  final String link;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.image,
    required this.link,
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
    };
  }
}
