import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/product_model.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _favoriteController;
  late Animation<double> _imageScale;
  late Animation<double> _favoriteScale;
  
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  bool _isExpanded = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _imageScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeInOut),
    );
    
    _favoriteScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _favoriteController, curve: Curves.elasticOut),
    );
    
    // Устанавливаем значения по умолчанию
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first;
    }
    if (widget.product.colors.isNotEmpty) {
      _selectedColor = widget.product.colors.first;
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // AppBar с изображением товара
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _toggleFavorite();
                },
                icon: AnimatedBuilder(
                  animation: _favoriteScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _favoriteScale.value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          widget.product.isFavorite 
                              ? Icons.favorite 
                              : Icons.favorite_border,
                          color: widget.product.isFavorite 
                              ? Colors.red 
                              : theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showShareDialog();
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.share,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProductImages(),
            ),
          ),
          
          // Основной контент
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок и бренд
                  _buildProductHeader(),
                  
                  const SizedBox(height: 20),
                  
                  // Цена и скидка
                  _buildPriceSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Рейтинг и отзывы
                  _buildRatingSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Выбор размера
                  if (widget.product.sizes.isNotEmpty) ...[
                    _buildSizeSelector(),
                    const SizedBox(height: 20),
                  ],
                  
                  // Выбор цвета
                  if (widget.product.colors.isNotEmpty) ...[
                    _buildColorSelector(),
                    const SizedBox(height: 20),
                  ],
                  
                  // Выбор количества
                  _buildQuantitySelector(),
                  
                  const SizedBox(height: 20),
                  
                  // Описание товара
                  _buildDescriptionSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Характеристики
                  _buildSpecificationsSection(),
                  
                  const SizedBox(height: 100), // Место для кнопки добавления в корзину
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Кнопка добавления в корзину
      bottomNavigationBar: _buildAddToCartButton(),
    );
  }

  Widget _buildProductImages() {
    return Stack(
      children: [
        // Основное изображение
        AnimatedBuilder(
          animation: _imageScale,
          builder: (context, child) {
            return Transform.scale(
              scale: _imageScale.value,
              child: GestureDetector(
                onTapDown: (_) => _imageController.forward(),
                onTapUp: (_) => _imageController.reverse(),
                onTapCancel: () => _imageController.reverse(),
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 400,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: double.infinity,
                      height: 400,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 400,
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Индикатор изображений (если их несколько)
        if (widget.product.sizes.length > 1 || widget.product.colors.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                (widget.product.sizes.length > 1 ? widget.product.sizes.length : 1) +
                (widget.product.colors.length > 1 ? widget.product.colors.length : 1),
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index == _currentImageIndex 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Бренд
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.product.brand,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Название товара
        Text(
          widget.product.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Категория
        Text(
          widget.product.category,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        // Текущая цена
        Text(
          widget.product.formattedPrice,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Старая цена (если есть скидка)
        if (widget.product.hasDiscount) ...[
          Text(
            widget.product.formattedOldPrice,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.product.formattedDiscount,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        // Рейтинг
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < widget.product.rating.floor() 
                  ? Icons.star 
                  : Icons.star_border,
              color: Colors.amber,
              size: 20,
            );
          }),
        ),
        
        const SizedBox(width: 8),
        
        Text(
          widget.product.formattedRating,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Количество отзывов
        Text(
          '${widget.product.formattedReviewCount} отзывов',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Размер',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: widget.product.sizes.map((size) {
            final isSelected = _selectedSize == size;
            return ChoiceChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSize = selected ? size : null;
                });
                HapticFeedback.lightImpact();
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Цвет',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: widget.product.colors.map((color) {
            final isSelected = _selectedColor == color;
            return ChoiceChip(
              label: Text(color),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedColor = selected ? color : null;
                });
                HapticFeedback.lightImpact();
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text(
          'Количество: ',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _quantity > 1 
                    ? () {
                        setState(() {
                          _quantity--;
                        });
                        HapticFeedback.lightImpact();
                      }
                    : null,
                icon: Icon(
                  Icons.remove,
                  color: _quantity > 1 ? null : Colors.grey.shade400,
                ),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _quantity++;
                  });
                  HapticFeedback.lightImpact();
                },
                icon: const Icon(Icons.add),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Описание',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
                HapticFeedback.lightImpact();
              },
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
            ),
          ],
        ),
        AnimatedCrossFade(
          firstChild: Text(
            widget.product.description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.product.description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
          crossFadeState: _isExpanded 
              ? CrossFadeState.showSecond 
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildSpecificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Характеристики',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSpecificationRow('Бренд', widget.product.brand),
              _buildSpecificationRow('Категория', widget.product.category),
              _buildSpecificationRow('Статус', widget.product.status),
              if (widget.product.sizes.isNotEmpty)
                _buildSpecificationRow('Доступные размеры', widget.product.sizes.join(', ')),
              if (widget.product.colors.isNotEmpty)
                                  _buildSpecificationRow('Доступные цвета', widget.product.colors.join(', ')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    final productsProvider = context.read<ProductsProvider>();
    final isInCart = productsProvider.isInCart(widget.product.id);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Кнопка добавления в корзину
            Expanded(
              child: ElevatedButton(
                onPressed: _canAddToCart() 
                    ? () {
                        HapticFeedback.mediumImpact();
                        _addToCart(productsProvider);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart 
                      ? Colors.grey.shade400 
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isInCart ? 'В корзине' : 'Добавить в корзину',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Кнопка быстрой покупки
            SizedBox(
              width: 60,
              height: 56,
              child: ElevatedButton(
                onPressed: _canAddToCart() 
                    ? () {
                        HapticFeedback.mediumImpact();
                        _addToCart(productsProvider);
                        _showQuickBuyDialog();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(
                  Icons.flash_on,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canAddToCart() {
    return _selectedSize != null && 
           _selectedColor != null && 
           widget.product.inStock;
  }

  void _addToCart(ProductsProvider productsProvider) {
    if (!_canAddToCart()) return;
    
    final cartProduct = CartProductModel(
      product: widget.product,
      quantity: _quantity,
      selectedSize: _selectedSize!,
      selectedColor: _selectedColor!,
    );
    
    productsProvider.addToCart(cartProduct.product);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.title} добавлен в корзину'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Перейти в корзину',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pushNamed('/cart');
          },
        ),
      ),
    );
  }

  void _toggleFavorite() {
    final productsProvider = context.read<ProductsProvider>();
    productsProvider.toggleFavorite(widget.product.id);
    
    if (productsProvider.isFavorite(widget.product.id)) {
      _favoriteController.forward().then((_) => _favoriteController.reverse());
    }
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поделиться'),
        content: const Text(
          'Функция "Поделиться" находится в разработке. '
          'В ближайшее время вы сможете делиться товарами в социальных сетях.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showQuickBuyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Быстрая покупка'),
        content: const Text(
          'Функция "Быстрая покупка" находится в разработке. '
          'В ближайшее время вы сможете оформлять заказы в один клик.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}