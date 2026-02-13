
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/shopify_service.dart';

class ShopifyProvider extends ChangeNotifier {
  List<dynamic> _allProducts = [];
  List<dynamic> _collections = [];
  String _selectedCategory = 'ALL';
  bool _isLoading = false;

  List<dynamic> get collections => _collections;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  ShopifyProvider() {
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString('cached_products');
      final collectionsJson = prefs.getString('cached_collections');

      if (productsJson != null) _allProducts = jsonDecode(productsJson);
      if (collectionsJson != null) _collections = jsonDecode(collectionsJson);

      if (_allProducts.isNotEmpty || _collections.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Cache Load Error: $e');
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_products', jsonEncode(_allProducts));
      await prefs.setString('cached_collections', jsonEncode(_collections));
    } catch (e) {
      debugPrint('Cache Save Error: $e');
    }
  }

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
    // If we have data already (from cache), don't show the primary loader
    // This creates a "stale-while-revalidate" feel
    if (_allProducts.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    final QueryOptions options = QueryOptions(
      document: gql(ShopifyService.getStoreDataQuery),
      fetchPolicy: FetchPolicy.networkOnly, // Always get fresh data in bg
    );

    try {
      final QueryResult result = await ShopifyService.client.query(options);

      if (!result.hasException) {
        _allProducts = result.data?['products']['edges'] ?? [];
        _collections = result.data?['collections']['edges'] ?? [];
        _saveToCache();
      }
    } catch (e) {
      debugPrint('Shopify Provider Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> createCheckout(List<dynamic> cartItems, {Map<String, dynamic>? buyerInfo}) async {
    final lines = cartItems.map((item) {
      return {
        'merchandiseId': item['variants']['edges'][0]['node']['id'],
        'quantity': 1,
      };
    }).toList();

    final MutationOptions createOptions = MutationOptions(
      document: gql(ShopifyService.cartCreateMutation),
      variables: {
        'input': {
          'lines': lines,
        },
      },
    );

    try {
      final QueryResult createResult = await ShopifyService.client.mutate(createOptions);
      if (createResult.hasException) return null;

      final cartData = createResult.data?['cartCreate'];
      final cartId = cartData?['cart']?['id'];

      if (cartId == null) return null;

      if (buyerInfo != null) {
        final MutationOptions identityOptions = MutationOptions(
          document: gql(ShopifyService.cartBuyerIdentityUpdateMutation),
          variables: {
            'cartId': cartId,
            'buyerIdentity': {
              'email': buyerInfo['email'],
              'deliveryAddressPreferences': [
                {
                  'deliveryAddress': {
                    'address1': buyerInfo['address'],
                    'city': buyerInfo['city'],
                    'province': buyerInfo['state'],
                    'zip': buyerInfo['zip'],
                    'country': 'US',
                  }
                }
              ],
            },
          },
        );

        final QueryResult identityResult = await ShopifyService.client.mutate(identityOptions);
        if (!identityResult.hasException) {
          final updatedCartData = identityResult.data?['cartBuyerIdentityUpdate'];
          return updatedCartData?['cart']?['checkoutUrl'];
        }
      }

      return cartData?['cart']?['checkoutUrl'];
    } catch (e) {
      debugPrint('Shopify Provider Checkout Error: $e');
      return null;
    }
  }
}
