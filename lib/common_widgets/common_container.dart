import 'package:flutter/material.dart';
import 'color_code.dart'; // your AppColors file

class CommonImageCard extends StatelessWidget {
  final String? imageUrl;
  final String? assetFallback;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final double? width;
  final double? height;
  final double borderRadius;
  final VoidCallback? onTap;

  const CommonImageCard({
    super.key,
    this.imageUrl,
    this.assetFallback = 'assets/images/doctor2.png',
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onTap,
    this.width,
    this.height,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap, // whole card tappable
      child: Container(
        width: width ?? size * 0.55,
        height: height ?? size * 0.5,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 🖼️ Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child:
              // (imageUrl != null && imageUrl!.isNotEmpty)
              //     ? Image.network(
              //   imageUrl!,
              //   fit: BoxFit.cover,
              //   width: double.infinity,
              //   height: double.infinity,
              //   errorBuilder: (context, error, stackTrace) => Image.asset(
              //     assetFallback!,
              //     fit: BoxFit.cover,
              //     width: double.infinity,
              //     height: double.infinity,
              //   ),
              // ) :

              Image.asset(
                imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // ❤️ Favorite Icon
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onFavoriteTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.redAccent : AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
