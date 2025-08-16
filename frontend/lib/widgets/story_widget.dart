import 'package:flutter/material.dart';

class StoryWidget extends StatelessWidget {
  final String username;
  final String imageUrl;
  final bool isViewed;

  const StoryWidget({
    super.key,
    required this.username,
    required this.imageUrl,
    this.isViewed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isViewed
                  ? null
                  : const LinearGradient(
                      colors: [Colors.purple, Colors.orange, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              border: Border.all(
                color: isViewed
                    ? Colors.grey.shade300
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            username,
            style: TextStyle(
              fontSize: 12,
              color: isViewed
                  ? Colors.grey.shade600
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isViewed ? FontWeight.normal : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
