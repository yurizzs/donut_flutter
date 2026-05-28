import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/donut_model.dart';

class CartItem {
  final DonutModel donut;
  int quantity;

  CartItem({required this.donut, this.quantity = 1});
}

class CartState {
  final List<CartItem> items;
  final double deliveryFee = 50.0;

  CartState({this.items = const []});

  double get subtotal => items.fold(0, (sum, item) => sum + (item.donut.price * item.quantity));
  double get total => items.isEmpty ? 0 : subtotal + deliveryFee;

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return CartState();
  }

  void addToCart(DonutModel donut) {
    final existingIndex = state.items.indexWhere((item) => item.donut.id == donut.id);
    if (existingIndex != -1) {
      final updatedItems = state.items.map((item) {
        if (item.donut.id == donut.id) {
          return CartItem(donut: item.donut, quantity: item.quantity + 1);
        }
        return item;
      }).toList();
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(items: [...state.items, CartItem(donut: donut)]);
    }
  }

  void removeFromCart(int donutId) {
    state = state.copyWith(
      items: state.items.where((item) => item.donut.id != donutId).toList(),
    );
  }

  void updateQuantity(int donutId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(donutId);
      return;
    }
    final updatedItems = state.items.map((item) {
      if (item.donut.id == donutId) {
        return CartItem(donut: item.donut, quantity: quantity);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }

  void clearCart() {
    state = CartState();
  }
}
