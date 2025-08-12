import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onTap;

  const ProductCard({required this.product, this.onTap, Key? key}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  bool liked = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    setState(() { liked = true; });
    _animController.forward(from:0.0);
    Timer(Duration(milliseconds: 800), () { _animController.reverse(); });
    // TODO: call like API
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final image = product['image'] ?? '';
    final title = product['title'] ?? 'No title';
    final price = product['price'] ?? '';
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: _onDoubleTap,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: product['external_id'] ?? product['title'] ?? UniqueKey().toString(),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: image,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (ctx, url) => Container(height:220,color:Colors.grey[300]),
                  errorWidget: (ctx, url, err) => Container(height:220,color:Colors.grey[300]),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height:6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(price, style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                      ScaleTransition(
                        scale: Tween(begin: 0.8, end: 1.4).animate(CurvedAnimation(parent: _animController, curve: Curves.elasticOut)),
                        child: Icon(liked?Icons.favorite:Icons.favorite_border, color: liked?Colors.red:Colors.grey)
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
