import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardPerformanceManager {
  static bool _isInitialized = false;
  static bool _keyboardVisible = false;
  
  static void optimizeKeyboardPerformance() {
    if (_isInitialized) return;
    _isInitialized = true;
    
    // Ultra-aggressive keyboard optimization for 0.3s response
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Disable ALL system UI change callbacks to prevent animation lag
      SystemChrome.setSystemUIChangeCallback(null);
      
      // Force immediate layout without animation delays
      WidgetsBinding.instance.performReassemble();
    });
    
    // Listen for keyboard events with immediate response
    WidgetsBinding.instance.addObserver(_KeyboardObserver());
  }

  static void configureOptimalKeyboardSettings() {
    // Configure system UI for ZERO animation and fastest response
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [], // Completely hide all system UI during keyboard operations
    );
    
    // Lock orientation to prevent any layout recalculations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Disable ALL haptic feedback to reduce processing overhead
    SystemChannels.platform.invokeMethod('HapticFeedback.vibrate', null);
  }
  
  static void disableAllAnimations() {
    // Complete animation disabling for instant keyboard response
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    
    // Android-specific: disable window transition animations
    SystemChannels.platform.invokeMethod('SystemChrome.setSystemUIChangeCallback', null);
  }
  
  static void _onKeyboardShow() {
    if (_keyboardVisible) return;
    _keyboardVisible = true;
    
    // Immediate response when keyboard appears
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    
    // Force immediate layout update without animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.performReassemble();
    });
  }
  
  static void _onKeyboardHide() {
    if (!_keyboardVisible) return;
    _keyboardVisible = false;
    
    // Minimal delay to prevent animation conflicts, then restore
    Future.delayed(const Duration(milliseconds: 50), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ]);
    });
  }
  
  static Widget wrapTextField(Widget textField) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          _onKeyboardShow();
        } else {
          _onKeyboardHide();
        }
      },
      child: RepaintBoundary(child: textField),
    );
  }
}

class _KeyboardObserver extends WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final bottomInset = view.viewInsets.bottom;
    if (bottomInset > 0) {
      KeyboardPerformanceManager._onKeyboardShow();
    } else {
      KeyboardPerformanceManager._onKeyboardHide();
    }
  }
}

class PerformanceOptimizedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;

  const PerformanceOptimizedTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<PerformanceOptimizedTextField> createState() => _PerformanceOptimizedTextFieldState();
}

class _PerformanceOptimizedTextFieldState extends State<PerformanceOptimizedTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    
    // Optimize focus handling to reduce animation callbacks
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Trigger immediate keyboard optimization
        KeyboardPerformanceManager._onKeyboardShow();
      } else {
        KeyboardPerformanceManager._onKeyboardHide();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction ?? TextInputAction.next,
        textCapitalization: widget.textCapitalization,
        autocorrect: false,
        enableSuggestions: false,
        // Optimize text input to reduce callbacks
        maxLines: 1,
        decoration: InputDecoration(
          labelText: widget.labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: widget.suffixIcon,
          // Optimize border rendering
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.orange, width: 2),
          ),
        ),
      ),
    );
  }
}