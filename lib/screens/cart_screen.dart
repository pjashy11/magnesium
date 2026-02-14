import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/cart_provider.dart';
import '../providers/shopify_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _showShippingIntelForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ShippingIntelForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final entries = cart.entries;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('YOUR RECOVERY KIT'),
        centerTitle: true,
      ),
      body: entries.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              children: [
                // ── Cart Items ──────────────────────────────────────
                ...entries.values.map((entry) => _CartItemRow(entry: entry)),
                const SizedBox(height: 28),

                // ── Upsell Section ──────────────────────────────────
                _UpsellSection(cartEntries: entries),
              ],
            ),
          ),
          _buildSummary(context, cart),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80,
              color: const Color(0xFF0F172A).withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text('KIT IS CURRENTLY EMPTY',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 40,
              offset: const Offset(0, -10))
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SUBTOTAL',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 2),
                    Text('${cart.totalItemCount} item${cart.totalItemCount == 1 ? '' : 's'}',
                        style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF0F172A).withValues(alpha: 0.4))),
                  ],
                ),
                Text('\$${cart.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        fontStyle: FontStyle.italic)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () => _showShippingIntelForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02B3A9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('CHECKOUT NOW',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    SizedBox(width: 12),
                    Icon(Icons.shopping_cart_checkout, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Cart Item Row ─────────────────────────────────────────────────────────────

class _CartItemRow extends StatelessWidget {
  final CartEntry entry;
  const _CartItemRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final product = entry.product;
    final quantity = entry.quantity;
    final unitPrice = double.tryParse(
        product['variants']['edges'][0]['node']['price']['amount']) ??
        0.0;
    final linePrice = unitPrice * quantity;
    final imageUrl = product['images']['edges']?.isNotEmpty == true
        ? product['images']['edges'][0]['node']['url']
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : const Icon(Icons.bolt, color: Color(0xFF02B3A9)),
          ),
          const SizedBox(width: 12),

          // Title + line price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '\$${linePrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Color(0xFF02B3A9),
                      fontWeight: FontWeight.w900,
                      fontSize: 14),
                ),
                if (quantity > 1)
                  Text(
                    '\$${unitPrice.toStringAsFixed(2)} each',
                    style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF0F172A).withValues(alpha: 0.4)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Quantity stepper
          _QuantityStepper(
            quantity: quantity,
            onDecrement: () => cart.removeFromCart(product),
            onIncrement: () => cart.addToCart(product),
            onDelete: () => cart.removeEntireEntry(product),
          ),
        ],
      ),
    );
  }
}

// ── Quantity Stepper ──────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDelete;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(
            icon: quantity == 1 ? Icons.delete_outline : Icons.remove,
            color: quantity == 1
                ? const Color(0xFFEF4444)
                : const Color(0xFF64748B),
            onTap: quantity == 1 ? onDelete : onDecrement,
          ),
          SizedBox(
            width: 30,
            child: Text('$quantity',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Color(0xFF0F172A))),
          ),
          _StepBtn(
            icon: Icons.add,
            color: const Color(0xFF02B3A9),
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _StepBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}

// ── Upsell Section ────────────────────────────────────────────────────────────

class _UpsellSection extends StatelessWidget {
  final Map<String, CartEntry> cartEntries;
  const _UpsellSection({required this.cartEntries});

  @override
  Widget build(BuildContext context) {
    final shopify = context.watch<ShopifyProvider>();
    final cartIds = cartEntries.keys.toSet();

    // Products not already in cart, limit to 6
    final suggestions = shopify.filteredProducts
        .where((p) => !cartIds.contains(p['node']['id']?.toString()))
        .take(6)
        .toList();

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3, height: 18, color: const Color(0xFFF19842),
                margin: const EdgeInsets.only(right: 10)),
            const Text('COMPLETE YOUR KIT',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: Color(0xFF0F172A))),
          ],
        ),
        const SizedBox(height: 4),
        Text('Athletes who buy this also add:',
            style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF0F172A).withValues(alpha: 0.45))),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final product = suggestions[index]['node'];
              return _UpsellCard(product: product);
            },
          ),
        ),
      ],
    );
  }
}

class _UpsellCard extends StatelessWidget {
  final dynamic product;
  const _UpsellCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final price = double.tryParse(
        product['variants']['edges'][0]['node']['price']['amount'])
        ?.toStringAsFixed(2) ??
        '—';
    final imageUrl = product['images']['edges']?.isNotEmpty == true
        ? product['images']['edges'][0]['node']['url']
        : null;

    return Container(
      width: 145,
      height: 220,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            child: Container(
              height: 100,
              width: double.infinity,
              color: const Color(0xFFF1F5F9),
              child: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : const Icon(Icons.bolt, color: Color(0xFF02B3A9), size: 32),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product['title'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text('\$$price',
                      style: const TextStyle(
                          color: Color(0xFF02B3A9),
                          fontWeight: FontWeight.w900,
                          fontSize: 12)),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        cart.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${product['title']} added to kit'),
                          backgroundColor: const Color(0xFF02B3A9),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF19842),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('+ ADD',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shipping Intel Form (unchanged) ──────────────────────────────────────────

class ShippingIntelForm extends StatefulWidget {
  const ShippingIntelForm({super.key});

  @override
  State<ShippingIntelForm> createState() => _ShippingIntelFormState();
}

class _ShippingIntelFormState extends State<ShippingIntelForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  bool _isSyncing = false;
  bool _isZipLoading = false;
  bool _isAddressLoading = false;
  String? _lastSelection;
  List<Map<String, dynamic>> _addressSuggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _zipController.addListener(_onZipChanged);
    _addressController.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _zipController.removeListener(_onZipChanged);
    _addressController.removeListener(_onAddressChanged);
    _zipController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _onAddressChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    final query = _addressController.text.trim();
    if (query == _lastSelection) {
      if (_addressSuggestions.isNotEmpty) setState(() => _addressSuggestions = []);
      return;
    }
    if (query.length < 3) {
      if (_addressSuggestions.isNotEmpty) setState(() => _addressSuggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _fetchAddressSuggestions(query));
  }

  Future<void> _fetchAddressSuggestions(String query) async {
    if (!mounted) return;
    setState(() => _isAddressLoading = true);
    try {
      final url =
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=6&countrycodes=us';
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'MagnesiumAthletesApp/4.0',
        'Accept-Language': 'en-US'
      }).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final results = data.map<Map<String, dynamic>>((item) {
          final addr = item['address'] ?? {};
          final house = addr['house_number']?.toString() ?? '';
          final road = addr['road']?.toString() ?? '';
          final city = addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['suburb'] ?? '';
          final state = addr['state']?.toString() ?? '';
          final zip = addr['postcode']?.toString() ?? '';
          String streetDisplay = house.isNotEmpty && road.isNotEmpty
              ? '$house $road'
              : road.isNotEmpty
              ? road
              : item['display_name']?.split(',')[0] ?? '';
          return {
            'display_full': '$streetDisplay, $city, $state'.replaceAll(RegExp(r',\s*,'), ','),
            'street': streetDisplay,
            'city': city,
            'state': state,
            'zip': zip,
            'is_verified': house.isNotEmpty,
          };
        }).where((m) => m['street']!.toString().isNotEmpty).toList();
        if (mounted) setState(() => _addressSuggestions = results);
      }
    } catch (e) {
      debugPrint('Address Lookup Sync Error: $e');
    } finally {
      if (mounted) setState(() => _isAddressLoading = false);
    }
  }

  void _onZipChanged() {
    final zip = _zipController.text.trim();
    if (zip.length == 5 && !_isZipLoading) _lookupZip(zip);
  }

  Future<void> _lookupZip(String zip) async {
    setState(() => _isZipLoading = true);
    try {
      final response = await http.get(Uri.parse('https://api.zippopotam.us/us/$zip'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final place = data['places'][0];
        setState(() {
          _cityController.text = place['place name'] ?? '';
          _stateController.text = place['state abbreviation'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Zip Lookup Error: $e');
    } finally {
      if (mounted) setState(() => _isZipLoading = false);
    }
  }

  Future<void> _startSecureSync() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSyncing = true);
    final buyerInfo = {
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'zip': _zipController.text.trim(),
    };
    final cartItems = context.read<CartProvider>().items;
    final checkoutUrl =
    await context.read<ShopifyProvider>().createCheckout(cartItems, buyerInfo: buyerInfo);
    if (!mounted) return;
    if (checkoutUrl != null) {
      Navigator.pop(context);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.95,
          child: CheckoutScreen(forcedUrl: checkoutUrl),
        ),
      );
    } else {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('GATEWAY TIMEOUT.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 0, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SHIPPING INFORMATION',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 32),
                    _buildField('EMAIL', _emailController, Icons.email_outlined),
                    _buildAddressSection(),
                    const SizedBox(height: 12),
                    _buildField('ZIP CODE', _zipController, Icons.pin_drop_outlined,
                        suffix: _isZipLoading
                            ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFF02B3A9)))
                            : null),
                    Row(
                      children: [
                        Expanded(child: _buildField('CITY', _cityController, Icons.location_city)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildField('STATE', _stateController, Icons.map_outlined)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSyncButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ADDRESS',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.5,
                color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          validator: (v) => v == null || v.isEmpty ? 'REQUIRED' : null,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Color(0xFF02B3A9), size: 20),
            suffixIcon: _isAddressLoading
                ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF02B3A9))))
                : null,
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            hintText: 'Enter street address',
            hintStyle: TextStyle(
                color: const Color(0xFF0F172A).withValues(alpha: 0.3),
                fontWeight: FontWeight.normal),
          ),
        ),
        _buildGoogleStyleSuggestions(),
      ],
    );
  }

  Widget _buildGoogleStyleSuggestions() {
    final query = _addressController.text.trim();
    if (query.length < 3 ||
        query == _lastSelection ||
        (_addressSuggestions.isEmpty && !_isAddressLoading)) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SUGGESTIONS',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF64748B),
                        letterSpacing: 1.5)),
                if (_isAddressLoading)
                  const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2))
                else
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, size: 14, color: Color(0xFF64748B)),
                    onPressed: () => setState(() => _addressSuggestions = []),
                  )
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _addressSuggestions.length,
              separatorBuilder: (context, index) =>
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final s = _addressSuggestions[index];
                return ListTile(
                  onTap: () {
                    setState(() {
                      _lastSelection = s['street']!;
                      _addressController.text = _lastSelection!;
                      if (s['city'].toString().isNotEmpty) _cityController.text = s['city']!;
                      if (s['state'].toString().isNotEmpty) _stateController.text = s['state']!;
                      if (s['zip'].toString().isNotEmpty) {
                        _zipController.text = s['zip']!;
                        _lookupZip(s['zip']!);
                      }
                      _addressSuggestions = [];
                    });
                  },
                  title: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                      children: [
                        TextSpan(
                            text: s['street'],
                            style: const TextStyle(fontWeight: FontWeight.w900)),
                        TextSpan(
                            text: ", ${s['city']}, ${s['state']}",
                            style: TextStyle(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Text('powered by ',
                    style: TextStyle(
                        fontSize: 9,
                        color: const Color(0xFF0F172A).withValues(alpha: 0.4))),
                const Text('Google',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4285F4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon,
      {Widget? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: (v) => v == null || v.isEmpty ? 'REQUIRED' : null,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF02B3A9), size: 20),
              suffixIcon: suffix != null
                  ? Padding(padding: const EdgeInsets.all(12), child: suffix)
                  : null,
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton() {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: _isSyncing ? null : _startSecureSync,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF19842),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isSyncing
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('PROCEED TO PAYMENT',
                style: TextStyle(
                    fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            SizedBox(width: 12),
            Icon(Icons.lock_outline, size: 18),
          ],
        ),
      ),
    );
  }
}
