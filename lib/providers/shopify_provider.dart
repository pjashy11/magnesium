
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/shopify_service.dart';

class ShopifyProvider extends ChangeNotifier {
  List<dynamic> _allProducts = [];
  List<dynamic> _collections = [];
  String _selectedCategory = 'ALL';
  bool _isLoading = false;

  List<dynamic> get collections => _collections;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  List<dynamic> get filteredProducts {
    if (_selectedCategory == 'ALL') return _allProducts;

    final collection = _collections.firstWhere(
          (c) => c['node']['title'].toString().toUpperCase() == _selectedCategory,
      orElse: () => null,
    );

    if (collection == null) return _allProducts;

    final productIds = (collection['node']['products']['edges'] as List)
        .map((e) => e['node']['id'])
        .toList();

    return _allProducts.where((p) => productIds.contains(p['node']['id'])).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchStoreData() async {
    _isLoading = true;
    notifyListeners();

    final QueryOptions options = QueryOptions(
      document: gql(ShopifyService.getStoreDataQuery),
    );

    try {
      final QueryResult result = await ShopifyService.client.query(options);

      if (!result.hasException) {
        _allProducts = result.data?['products']['edges'] ?? [];
        _collections = result.data?['collections']['edges'] ?? [];
      }
    } catch (e) {
      debugPrint('Shopify Provider Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> createCheckout(List<dynamic> cartItems) async {
    // Cart API uses 'merchandiseId' for the variant GID
    final lines = cartItems.map((item) {
      return {
        'merchandiseId': item['variants']['edges'][0]['node']['id'],
        'quantity': 1,
      };
    }).toList();

    final MutationOptions options = MutationOptions(
      document: gql(ShopifyService.cartCreateMutation),
      variables: {
        'input': {
          'lines': lines,
        },
      },
    );

    try {
      final QueryResult result = await ShopifyService.client.mutate(options);

      if (result.hasException) {
        debugPrint('Cart Mutation Exception: ${result.exception.toString()}');
        return null;
      }

      final cartData = result.data?['cartCreate'];
      final errors = cartData?['userErrors'] as List?;

      if (errors != null && errors.isNotEmpty) {
        debugPrint('Shopify Cart User Error: ${errors[0]['message']}');
        return null;
      }

      // The Cart API returns a checkoutUrl for the secure handoff
      return cartData?['cart']?['checkoutUrl'];
    } catch (e) {
      debugPrint('Shopify Provider Cart Error: $e');
      return null;
    }
  }
}