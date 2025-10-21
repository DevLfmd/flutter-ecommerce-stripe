import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/models/cart_item.dart';
import '../../../products/presentation/widgets/product_image.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ProductImage(
                imageUrl: item.productImageUrl,
                height: 80,
                width: 80,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Remove Button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline),
                        color: Theme.of(context).colorScheme.error,
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // SKU
                  if (item.productSku != null)
                    Text(
                      'SKU: ${item.productSku}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Price and Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Flexible(
                        child: Text(
                          item.formattedUnitPrice,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Quantity Controls
                      _buildQuantityControls(context),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Total Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        item.formattedTotalPrice,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
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

  Widget _buildQuantityControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease Button
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              onPressed: item.quantity > 1 ? () => onQuantityChanged(item.quantity - 1) : null,
              icon: const Icon(Icons.remove, size: 16),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          
          // Quantity Display
          Container(
            width: 36,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              item.quantity.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          
          // Increase Button
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              onPressed: () => onQuantityChanged(item.quantity + 1),
              icon: const Icon(Icons.add, size: 16),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

