import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartEntry {
  final dynamic product;
  final int quantity;
  const CartEntry({required this.product, required this.quantity});
  CartEntry copyWith({int? quantity}) =>
      CartEntry(product: product, quantity: quantity ?? this.quantity);
}

class CartProvider extends ChangeNotifier {
  // Keyed by product ID → CartEntry
  final Map<String, CartEntry> _entries = {};

  CartProvider() {
    _loadCart();
  }

  /// Ordered list of unique products (for backwards compat)
  List<dynamic> get items => _entries.values.map((e) => e.product).toList();

  /// Full entries map — used by CartScreen for quantity display
  Map<String, CartEntry> get entries => Map.unmodifiable(_entries);

  int get totalItemCount =>
      _entries.values.fold(0, (sum, e) => sum + e.quantity);

  int quantityOf(dynamic product) =>
      _entries[_idOf(product)]?.quantity ?? 0;

  void addToCart(dynamic product, {int quantity = 1}) {
    final id = _idOf(product);
    if (_entries.containsKey(id)) {
      _entries[id] = _entries[id]!.copyWith(
        quantity: _entries[id]!.quantity + quantity,
      );
    } else {
      _entries[id] = CartEntry(product: product, quantity: quantity);
    }
    _saveCart();
    notifyListeners();
  }

  /// Decrements by 1; removes entry when quantity reaches 0.
  void removeFromCart(dynamic product) {
    final id = _idOf(product);
    if (!_entries.containsKey(id)) return;
    final current = _entries[id]!.quantity;
    if (current <= 1) {
      _entries.remove(id);
    } else {
      _entries[id] = _entries[id]!.copyWith(quantity: current - 1);
    }
    _saveCart();
    notifyListeners();
  }

  void removeEntireEntry(dynamic product) {
    _entries.remove(_idOf(product));
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _entries.clear();
    _saveCart();
    notifyListeners();
  }

  double get totalPrice {
    return _entries.values.fold(0.0, (sum, entry) {
      final priceStr =
      entry.product['variants']['edges'][0]['node']['price']['amount'];
      final price = double.tryParse(priceStr) ?? 0.0;
      return sum + price * entry.quantity;
    });
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartJson = prefs.getString('mag_athletes_cart_v2');
      if (cartJson != null) {
        final List decoded = jsonDecode(cartJson);
        for (final item in decoded) {
          final product = item['product'];
          final quantity = (item['quantity'] as num).toInt();
          final id = _idOf(product);
          _entries[id] = CartEntry(product: product, quantity: quantity);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _entries.values
          .map((e) => {'product': e.product, 'quantity': e.quantity})
          .toList();
      await prefs.setString('mag_athletes_cart_v2', jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  static String _idOf(dynamic product) =>
      product['id']?.toString() ?? product['title']?.toString() ?? '';
}
