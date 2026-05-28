import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../auth/login_modal.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final userAsync = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Cart', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryText,
      ),
      body: cart.items.isEmpty ? _buildEmptyState() : _buildCartList(context, ref, cart),
      bottomNavigationBar: cart.items.isEmpty ? null : _buildCheckoutBar(context, ref, cart, userAsync),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, WidgetRef ref, CartState cart) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: item.donut.image ?? '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(Icons.donut_large, color: AppColors.accent),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.donut.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '₱${item.donut.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(color: AppColors.accent, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.accent),
                    onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.donut.id, item.quantity - 1),
                  ),
                  Text(
                    '${item.quantity}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
                    onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.donut.id, item.quantity + 1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => ref.read(cartProvider.notifier).removeFromCart(item.donut.id),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar(BuildContext context, WidgetRef ref, CartState cart, AsyncValue userAsync) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: GoogleFonts.poppins(color: Colors.grey)),
              Text('₱${cart.subtotal.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery Fee', style: GoogleFonts.poppins(color: Colors.grey)),
              Text('₱${cart.deliveryFee.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(
                '₱${cart.total.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final authState = ref.read(authProvider);
                debugPrint('Checkout authState: $authState, value: ${authState.value}');
                final user = authState.value;
                if (user == null) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const LoginModal(),
                  );
                } else {
                  _handleCheckout(context, ref, cart);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context, WidgetRef ref, CartState cart) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text('Do you want to place this order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );
if (confirm == true) {
  final user = ref.read(authProvider).value;
  if (user == null || user.id == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please login to checkout')),
    );
    return;
  }

  try {
    // Prepare payload as required by Laravel API
    final payload = {
      'customer_id': user.id,
      'order_date': DateTime.now().toIso8601String(),
      'total_amount': cart.total,
      'status': 'Pending',
      'items': cart.items.map((item) => {
        'donut_id': item.donut.id,
        'quantity': item.quantity,
      }).toList(),
    };

    debugPrint('Checkout Payload: $payload');
    await ref.read(ordersProvider.notifier).placeOrder(payload);

    ref.read(cartProvider.notifier).clearCart();
    if(context.mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    }
  } catch (e) {
    debugPrint('Checkout Error: $e');
    if(context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

  }
}
