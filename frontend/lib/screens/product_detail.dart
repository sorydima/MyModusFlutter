import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetail extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetail({required this.product, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final images = product['images'] ?? (product['image']!=null ? [product['image']] : []);
    final title = product['title'] ?? 'No title';
    final price = product['price'] ?? '';
    final description = product['description'] ?? '';
    final heroTag = product['external_id'] ?? product['title'] ?? UniqueKey().toString();
    return Scaffold(
      appBar: AppBar(title: Text('Product')),
      body: ListView(
        children: [
          if (images.isNotEmpty)
            Hero(
              tag: heroTag,
              child: SizedBox(
                height: 320,
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (ctx, i) => CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover, errorWidget: (_,__,___)=>Container(color:Colors.grey[300])),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
                SizedBox(height:8),
                Text(price, style: TextStyle(color: Colors.green[700], fontSize:18)),
                SizedBox(height:12),
                Text(description),
                SizedBox(height:20),
                ElevatedButton.icon(onPressed: (){}, icon: Icon(Icons.shopping_cart), label: Text('Buy')),
              ],
            ),
          )
        ],
      ),
    );
  }
}
