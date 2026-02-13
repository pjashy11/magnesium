
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/shopify_provider.dart';
import '../components/molecular_background.dart';
import 'storefront_screen.dart';
import 'cart_screen.dart';

/// BRAND ASSETS
const String brandLogoUrl = 'https://firebasestorage.googleapis.com/v0/b/magnesium-athletes.firebasestorage.app/o/logo.svg?alt=media&token=53463da7-1650-4339-a2c1-f8634053928f';
const String heroImageUrl = 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&q=80&w=2070';

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
        semanticsLabel: '', // Prevents fallback text rendering
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ShopifyProvider>().fetchStoreData();
      }
    });
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(title,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Color(0xFF0F172A))
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ...points.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['label']!.toUpperCase(),
                              style: TextStyle(color: color, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)
                          ),
                          const SizedBox(height: 8),
                          Text(p['content']!,
                              style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF475569))
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
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
      width: double.infinity,
      height: 600,
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
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                const SizedBox(height: 24),
                Text(
                  'High-absorption magnesium salts and skin-essential vitamins engineered to target stiffness, relax muscles, and accelerate athletic recovery.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorefrontScreen())),
                  child: Container(
                    height: 72,
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMolecularBreakdown() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(vertical: 80),
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
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              // Wide enough for text, tall enough for comfort
              childAspectRatio: 0.92,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildIngredientCard(
                    context,
                    'MAGNESIUM SALTS',
                    'Deep-Absorbing Recovery',
                    Icons.bolt,
                    const Color(0xFF02B3A9),
                    []
                ),
                _buildIngredientCard(
                    context,
                    'MSM',
                    'Joint Performance',
                    Icons.verified_user_outlined,
                    const Color(0xFFF19842),
                    []
                ),
                _buildIngredientCard(
                    context,
                    'MENTHOL',
                    'Cooling Therapy',
                    Icons.ac_unit,
                    const Color(0xFF02B3A9),
                    []
                ),
                _buildIngredientCard(
                    context,
                    'ARNICA',
                    'Healing Botanical',
                    Icons.health_and_safety_outlined,
                    const Color(0xFFF19842),
                    []
                ),
                _buildIngredientCard(
                    context,
                    'DEAD SEA SALT',
                    'Mineral Charge',
                    Icons.water_drop_outlined,
                    const Color(0xFF02B3A9),
                    []
                ),
                _buildIngredientCard(
                    context,
                    'RECOVERY OILS',
                    'Skin & Tea Tree',
                    Icons.opacity,
                    const Color(0xFFF19842),
                    []
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientCard(BuildContext context, String title, String subtitle, IconData icon, Color color, List<Map<String, String>> points) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 21, // BOLD & LARGE
                fontStyle: FontStyle.italic,
                color: Colors.white,
                height: 1.0,
                letterSpacing: -0.8,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)]
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(subtitle,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14, // INCREASED CONTRAST & SIZE
                fontWeight: FontWeight.bold,
                height: 1.1
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('INTEL',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          fontStyle: FontStyle.italic
                      )
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.bolt_sharp, color: Colors.white, size: 12),
                ],
              ),
            ),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: imageUrl != null
                            ? Image.network(imageUrl, fit: BoxFit.cover, color: Colors.black.withValues(alpha: 0.1), colorBlendMode: BlendMode.darken)
                            : Container(color: const Color(0xFFF1F5F9)),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                            ),
                          ),
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
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text(
                                    'VIEW COLLECTION',
                                    style: TextStyle(
                                      color: Color(0xFF02B3A9),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward, color: Color(0xFF02B3A9), size: 10),
                                ],
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
    return GestureDetector(
      onTap: () => _showMissionPopup(context),
      child: Container(
        margin: const EdgeInsets.all(30),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF02B3A9).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF02B3A9).withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            const Text('OUR MISSION',
                style: TextStyle(color: Color(0xFF02B3A9), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
            const SizedBox(height: 12),
            Text(
              'Enhancing performance and recovery through science.',
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.8), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF02B3A9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF02B3A9).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: const Text('READ MISSION', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
          ],
        ),
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
                    'At Magnesium Athletes, our mission is to enhance your performance and recovery through the power of our Active Recovery Soak formula and extended products. We believe that all athletes deserve the best possible care for their bodies. Our premium-quality products are designed to optimize and enhance your Performance, Recovery and Well-being.',
                    style: TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 32),
                  const Text('OUR MISSION IS THREEFOLD:',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: Color(0xFF02B3A9))),
                  const SizedBox(height: 24),
                  _buildMissionPoint(
                    'PERFORMANCE ENHANCEMENT',
                    'We strive to help athletes reach their peak performance by providing special formulated magnesium bath salts that promote muscle relaxation, reduce fatigue, and improve overall endurance. Our scientifically formulated products are specifically tailored to support your athletic endeavors, enabling you to push your limits and achieve your goals.',
                  ),
                  const SizedBox(height: 24),
                  _buildMissionPoint(
                    'RAPID RECOVERY',
                    'We understand the importance of recovery in maximizing athletic potential. Our magnesium bath salts are meticulously crafted to facilitate post-workout rejuvenation and muscle repair. By soaking in our revitalizing Active Recovery Bath Soaks, you can accelerate recovery time, reduce inflammation, and minimize the risk of injuries, allowing you to get back in the game stronger and faster.',
                  ),
                  const SizedBox(height: 24),
                  _buildMissionPoint(
                    'WELL-BEING',
                    'We are committed to promoting holistic skincare and body routine for our athletes. Our mission extends beyond performance and recovery to encompass your overall physical and mental wellness. Feel the power of our magnesium products created to alleviate pain, heal sore muscles, relax your mind, and clean your body and skin from bacteria, viruses, and fungi that can be absorbed during and from your training environments. Our goal is for you to excel in your sport while prioritizing your overall well-being. We are proud and honored to be your trusted partner in your athletic journey, providing you with the highest quality magnesium products that empower you to excel and unleash your potential. After all, a balanced athlete is a successful athlete!',
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

  Widget _buildMissionPoint(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF0F172A))),
        const SizedBox(height: 10),
        Text(content, style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF475569))),
      ],
    );
  }
}
