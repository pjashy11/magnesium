
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/shopify_provider.dart';
import '../components/molecular_background.dart';
import 'storefront_screen.dart';
import 'cart_screen.dart';
import 'dart:math' as math;

/// BRAND ASSETS
const String brandLogoUrl = 'https://firebasestorage.googleapis.com/v0/b/magnesium-athletes.firebasestorage.app/o/logo.svg?alt=media&token=53463da7-1650-4339-a2c1-f8634053928f';
const String heroImageUrl = 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&q=80&w=2070';

class InstagramIcon extends StatelessWidget {
  final double size;
  final Color color;
  const InstagramIcon({super.key, this.size = 24, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z" fill="currentColor"/>
      </svg>''',
      height: size,
      width: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class BrandLogo extends StatefulWidget {
  final double height;
  final bool isLight;
  const BrandLogo({super.key, this.height = 32, this.isLight = false});

  @override
  State<BrandLogo> createState() => _BrandLogoState();
}

class _BrandLogoState extends State<BrandLogo> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: SvgPicture.network(
        brandLogoUrl,
        height: widget.height,
        fit: BoxFit.contain,
        semanticsLabel: '',
        placeholderBuilder: (context) => _buildPulsePlaceholder(),
        errorBuilder: (context, error, stackTrace) => _buildPulsePlaceholder(),
      ),
    );
  }

  Widget _buildPulsePlaceholder() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.05 + (_pulseController.value * 0.3),
          child: Center(
            child: Icon(
              Icons.bolt_rounded,
              color: widget.isLight ? Colors.white : const Color(0xFF02B3A9),
              size: widget.height * 0.7,
            ),
          ),
        );
      },
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
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ShopifyProvider>().fetchStoreData();
      }
    });
    _scrollController.addListener(() {
      if (!_hasScrolled && _scrollController.offset > 10) {
        setState(() => _hasScrolled = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _showMissionPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MissionPopup(),
    );
  }

  void _showIngredientDetail(BuildContext context, String title, List<Map<String, String>> points, Color color, IconData icon) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.12))),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: points.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['label']!.toUpperCase(),
                            style: TextStyle(color: color, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11),
                          ),
                          const SizedBox(height: 6),
                          Text(p['content']!,
                            style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                _buildMolecularBreakdown(),
                _buildMissionTrigger(context),
                if (shopify.collections.isNotEmpty)
                  _buildCollectionNavigator(shopify.collections),
                _buildAboutSection(),
                _buildFooterCTA(),
                _buildSocialSection(), // Moved to the very bottom
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
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: const BrandLogo(height: 60),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const InstagramIcon(color: Color(0xFF02B3A9), size: 24),
            onPressed: _launchInstagram,
            tooltip: 'Follow us on Instagram',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
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
      width: double.infinity,
      height: 560,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              heroImageUrl,
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.95),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const Text(
                  'ELITE',
                  style: TextStyle(
                    fontSize: 72,
                    height: 0.85,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    letterSpacing: -2,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF02B3A9), Color(0xFF4EE2D9)],
                  ).createShader(bounds),
                  child: const Text(
                    'RECOVERY',
                    style: TextStyle(
                      fontSize: 52,
                      height: 0.85,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'High-absorption magnesium salts and skin-essential vitamins engineered to target stiffness, relax muscles, and accelerate athletic recovery.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorefrontScreen())),
                  child: Container(
                    height: 64,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFFF19842),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF19842).withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'EXPLORE THE COLLECTION',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 2,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(child: _ScrollIndicator(hasScrolled: _hasScrolled)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMolecularBreakdown() {
    final ingredients = [
      _Ingredient('MAGNESIUM SALTS', 'Deep-Absorbing', 'Mg', '01', const Color(0xFF02B3A9), [
        {'label': 'Muscle Relaxation', 'content': 'Magnesium is a natural muscle relaxant. When absorbed through the skin, it helps to ease muscle tension and reduce cramps.'},
        {'label': 'Inflammation Reduction', 'content': 'These forms of magnesium have anti-inflammatory properties, which help to reduce muscle soreness and joint pain post-exercise.'},
        {'label': 'Detoxification', 'content': 'Magnesium sulfate (Epsom salt) assists in flushing out toxins from the body, promoting a sense of relaxation and recovery.'},
      ]),
      _Ingredient('MSM', 'Methylsulfonylmethane', 'Ms', '02', const Color(0xFFF19842), [
        {'label': 'Methylsulfonylmethane', 'content': 'Methylsulfonylmethane (MSM) is a naturally occurring sulfur compound known for its exceptional anti-inflammatory properties.'},
        {'label': 'Joint Health', 'content': 'MSM is believed to help reduce joint pain and inflammation, making it popular among people with arthritis.'},
        {'label': 'Muscle Recovery', 'content': 'It can aid in reducing muscle soreness and speeding up recovery after exercise.'},
        {'label': 'Skin Health', 'content': 'MSM supports healthy skin by reducing inflammation and contributing to collagen production.'},
        {'label': 'Detoxification', 'content': 'It may help the body detox by supporting the liver and enhancing the elimination of toxins.'},
      ]),
      _Ingredient('MENTHOL', 'Cooling Therapy', 'Me', '03', const Color(0xFF02B3A9), [
        {'label': 'Cooling Sensation', 'content': 'Camphor and menthol provide a cooling effect that helps soothe aching muscles and joints.'},
        {'label': 'Antiseptic Properties', 'content': 'They help prevent infections by keeping the skin clean and bacteria-free.'},
      ]),
      _Ingredient('ARNICA', 'Healing Botanical', 'Ar', '04', const Color(0xFFF19842), [
        {'label': 'Healing Properties', 'content': 'Arnica is known for its ability to speed up the healing process of bruises and muscle strains.'},
        {'label': 'Pain Relief', 'content': 'It helps reduce pain and inflammation, making it ideal for post-workout recovery.'},
      ]),
      _Ingredient('DEAD SEA SALT', 'Mineral Charge', 'Ds', '05', const Color(0xFF02B3A9), [
        {'label': 'Mineral-Rich', 'content': 'Dead Sea salt is packed with minerals that are beneficial for the skin and overall health.'},
        {'label': 'Skin Health', 'content': 'It helps in improving skin hydration and reducing inflammation, promoting healthier skin.'},
      ]),
      _Ingredient('RECOVERY OILS', 'Skin & Tea Tree', 'Ro', '06', const Color(0xFFF19842), [
        {'label': 'Hydration', 'content': 'Essential skin oils help to moisturize the skin, preventing dryness and maintaining skin elasticity.'},
        {'label': 'Nourishment', 'content': 'They provide essential nutrients that keep the skin healthy and glowing.'},
        {'label': 'Anti-fungal & Antibacterial', 'content': 'Tea tree oil helps prevent fungal and bacterial infections, keeping the skin clean and healthy.'},
        {'label': 'Acne Prevention', 'content': 'Its antiseptic properties help in preventing and treating sweat acne and other skin irritations.'},
      ]),
    ];

    final rows = [
      [ingredients[0], ingredients[1], ingredients[2]],
      [ingredients[3], ingredients[4], ingredients[5]],
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.only(top: 40, bottom: 80),
      child: MolecularBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text('MOLECULAR BREAKDOWN',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text('HOW OUR ACTIVE RECOVERY FORMULA WORKS',
                  style: TextStyle(color: Color(0xFF02B3A9), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: rows.map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((ing) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        width: 105,
                        height: 125,
                        child: _AnimatedPeriodicTile(ing: ing, onTap: () => _showIngredientDetail(context, ing.title, ing.points, ing.color, Icons.science)),
                      ),
                    )).toList(),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
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
            'Born from the shared passion of a dedicated Cross-Fit/Boxing enthusiast and a natural skin care expert, Magnesium Athletes was created to revolutionize recovery.',
            style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.7), fontSize: 16, height: 1.6, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.fromLTRB(30, 60, 30, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('FOLLOW OUR JOURNEY',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 3, color: Color(0xFF02B3A9))),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _launchInstagram,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InstagramIcon(color: Color(0xFFF19842), size: 24),
                  SizedBox(width: 16),
                  Text(
                    '@MAGNESIUMATHLETES',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionNavigator(List<dynamic> collections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Text('BROWSE COLLECTIONS',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: Color(0xFF64748B))),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final col = collections[index]['node'];
              final title = col['title'].toString().toUpperCase();
              final products = col['products']['edges'] as List;

              String? imageUrl;
              if (products.isNotEmpty) {
                final firstProd = products[0]['node'];
                if (firstProd['images']['edges']?.isNotEmpty == true) {
                  imageUrl = firstProd['images']['edges'][0]['node']['url'];
                }
              }

              return GestureDetector(
                onTap: () {
                  context.read<ShopifyProvider>().setCategory(title);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StorefrontScreen()));
                },
                child: Container(
                  width: 220,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFF02B3A9).withValues(alpha: 0.25), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: imageUrl != null
                            ? Image.network(imageUrl, fit: BoxFit.cover, color: Colors.black.withValues(alpha: 0.15), colorBlendMode: BlendMode.darken)
                            : Container(color: const Color(0xFFF1F5F9)),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xFF0F172A)],
                              stops: [0.35, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF02B3A9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('VIEW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 10,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, color: Colors.white, size: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMissionTrigger(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFFF8FAFC)],
          stops: [0.0, 0.55],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
      child: GestureDetector(
        onTap: () => _showMissionPopup(context),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF02B3A9).withValues(alpha: 0.12),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28, height: 2,
                    color: const Color(0xFF02B3A9),
                    margin: const EdgeInsets.only(right: 10),
                  ),
                  const Text('OUR MISSION',
                      style: TextStyle(color: Color(0xFF02B3A9), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 11)),
                  Container(
                    width: 28, height: 2,
                    color: const Color(0xFF02B3A9),
                    margin: const EdgeInsets.only(left: 10),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Enhancing performance and recovery through science.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, height: 1.2),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF02B3A9), Color(0xFF01927A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF02B3A9).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('READ MISSION', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterCTA() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF19842), Color(0xFFB85E1A)],
        ),
      ),
      child: Column(
        children: [
          const Text('READY TO OPTIMIZE?',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, fontStyle: FontStyle.italic, color: Colors.white)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 70,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorefrontScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFB85E1A),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                shadowColor: Colors.black.withValues(alpha: 0.2),
              ),
              child: const Text('SHOP THE COLLECTION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class MissionPopup extends StatelessWidget {
  const MissionPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MISSION STATEMENT',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, fontStyle: FontStyle.italic, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                  const SizedBox(height: 20),
                  const Text(
                    'At Magnesium Athletes, our mission is to enhance your performance and recovery through the power of science.',
                    style: TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 40),
                  const Text('-Magnesium Athletes.',
                      style: TextStyle(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 18, color: Color(0xFF0F172A))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedPeriodicTile extends StatefulWidget {
  final _Ingredient ing;
  final VoidCallback onTap;
  const _AnimatedPeriodicTile({required this.ing, required this.onTap});

  @override
  State<_AnimatedPeriodicTile> createState() => _AnimatedPeriodicTileState();
}

class _AnimatedPeriodicTileState extends State<_AnimatedPeriodicTile> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          final shimmerValue = (math.sin(_shimmerController.value * 2 * math.pi) + 1) / 2;
          return Container(
            decoration: BoxDecoration(
              color: widget.ing.color.withValues(alpha: 0.18 + (shimmerValue * 0.1)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.ing.color.withValues(alpha: 0.5 + (shimmerValue * 0.4)),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.ing.color.withValues(alpha: 0.1 * shimmerValue),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
            ),
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.ing.atomicNumber,
                    style: TextStyle(
                      color: widget.ing.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.ing.symbol,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -1,
                        shadows: [
                          Shadow(
                            color: widget.ing.color.withValues(alpha: 0.6 + (shimmerValue * 0.3)),
                            blurRadius: 14,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Text(
                  widget.ing.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.ing.subtitle,
                  style: TextStyle(
                    color: widget.ing.color.withValues(alpha: 0.7 + (shimmerValue * 0.3)),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScrollIndicator extends StatefulWidget {
  final bool hasScrolled;
  const _ScrollIndicator({required this.hasScrolled});

  @override
  State<_ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<_ScrollIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.hasScrolled ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 400),
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withValues(alpha: 0.35),
            size: 42,
          ),
        ),
      ),
    );
  }
}

class _Ingredient {
  final String title;
  final String subtitle;
  final String symbol;
  final String atomicNumber;
  final Color color;
  final List<Map<String, String>> points;
  const _Ingredient(this.title, this.subtitle, this.symbol, this.atomicNumber, this.color, this.points);
}

