import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/domain/models/cart_item.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomeContent(),
    const ProductsPage(),
    const CartPage(),
    const OrdersPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Produtos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrinho',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  Future<void> _addProductToCart(BuildContext context, String productName, double price) async {
    try {
      // Create a simple product for demo purposes
      final product = {
        'id': 'demo_${productName.toLowerCase().replaceAll(' ', '_')}',
        'name': productName,
        'price': price,
        'imageUrl': null,
        'sku': 'DEMO-${DateTime.now().millisecondsSinceEpoch}',
      };
      
      // Get current cart items
      final currentCart = StorageService.getCart();
      
      // Check if product already exists in cart
      final existingItemIndex = currentCart.indexWhere(
        (item) => item.productName == productName,
      );
      
      if (existingItemIndex != -1) {
        // Update quantity of existing item
        final existingItem = currentCart[existingItemIndex];
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
        currentCart[existingItemIndex] = updatedItem;
      } else {
        // Add new item to cart
        final newItem = CartItem(
          id: '${product['id']}_${DateTime.now().millisecondsSinceEpoch}',
          productId: product['id'] as String,
          productName: product['name'] as String,
          productImageUrl: product['imageUrl'] as String?,
          productSku: product['sku'] as String?,
          unitPrice: product['price'] as double,
          quantity: 1,
          addedAt: DateTime.now(),
        );
        currentCart.add(newItem);
      }
      
      // Save updated cart
      await StorageService.storeCart(currentCart);
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$productName adicionado ao carrinho'),
            action: SnackBarAction(
              label: 'Ver Carrinho',
              onPressed: () => context.go('/cart'),
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar produto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.purple[600]!],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Escribo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.search, size: 24),
              onPressed: () {
                // Handle search
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, size: 24),
                  onPressed: () => context.go('/cart'),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 24),
              onPressed: () {
                // Handle notifications
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[600]!,
                    Colors.purple[600]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Background shapes
                  Positioned(
                    right: -100,
                    top: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 50,
                    top: 50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '🎉 Black Friday',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ofertas Imperdíveis',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Até 70% de desconto em produtos selecionados',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => context.go('/products'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue[600],
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Comprar Agora',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: () => context.go('/products'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white, width: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text('Ver Produtos'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Categories Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categorias',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/products'),
                        child: const Text(
                          'Ver todas',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryCard(
                          icon: Icons.phone_android,
                          title: 'Smartphones',
                          subtitle: '123 produtos',
                          color: Colors.blue,
                          onTap: () => context.go('/products?category=smartphones'),
                        ),
                        const SizedBox(width: 16),
                        _CategoryCard(
                          icon: Icons.laptop,
                          title: 'Notebooks',
                          subtitle: '89 produtos',
                          color: Colors.green,
                          onTap: () => context.go('/products?category=notebooks'),
                        ),
                        const SizedBox(width: 16),
                        _CategoryCard(
                          icon: Icons.headphones,
                          title: 'Acessórios',
                          subtitle: '156 produtos',
                          color: Colors.orange,
                          onTap: () => context.go('/products?category=accessories'),
                        ),
                        const SizedBox(width: 16),
                        _CategoryCard(
                          icon: Icons.tv,
                          title: 'Eletrônicos',
                          subtitle: '78 produtos',
                          color: Colors.purple,
                          onTap: () => context.go('/products?category=electronics'),
                        ),
                        const SizedBox(width: 16),
                        _CategoryCard(
                          icon: Icons.sports_esports,
                          title: 'Gaming',
                          subtitle: '45 produtos',
                          color: Colors.red,
                          onTap: () => context.go('/products?category=gaming'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Featured Products
            Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Produtos em Destaque',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/products'),
                        child: const Text(
                          'Ver todos',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 440,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _ProductCard(
                          name: 'iPhone 15 Pro',
                          price: 'R\$ 8.999',
                          originalPrice: 'R\$ 10.999',
                          image: '📱',
                          rating: 4.8,
                          reviews: 124,
                          isNew: true,
                          discount: 18,
                          description: 'O mais avançado iPhone com chip A17 Pro, câmera de 48MP e design em titânio.',
                          onTap: () => context.go('/products/1'),
                          onAddToCart: () => _addProductToCart(context, 'iPhone 15 Pro', 8999.0),
                        ),
                        const SizedBox(width: 16),
                        _ProductCard(
                          name: 'MacBook Air M2',
                          price: 'R\$ 12.999',
                          originalPrice: 'R\$ 14.999',
                          image: '💻',
                          rating: 4.9,
                          reviews: 89,
                          isNew: false,
                          discount: 13,
                          description: 'Notebook ultraportátil com chip M2, tela Liquid Retina de 13.6" e bateria de longa duração.',
                          onTap: () => context.go('/products/2'),
                          onAddToCart: () => _addProductToCart(context, 'MacBook Air M2', 12999.0),
                        ),
                        const SizedBox(width: 16),
                        _ProductCard(
                          name: 'AirPods Pro 2',
                          price: 'R\$ 2.299',
                          originalPrice: 'R\$ 2.799',
                          image: '🎧',
                          rating: 4.7,
                          reviews: 256,
                          isNew: true,
                          discount: 18,
                          description: 'Fones sem fio com cancelamento ativo de ruído, áudio espacial e até 6h de bateria.',
                          onTap: () => context.go('/products/3'),
                          onAddToCart: () => _addProductToCart(context, 'AirPods Pro 2', 2299.0),
                        ),
                        const SizedBox(width: 16),
                        _ProductCard(
                          name: 'Apple Watch Series 9',
                          price: 'R\$ 3.999',
                          originalPrice: 'R\$ 4.499',
                          image: '⌚',
                          rating: 4.6,
                          reviews: 178,
                          isNew: false,
                          discount: 11,
                          description: 'Smartwatch com monitoramento de saúde, GPS, resistência à água e tela Always-On.',
                          onTap: () => context.go('/products/4'),
                          onAddToCart: () => _addProductToCart(context, 'Apple Watch Series 9', 3999.0),
                        ),
                        const SizedBox(width: 16),
                        _ProductCard(
                          name: 'iPad Pro M2',
                          price: 'R\$ 6.999',
                          originalPrice: 'R\$ 7.999',
                          image: '📱',
                          rating: 4.8,
                          reviews: 92,
                          isNew: true,
                          discount: 12,
                          description: 'Tablet profissional com chip M2, tela Liquid Retina XDR de 12.9" e suporte ao Apple Pencil.',
                          onTap: () => context.go('/products/5'),
                          onAddToCart: () => _addProductToCart(context, 'iPad Pro M2', 6999.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Offers Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ofertas Especiais',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade50,
                          Colors.orange.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Black Friday',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Até 70% de desconto em produtos selecionados',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.red.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context.go('/products?offer=black-friday'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Ver Ofertas'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Center(
                            child: Text(
                              '🔥',
                              style: TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ações Rápidas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.store,
                          title: 'Produtos',
                          subtitle: 'Ver catálogo',
                          onTap: () => context.go('/products'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.shopping_cart,
                          title: 'Carrinho',
                          subtitle: 'Ver itens',
                          onTap: () => context.go('/cart'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.receipt_long,
                          title: 'Pedidos',
                          subtitle: 'Histórico',
                          onTap: () => context.go('/orders'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.person,
                          title: 'Perfil',
                          subtitle: 'Configurações',
                          onTap: () => context.go('/profile'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 100,
          height: 140,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String originalPrice;
  final String image;
  final double rating;
  final int reviews;
  final bool isNew;
  final int discount;
  final String description;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.isNew,
    required this.discount,
    required this.description,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 200,
          height: 420,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey[100]!, Colors.grey[200]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        image,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  if (isNew)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NOVO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-$discount%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontSize: 12,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber[600],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($reviews)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    price,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    originalPrice,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAddToCart ?? onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Adicionar ao Carrinho',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

