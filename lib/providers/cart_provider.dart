
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<dynamic> _items = [];
  List<dynamic> get items => _items;

  void addToCart(dynamic product) {
    _items.add(product);
    notifyListeners();
  }

  void removeFromCart(dynamic product) {
    _items.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
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
