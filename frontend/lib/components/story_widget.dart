import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

class StoryItem {
  final String id;
  final String image;
  final String title;
  StoryItem({required this.id, required this.image, required this.title});
}

class StoriesReel extends StatefulWidget {
  final List<StoryItem> items;
  StoriesReel({required this.items, Key? key}): super(key: key);

  @override
  _StoriesReelState createState() => _StoriesReelState();
}

class _StoriesReelState extends State<StoriesReel> {
  int index = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startAutoplay();
  }

  void startAutoplay() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 3), (_) {
      setState(() {
        index = (index + 1) % widget.items.length;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        itemBuilder: (ctx, i) {
          final it = widget.items[i];
          final active = i == index;
          return GestureDetector(
            onTap: () {
              // open story viewer
              Navigator.push(context, PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => StoryViewer(items: widget.items, initialIndex: i)
              ));
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: active?4:12),
              width: active?90:72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius:4)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(imageUrl: it.image, fit: BoxFit.cover, placeholder: (_,__)=>Container(color:Colors.grey[300])),
              ),
            ),
          );
        },
      ),
    );
  }
}

class StoryViewer extends StatefulWidget {
  final List<StoryItem> items;
  final int initialIndex;
  StoryViewer({required this.items, required this.initialIndex});

  @override
  _StoryViewerState createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  late PageController ctrl;
  @override
  void initState() {
    super.initState();
    ctrl = PageController(initialPage: widget.initialIndex);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: PageView.builder(
          controller: ctrl,
          itemCount: widget.items.length,
          itemBuilder: (ctx, i) {
            final it = widget.items[i];
            return Stack(
              children: [
                Center(child: CachedNetworkImage(imageUrl: it.image, fit: BoxFit.contain)),
                Positioned(top:20,left:20, child: Text(it.title, style: TextStyle(color:Colors.white, fontSize:18)))
              ],
            );
          },
        ),
      ),
    );
  }
}
