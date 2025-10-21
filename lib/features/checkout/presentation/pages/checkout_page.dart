import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/payment_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../cart/domain/models/cart_item.dart';
import '../widgets/checkout_summary_card.dart';
import '../widgets/payment_method_card.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  String _selectedPaymentMethod = 'card';
  
  double get _totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

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
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _processPayment() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carrinho vazio')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Criar PaymentIntent
      final paymentIntent = await PaymentService.createPaymentIntent(
        amount: _totalAmount,
        currency: 'brl',
        items: _cartItems,
      );

      // Confirmar pagamento
      final result = await PaymentService.confirmPayment(
        clientSecret: paymentIntent['client_secret']!,
        paymentMethodData: {
          'type': 'card',
          'card': {
            'number': '4242424242424242',
            'exp_month': 12,
            'exp_year': 2025,
            'cvc': '123',
          },
          'billing_details': {
            'name': 'Cliente',
            'email': 'cliente@exemplo.com',
          },
        },
      );

      if (result['status'] == 'succeeded') {
        // Limpar carrinho após pagamento bem-sucedido
        await StorageService.clearCart();
        
        // Navegar para página de sucesso
        if (mounted) {
          context.go('/orders');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pagamento realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _error = 'Pagamento não foi processado';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Compra'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cart'),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _cartItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
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
              'Erro ao carregar checkout',
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
              onPressed: _loadCartItems,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_cartItems.isEmpty) {
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
              'Carrinho vazio',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione produtos ao carrinho para continuar',
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumo do Pedido
          CheckoutSummaryCard(
            items: _cartItems,
            totalAmount: _totalAmount,
          ),
          
          const SizedBox(height: 24),
          
          // Método de Pagamento
          PaymentMethodCard(
            selectedMethod: _selectedPaymentMethod,
            onMethodChanged: (method) {
              setState(() {
                _selectedPaymentMethod = method;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Informações de Entrega
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações de Entrega',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Endereço: Rua Exemplo, 123 - Centro'),
                  const Text('CEP: 12345-678'),
                  const Text('Cidade: São Paulo - SP'),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      // Implementar edição de endereço
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Endereço'),
                  ),
                ],
              ),
            ),
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
                  'Total (${_cartItems.length} itens)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  PaymentService.formatAmount(_totalAmount),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Botão de Pagamento
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Finalizar Pagamento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
