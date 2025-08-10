import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import '../theme.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int cartCount;
  final int favoritesCount;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.cartCount,
    required this.favoritesCount,
  }) : super(key: key);

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.search,
            label: 'Search',
            index: 1,
          ),
          _buildCartButton(),
          _buildNavItem(
            icon: Icons.favorite,
            label: 'Favorites',
            index: 3,
            badgeCount: widget.favoritesCount,
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Profile',
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    int? badgeCount,
  }) {
    final isSelected = widget.currentIndex == index;
    
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartButton() {
    return GestureDetector(
      onTap: () => widget.onTap(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Badge(
          badgeContent: widget.cartCount > 0
              ? Text(
                  widget.cartCount > 99 ? '99+' : widget.cartCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
          badgeStyle: BadgeStyle(
            badgeColor: AppTheme.primaryColor,
            padding: const EdgeInsets.all(2),
          ),
          position: BadgePosition.topEnd(top: 0, end: 0),
          child: Icon(
            Icons.shopping_cart,
            size: 24,
            color: widget.currentIndex == 2 ? AppTheme.primaryColor : Colors.grey,
          ),
        ),
      ),
    );
  }
}