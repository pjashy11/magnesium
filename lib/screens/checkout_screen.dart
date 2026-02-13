
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/cart_provider.dart';
import '../providers/shopify_provider.dart';

class CheckoutScreen extends StatefulWidget {
  final String? forcedUrl;
  const CheckoutScreen({super.key, this.forcedUrl});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  WebViewController? _controller;
  bool _isSyncing = true;
  int _loadingProgress = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCheckoutSession();
  }

  Future<void> _initializeCheckoutSession() async {
    try {
      String? webUrl = widget.forcedUrl;

      if (webUrl == null) {
        final cartItems = context.read<CartProvider>().items;
        webUrl = await context.read<ShopifyProvider>().createCheckout(cartItems);
      }

      if (webUrl != null) {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0xFFF8FAFC))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                if (mounted) setState(() => _loadingProgress = progress);
              },
              onPageFinished: (String url) {
                if (mounted) setState(() => _isSyncing = false);

                // Check if we've reached the thank you page to clear the cart
                if (url.contains('thank_you') || url.contains('orders/')) {
                  _handleCheckoutSuccess();
                }
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('Secure Tunnel Error: ${error.description}');
              },
              onNavigationRequest: (NavigationRequest request) {
                final String url = request.url;

                // INTERCEPT NON-WEB SCHEMES (mailto, tel, etc)
                if (url.startsWith('mailto:') || url.startsWith('tel:')) {
                  _handleExternalScheme(url);
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(webUrl));

        if (mounted) {
          setState(() {
            _controller = controller;
          });
        }
      } else {
        setState(() {
          _isSyncing = false;
          _errorMessage = "COULD NOT ESTABLISH SECURE LINK";
        });
      }
    } catch (e) {
      setState(() {
        _isSyncing = false;
        _errorMessage = "BIO-SYNC ERROR: $e";
      });
    }
  }

  Future<void> _handleExternalScheme(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch external scheme: $url');
      }
    } catch (e) {
      debugPrint('Error launching external scheme: $e');
    }
  }

  void _handleCheckoutSuccess() {
    context.read<CartProvider>().clearCart();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('SECURE CHECKOUT'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF0F172A), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: LinearProgressIndicator(
            value: _loadingProgress / 100,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF02B3A9)),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_controller != null)
            WebViewWidget(
              controller: _controller!,
              gestureRecognizers: {
                Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer(),
                ),
              },
            ),
          if (_isSyncing || _loadingProgress < 10)
            _buildLoadingCurtain(),
          if (_errorMessage != null)
            _buildErrorState(),
        ],
      ),
    );
  }

  Widget _buildLoadingCurtain() {
    return Container(
      color: const Color(0xFFF8FAFC),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF02B3A9)),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'CONNECTING TO SECURE GATEWAY',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 2,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_loadingProgress% ENCRYPTION SYNC',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1,
              color: const Color(0xFF0F172A).withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFF19842), size: 64),
          const SizedBox(height: 24),
          Text(
            _errorMessage ?? 'CONNECTION FAILED',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isSyncing = true;
                  _errorMessage = null;
                  _loadingProgress = 0;
                });
                _initializeCheckoutSession();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF02B3A9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('RETRY SYNC', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          )
        ],
      ),
    );
  }
}