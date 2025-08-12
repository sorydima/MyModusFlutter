import 'package:flutter/material.dart';
import '../services/api.dart';
import '../components/product_card.dart';
import '../components/story_widget.dart';
import 'product_detail.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<dynamic> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    try {
      final res = await fetchProducts();
      setState(() { items = res; loading = false; });
    } catch (e) {
      setState(() { items = []; loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final demoStories = [
      StoryItem(id:'s1', image:'https://picsum.photos/seed/1/400/800', title:'New in'),
      StoryItem(id:'s2', image:'https://picsum.photos/seed/2/400/800', title:'Sale'),
      StoryItem(id:'s3', image:'https://picsum.photos/seed/3/400/800', title:'Trending'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('MyModus')),
      body: loading ? Center(child:CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: () async { load(); },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: StoriesReel(items: demoStories)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal:12, vertical:8),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childCount: items.length,
                itemBuilder: (ctx, i) {
                  final p = items[i];
                  return GestureDetector(
                    onDoubleTap: (){}, // handled in card
                    child: ProductCard(product: p, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetail(product: p)));
                    }),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create_post'),
        child: Icon(Icons.add),
      ),
    );
  }
}
