import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import '../theme.dart';

class ProductFeedScreen extends StatefulWidget {
  const ProductFeedScreen({Key? key}) : super(key: key);

  @override
  State<ProductFeedScreen> createState() => _ProductFeedScreenState();
}

class _ProductFeedScreenState extends State<ProductFeedScreen> {
  final ApiService _apiService = ApiService();
  final RefreshController _refreshController = RefreshController();
  
  List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (isRefresh) {
        _products.clear();
        _currentPage = 1;
      }

      final newProducts = await _apiService.getProducts(limit: _limit);
      
      setState(() {
        if (isRefresh) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }
        _isLoading = false;
        _hasMore = newProducts.length == _limit;
        _currentPage++;
      });

      if (isRefresh) {
        _refreshController.refreshCompleted();
      } else {
        _refreshController.loadComplete();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (isRefresh) {
        _refreshController.refreshFailed();
      } else {
        _refreshController.loadFailed();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (!_hasMore || _isLoading) return;
    await _loadProducts();
  }

  void _onProductTap(ProductModel product) {
    Navigator.pushNamed(
      context,
      '/product-detail',
      arguments: product,
    ).then((_) {
      // Refresh feed when returning from detail
      _loadProducts(isRefresh: true);
    });
  }

  void _onFavoriteTap(ProductModel product) {
    // TODO: Implement favorite functionality
    setState(() {
      // Update product favorite status
    });
  }

  void _onAddToCart(ProductModel product) {
    // TODO: Implement add to cart functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${product.title} to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('MyModus'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => Navigator.pushNamed(context, '/filters'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: _hasMore,
        header: const WaterDropHeader(),
        footer: CustomFooter(
          builder: (context, mode) {
            if (mode == LoadStatus.idle) {
              return const SizedBox.shrink();
            } else if (mode == LoadStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (mode == LoadStatus.failed) {
              return const Center(child: Text('Load failed'));
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        onRefresh: () => _loadProducts(isRefresh: true),
        onLoading: _loadMoreProducts,
        child: _buildProductGrid(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _loadProducts(isRefresh: true),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading && _products.isEmpty) {
      return _buildSkeletonGrid();
    }

    if (_products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ProductCard(
          product: product,
          onTap: () => _onProductTap(product),
          onFavorite: () => _onFavoriteTap(product),
          onAddToCart: () => _onAddToCart(product),
        );
      },
    );
  }

  Widget _buildSkeletonGrid() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const ProductCardSkeleton();
      },
    );
  }
}