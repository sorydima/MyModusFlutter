import 'package:flutter/material.dart';

class ShopProfile extends StatelessWidget {
  final Map<String, dynamic> shop;
  const ShopProfile({required this.shop, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = shop['name'] ?? 'Shop';
    final banner = shop['banner'] ?? '';
    final bio = shop['bio'] ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        children: [
          if (banner!='') Image.network(banner, height:160, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Container(height:160,color:Colors.grey[300])) else Container(height:160,color:Colors.grey[300]),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
                SizedBox(height:8),
                Text(bio),
                SizedBox(height:12),
                Text('Products', style: TextStyle(fontWeight: FontWeight.w600)),
                // products list placeholder
                SizedBox(height:200, child: Center(child: Text('Shop products will show here')))
              ],
            ),
          )
        ],
      ),
    );
  }
}
