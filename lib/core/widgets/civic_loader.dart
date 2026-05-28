import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';

class CivicLoader extends StatelessWidget {
  const CivicLoader({super.key, this.size = 32, this.message});

  final double size;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.brandYellow,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class CivicLoaderOverlay extends StatelessWidget {
  const CivicLoaderOverlay({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.brandBlack.withValues(alpha: 0.35),
      alignment: Alignment.center,
      child: CivicCardLoader(message: message),
    );
  }
}

class CivicCardLoader extends StatelessWidget {
  const CivicCardLoader({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CivicLoader(message: message),
    );
  }
}
