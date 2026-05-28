import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/config/app_env.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/core/utils/danger_colors.dart';
import 'package:niddepoule/core/widgets/civic_empty_state.dart';
import 'package:niddepoule/core/widgets/civic_loader.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';
import 'package:niddepoule/features/map/presentation/providers/map_providers.dart';
import 'package:niddepoule/features/map/presentation/widgets/map_location_banner.dart';
import 'package:niddepoule/features/map/presentation/widgets/pothole_list_panel.dart';
import 'package:niddepoule/features/map/presentation/widgets/pothole_map_bottom_sheet.dart';
import 'package:niddepoule/features/potholes/data/models/pothole.dart';
import 'package:niddepoule/core/widgets/civic_bottom_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  geo.Position? _userPosition;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final position = await ref.read(locationServiceProvider).getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _userPosition = position;
      _loadingLocation = false;
    });
  }

  void _openPotholeSheet(Pothole pothole) {
    HapticFeedback.lightImpact();
    showCivicBottomSheet<void>(
      context: context,
      child: PotholeMapBottomSheet(
        pothole: pothole,
        onConfirmPresent: () async {
          try {
            await ref.read(potholeServiceProvider).confirmStillPresent(pothole.id);
            if (!mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Confirmation enregistrée.')),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur: $e')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final potholesAsync = ref.watch(potholesProvider);

    return CivicScaffold(
      title: 'Carte',
      extendBody: true,
      actions: [
        IconButton(
          onPressed: _loadingLocation ? null : _loadUserLocation,
          icon: const Icon(Icons.my_location),
          tooltip: 'Actualiser ma position',
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/home/report'),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Signaler'),
      ),
      body: Column(
        children: [
          MapLocationBanner(
            loading: _loadingLocation,
            position: _userPosition,
          ),
          Expanded(
            child: potholesAsync.when(
              data: (potholes) {
                if (potholes.isEmpty) {
                  return CivicEmptyState(
                    title: 'Aucun nid-de-poule signalé',
                    subtitle: 'Soyez le premier à signaler un danger routier.',
                    icon: Icons.map_outlined,
                    actionLabel: 'Signaler',
                    onAction: () => context.go('/home/report'),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 600;
                    if (wide) {
                      return Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _MapCanvas(
                              potholes: potholes,
                              onPotholeTap: _openPotholeSheet,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: PotholeListPanel(
                              potholes: potholes,
                              onTap: _openPotholeSheet,
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _MapCanvas(
                            potholes: potholes,
                            onPotholeTap: _openPotholeSheet,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: PotholeListPanel(
                            potholes: potholes,
                            onTap: _openPotholeSheet,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CivicLoader(message: 'Chargement de la carte...')),
              error: (e, _) => CivicEmptyState(
                title: 'Erreur carte',
                subtitle: '$e',
                icon: Icons.error_outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({
    required this.potholes,
    required this.onPotholeTap,
  });

  final List<Pothole> potholes;
  final void Function(Pothole) onPotholeTap;

  @override
  Widget build(BuildContext context) {
    if (AppEnv.mapboxAccessToken.isNotEmpty) {
      return Stack(
        children: [
          const mb.MapWidget(key: ValueKey('civicroad_map')),
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandBlack.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                '${potholes.length} nid(s)-de-poule actifs',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1,
      ),
      itemCount: potholes.length,
      itemBuilder: (context, index) {
        final p = potholes[index];
        final color = DangerColors.forLevel(p.dangerLevel);
        return Material(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => onPotholeTap(p),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: color),
                  Text(
                    DangerColors.label(p.dangerLevel),
                    style: TextStyle(color: color, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                  Text('${p.reportCount}', style: TextStyle(color: color)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
