import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/donut_model.dart';
import '../../providers/cart_provider.dart';

class DonutDetailModal extends ConsumerStatefulWidget {
  final DonutModel donut;

  const DonutDetailModal({super.key, required this.donut});

  @override
  ConsumerState<DonutDetailModal> createState() => _DonutDetailModalState();
}

class _DonutDetailModalState extends ConsumerState<DonutDetailModal> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: widget.donut.image ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.donut.name,
                    style: GoogleFonts.inter(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text('₱${(widget.donut.price * _quantity).toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent)),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.donut.description ?? 'No description available.',
                style: GoogleFonts.inter(color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => setState(() => _quantity = (_quantity > 1) ? _quantity - 1 : 1),
                ),
                Text('$_quantity', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  for(int i=0; i<_quantity; i++) {
                    ref.read(cartProvider.notifier).addToCart(widget.donut);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${widget.donut.name} x$_quantity added to cart')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
