import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';

class MapLocationBanner extends StatelessWidget {
  const MapLocationBanner({
    super.key,
    required this.loading,
    required this.position,
  });

  final bool loading;
  final geo.Position? position;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.brandBlack,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(Icons.gps_fixed, color: AppColors.brandYellow, size: 18),
          AppSpacing.gapH(AppSpacing.sm),
          Expanded(
            child: Text(
              loading
                  ? 'Localisation en cours...'
                  : position == null
                      ? 'Position indisponible — activez la localisation'
                      : 'Vous: ${position!.latitude.toStringAsFixed(4)}, '
                          '${position!.longitude.toStringAsFixed(4)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textOnDark,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
