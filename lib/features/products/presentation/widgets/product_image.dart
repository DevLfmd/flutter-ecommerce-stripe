import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double? width;
  final BoxFit fit;

  const ProductImage({
    super.key,
    this.imageUrl,
    required this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => _buildLoadingPlaceholder(context),
      errorWidget: (context, url, error) => _buildErrorPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Icon(
        Icons.image_not_supported,
        size: height * 0.3,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: height * 0.2,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Erro ao carregar imagem',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}

