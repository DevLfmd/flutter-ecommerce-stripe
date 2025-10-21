import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/models/product.dart';
import '../../../cart/domain/models/cart_item.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  Product? _product;
  bool _isLoading = false;
  String? _error;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final product = await apiService.getProduct(widget.productId);
      
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProduct,
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _product != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar produto',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProduct,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_product == null) {
      return const Center(
        child: Text('Produto não encontrado'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          _buildProductImage(),
          
          // Product Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  _product!.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Price
                Text(
                  _product!.formattedPrice,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Stock Status
                _buildStockStatus(),
                
                const SizedBox(height: 16),
                
                // Description
                if (_product!.description != null) ...[
                  Text(
                    'Descrição',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product!.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Product Details
                _buildProductDetails(),
                
                const SizedBox(height: 16),
                
                // Quantity Selector
                _buildQuantitySelector(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatus() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (_product!.isOutOfStock) {
      statusColor = Colors.red;
      statusText = 'Fora de estoque';
      statusIcon = Icons.cancel;
    } else if (_product!.isLowStock) {
      statusColor = Colors.orange;
      statusText = 'Estoque baixo';
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.green;
      statusText = 'Em estoque';
      statusIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhes do Produto',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('SKU', _product!.sku ?? 'N/A'),
            _buildDetailRow('Categoria', _product!.category ?? 'N/A'),
            _buildDetailRow('Estoque', '${_product!.stockQuantity} unidades'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quantidade',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1 ? () {
                    setState(() {
                      _quantity--;
                    });
                  } : null,
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _quantity.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: _quantity < _product!.stockQuantity ? () {
                    setState(() {
                      _quantity++;
                    });
                  } : null,
                  icon: const Icon(Icons.add),
                ),
                const Spacer(),
                Text(
                  'Máximo: ${_product!.stockQuantity}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _addToCart(),
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Adicionar ao Carrinho'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _buyNow,
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Comprar Agora'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    if (_product == null) return;
    
    try {
      // Get current cart items
      final currentCart = StorageService.getCart();
      
      // Check if product already exists in cart
      final existingItemIndex = currentCart.indexWhere(
        (item) => item.productId == _product!.id,
      );
      
      if (existingItemIndex != -1) {
        // Update quantity of existing item
        final existingItem = currentCart[existingItemIndex];
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + _quantity,
        );
        currentCart[existingItemIndex] = updatedItem;
      } else {
        // Add new item to cart
        final newItem = CartItem.fromProduct(_product!, _quantity);
        currentCart.add(newItem);
      }
      
      // Save updated cart
      await StorageService.storeCart(currentCart);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_product!.name} adicionado ao carrinho'),
            action: SnackBarAction(
              label: 'Ver Carrinho',
              onPressed: () => context.go('/cart'),
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar produto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _buyNow() {
    // Implement buy now functionality
    context.go('/cart');
  }

  void _shareProduct() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de compartilhamento em desenvolvimento')),
    );
  }

  void _toggleFavorite() {
    // Implement favorite functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de favoritos em desenvolvimento')),
    );
  }

  Widget _buildProductImage() {
    if (_product!.imageUrl == null || _product!.imageUrl!.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Imagem não disponível',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[100],
      child: Image.network(
        _product!.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 300,
            width: double.infinity,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            width: double.infinity,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar imagem',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verifique sua conexão com a internet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

