import 'package:flutter/material.dart';

class PaymentMethodCard extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodChanged;

  const PaymentMethodCard({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Método de Pagamento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Cartão de Crédito/Débito
            _buildPaymentOption(
              context,
              value: 'card',
              title: 'Cartão de Crédito/Débito',
              subtitle: 'Visa, Mastercard, Elo',
              icon: Icons.credit_card,
              isSelected: selectedMethod == 'card',
            ),
            
            const SizedBox(height: 12),
            
            // PIX
            _buildPaymentOption(
              context,
              value: 'pix',
              title: 'PIX',
              subtitle: 'Pagamento instantâneo',
              icon: Icons.qr_code,
              isSelected: selectedMethod == 'pix',
            ),
            
            const SizedBox(height: 12),
            
            // Boleto
            _buildPaymentOption(
              context,
              value: 'boleto',
              title: 'Boleto Bancário',
              subtitle: 'Pagamento em até 3 dias úteis',
              icon: Icons.receipt,
              isSelected: selectedMethod == 'boleto',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onMethodChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
