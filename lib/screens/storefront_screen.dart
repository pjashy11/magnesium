
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/shopify_provider.dart';
import '../providers/cart_provider.dart';
import '../components/molecular_background.dart';
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

  Future<void> _launchInstagram() async {
    final Uri url = Uri.parse('https://www.instagram.com/magnesiumathletes');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Instagram')),
        );
      }
    }
  }

  void _showProductDetails(BuildContext context, dynamic product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailPopup(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: const BrandLogo(height: 60),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const InstagramIcon(color: Color(0xFFF19842), size: 22),
              onPressed: _launchInstagram,
              tooltip: 'Follow us on Instagram',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
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
                  if (cart.entries.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFF02B3A9), shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '${cart.totalItemCount}',
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
      body: MolecularBackground(
        isLight: true,
        child: Consumer<ShopifyProvider>(
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
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.52,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: shopify.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = shopify.filteredProducts[index]['node'];
                      return ProductTile(
                        product: product,
                        onTap: () => _showProductDetails(context, product),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ShopifyProvider shopify) {
    final categories = ['ALL', ...shopify.collections.map((c) => c['node']['title'].toString().toUpperCase())];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 12),
                child: Text(
                  'RECOVERY CATEGORIES',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              SizedBox(
                height: 64,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = shopify.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(
                            cat,
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 0.5,
                                color: isSelected ? Colors.white : const Color(0xFF475569)
                            )
                        ),
                        selected: isSelected,
                        onSelected: (_) => shopify.setCategory(cat),
                        selectedColor: const Color(0xFFF19842),
                        backgroundColor: Colors.white.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        showCheckmark: false,
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        elevation: isSelected ? 4 : 0,
                        shadowColor: const Color(0xFFF19842).withValues(alpha: 0.3),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  final dynamic product;
  final VoidCallback onTap;
  const ProductTile({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rawPrice = product['variants']['edges'][0]['node']['price']['amount'];
    final formattedPrice = double.tryParse(rawPrice)?.toStringAsFixed(2) ?? rawPrice;
    final imageUrl = product['images']['edges']?.isNotEmpty == true ? product['images']['edges'][0]['node']['url'] : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10)
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.white.withValues(alpha: 0.95),
            child: InkWell(
              onTap: onTap,
              splashColor: const Color(0xFF02B3A9).withValues(alpha: 0.1),
              highlightColor: Colors.transparent,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 1.0),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Hero(
                              tag: 'prod-${product['id']}',
                              child: imageUrl != null
                                  ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity)
                                  : const Center(child: Icon(Icons.bolt, color: Color(0xFF02B3A9), size: 40)),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['title'].toString().toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: Color(0xFF0F172A),
                                height: 1.1,
                                letterSpacing: -0.5,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                                '\$$formattedPrice',
                                style: const TextStyle(
                                  color: Color(0xFF02B3A9),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                )
                            ),
                            const SizedBox(height: 12),
                            _buildAddToCartButton(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFFF19842), Color(0xFFFBAF6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          context.read<CartProvider>().addToCart(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product['title']} added to kit'),
              backgroundColor: const Color(0xFF02B3A9),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
            'ADD TO KIT',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.2
            )
        ),
      ),
    );
  }
}

class ProductDetailPopup extends StatefulWidget {
  final dynamic product;
  const ProductDetailPopup({super.key, required this.product});

  @override
  State<ProductDetailPopup> createState() => _ProductDetailPopupState();
}

class _ProductDetailPopupState extends State<ProductDetailPopup> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final rawPrice = widget.product['variants']['edges'][0]['node']['price']['amount'];
    final formattedPrice = double.tryParse(rawPrice)?.toStringAsFixed(2) ?? rawPrice;
    final imageUrl = widget.product['images']['edges']?.isNotEmpty == true
        ? widget.product['images']['edges'][0]['node']['url']
        : null;
    final description = widget.product['description'] ?? 'No bio-sync data available.';

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 340,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: imageUrl != null
                              ? Image.network(imageUrl, fit: BoxFit.contain)
                              : const Icon(Icons.bolt, color: Color(0xFF02B3A9), size: 80),
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.science, color: Color(0xFF02B3A9), size: 24),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product['title'],
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, height: 1.1, color: Color(0xFF0F172A), fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$$formattedPrice',
                        style: const TextStyle(
                          color: Color(0xFF02B3A9),
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'BIO-SYNC RECOVERY PROTOCOL',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.7), fontSize: 16, height: 1.6),
                  ),
                ],
              ),
            ),
          ),

          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -10))
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildQtyButton(Icons.remove, () {
                  if (_quantity > 1) setState(() => _quantity--);
                }),
                Text(
                  '$_quantity',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                _buildQtyButton(Icons.add, () => setState(() => _quantity++)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF19842), Color(0xFFFBAF6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().addToCart(widget.product, quantity: _quantity);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('ADD TO KIT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: const Color(0xFF0F172A), size: 20),
      onPressed: onPressed,
    );
  }
}