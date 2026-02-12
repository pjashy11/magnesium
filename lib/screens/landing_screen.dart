
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/shopify_provider.dart';
import 'storefront_screen.dart';
import 'cart_screen.dart';

const String brandlogo = 'https://firebasestorage.googleapis.com/v0/b/magnesium-athletes.firebasestorage.app/o/logo.svg?alt=media&token=53463da7-1650-4339-a2c1-f8634053928f';

class BrandLogo extends StatelessWidget {
  final double height;
  final bool isLight;
  const BrandLogo({super.key, this.height = 32, this.isLight = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: SvgPicture.network(
        brandlogo,
        height: height,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => _buildPlaceholder(),
        // Fallback in case of network or rendering error
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MAGNESIUM',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: height * 0.35,
              color: isLight ? Colors.white : const Color(0xFF02B3A9),
              fontStyle: FontStyle.italic,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'athletes',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: height * 0.35,
              color: isLight ? Colors.white : const Color(0xFFF19842),
              letterSpacing: -1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ShopifyProvider>().fetchStoreData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopify = context.watch<ShopifyProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(),
                _buildValuePillars(),
                if (shopify.collections.isNotEmpty)
                  ...shopify.collections.map((col) => _buildCollectionCarousel(col)),
                _buildMolecularBreakdown(),
                _buildOurStory(),
                _buildFooterCTA(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 100,
      centerTitle: false,
      titleSpacing: 24,
      title: const BrandLogo(height: 60),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF02B3A9), size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RECOVER HARDER.',
              style: TextStyle(
                  fontSize: 58,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Transform(
            transform: Matrix4.skewX(-0.15),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFF19842), Color(0xFFFFB366), Color(0xFFF19842)],
                stops: [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: const Text('DOMINATE.',
                  style: TextStyle(
                      fontSize: 64,
                      height: 0.9,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Color(0x33F19842), offset: Offset(4, 4), blurRadius: 10)
                      ])),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Precision-engineered transdermal magnesium for elite recovery. Fuel your muscles, flush toxins, and accelerate performance with bio-available minerals built for the grind.',
            style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.6), fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 40),
          const SizedBox.shrink(),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorefrontScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('SHOP THE CATALOG',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuePillars() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildPillarCard('01', 'RECHARGE', 'Transdermal absorption bypasses the gap for instant muscle fuel.', Icons.bolt),
          const SizedBox(height: 12),
          _buildPillarCard('02', 'DETOX', 'Flush lactic acid and metabolic waste through cellular osmotic pressure.', Icons.waves),
          const SizedBox(height: 12),
          _buildPillarCard('03', 'DEFEND', 'Natural antimicrobial oils protect against gym-acquired bacteria.', Icons.shield_outlined),
        ],
      ),
    );
  }

  Widget _buildPillarCard(String num, String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(6)),
            child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontSize: 12, height: 1.4)),
              ],
            ),
          ),
          Icon(icon, color: const Color(0xFF02B3A9), size: 20),
        ],
      ),
    );
  }

  Widget _buildCollectionCarousel(dynamic collection) {
    final rawTitle = collection['node']?['title']?.toString() ?? 'COLLECTION';
    final title = rawTitle.toUpperCase();
    final products = (collection['node']?['products']?['edges'] ?? []) as List;

    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorefrontScreen())),
                child: const Text('VIEW ALL',
                    style: TextStyle(color: Color(0xFF02B3A9), fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: products.length > 5 ? 5 : products.length,
            itemBuilder: (context, index) {
              final product = products[index]['node'];
              if (product == null) return const SizedBox.shrink();

              final imageUrl = (product['images']?['edges'] != null && product['images']['edges'].isNotEmpty)
                  ? product['images']['edges'][0]['node']['url']
                  : null;

              return Container(
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageUrl != null
                            ? Image.network(imageUrl, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.bolt, color: Color(0xFF02B3A9), size: 30))
                            : const Icon(Icons.bolt, color: Color(0xFF02B3A9), size: 30),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product['title']?.toString() ?? 'Product Item',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          const Text('PREMIUM GRADE',
                              style: TextStyle(color: Color(0xFFF19842), fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMolecularBreakdown() {
    return Container(
      padding: const EdgeInsets.all(30),
      color: const Color(0xFF0F172A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RECOVERY LAB',
              style: TextStyle(color: Color(0xFF02B3A9), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 16),
          const Text('MOLECULAR\nBREAKDOWN',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, height: 0.9, color: Colors.white)),
          const SizedBox(height: 32),
          _buildDarkIngredientTile('MAGNESIUM SALTS', 'Sulfate & Chloride variants for rapid cell detox.', Icons.bolt),
          _buildDarkIngredientTile('MAGNESIUM LOTION', 'Transdermal absorption for direct muscle application.', Icons.spa_outlined),
          _buildDarkIngredientTile('ARNICA MONTANA', 'High-potency anti-inflammatory for muscle strain.', Icons.health_and_safety),
          _buildDarkIngredientTile('MSM BIO-SULFUR', 'Critical joint support and collagen synthesis.', Icons.layers),
        ],
      ),
    );
  }

  Widget _buildDarkIngredientTile(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF02B3A9), size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOurStory() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BORN IN THE TRENCHES',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Color(0xFF0F172A))),
          const SizedBox(height: 20),
          Text(
            'Magnesium Athletes was created by a dedicated CrossFit/Boxing enthusiast and a skin care expert to solve a critical gap in recovery: purity and bioavailability.',
            style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.7), fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 12),
          Text(
            'We focus on ridding the skin of viruses and bacteria found in intense gym environments while fueling the body with transdermal minerals.',
            style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.7), fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterCTA() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      decoration: const BoxDecoration(
        color: Color(0xFFF19842),
      ),
      child: Column(
        children: [
          const Text('READY TO OPTIMIZE?',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, fontStyle: FontStyle.italic, color: Colors.white)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 70,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorefrontScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFF19842),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('SHOP THE COLLECTION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
          ),
          const SizedBox(height: 40),
          // Logo removed as requested to avoid blending with orange background
        ],
      ),
    );
  }
}