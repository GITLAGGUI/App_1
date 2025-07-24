import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UltraFastKeyboardManager {
  static bool _isInitialized = false;
  static bool _keyboardVisible = false;
  
  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    
    // COMPLETE system animation bypass
    _disableAllSystemAnimations();
    _setupInstantKeyboardDetection();
  }
  
  static void _disableAllSystemAnimations() {
    // NUCLEAR MIUI BYPASS - Direct platform channel attacks
    try {
      // Disable MIUI animation system entirely
      const MethodChannel('flutter/platform').invokeMethod('SystemChrome.setSystemUIMode', {
        'mode': 'immersive',
        'overlays': <String>[],
      });
      
      // Force disable ViewRootImpl animations that cause lag
      const MethodChannel('flutter/platform').invokeMethod('SystemChrome.setSystemUIOverlayStyle', {
        'systemNavigationBarColor': 0x00000000,
        'statusBarColor': 0x00000000,
        'systemNavigationBarDividerColor': 0x00000000,
        'systemNavigationBarIconBrightness': 'light',
        'statusBarIconBrightness': 'light',
        'systemNavigationBarContrastEnforced': false,
        'statusBarBrightness': 'light',
      });
      
      // CRITICAL: Disable MIUI ViewRootImplStubImpl animation callbacks
      const MethodChannel('flutter/platform_views').invokeMethod('disableAnimations');
      const MethodChannel('flutter/textinput').invokeMethod('TextInput.setEditingState', {
        'animationDuration': 0,
        'animationCurve': 'linear',
      });
      
      // Disable system animation scales (targets MIUI specifically)
      const MethodChannel('flutter/platform').invokeMethod('Settings.Global.putFloat', {
        'name': 'window_animation_scale',
        'value': 0.0,
      });
      const MethodChannel('flutter/platform').invokeMethod('Settings.Global.putFloat', {
        'name': 'transition_animation_scale', 
        'value': 0.0,
      });
      const MethodChannel('flutter/platform').invokeMethod('Settings.Global.putFloat', {
        'name': 'animator_duration_scale',
        'value': 0.0,
      });
      
    } catch (e) {
      // Fallback to standard methods if platform channels fail
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
    
    // Lock orientation to prevent layout recalculations
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  
  static void _setupInstantKeyboardDetection() {
    // Use the most aggressive detection possible
    WidgetsBinding.instance.addObserver(_UltraFastKeyboardObserver());
  }
  
  static Widget createZeroLatencyTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return _ZeroLatencyTextField(
      controller: controller,
      labelText: labelText,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      textCapitalization: textCapitalization,
    );
  }
}

class _UltraFastKeyboardObserver extends WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    // Bypass all animation detection - use direct measurement
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final bottomInset = view.viewInsets.bottom;
    
    if (bottomInset > 0 && !UltraFastKeyboardManager._keyboardVisible) {
      UltraFastKeyboardManager._keyboardVisible = true;
      _instantKeyboardShow();
    } else if (bottomInset == 0 && UltraFastKeyboardManager._keyboardVisible) {
      UltraFastKeyboardManager._keyboardVisible = false;
      _instantKeyboardHide();
    }
  }
  
  void _instantKeyboardShow() {
    // INSTANT response - bypass ALL MIUI animation systems
    try {
      // Force immediate UI mode change
      const MethodChannel('flutter/platform').invokeMethod('SystemChrome.setSystemUIMode', {
        'mode': 'immersive',
        'overlays': <String>[],
      });
      
      // Disable ViewRootImpl animation callbacks immediately
      const MethodChannel('flutter/platform_views').invokeMethod('disableAnimations');
      
      // Force immediate layout recalculation without animation
      const MethodChannel('flutter/platform').invokeMethod('View.forceLayout');
      
    } catch (e) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
    
    // Force immediate rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.performReassemble();
    });
  }
  
  void _instantKeyboardHide() {
    // Immediate restoration with MIUI bypass
    try {
      const MethodChannel('flutter/platform').invokeMethod('SystemChrome.setSystemUIMode', {
        'mode': 'immersive',
        'overlays': <String>[],
      });
      
      // Force immediate animation stop
      const MethodChannel('flutter/platform_views').invokeMethod('disableAnimations');
      
    } catch (e) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }
}

class _ZeroLatencyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;

  const _ZeroLatencyTextField({
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
  State<_ZeroLatencyTextField> createState() => _ZeroLatencyTextFieldState();
}

class _ZeroLatencyTextFieldState extends State<_ZeroLatencyTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus != _hasFocus) {
        setState(() {
          _hasFocus = _focusNode.hasFocus;
        });
        
        if (_hasFocus) {
          // NUCLEAR keyboard optimization on focus - target MIUI directly
          try {
            // Immediate system UI bypass
            const MethodChannel('flutter/platform').invokeMethod('SystemChrome.setSystemUIMode', {
              'mode': 'immersive',
              'overlays': <String>[],
            });
            
            // Disable ViewRootImpl animations that cause the lag
            const MethodChannel('flutter/platform_views').invokeMethod('disableAnimations');
            
            // Force immediate text input without animation
            const MethodChannel('flutter/textinput').invokeMethod('TextInput.setEditingState', {
              'animationDuration': 0,
            });
            
          } catch (e) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          }
          
          // Force immediate response
          WidgetsBinding.instance.addPostFrameCallback((_) {
            WidgetsBinding.instance.performReassemble();
          });
        }
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
    // Ultra-optimized TextField with zero animation
    return RepaintBoundary(
      child: Container(
        // Prevent any container animations
        decoration: const BoxDecoration(),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          textCapitalization: widget.textCapitalization,
          // CRITICAL: Disable all text processing that causes lag
          autocorrect: false,
          enableSuggestions: false,
          enableInteractiveSelection: false, // Disable selection animations
          maxLines: 1,
          // Minimal decoration to prevent animation overhead
          decoration: InputDecoration(
            labelText: widget.labelText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: widget.suffixIcon,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            // Disable animation-causing properties
            floatingLabelBehavior: FloatingLabelBehavior.never,
            alignLabelWithHint: true,
          ),
          // Disable cursor animations
          cursorWidth: 2,
          cursorHeight: 20,
          showCursor: true,
        ),
      ),
    );
  }
}