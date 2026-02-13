
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  List<dynamic> _items = [];
  List<dynamic> get items => _items;

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartJson = prefs.getString('mag_athletes_cart');
      if (cartJson != null) {
        _items = jsonDecode(cartJson);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart cache: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mag_athletes_cart', jsonEncode(_items));
    } catch (e) {
      debugPrint('Error saving cart cache: $e');
    }
  }

  void addToCart(dynamic product, {int quantity = 1}) {
    for (var i = 0; i < quantity; i++) {
      _items.add(product);
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(dynamic product) {
    // Remove only one instance of the product
    final index = _items.indexWhere((item) => item['id'] == product['id']);
    if (index != -1) {
      _items.removeAt(index);
    } else {
      _items.remove(product);
    }
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(0.0, (sum, item) {
      final priceStr = item['variants']['edges'][0]['node']['price']['amount'];
      final price = double.tryParse(priceStr) ?? 0.0;
      return sum + price;
    });
  }
}
