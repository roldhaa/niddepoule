import 'package:flutter/material.dart';

class CivicBeforeAfterSlider extends StatefulWidget {
  const CivicBeforeAfterSlider({
    super.key,
    required this.beforeImageUrl,
    required this.afterImageUrl,
    this.height = 240,
    this.borderRadius = 24,
  });

  final String beforeImageUrl;
  final String afterImageUrl;
  final double height;
  final double borderRadius;

  @override
  State<CivicBeforeAfterSlider> createState() => _CivicBeforeAfterSliderState();
}

class _CivicBeforeAfterSliderState extends State<CivicBeforeAfterSlider> {
  double _slidePercent = 0.5;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) {
              setState(() {
                _slidePercent = (_slidePercent + details.delta.dx / width).clamp(0.0, 1.0);
              });
            },
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: Stack(
                children: [
                  // After Image (Background)
                  SizedBox(
                    width: width,
                    height: widget.height,
                    child: Image.network(
                      widget.afterImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                  ),

                  // Before Image (Foreground Clipped)
                  ClipRect(
                    clipper: _BeforeClipper(_slidePercent),
                    child: SizedBox(
                      width: width,
                      height: widget.height,
                      child: Image.network(
                        widget.beforeImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.broken_image, color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  // Static labels
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Avant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF42A5F5).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Après',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Divider Line
                  Positioned(
                    left: width * _slidePercent - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),

                  // Central handle with black play icon
                  Positioned(
                    left: width * _slidePercent - 20,
                    top: (widget.height - 40) / 2,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BeforeClipper extends CustomClipper<Rect> {
  _BeforeClipper(this.percent);
  final double percent;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * percent, size.height);
  }

  @override
  bool shouldReclip(_BeforeClipper oldClipper) => oldClipper.percent != percent;
}
