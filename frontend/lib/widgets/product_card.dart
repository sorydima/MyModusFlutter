import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onFav;
  final bool isFav;

  const ProductCard({super.key, required this.product, this.onFav, this.isFav = false});

  void _launchLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceText = product.price?.toString() ?? '-';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 6,
      child: InkWell(
        onTap: () => _launchLink(product.link),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                child: product.image != null
                    ? Image.network(product.image!, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_,__,___)=>Container(color: Colors.grey))
                    : Container(color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:8.0, vertical:6),
              child: Row(children: [
                Text('$priceText ₽', style: TextStyle(color: Colors.pink[700], fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: Icon(isFav? Icons.favorite: Icons.favorite_border, color: isFav? Colors.red: Colors.grey), onPressed: onFav)
              ]),
            )
          ],
        ),
      ),
    );
  }
}
