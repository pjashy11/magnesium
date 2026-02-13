
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('YOUR RECOVERY KIT'),
        centerTitle: true,
      ),
      body: cart.items.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                final price = item['variants']['edges'][0]['node']['price']['amount'];
                final imageUrl = item['images']['edges']?.isNotEmpty == true
                    ? item['images']['edges'][0]['node']['url']
                    : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imageUrl != null
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : const Icon(Icons.bolt, color: Color(0xFF02B3A9)),
                    ),
                    title: Text(
                        item['title'],
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)
                    ),
                    subtitle: Text(
                        '\$$price',
                        style: const TextStyle(color: Color(0xFF02B3A9), fontWeight: FontWeight.w900)
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF64748B)),
                      onPressed: () => cart.removeFromCart(item),
                    ),
                  ),
                );
              },
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
          Icon(Icons.shopping_bag_outlined, size: 80, color: const Color(0xFF0F172A).withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text('KIT IS CURRENTLY EMPTY', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 12, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, -10))
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SUBTOTAL', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF64748B), fontSize: 12, letterSpacing: 1.5)),
                Text('\$${cart.totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 32, fontStyle: FontStyle.italic)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                onPressed: () => _showShippingIntelForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02B3A9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('CHECKOUT NOW', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    SizedBox(width: 12),
                    Icon(Icons.shopping_cart_checkout, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      if (_addressSuggestions.isNotEmpty) {
        setState(() => _addressSuggestions = []);
      }
      return;
    }

    if (query.length < 3) {
      if (_addressSuggestions.isNotEmpty) {
        setState(() => _addressSuggestions = []);
      }
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchAddressSuggestions(query);
    });
  }

  Future<void> _fetchAddressSuggestions(String query) async {
    if (!mounted) return;
    setState(() => _isAddressLoading = true);

    try {
      final url = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=6&countrycodes=us';
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

          String streetDisplay = "";
          if (house.isNotEmpty && road.isNotEmpty) {
            streetDisplay = "$house $road";
          } else if (road.isNotEmpty) {
            streetDisplay = road;
          } else {
            streetDisplay = item['display_name']?.split(',')[0] ?? '';
          }

          return {
            'display_full': "$streetDisplay, $city, $state".replaceAll(RegExp(r',\s*,'), ','),
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
    if (zip.length == 5 && !_isZipLoading) {
      _lookupZip(zip);
    }
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
    final checkoutUrl = await context.read<ShopifyProvider>().createCheckout(cartItems, buyerInfo: buyerInfo);

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GATEWAY TIMEOUT.')));
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
      padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SHIPPING INFORMATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, fontStyle: FontStyle.italic, letterSpacing: -0.5)),
                    const SizedBox(height: 32),
                    _buildField('EMAIL', _emailController, Icons.email_outlined),
                    _buildAddressSection(),
                    const SizedBox(height: 12),
                    _buildField('ZIP CODE', _zipController, Icons.pin_drop_outlined,
                        suffix: _isZipLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF02B3A9))) : null
                    ),
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
        const Text('ADDRESS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          validator: (v) => v == null || v.isEmpty ? 'REQUIRED' : null,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Color(0xFF02B3A9), size: 20),
            suffixIcon: _isAddressLoading ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF02B3A9)))) : null,
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            hintText: 'Enter street address',
            hintStyle: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.3), fontWeight: FontWeight.normal),
          ),
        ),
        _buildGoogleStyleSuggestions(),
      ],
    );
  }

  Widget _buildGoogleStyleSuggestions() {
    final query = _addressController.text.trim();
    if (query.length < 3 || query == _lastSelection || (_addressSuggestions.isEmpty && !_isAddressLoading)) {
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
            offset: const Offset(0, 10),
          )
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
                const Text('SUGGESTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1.5)),
                if (_isAddressLoading)
                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
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
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
                        TextSpan(text: s['street'], style: const TextStyle(fontWeight: FontWeight.w900)),
                        TextSpan(text: ", ${s['city']}, ${s['state']}", style: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.5))),
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
                Text('powered by ', style: TextStyle(fontSize: 9, color: const Color(0xFF0F172A).withValues(alpha: 0.4))),
                const Text('Google', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {Widget? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: (v) => v == null || v.isEmpty ? 'REQUIRED' : null,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF02B3A9), size: 20),
              suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.all(12), child: suffix) : null,
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            Text('PROCEED TO PAYMENT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            SizedBox(width: 12),
            Icon(Icons.lock_outline, size: 18),
          ],
        ),
      ),
    );
  }
}