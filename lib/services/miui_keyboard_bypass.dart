import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MIUIKeyboardBypass {
  static bool _isInitialized = false;
  static bool _keyboardVisible = false;
  
  static void initialize(BuildContext context) {
    if (_isInitialized) return;
    _isInitialized = true;
    
    // Instead of fighting MIUI, work around it completely
    _setupMIUIWorkaround();
  }
  
  static void _setupMIUIWorkaround() {
    // Use the most basic system UI mode that MIUI can't override
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    
    // Lock orientation to prevent MIUI layout recalculations
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    
    // Set up keyboard detection without relying on animations
    WidgetsBinding.instance.addObserver(_MIUIKeyboardObserver());
  }
  
  static Widget createBypassTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return _MIUIBypassTextField(
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

class _MIUIKeyboardObserver extends WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    // Simple keyboard detection without animation interference
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final bottomInset = view.viewInsets.bottom;
    
    bool newKeyboardState = bottomInset > 0;
    if (newKeyboardState != MIUIKeyboardBypass._keyboardVisible) {
      MIUIKeyboardBypass._keyboardVisible = newKeyboardState;
      
      if (newKeyboardState) {
        _onKeyboardShow();
      } else {
        _onKeyboardHide();
      }
    }
  }
  
  void _onKeyboardShow() {
    // Minimal response - don't trigger MIUI animations
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }
  
  void _onKeyboardHide() {
    // Minimal response - don't trigger MIUI animations
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }
}

class _MIUIBypassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;

  const _MIUIBypassTextField({
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
  State<_MIUIBypassTextField> createState() => _MIUIBypassTextFieldState();
}

class _MIUIBypassTextFieldState extends State<_MIUIBypassTextField> {
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
          // Minimal system interaction to avoid triggering MIUI animations
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
    // Ultra-minimal TextField design to avoid MIUI interference
    return SizedBox(
      // Fixed container to prevent layout animations
      height: 56,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction ?? TextInputAction.next,
        textCapitalization: widget.textCapitalization,
        // Disable everything that could trigger MIUI animations
        autocorrect: false,
        enableSuggestions: false,
        enableInteractiveSelection: false,
        maxLines: 1,
        // Minimal decoration
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
          // Disable floating label animations
          floatingLabelBehavior: FloatingLabelBehavior.never,
          alignLabelWithHint: true,
          // Remove content padding that could cause layout shifts
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        // Minimal cursor
        cursorWidth: 2,
        cursorHeight: 20,
        showCursor: true,
      ),
    );
  }
}