import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/parser_service.dart';
import '../widgets/product_card.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cache_service.dart';
import '../services/favorites_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  List<Product> favorites = [];
  bool loading = true;
  String status = 'Загрузка...';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(()=> loading=true);
    try {
      final parsed = await ApiService.fetchProducts();
      if (parsed.isNotEmpty) {
        products = parsed;
        await CacheService.saveProducts(products);
        status = 'Данные обновлены';
      } else {
        products = await CacheService.loadProducts();
        status = 'Показываем кеш';
      }
    } catch (e) {
      products = await CacheService.loadProducts();
      status = 'Ошибка: $e — показываем кеш';
    } finally {
      favorites = await FavoritesService.loadFavorites();
      setState(()=> loading=false);
    }
  }

  Future<void> _toggleFav(Product p) async {
    final exists = favorites.any((f) => f.id == p.id);
    if (exists) favorites.removeWhere((f) => f.id==p.id); else favorites.add(p);
    await FavoritesService.saveFavorites(favorites);
    setState(()=>{});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Modus', style: GoogleFonts.playfairDisplay()),
        backgroundColor: Colors.black,
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _load)],
      ),
      body: loading ? Center(child: Column(mainAxisSize: MainAxisSize.min, children:[CircularProgressIndicator(), SizedBox(height:12), Text(status)])) :
      Column(
        children: [
          Container(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/banner.jpg', fit: BoxFit.cover),
                Container(color: Colors.black.withOpacity(0.25)),
                Positioned(left:20, top:30, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('My Modus', style: GoogleFonts.playfairDisplay(textStyle: TextStyle(color: Colors.pink[100], fontSize:28, fontWeight: FontWeight.w700))),
                  SizedBox(height:8),
                  Text('Curated looks • New season', style: TextStyle(color: Colors.white70))
                ])),
                Positioned(right:16, bottom:16, child: ElevatedButton(onPressed: (){}, child: Text('Коллекция')))
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.66, crossAxisSpacing:12, mainAxisSpacing:12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                final isFav = favorites.any((f)=>f.id==p.id);
                return ProductCard(product: p, isFav: isFav, onFav: ()=> _toggleFav(p));
              },
            ),
          )
        ],
      ),
    );
  }
}
