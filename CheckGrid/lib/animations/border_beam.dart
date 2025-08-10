import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Creates an animated border beam effect around a child widget.
///
/// The [duration] controls how fast the beam moves around the border in seconds.
/// The [beamLength] determines what portion of the border is illuminated (0.0-1.0).
/// The [gradientLength] controls the gradient transition length (0.0-1.0).
class BorderBeam extends StatefulWidget {
  final Widget child;
  final int duration;
  final double borderWidth;
  final Color colorFrom;
  final Color colorTo;
  final Color staticBorderColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final double beamLength;
  final double gradientLength;

  const BorderBeam({
    super.key,
    required this.child,
    this.duration = 15,
    this.borderWidth = 1.5,
    this.colorFrom = const Color(0xFFFFAA40),
    this.colorTo = const Color(0xFF9C40FF),
    this.staticBorderColor = const Color(0xFFCCCCCC),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = const EdgeInsets.all(0),
    this.beamLength = 0.25,
    this.gradientLength = 0.125,
  }) : assert(
         beamLength >= 0.0 && beamLength <= 1.0,
         'beamLength must be between 0.0 and 1.0',
       ),
       assert(
         gradientLength >= 0.0 && gradientLength <= 1.0,
         'gradientLength must be between 0.0 and 1.0',
       );

  @override
  State<BorderBeam> createState() => _BorderBeamState();
}

class _BorderBeamState extends State<BorderBeam>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      duration: Duration(seconds: widget.duration),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Start animation when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _controller.stop();
        break;
      case AppLifecycleState.resumed:
        if (mounted) _controller.repeat();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        _controller.stop();
        break;
    }
  }

  @override
  void didUpdateWidget(BorderBeam oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = Duration(seconds: widget.duration);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: BorderBeamPainter(
            progress: _animation.value,
            borderWidth: widget.borderWidth,
            colorFrom: widget.colorFrom,
            colorTo: widget.colorTo,
            staticBorderColor: widget.staticBorderColor,
            borderRadius: widget.borderRadius,
            beamLength: widget.beamLength,
            gradientLength: widget.gradientLength,
          ),
          child: Padding(padding: widget.padding, child: widget.child),
        );
      },
    );
  }
}

class BorderBeamPainter extends CustomPainter {
  final double progress;
  final double borderWidth;
  final Color colorFrom;
  final Color colorTo;
  final Color staticBorderColor;
  final BorderRadius borderRadius;
  final double beamLength;
  final double gradientLength;

  BorderBeamPainter({
    required this.progress,
    required this.borderWidth,
    required this.colorFrom,
    required this.colorTo,
    required this.staticBorderColor,
    required this.borderRadius,
    required this.beamLength,
    required this.gradientLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = borderRadius.toRRect(rect);

    // Draw static border
    final staticPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = staticBorderColor;
    canvas.drawRRect(rrect, staticPaint);

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;

    // Calculate beam position and length
    final animationProgress = progress % 1.0;
    final start = animationProgress * pathLength;
    final beamLengthInPixels = pathLength * beamLength;
    final end = (start + beamLengthInPixels) % pathLength;

    Path extractPath;
    if (end > start) {
      extractPath = pathMetrics.extractPath(start, end);
    } else {
      extractPath = pathMetrics.extractPath(start, pathLength);
      extractPath.addPath(pathMetrics.extractPath(0, end), Offset.zero);
    }

    // Calculate gradient positions
    final gradientLengthInPixels = pathLength * gradientLength;
    final gradientStart =
        pathMetrics.getTangentForOffset(start)?.position ?? Offset.zero;
    final gradientEnd =
        pathMetrics
            .getTangentForOffset((start + gradientLengthInPixels) % pathLength)
            ?.position ??
        Offset.zero;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

    paint.shader = ui.Gradient.linear(
      gradientStart,
      gradientEnd,
      [
        colorTo.withOpacity(0.0), // Transparent for fading effect
        colorTo,
        colorFrom,
      ],
      [0.0, 0.3, 1.0],
    );

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant BorderBeamPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.colorFrom != colorFrom ||
        oldDelegate.colorTo != colorTo ||
        oldDelegate.staticBorderColor != staticBorderColor ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.beamLength != beamLength ||
        oldDelegate.gradientLength != gradientLength;
  }
}
