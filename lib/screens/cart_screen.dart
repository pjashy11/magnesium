
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('RECOVERY KIT'),
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
                onPressed: () {
                  // Presentation: Open as a Native-feeling Modal Sheet
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    enableDrag: false, // CRITICAL: Prevents accidental closure when scrolling checkout form
                    backgroundColor: Colors.transparent,
                    builder: (context) => const FractionallySizedBox(
                      heightFactor: 0.95,
                      child: CheckoutScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02B3A9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('AUTHORIZE NATIVE CHECKOUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    SizedBox(width: 12),
                    Icon(Icons.lock_outline, size: 18),
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