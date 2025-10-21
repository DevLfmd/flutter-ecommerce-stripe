import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/storage_service.dart';
import '../../domain/models/cart_item.dart';
import '../widgets/cart_item_card.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cartItems = StorageService.getCart();
      setState(() {
        _cartItems = cartItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCartItem(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeCartItem(item);
      return;
    }

    final updatedItem = item.copyWith(quantity: newQuantity);
    final updatedItems = _cartItems.map((cartItem) {
      return cartItem.id == item.id ? updatedItem : cartItem;
    }).toList();

    await StorageService.storeCart(updatedItems);
    setState(() {
      _cartItems = updatedItems;
    });
  }

  Future<void> _removeCartItem(CartItem item) async {
    final updatedItems = _cartItems.where((cartItem) => cartItem.id != item.id).toList();
    await StorageService.storeCart(updatedItems);
    setState(() {
      _cartItems = updatedItems;
    });
  }

  Future<void> _clearCart() async {
    await StorageService.clearCart();
    setState(() {
      _cartItems = [];
    });
  }

  double get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get _totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _showClearCartDialog,
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _cartItems.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_cartItems.isEmpty) {
      return _buildEmptyCart();
    }

    return Column(
      children: [
        // Cart Items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return CartItemCard(
                item: item,
                onQuantityChanged: (newQuantity) => _updateCartItem(item, newQuantity),
                onRemove: () => _removeCartItem(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Seu carrinho está vazio',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione alguns produtos para começar',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/products'),
            icon: const Icon(Icons.store),
            label: const Text('Ver Produtos'),
          ),
        ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${_totalItems} itens)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'R\$ ${_totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Checkout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _proceedToCheckout,
                child: const Text('Finalizar Compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToCheckout() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carrinho vazio')),
      );
      return;
    }
    
    context.go('/checkout');
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Carrinho'),
        content: const Text('Tem certeza que deseja remover todos os itens do carrinho?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearCart();
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}

