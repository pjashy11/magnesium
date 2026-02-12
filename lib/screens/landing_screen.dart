import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/shopify_provider.dart';
import 'storefront_screen.dart';
import 'cart_screen.dart';

/// BRAND ASSETS
const String brandLogoUrl = 'https://firebasestorage.googleapis.com/v0/b/magnesium-athletes.firebasestorage.app/o/logo.svg?alt=media&token=53463da7-1650-4339-a2c1-f8634053928f';

class BrandLogo extends StatelessWidget {
  final double height;
  final bool isLight;
  const BrandLogo({super.key, this.height = 32, this.isLight = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: SvgPicture.network(
        brandLogoUrl,
        height: height,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => _buildPlaceholder(),
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _missionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ShopifyProvider>().fetchStoreData();
      }
    });
  }

  void _scrollToMission() {
    Scrollable.ensureVisible(
      _missionKey.currentContext!,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopify = context.watch<ShopifyProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(),
                _buildMissionSection(key: _missionKey),
                _buildAboutSection(),
                if (shopify.collections.isNotEmpty)
                  ...shopify.collections.map((col) => _buildCollectionCarousel(col)),
                _buildMolecularBreakdown(),
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
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorefrontScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('SHOP CATALOG',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 64,
                  child: OutlinedButton(
                    onPressed: _scrollToMission,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF02B3A9), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('OUR MISSION',
                        style: TextStyle(color: Color(0xFF02B3A9), fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection({Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF02B3A9).withValues(alpha: 0.05),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OUR MISSION',
              style: TextStyle(color: Color(0xFF02B3A9), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
          const SizedBox(height: 16),
          const Text('OPTIMIZE.\nRECOVER.\nDOMINATE.',
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, height: 0.9, color: Color(0xFF0F172A))),
          const SizedBox(height: 20),
          Text(
            'At Magnesium Athletes, we believe every competitor deserves elite care. Our mission is to enhance performance, facilitate rapid recovery, and prioritize holistic well-being through scientifically formulated transdermal fuel.',
            style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.6), fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 40, height: 2, color: const Color(0xFFF19842)),
              const SizedBox(width: 12),
              const Text('THE ORIGIN STORY',
                  style: TextStyle(color: Color(0xFFF19842), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('BORN IN THE TRENCHES',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          Text(
            'Born from the shared passion of a dedicated Cross-Fit/Boxing enthusiast and a natural skin care expert, Magnesium Athletes was created to revolutionize recovery. We set out to banish gritty skin, alleviate muscle aches, and quell inflammation—all while keeping athletes remarkably clean and fresh.',
            style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.7), fontSize: 16, height: 1.6, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 16),
          Text(
            'Our journey began with extensive research into the healing powers of natural ingredients. We focus on ridding the skin of viruses and bacteria found in sweat and gym environments, ensuring that your recovery doesn\'t just feel good—it protects your body.',
            style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.7), fontSize: 16, height: 1.6, fontWeight: FontWeight.w400),
          ),
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
      color: const Color(0xFF0F172A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(30, 60, 30, 8),
            child: Text('MOLECULAR BREAKDOWN',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text('HOW OUR ACTIVE RECOVERY FORMULA WORKS',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 32),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 1,
            childAspectRatio: 2.5,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            mainAxisSpacing: 16,
            children: [
              _buildIngredientCard(
                'MAGNESIUM SALTS',
                'Sulfate & Chloride variants. Relaxes muscles, reduces cramps, and flushes toxins at the cellular level.',
                Icons.bolt,
                const Color(0xFF02B3A9),
              ),
              _buildIngredientCard(
                'MSM (BIO-SULFUR)',
                'Crucial for collagen and keratin. Supports cartilage health, reduces joint pain, and improves skin elasticity.',
                Icons.layers_outlined,
                const Color(0xFFF19842),
              ),
              _buildIngredientCard(
                'ARNICA MONTANA',
                'Speeds up healing of bruises and strains. High-potency anti-inflammatory properties for rapid pain relief.',
                Icons.health_and_safety_outlined,
                const Color(0xFF02B3A9),
              ),
              _buildIngredientCard(
                'TEA TREE & ESSENTIAL OILS',
                'Antifungal and antibacterial shield. Prevents gym-acquired infections and keeps skin hydrated.',
                Icons.eco_outlined,
                const Color(0xFFF19842),
              ),
            ],
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white)),
                const SizedBox(height: 8),
                Text(desc, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.4)),
              ],
            ),
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
        ],
      ),
    );
  }
}