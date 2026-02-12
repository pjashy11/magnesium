
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopify_provider.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'landing_screen.dart';

class StorefrontScreen extends StatefulWidget {
  const StorefrontScreen({super.key});
  @override
  State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ShopifyProvider>().fetchStoreData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100, // Matched with landing screen for consistent brand prominence
        title: const BrandLogo(height: 60),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFF19842), size: 32),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                  ),
                  if (cart.items.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFF02B3A9), shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '${cart.items.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ShopifyProvider>(
        builder: (context, shopify, child) {
          if (shopify.isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFF19842)));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategorySelector(shopify),
              Expanded(
                child: shopify.filteredProducts.isEmpty
                    ? const Center(child: Text('NO ITEMS IN THIS CATEGORY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)))
                    : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: shopify.filteredProducts.length,
                  itemBuilder: (context, index) => ProductTile(product: shopify.filteredProducts[index]['node']),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector(ShopifyProvider shopify) {
    final categories = ['ALL', ...shopify.collections.map((c) => c['node']['title'].toString().toUpperCase())];

    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = shopify.selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: isSelected ? Colors.white : Colors.black54)),
              selected: isSelected,
              onSelected: (_) => shopify.setCategory(cat),
              selectedColor: const Color(0xFFF19842),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
              showCheckmark: false,
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  final dynamic product;
  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final price = product['variants']['edges'][0]['node']['price']['amount'];
    final imageUrl = product['images']['edges']?.isNotEmpty == true ? product['images']['edges'][0]['node']['url'] : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(18)),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity)
                  : const Center(child: Icon(Icons.bolt, color: Color(0xFF02B3A9), size: 40)),
            ),
          ),
          const SizedBox(height: 12),
          Text(product['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('\$$price', style: const TextStyle(color: Color(0xFF02B3A9), fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<CartProvider>().addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product['title']} added to kit'),
                    backgroundColor: const Color(0xFF02B3A9),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF19842),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('ADD TO KIT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
            ),
          )
        ],
      ),
    );
  }
}