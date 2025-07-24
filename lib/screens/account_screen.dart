import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'signin_screen.dart';
import 'cart_screen.dart';
import 'about_screen.dart';
import 'edit_profile_screen.dart';
import '../services/theme_service.dart';
import '../services/database_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> with TickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final DatabaseService _databaseService = DatabaseService();
  bool _notificationsEnabled = true;
  bool _twoFactorEnabled = false;
  final int _selectedIndex = 3; // Account tab is selected
  
  // User profile data
  String? _profileImageUrl;
  String? _displayName;
  String? _userEmail;
  bool _isLoadingProfile = false;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      setState(() {
        _isLoadingProfile = true;
      });

      try {
        final userDoc = await _databaseService.getUserProfile(user!.uid);
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _profileImageUrl = userData['profileImageUrl'] ?? user!.photoURL;
            _displayName = userData['displayName'] ?? user!.displayName;
            _userEmail = userData['email'] ?? user!.email;
          });
        } else {
          setState(() {
            _profileImageUrl = user!.photoURL;
            _displayName = user!.displayName;
            _userEmail = user!.email;
          });
        }
      } catch (e) {
        // Use Firebase Auth data as fallback
        setState(() {
          _profileImageUrl = user!.photoURL;
          _displayName = user!.displayName;
          _userEmail = user!.email;
        });
      } finally {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
    
    // If profile was updated, reload the data
    if (result == true) {
      _loadUserProfile();
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    // Don't setState if we're navigating away from the screen
    if (index == _selectedIndex) return;
    
    // Navigate to different screens based on index
    switch (index) {
      case 0:
        // Home
        Navigator.pop(context); // Go back to home screen
        break;
      case 1:
        // Near By
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Near By feature coming soon!')),
        );
        break;
      case 2:
        // Cart
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
        break;
      case 3:
        // Account - already on account screen
        break;
    }
  }

  void _showLogoutDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Sign Out',
            style: TextStyle(color: theme.textTheme.titleLarge?.color),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B6B),
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeService = Provider.of<ThemeService>(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: theme.primaryColor,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFF6B6B),
                      const Color(0xFFFF8E53),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Profile Picture with Animation
                          Hero(
                            tag: 'profile-picture',
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    spreadRadius: 2,
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _isLoadingProfile
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : _profileImageUrl != null
                                        ? Image.network(
                                            _profileImageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return _buildDefaultAvatar();
                                            },
                                          )
                                        : _buildDefaultAvatar(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // User Name
                          Text(
                            _displayName ?? 'User Name',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // User Email/Phone
                          Text(
                            _userEmail?.contains('@hotplate.com') == true
                                ? 'Phone: ${_userEmail!.replaceAll('@hotplate.com', '')}'
                                : _userEmail ?? 'user@hotplate.com',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon!')),
                  );
                },
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Edit Profile Button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 30),
                      child: ElevatedButton.icon(
                        onPressed: _navigateToEditProfile,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),

                    // Quick Actions Section
                    _buildQuickActionsSection(theme),
                    const SizedBox(height: 20),

                    // Settings Section
                    _buildSettingsSection(theme, themeService, isDark),
                    const SizedBox(height: 20),

                    // Account Management Section
                    _buildAccountSection(theme, isDark),
                    const SizedBox(height: 20),

                    // Support Section
                    _buildSupportSection(theme, isDark),
                    const SizedBox(height: 30),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showLogoutDialog,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: theme.copyWith(
          bottomNavigationBarTheme: theme.bottomNavigationBarTheme.copyWith(
            backgroundColor: theme.cardTheme.color,
            selectedItemColor: const Color(0xFFFF6B6B),
            unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.near_me_outlined),
              activeIcon: Icon(Icons.near_me),
              label: 'Near By',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              activeIcon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeData theme) {
    return _buildSection(
      title: 'Quick Actions',
      theme: theme,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.history,
                title: 'Order History',
                subtitle: '12 orders',
                color: Colors.blue,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order History feature coming soon!')),
                  );
                },
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.favorite,
                title: 'Favorites',
                subtitle: '8 items',
                color: Colors.red,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Favorites feature coming soon!')),
                  );
                },
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.payment,
                title: 'Payment',
                subtitle: '3 methods',
                color: Colors.green,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment Methods feature coming soon!')),
                  );
                },
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.location_on,
                title: 'Addresses',
                subtitle: '2 saved',
                color: Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Addresses feature coming soon!')),
                  );
                },
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.brightness == Brightness.dark 
                  ? Colors.grey[700]! 
                  : Colors.grey[200]!,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(ThemeData theme, ThemeService themeService, bool isDark) {
    return _buildSection(
      title: 'Settings',
      theme: theme,
      children: [
        _buildSwitchTile(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          subtitle: 'Better visibility in low light',
          value: themeService.isDarkMode,
          onChanged: (value) => themeService.toggleTheme(),
          theme: theme,
        ),
        _buildMenuTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Order updates and promotions',
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: const Color(0xFFFF6B6B),
          ),
          onTap: () {},
          theme: theme,
        ),
        _buildMenuTile(
          icon: Icons.language_outlined,
          title: 'Language',
          subtitle: 'English (US)',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Language settings coming soon!')),
            );
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildAccountSection(ThemeData theme, bool isDark) {
    return _buildSection(
      title: 'Account & Security',
      theme: theme,
      children: [
        _buildSwitchTile(
          icon: Icons.security_outlined,
          title: 'Two-Factor Authentication',
          subtitle: 'Extra security for your account',
          value: _twoFactorEnabled,
          onChanged: (value) {
            setState(() {
              _twoFactorEnabled = value;
            });
          },
          theme: theme,
        ),
        _buildMenuTile(
          icon: Icons.lock_outline,
          title: 'Change Password',
          subtitle: 'Update your password',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Change Password feature coming soon!')),
            );
          },
          theme: theme,
        ),
        _buildMenuTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Settings',
          subtitle: 'Manage your privacy preferences',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy Settings feature coming soon!')),
            );
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildSupportSection(ThemeData theme, bool isDark) {
    return _buildSection(
      title: 'Support & Info',
      theme: theme,
      children: [
        _buildMenuTile(
          icon: Icons.help_outline,
          title: 'Help Center',
          subtitle: 'FAQs and support articles',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help Center feature coming soon!')),
            );
          },
          theme: theme,
        ),
        _buildMenuTile(
          icon: Icons.feedback_outlined,
          title: 'Send Feedback',
          subtitle: 'Help us improve the app',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feedback feature coming soon!')),
            );
          },
          theme: theme,
        ),
        _buildMenuTile(
          icon: Icons.info_outline,
          title: 'About HotPlate',
          subtitle: 'Version 1.0.0',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFF6B6B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              trailing ?? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return _buildMenuTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFFF6B6B),
      ),
      onTap: () => onChanged(!value),
      theme: theme,
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 50,
        color: Color(0xFFFF6B6B),
      ),
    );
  }
}