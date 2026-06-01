import 'dart:ui' as ui;
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
import 'package:niddepoule/features/potholes/data/models/pothole.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';
import 'package:niddepoule/app/theme/theme_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  geo.Position? _userPosition;
  String _selectedCategory = 'Tous';
  Pothole? _selectedPothole;

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
    });
  }

  void _onPotholeSelected(Pothole pothole) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedPothole = pothole;
    });
  }

  @override
  Widget build(BuildContext context) {
    final potholesAsync = ref.watch(potholesProvider);

    return CivicScaffold(
      extendBody: true,
      backgroundColor: AppColors.brandBlack,
      body: Stack(
        children: [
          // 1. The Map Canvas
          Positioned.fill(
            child: potholesAsync.when(
              data: (potholes) {
                final filtered = potholes.where((p) {
                  if (_selectedCategory == 'Tous') return true;
                  if (_selectedCategory == 'Nids-de-poule') return p.dangerLevel == DangerLevel.high || p.dangerLevel == DangerLevel.medium;
                  if (_selectedCategory == 'Travaux') return p.dangerLevel == DangerLevel.low;
                  if (_selectedCategory == 'Dangers') return p.dangerLevel == DangerLevel.high;
                  return true;
                }).toList();

                return _MapCanvas(
                  potholes: filtered,
                  onPotholeTap: _onPotholeSelected,
                  onMapTap: () {
                    setState(() {
                      _selectedPothole = null;
                    });
                  },
                  userPosition: _userPosition,
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

          // 2. Top search row overlay (Hamburger + Search + Notification)
          Positioned(
            top: 55,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _buildTopIconButton(
                      icon: Icons.menu,
                      onTap: () {
                        // Open menu/drawer action
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTopSearchBar()),
                    const SizedBox(width: 8),
                    _buildTopIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () {
                        context.push('/home/alerts');
                      },
                      showBadge: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 3. Category filter pills
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPill('Tous', Icons.eco_rounded, Colors.green),
                      _buildPill('Nids-de-poule', Icons.warning_amber_rounded, Colors.amber),
                      _buildPill('Travaux', Icons.construction_rounded, Colors.orange),
                      _buildPill('Dangers', Icons.error_outline_rounded, Colors.redAccent),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Floating Action Controls overlay (Right side)
          Positioned(
            right: 16,
            top: 240,
            child: Column(
              children: [
                _buildMapControl(Icons.layers_rounded, () {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                }),
                const SizedBox(height: 12),
                _buildMapControl(Icons.near_me_rounded, _loadUserLocation),
                const SizedBox(height: 12),
                _buildMapControl(Icons.volume_up_rounded, () {
                  // Toggle audio alert sounds
                }),
              ],
            ),
          ),

          // 5. Sliding detailed card overlay
          if (_selectedPothole != null)
            Positioned(
              bottom: 88,
              left: 16,
              right: 16,
              child: _buildDetailsCard(_selectedPothole!),
            ),
        ],
      ),
    );
  }

  Widget _buildTopIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (showBadge)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Où va-t-on ?',
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Icon(Icons.mic, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildPill(String name, IconData icon, Color iconColor) {
    final isSelected = _selectedCategory == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = name;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.black.withValues(alpha: 0.8) 
              : Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandOrange : Colors.white.withValues(alpha: 0.08),
            width: 1.2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.brandOrange.withValues(alpha: 0.2), blurRadius: 6)
          ] : null,
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: iconColor, 
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildDetailsCard(Pothole pothole) {
    final dangerLabel = DangerColors.label(pothole.dangerLevel);

    // List of real pothole photos from Unsplash for display
    final List<String> potholeImages = [
      'https://images.unsplash.com/photo-1619537901462-a6292f2e41fc?q=80&w=300',
      'https://images.unsplash.com/photo-1596489370830-dfa053c9f2be?q=80&w=300',
      'https://images.unsplash.com/photo-1621293954908-907141448d37?q=80&w=300',
      'https://images.unsplash.com/photo-1584467541268-b029fb34de4e?q=80&w=300',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1015).withValues(alpha: 0.95), // Premium carbon-black card background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Drag Handle (tap to close)
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedPothole = null;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // 2. Street Name and 9.2 Rating Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  pothole.city ?? 'Rue Dalphond',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red[700]!,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '9.2',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 3. Subtitle Info: Nid-de-poule · Danger élevé
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Nid-de-poule  •  ',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                TextSpan(
                  text: dangerLabel,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // 4. Distance and Report Count
          const Text(
            '123 m  •  Signalé 14 fois',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          // 5. Horizontal list of images
          SizedBox(
            height: 76,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: potholeImages.length,
              itemBuilder: (context, idx) {
                return Container(
                  width: 105,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(potholeImages[idx]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 6. Action Button: "Voir les détails" full-width
          InkWell(
            onTap: () {
              context.push('/pothole/${pothole.id}');
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.2,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Text(
                    'Voir les détails',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCanvas extends StatefulWidget {
  const _MapCanvas({
    required this.potholes,
    required this.onPotholeTap,
    this.onMapTap,
    required this.userPosition,
  });

  final List<Pothole> potholes;
  final void Function(Pothole) onPotholeTap;
  final VoidCallback? onMapTap;
  final geo.Position? userPosition;

  @override
  State<_MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<_MapCanvas> {
  mb.MapboxMap? _mapboxMap;
  mb.PointAnnotationManager? _annotationManager;
  final Map<String, Pothole> _annotationToPothole = {};
  Uint8List? _redMarker;
  Uint8List? _orangeMarker;
  Uint8List? _yellowMarker;
  Uint8List? _userMarker;

  @override
  void initState() {
    super.initState();
    _initMarkerImages();
  }

  Future<void> _initMarkerImages() async {
    _redMarker = await _createMarkerImage(color: AppColors.dangerHigh, size: 50);
    _orangeMarker = await _createMarkerImage(color: AppColors.dangerMedium, size: 50);
    _yellowMarker = await _createMarkerImage(color: AppColors.dangerLow, size: 50);
    _userMarker = await _createUserMarkerImage(size: 40);
    if (mounted) setState(() {});
  }

  Future<Uint8List> _createMarkerImage({required Color color, required double size}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double r = size / 2;
    
    // Halo Glow
    final Paint glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(r, r), r * 0.95, glowPaint);

    // Pin outer border
    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(r, r), r * 0.5, borderPaint);

    // Pin body
    final Paint mainPaint = Paint()..color = color;
    canvas.drawCircle(Offset(r, r), r * 0.45, mainPaint);

    // Inner dot
    final Paint innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(r, r), r * 0.18, innerPaint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> _createUserMarkerImage({required double size}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double r = size / 2;

    // Glowing halo
    final Paint glowPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(r, r), r * 0.9, glowPaint);

    // Border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(r, r), r * 0.45, borderPaint);

    // Solid Blue Center
    final Paint innerPaint = Paint()..color = Colors.blueAccent;
    canvas.drawCircle(Offset(r, r), r * 0.4, innerPaint);

    // Inner white dot
    final Paint whiteDot = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(r, r), r * 0.15, whiteDot);

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _onMapCreated(mb.MapboxMap controller) async {
    _mapboxMap = controller;
    
    _annotationManager = await controller.annotations.createPointAnnotationManager();
    _annotationManager?.addOnPointAnnotationClickListener(_AnnotationClickListener(
      onTap: (annotation) {
        final pothole = _annotationToPothole[annotation.id];
        if (pothole != null) {
          widget.onPotholeTap(pothole);
        }
      }
    ));
    _updateMarkers();
    _centerCameraOnUser();
  }

  void _centerCameraOnUser() {
    final pos = widget.userPosition;
    if (_mapboxMap != null && pos != null) {
      _mapboxMap?.setCamera(mb.CameraOptions(
        center: mb.Point(coordinates: mb.Position(pos.longitude, pos.latitude)),
        zoom: 14.0,
      ));
    }
  }

  @override
  void didUpdateWidget(covariant _MapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.potholes != widget.potholes) {
      _updateMarkers();
    }
    if (oldWidget.userPosition != widget.userPosition) {
      _centerCameraOnUser();
    }
  }

  Future<void> _updateMarkers() async {
    final manager = _annotationManager;
    if (manager == null) return;

    await manager.deleteAll();
    _annotationToPothole.clear();

    if (_redMarker == null) return; // Images not loaded yet

    final List<mb.PointAnnotationOptions> optionsList = [];

    // Add user marker
    final pos = widget.userPosition;
    if (pos != null && _userMarker != null) {
      optionsList.add(mb.PointAnnotationOptions(
        geometry: mb.Point(coordinates: mb.Position(pos.longitude, pos.latitude)),
        image: _userMarker,
        iconSize: 1.0,
      ));
    }

    // Add pothole markers
    for (final pothole in widget.potholes) {
      Uint8List? markerImg;
      switch (pothole.dangerLevel) {
        case DangerLevel.high:
          markerImg = _redMarker;
          break;
        case DangerLevel.medium:
          markerImg = _orangeMarker;
          break;
        case DangerLevel.low:
          markerImg = _yellowMarker;
          break;
      }

      if (markerImg != null) {
        optionsList.add(mb.PointAnnotationOptions(
          geometry: mb.Point(coordinates: mb.Position(pothole.longitude, pothole.latitude)),
          image: markerImg,
          iconSize: 1.0,
        ));
      }
    }

    final annotations = await manager.createMulti(optionsList);

    // Map annotations back to potholes
    int annotationIndex = (pos != null && _userMarker != null) ? 1 : 0;
    for (int i = 0; i < widget.potholes.length; i++) {
      if (annotationIndex < annotations.length) {
        final ann = annotations[annotationIndex];
        if (ann != null) {
          _annotationToPothole[ann.id] = widget.potholes[i];
        }
        annotationIndex++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppEnv.mapboxAccessToken.isNotEmpty) {
      return mb.MapWidget(
        key: ValueKey('civicroad_map_${AppColors.isDarkMode}'),
        onMapCreated: _onMapCreated,
        onTapListener: (context) {
          widget.onMapTap?.call();
        },
        styleUri: 'mapbox://styles/mapbox/streets-v12',
      );
    }

    // Mock Canvas when token is empty
    return GridView.builder(
      padding: const EdgeInsets.only(top: 150, left: 16, right: 16, bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.3,
      ),
      itemCount: widget.potholes.length,
      itemBuilder: (context, index) {
        final p = widget.potholes[index];
        final color = DangerColors.forLevel(p.dangerLevel);
        return Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => widget.onPotholeTap(p),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: color, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    p.city ?? 'Rue Dalphond',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Danger : ${DangerColors.label(p.dangerLevel)}',
                    style: TextStyle(color: color, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnnotationClickListener extends mb.OnPointAnnotationClickListener {
  _AnnotationClickListener({required this.onTap});
  final void Function(mb.PointAnnotation) onTap;

  @override
  void onPointAnnotationClick(mb.PointAnnotation annotation) {
    onTap(annotation);
  }
}

