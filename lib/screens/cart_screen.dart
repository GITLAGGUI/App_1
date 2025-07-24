import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/ultra_fast_keyboard_manager.dart';
import 'home_screen.dart';
import 'account_screen.dart';

class CartItem {
  final String id;
  final String name;
  final String restaurant;
  final String imageUrl;
  final double price;
  final List<String> customizations;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.restaurant,
    required this.imageUrl,
    required this.price,
    required this.customizations,
    this.quantity = 1,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  final int _selectedIndex = 2; // Cart tab is selected
  final TextEditingController _promoController = TextEditingController();
  late AnimationController _progressController;
  late AnimationController _confettiController;
  late Animation<double> _progressAnimation;
  
  bool _isEditing = false;
  bool _promoApplied = false;
  double _discount = 0.0;
  String _promoCode = '';

  // Sample cart items
  final List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      name: 'Grilled Salmon',
      restaurant: 'Pizza Hut',
      imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      price: 96.00,
      customizations: ['Extra Lemon', 'Medium Rare'],
      quantity: 1,
    ),
    CartItem(
      id: '2',
      name: 'Mixed Vegetable',
      restaurant: 'Green Garden',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      price: 17.03,
      customizations: ['No Onion', 'Extra Sauce'],
      quantity: 2,
    ),
    CartItem(
      id: '3',
      name: 'Fried Egg',
      restaurant: 'Breakfast Corner',
      imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      price: 15.06,
      customizations: ['Sunny Side Up'],
      quantity: 1,
    ),
  ];

  final List<CartItem> _savedItems = [];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    // Don't start progress animation immediately to improve initial load performance
  }

  @override
  void dispose() {
    _progressController.dispose();
    _confettiController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // Don't setState if we're navigating away from the screen
    if (index == _selectedIndex) return;
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Near By feature coming soon!')),
        );
        break;
      case 2:
        // Already on cart screen
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AccountScreen()),
        );
        break;
    }
  }

  void _updateQuantity(String itemId, int change) {
    setState(() {
      final itemIndex = _cartItems.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        _cartItems[itemIndex].quantity += change;
        if (_cartItems[itemIndex].quantity <= 0) {
          _removeItem(itemId);
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _removeItem(String itemId) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == itemId);
    });
  }

  void _saveForLater(String itemId) {
    setState(() {
      final itemIndex = _cartItems.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        _savedItems.add(_cartItems[itemIndex]);
        _cartItems.removeAt(itemIndex);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item saved for later'),
        backgroundColor: Color(0xFF27AE60),
      ),
    );
  }

  void _applyPromoCode() {
    final code = _promoController.text.trim().toUpperCase();
    if (code == 'SAVE20') {
      setState(() {
        _promoApplied = true;
        _discount = 0.20;
        _promoCode = code;
      });
      _confettiController.forward();
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Promo code applied! 20% discount'),
          backgroundColor: Color(0xFF27AE60),
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid promo code'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
    }
  }

  double get _subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get _deliveryFee => _subtotal > 50 ? 0.0 : 2.99;
  double get _tax => _subtotal * 0.08;
  double get _discountAmount => _subtotal * _discount;
  double get _total => _subtotal + _deliveryFee + _tax - _discountAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.appBarTheme.iconTheme?.color,
          ),
        ),
        title: Text(
          'Your Food Cart',
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Text(
              _isEditing ? 'Done' : 'Edit',
              style: TextStyle(
                color: const Color(0xFFFF5733),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5733)),
                minHeight: 4,
              );
            },
          ),
        ),
      ),
      body: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_cartItems.isNotEmpty) _buildCheckoutSection(),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFFFF5733),
            unselectedItemColor: theme.brightness == Brightness.dark
                ? Colors.grey[400]
                : const Color(0xFF666666),
            backgroundColor: theme.brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'HOME',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.near_me),
                label: 'NEAR BY',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'CART',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'ACCOUNT',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[400]
                  : const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add some delicious food to get started!',
            style: TextStyle(
              fontSize: 16,
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[400]
                  : const Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5733),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Browse Restaurants',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemsSection(),
          const SizedBox(height: 24),
          if (_savedItems.isNotEmpty) _buildSavedItemsSection(),
          _buildPromoSection(),
          const SizedBox(height: 24),
          _buildOrderSummary(),
          const SizedBox(height: 100), // Space for checkout button
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items in Your Cart (${_cartItems.length})',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cartItems.length,
          itemBuilder: (context, index) {
            return _buildCartItemCard(_cartItems[index]);
          },
        ),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(item.id),
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE74C3C),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 24,
          ),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.bookmark,
            color: Colors.white,
            size: 24,
          ),
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            _removeItem(item.id);
          } else {
            _saveForLater(item.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Color(0xFF666666),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.restaurant,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: item.customizations.map((custom) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5733).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            custom,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF5733),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF5733),
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _updateQuantity(item.id, -1),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: item.quantity > 1 ? const Color(0xFFFF5733) : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: item.quantity > 1 ? Colors.white : Colors.grey[600],
                                ),
                              ),
                            ),
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _updateQuantity(item.id, 1),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5733),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_isEditing)
                IconButton(
                  onPressed: () => _removeItem(item.id),
                  icon: const Icon(
                    Icons.delete,
                    color: Color(0xFFE74C3C),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved for Later',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _savedItems.length,
            itemBuilder: (context, index) {
              final item = _savedItems[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPromoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Have a Promo Code?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: UltraFastKeyboardManager.createZeroLatencyTextField(
                  controller: _promoController,
                  labelText: 'Enter your promo code',
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _promoApplied ? null : _applyPromoCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _promoApplied ? const Color(0xFF27AE60) : const Color(0xFFFF5733),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _promoApplied ? 'Applied' : 'Apply',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (_promoApplied)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF27AE60),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Code "$_promoCode" applied successfully!',
                    style: const TextStyle(
                      color: Color(0xFF27AE60),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal', _subtotal),
          _buildSummaryRow('Delivery Fee', _deliveryFee, 
            subtitle: _deliveryFee == 0 ? 'Free delivery on orders over \$50' : null),
          _buildSummaryRow('Tax', _tax),
          if (_promoApplied)
            _buildSummaryRow('Discount ($_promoCode)', -_discountAmount, 
              color: const Color(0xFF27AE60)),
          const Divider(height: 24),
          _buildSummaryRow('Total', _total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {
    String? subtitle,
    Color? color,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: color ?? const Color(0xFF333333),
                ),
              ),
              Text(
                '${amount < 0 ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                  color: color ?? (isTotal ? const Color(0xFFFF5733) : const Color(0xFF333333)),
                ),
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Proceeding to checkout...'),
                  backgroundColor: Color(0xFF27AE60),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5733),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              'Proceed to Checkout • \$${_total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}