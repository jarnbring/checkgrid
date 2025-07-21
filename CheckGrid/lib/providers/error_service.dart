import 'package:flutter/material.dart';

class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  // Logga fel
  void logError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    debugPrint('🔴 ERROR: $error');
    if (context != null) debugPrint('📍 CONTEXT: $context');
    if (stackTrace != null) debugPrint('📊 STACK: $stackTrace');
    if (additionalData != null) debugPrint('📋 DATA: $additionalData');
  }

  // Visa fel för användaren
  void showError(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
    bool isSnackBar = true,
    bool useTopPosition = false,
  }) {
    if (!context.mounted) return;

    if (isSnackBar) {
      if (useTopPosition) {
        _showTopSnackBar(context, message, onRetry: onRetry);
      } else {
        _showErrorSnackBar(context, message, onRetry: onRetry);
      }
    } else {
      _showErrorDialog(context, message, onRetry: onRetry);
    }
  }

  // Original SnackBar (botten)
  void _showErrorSnackBar(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        action:
            onRetry != null
                ? SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: onRetry,
                )
                : null,
      ),
    );
  }

  // Anpassad SnackBar i övre högra hörnet
  void _showTopSnackBar(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => TopSnackBar(
            message: message,
            onRetry: onRetry,
            onDismiss: () {
              overlayEntry.remove();
            },
          ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove efter 4 sekunder
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _showErrorDialog(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
            title: const Text('Something went wrong'),
            content: Text(message),
            actions: [
              if (onRetry != null)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onRetry();
                  },
                  child: const Text('Retry'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  // Hantera och visa fel i en operation
  Future<T?> handleError<T>(
    Future<T> Function() operation, {
    BuildContext? context,
    String? errorMessage,
    String? logContext,
    VoidCallback? onRetry,
    bool showDialog = false,
    bool useTopSnackBar = false,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      logError(error, stackTrace, context: logContext ?? 'Unknown operation');

      if (context?.mounted == true) {
        showError(
          context!,
          errorMessage ?? 'An unexpected error occurred',
          onRetry: onRetry,
          isSnackBar: !showDialog,
          useTopPosition: useTopSnackBar,
        );
      }

      return null;
    }
  }
}

// Anpassad TopSnackBar widget
class TopSnackBar extends StatefulWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback onDismiss;

  const TopSnackBar({
    super.key,
    required this.message,
    this.onRetry,
    required this.onDismiss,
  });

  @override
  State<TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<TopSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Slide in från höger
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 50, // Under status bar
      right: 16,
      left: MediaQuery.of(context).size.width * 0.25, // Täcker 75% från höger
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: Colors.red.shade600,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  if (widget.onRetry != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        _dismiss();
                        widget.onRetry?.call();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                  IconButton(
                    onPressed: _dismiss,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extensions för enkel användning
extension ErrorHandling on BuildContext {
  void showError(String message, {VoidCallback? onRetry}) {
    ErrorService().showError(this, message, onRetry: onRetry);
  }

  void showTopError(String message, {VoidCallback? onRetry}) {
    ErrorService().showError(
      this,
      message,
      onRetry: onRetry,
      useTopPosition: true,
    );
  }

  void showErrorDialog(String message, {VoidCallback? onRetry}) {
    ErrorService().showError(
      this,
      message,
      onRetry: onRetry,
      isSnackBar: false,
    );
  }
}
