import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetail extends StatelessWidget {
  final Product product;
  const ProductDetail({super.key, required this.product});

  void _launchLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title, style: GoogleFonts.playfairDisplay()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Image.network(product.image ?? '', height: 320, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Container(height:320,color:Colors.grey)),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.title, style: GoogleFonts.playfairDisplay(textStyle: TextStyle(fontSize:22, fontWeight: FontWeight.w700))),
              SizedBox(height:8),
              Row(children: [
                Text('${product.price ?? '-'} ₽', style: TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: Colors.pink[700])),
                SizedBox(width:8),
                if (product.oldPrice != null) Text('${product.oldPrice} ₽', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                Spacer(),
                ElevatedButton(onPressed: ()=> _launchLink(product.link), child: Text('Купить на Wildberries'))
              ]),
              SizedBox(height:12),
              Text('Описание', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height:6),
              Text('Стильное изделие от My Modus. Подробности и размеры смотрите на странице Wildberries.'),
            ]),
          )
        ],
      ),
    );
  }
}
