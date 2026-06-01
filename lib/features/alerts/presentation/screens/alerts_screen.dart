import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isNavigating) {
      return _buildNavigationHUD();
    }

    return CivicScaffold(
      title: 'Alertes',
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      body: Column(
        children: [
          // Top tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.brandOrange,
              labelColor: AppColors.brandOrange,
              unselectedLabelColor: AppColors.textSecondary,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'À proximité (3)'),
                Tab(text: 'Abonnements'),
                Tab(text: 'Système'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProximityAlerts(),
                _buildMockEmptyTab('Abonnements'),
                _buildMockEmptyTab('Système'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProximityAlerts() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Alert 1: Active Warning with Map preview
        Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1012),
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.dangerHigh.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.dangerHigh.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.dangerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nid-de-poule dangereux à 120 m devant vous',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rue Dalphond',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Simulated route card
              Container(
                height: 120,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.brandBlack,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Stack(
                  children: [
                    // Grid lines (futuristic map look)
                    CustomPaint(
                      size: const Size(double.infinity, 120),
                      painter: _MapGridPainter(),
                    ),
                    // Path line
                    CustomPaint(
                      size: const Size(double.infinity, 120),
                      painter: _PathPainter(),
                    ),
                    // Hazard marker
                    Positioned(
                      left: 180,
                      top: 40,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.dangerHigh,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppColors.dangerHigh, blurRadius: 8)
                          ]
                        ),
                        child: const Icon(Icons.warning, color: Colors.white, size: 14),
                      ),
                    ),
                    // User position pointer
                    Positioned(
                      left: 60,
                      top: 75,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.blue, blurRadius: 10)
                          ]
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isNavigating = true;
                        });
                      },
                      icon: Icon(Icons.navigation_rounded, color: AppColors.brandOrange),
                      label: Text(
                        'Lancer le guidage',
                        style: TextStyle(color: AppColors.brandOrange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),

        // Alert 2: Purple sector info
        Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF231230), Color(0xFF150B1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, color: Colors.purpleAccent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '3 nouveaux signalements',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Signalés récemment dans votre secteur.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.purpleAccent,
                  shape: BoxShape.circle,
                ),
              )
            ],
          ),
        ),

        // Alert 3: Critical Zone
        Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brandBlackSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, color: AppColors.brandOrange, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Zone critique à Shawinigan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Plusieurs nids-de-poule signalés cette semaine.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMockEmptyTab(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Aucune alerte dans $title',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // GUIDAGE GPS VIEW (Interactive simulation of Screen 6 of Image 2)
  Widget _buildNavigationHUD() {
    return Container(
      color: AppColors.brandBlack,
      child: Stack(
        children: [
          // Map Background (Mock grid map with path)
          Positioned.fill(
            child: CustomPaint(
              painter: _NavigationMapPainter(),
            ),
          ),

          // Upper Danger banner
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))
                ]
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nid-de-poule dangereux !',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '120 m · Rue Dalphond',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.volume_up, color: Colors.white, size: 20),
                  )
                ],
              ),
            ),
          ),

          // Action navigation instructions overlay
          Positioned(
            top: 170,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.turn_right, color: Colors.blueAccent, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dans 120 m',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          'Puis tourner à droite',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // Speedometer widget (circular design)
          Positioned(
            bottom: 120,
            left: 20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brandOrange, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 8)
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '45',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  Text(
                    'km/h',
                    style: TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation info bar
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Avenue Jean-Duchesne',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '3 min · 1.2 km · 07:05',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandBlackSoft,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(90, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          setState(() {
                            _isNavigating = false;
                          });
                        },
                        child: const Text('Quitter', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(40, size.height - 20);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width * 0.5, size.height * 0.45);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.4, size.width - 40, 20);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavigationMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw background color
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF0B0C0F));

    // Draw grids
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw glowing routing path
    final routePaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final routeSolid = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final routeGlow = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.5)
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final path = Path();
    path.moveTo(size.width / 2, size.height - 80);
    path.quadraticBezierTo(size.width / 2, size.height * 0.6, size.width / 2 - 30, size.height * 0.5);
    path.quadraticBezierTo(size.width / 2 - 60, size.height * 0.4, size.width / 2 + 40, size.height * 0.25);
    path.lineTo(size.width / 2 + 50, size.height * 0.1);

    canvas.drawPath(path, routeGlow);
    canvas.drawPath(path, routePaint);
    canvas.drawPath(path, routeSolid);

    // Draw warning circle on map
    final warningGlow = Paint()
      ..color = Colors.red.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(size.width / 2 - 45, size.height * 0.45), 25, warningGlow);

    final warningCircle = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2 - 45, size.height * 0.45), 12, warningCircle);

    final iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: '!',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
    iconPainter.layout();
    iconPainter.paint(canvas, Offset(size.width / 2 - 48, size.height * 0.45 - 8));

    // Draw user position
    final userGlow = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(size.width / 2, size.height - 180), 20, userGlow);

    final userPin = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height - 180), 8, userPin);

    final userDot = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height - 180), 4, userDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
