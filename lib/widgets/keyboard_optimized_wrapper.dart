import 'package:flutter/material.dart';

class KeyboardOptimizedWrapper extends StatelessWidget {
  final Widget child;

  const KeyboardOptimizedWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation,
        builder: (context, child) {
          return this.child;
        },
      ),
    );
  }
}

class OptimizedScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final Widget? floatingActionButton;

  const OptimizedScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      // Optimize keyboard handling to reduce animation callbacks
      resizeToAvoidBottomInset: true,
      body: KeyboardOptimizedWrapper(
        child: body ?? const SizedBox.shrink(),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}