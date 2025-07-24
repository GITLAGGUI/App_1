import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        title: Text(
          'About HotPlate',
          style: theme.appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.iconTheme?.color,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Version
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode 
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // App Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFF6B6B).withValues(alpha: 0.8),
                            const Color(0xFFFF8E53).withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'HotPlate',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // About Section
            _buildSection(
              context,
              'About HotPlate',
              'HotPlate is your ultimate food delivery companion, bringing delicious meals from your favorite restaurants right to your doorstep. We connect food lovers with amazing local eateries, making it easier than ever to satisfy your cravings.',
            ),

            // Mission Section
            _buildSection(
              context,
              'Our Mission',
              'To revolutionize food delivery by providing a seamless, reliable, and enjoyable experience for both customers and restaurant partners. We believe that great food should be accessible to everyone, anytime, anywhere.',
            ),

            // Features Section
            _buildSection(
              context,
              'Key Features',
              '• Real-time order tracking\n'
              '• Wide variety of restaurants\n'
              '• Secure payment options\n'
              '• User-friendly interface\n'
              '• Fast and reliable delivery\n'
              '• Customer support 24/7\n'
              '• Personalized recommendations\n'
              '• Order history and favorites',
            ),

            // Technology Section
            _buildSection(
              context,
              'Technology Stack',
              'HotPlate is built using cutting-edge technology to ensure the best performance and user experience:\n\n'
              '• Flutter for cross-platform mobile development\n'
              '• Firebase for backend services and real-time data\n'
              '• Advanced security protocols for payment processing\n'
              '• Machine learning for personalized recommendations\n'
              '• Cloud infrastructure for scalability and reliability',
            ),

            // Team Section
            _buildSection(
              context,
              'Our Team',
              'HotPlate is developed by a passionate team of engineers, designers, and food enthusiasts who are dedicated to creating the best food delivery experience. Our diverse team brings together expertise in mobile development, user experience design, and the food industry.',
            ),

            // Contact Section
            _buildSection(
              context,
              'Contact Us',
              'We love hearing from our users! Get in touch with us:\n\n'
              '📧 Email: support@hotplate.com\n'
              '📱 Phone: +1 (555) 123-4567\n'
              '🌐 Website: www.hotplate.com\n'
              '📍 Address: 123 Food Street, Culinary City, FC 12345\n\n'
              'Follow us on social media:\n'
              '• Facebook: @HotPlateApp\n'
              '• Instagram: @hotplate_official\n'
              '• Twitter: @HotPlateApp',
            ),

            // Legal Section
            _buildSection(
              context,
              'Legal Information',
              '© 2024 HotPlate Inc. All rights reserved.\n\n'
              'This app is protected by copyright and other intellectual property laws. The HotPlate name and logo are trademarks of HotPlate Inc.\n\n'
              'For Terms of Service and Privacy Policy, please visit our website or contact our support team.',
            ),

            // Acknowledgments Section
            _buildSection(
              context,
              'Acknowledgments',
              'We would like to thank all our restaurant partners, delivery drivers, and loyal customers who make HotPlate possible. Special thanks to the open-source community and the developers of the libraries and frameworks that power our app.',
            ),

            const SizedBox(height: 30),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Made with ❤️ for food lovers everywhere',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Thank you for choosing HotPlate!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF6B6B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}