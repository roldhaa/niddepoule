import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';
import 'package:niddepoule/core/widgets/civic_app_bar.dart';
import 'package:niddepoule/features/reports/presentation/providers/report_form_provider.dart';
import 'package:niddepoule/features/reports/data/models/report.dart' show DangerLevel;

class ReportPotholeScreen extends ConsumerStatefulWidget {
  const ReportPotholeScreen({
    super.key,
    this.potholeId,
    this.redirectPath,
  });

  final String? potholeId;
  final String? redirectPath;

  @override
  ConsumerState<ReportPotholeScreen> createState() => _ReportPotholeScreenState();
}

class _ReportPotholeScreenState extends ConsumerState<ReportPotholeScreen> with WidgetsBindingObserver {
  Position? _position;
  bool _loadingLocation = false;
  
  // Custom high fidelity steps
  // 1: Camera viseur (Standard/Scan)
  // 2: AI Details specs (Analyse IA)
  // 3: Success XP overlay
  int _currentFlowStep = 1;

  // Scanning progress state
  bool _isScanning = false;
  double _scanProgress = 0.0;
  Timer? _scanTimer;

  // AI specs details
  double _dangerLevelScore = 8.7; // default 8.7 matching the mockup

  // Live Camera states
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _cameraPermissionDenied = false;
  int _selectedCameraIndex = 0;

  // Simulated Camera states
  bool _useSimulatedCamera = false;
  final List<String> _simulatedImages = [
    'https://images.unsplash.com/photo-1515162305285-0293e4767cc2?q=80&w=800&auto=format&fit=crop', // Road pothole
    'https://images.unsplash.com/photo-1584824486509-112e4181ff6b?q=80&w=800&auto=format&fit=crop', // Asphalt cracks
  ];
  int _simulatedImageIndex = 0;

  // Capture & Flash states
  bool _isCapturing = false;
  bool _showShutterFlash = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLocation();
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
      setState(() {
        _isCameraInitialized = false;
      });
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No cameras found, switching to simulation');
        if (mounted) {
          setState(() {
            _useSimulatedCamera = true;
            _isCameraInitialized = true;
          });
        }
        return;
      }
      
      final camera = _cameras![_selectedCameraIndex];
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _cameraPermissionDenied = false;
          _useSimulatedCamera = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (e is CameraException && e.code == 'CameraAccessDenied') {
        if (mounted) {
          setState(() {
            _cameraPermissionDenied = true;
            _useSimulatedCamera = false;
          });
        }
      } else {
        // Fallback to simulated camera on other errors
        if (mounted) {
          setState(() {
            _useSimulatedCamera = true;
            _isCameraInitialized = true;
          });
        }
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_useSimulatedCamera) {
      setState(() {
        _simulatedImageIndex = (_simulatedImageIndex + 1) % _simulatedImages.length;
      });
      return;
    }
    if (_cameras == null || _cameras!.isEmpty) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    if (_cameraController != null) {
      await _cameraController!.dispose();
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
    _initializeCamera();
  }

  Future<File> _createMockPhotoFile() async {
    final tempDir = Directory.systemTemp;
    final mockFile = File('${tempDir.path}/mock_pothole_${_simulatedImageIndex}.jpg');
    
    // Check if it already exists to avoid redundant downloads
    if (await mockFile.exists() && await mockFile.length() > 1000) {
      return mockFile;
    }

    final imageUrl = _simulatedImages[_simulatedImageIndex];

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(imageUrl));
      final response = await request.close();
      final bytes = <int>[];
      await for (var chunk in response) {
        bytes.addAll(chunk);
      }
      if (bytes.isNotEmpty) {
        await mockFile.writeAsBytes(bytes);
        return mockFile;
      }
    } catch (e) {
      debugPrint('Error downloading mock photo: $e');
    }

    // Offline fallback: write minimal valid 1x1 transparent GIF
    await mockFile.writeAsBytes([71, 73, 70, 56, 57, 97, 1, 0, 1, 0, 128, 0, 0, 0, 0, 0, 255, 255, 255, 33, 249, 4, 1, 0, 0, 0, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 2, 76, 1, 0, 59]);
    return mockFile;
  }

  Future<void> _takePicture() async {
    if (_isCapturing || _isScanning) return;

    setState(() {
      _isCapturing = true;
      _showShutterFlash = true;
    });

    // Shutter flash effect: turn off after 150ms
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _showShutterFlash = false;
        });
      }
    });

    if (_useSimulatedCamera || _cameraController == null || !_cameraController!.value.isInitialized) {
      final file = await _createMockPhotoFile();
      ref.read(reportFormProvider.notifier).setPhoto(file);
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
      _startInteractiveAIScan();
      return;
    }
    if (_cameraController!.value.isTakingPicture) {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
      return;
    }

    try {
      final XFile file = await _cameraController!.takePicture();
      ref.read(reportFormProvider.notifier).setPhoto(File(file.path));
      _startInteractiveAIScan();
    } catch (e) {
      debugPrint('Error taking picture: $e');
      final file = await _createMockPhotoFile();
      ref.read(reportFormProvider.notifier).setPhoto(file);
      _startInteractiveAIScan();
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        ref.read(reportFormProvider.notifier).setPhoto(File(image.path));
        _startInteractiveAIScan();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _loadLocation() async {
    setState(() => _loadingLocation = true);
    final position = await ref.read(locationServiceProvider).getCurrentPosition();
    if (mounted) {
      setState(() {
        _position = position;
        _loadingLocation = false;
        if (_position != null && _currentFlowStep == 1) {
          _currentFlowStep = 2;
        }
      });
    }
  }

  void _startInteractiveAIScan() {
    setState(() {
      _isScanning = true;
      _scanProgress = 0.0;
    });

    _scanTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) return;
      setState(() {
        _scanProgress += 0.015;
        if (_scanProgress >= 1.0) {
          _scanProgress = 1.0;
          timer.cancel();
          _isScanning = false;
          // Transition to specs/Analyse IA step
          _currentFlowStep = 3;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentFlowStep == 4) {
      return _buildSuccessOverlay();
    }

    return CivicScaffold(
      backgroundColor: const Color(0xFF0B0C0F), // Unified dark background
      appBar: CivicAppBar(
        title: _currentFlowStep == 1
            ? 'Localisation'
            : _currentFlowStep == 2
                ? 'Signaler'
                : 'Analyse IA',
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (_currentFlowStep == 3) {
              setState(() {
                _currentFlowStep = 2;
              });
            } else if (_currentFlowStep == 2) {
              if (_position != null) {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home/map');
                }
              } else {
                setState(() {
                  _currentFlowStep = 1;
                });
              }
            } else {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home/map');
              }
            }
          },
          icon: Icon(
            _currentFlowStep == 1 ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step progress indicator bar (only visible during flow)
          if (_currentFlowStep <= 3) _buildStepProgressTracker(),
          Expanded(
            child: _currentFlowStep == 1
                ? _buildLocalisationStep()
                : _currentFlowStep == 2
                    ? _buildCameraStep()
                    : _buildAIAnalysisStep(),
          ),
        ],
      ),
    );
  }

  // Header steps indicator tracker
  Widget _buildStepProgressTracker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTrackerItem(1, 'Localisation', _currentFlowStep == 1),
          _buildTrackerDivider(),
          _buildTrackerItem(2, 'Photo', _currentFlowStep == 2),
          _buildTrackerDivider(),
          _buildTrackerItem(3, 'Détails', _currentFlowStep == 3),
        ],
      ),
    );
  }

  Widget _buildTrackerItem(int stepNumber, String name, bool isActive) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isActive ? AppColors.brandOrange : Colors.grey[850],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildTrackerDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 16,
      height: 1,
      color: Colors.grey[800],
    );
  }

  Widget _buildLocalisationStep() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF15161E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing location pulse illustration
            Stack(
              alignment: Alignment.center,
              children: [
                _buildPulseCircle(140, Colors.orange.withValues(alpha: 0.04)),
                _buildPulseCircle(110, Colors.orange.withValues(alpha: 0.08)),
                _buildPulseCircle(80, Colors.orange.withValues(alpha: 0.15)),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.brandOrange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandOrange,
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Localisation requise',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Outfit',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Pour signaler précisément le nid-de-poule sur la carte, l\'application a besoin de votre position GPS en temps réel.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontFamily: 'Outfit',
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (_loadingLocation)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandOrange),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(220, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.brandOrange.withValues(alpha: 0.3),
                ),
                onPressed: _loadLocation,
                icon: const Icon(Icons.my_location_rounded, size: 20),
                label: const Text(
                  'Activer la localisation',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // STEP 1: Camera viewport with reticle & "IA analyse..." overlay card
  Widget _buildCameraStep() {
    final formState = ref.watch(reportFormProvider);
    final File? photoFile = formState.photo;

    // Viewfinder content
    Widget viewfinderContent;

    if (photoFile != null) {
      // If photo is already selected/taken (during scan progress or after), display the photo
      viewfinderContent = Image.file(
        photoFile,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (_cameraPermissionDenied) {
      viewfinderContent = Container(
        color: Colors.black,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Accès caméra requis',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Veuillez autoriser l\'accès à l\'appareil photo dans les paramètres pour pouvoir scanner les nids-de-poule.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _initializeCamera,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Réessayer', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
              ),
            ],
          ),
        ),
      );
    } else if (_useSimulatedCamera) {
      viewfinderContent = _SimulatedCameraPreview(
        imageUrl: _simulatedImages[_simulatedImageIndex],
      );
    } else if (!_isCameraInitialized || _cameraController == null) {
      viewfinderContent = Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandOrange),
          ),
        ),
      );
    } else {
      // Live camera feed
      final double aspectRatio = _cameraController!.value.aspectRatio;
      viewfinderContent = ClipRect(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: 100,
              height: aspectRatio < 1 ? 100 / aspectRatio : 100 * aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Camera Viewfinder feed or photo
            Positioned.fill(child: viewfinderContent),

            // Camera grid line thirds
            Positioned.fill(
              child: CustomPaint(
                painter: _CameraGridThirdsPainter(),
              ),
            ),

            // Shutter flash effect
            if (_showShutterFlash)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                ),
              ),

            // Top settings controls or Retake button
            if (photoFile == null)
              Positioned(
                top: 16,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRoundOverlayButton(
                      _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      isActive: _isFlashOn,
                      onTap: () {
                        setState(() {
                          _isFlashOn = !_isFlashOn;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isFlashOn ? 'Flash activé' : 'Flash désactivé'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    _buildRoundOverlayButton(
                      Icons.camera_alt_rounded,
                      onTap: () {},
                    ),
                    _buildRoundOverlayButton(
                      Icons.settings_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Paramètres de l\'appareil photo'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            else if (!_isScanning)
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    ref.read(reportFormProvider.notifier).setPhoto(null);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Reprendre',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bounding Box Reticle
            if (photoFile == null && !_isScanning)
              Center(
                child: SizedBox(
                  width: 250,
                  height: 180,
                  child: CustomPaint(
                    painter: _ReticlePainter(),
                  ),
                ),
              ),

            // IA Analyse Progress Banner Overlay (Only during active scanning)
            if (_isScanning)
              Positioned(
                bottom: 176,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15161E).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Left Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brandOrange.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.center_focus_strong_rounded,
                          color: AppColors.brandOrange,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Label + Progress Bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'IA analyse...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: _scanProgress,
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF007AFF),
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right progress circle ring
                      SizedBox(
                        width: 38,
                        height: 38,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _scanProgress,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.brandOrange,
                              ),
                              strokeWidth: 3,
                            ),
                            Text(
                              '${(_scanProgress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Shutter options controls bottom panel (always overlaid at the bottom)
            Positioned(
              bottom: 80,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gallery thumbnail preview
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: (_isCapturing || _isScanning) ? null : _pickImageFromGallery,
                    child: Opacity(
                      opacity: (_isCapturing || _isScanning) ? 0.5 : 1.0,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white30, width: 1.5),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1515162305285-0293e4767cc2?q=80&w=150',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Shutter button
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _takePicture,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (_isCapturing || _isScanning) ? Colors.white30 : Colors.white,
                          width: 4,
                        ),
                      ),
                      child: _isCapturing
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: (_isCapturing || _isScanning) ? Colors.white30 : Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                  ),
                  // Flip camera button
                  IconButton(
                    onPressed: _toggleCamera,
                    icon: const Icon(
                      Icons.sync_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Sans photo / Photo/vidéo selector bar
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF15161E),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(reportFormProvider.notifier).setPhoto(null);
                          setState(() {
                            _currentFlowStep = 3;
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              'Sans photo',
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF202330),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.brandOrange,
                            width: 1.0,
                          ),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Photo/vidéo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundOverlayButton(IconData icon, {VoidCallback? onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppColors.brandOrange : Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // STEP 3: Analyse IA details specs screen
  Widget _buildAIAnalysisStep() {
    final formState = ref.watch(reportFormProvider);
    final File? photoFile = formState.photo;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      children: [
        // Dynamic banner depending on if a photo is present or not
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: photoFile != null ? const Color(0xFF101C14) : const Color(0xFF1A1D26),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: photoFile != null 
                  ? const Color(0xFF34C759).withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: photoFile != null ? const Color(0xFF34C759) : Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  photoFile != null ? Icons.check_rounded : Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      photoFile != null ? 'Nid-de-poule détecté' : 'Signalement manuel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      photoFile != null ? 'Confiance 95%' : 'Aucune photo fournie',
                      style: TextStyle(
                        color: photoFile != null ? const Color(0xFF34C759) : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              if (photoFile != null)
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pothole Image with perspective 3D holographic wireframe mesh scan overlay!
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: photoFile != null
                      ? Image.file(
                          photoFile,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: const Color(0xFF15161E),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.no_photography_rounded,
                                  color: Colors.white.withValues(alpha: 0.35),
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Aucun visuel associé',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                // Custom 3D wireframe mesh overlay
                if (photoFile != null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _WireframeGridPainter(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Stats row (Diameter, Depth, Estimated duration) - Only visible if photo is taken
        if (photoFile != null) ...[
          Row(
            children: [
              Expanded(
                child: _buildSpecCard('Diamètre', '78 cm', Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSpecCard('Profondeur', '7.4 cm', Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSpecCard('Durée estimée', 'Élevée', const Color(0xFFFF5500)),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Danger Slider Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF15161E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Niveau de danger',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  Text(
                    '${_dangerLevelScore.toStringAsFixed(1)} /10',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DangerSlider(
                initialValue: _dangerLevelScore,
                onChanged: (score) {
                  setState(() {
                    _dangerLevelScore = score;
                  });
                  DangerLevel level;
                  if (score < 3.3) {
                    level = DangerLevel.low;
                  } else if (score < 6.6) {
                    level = DangerLevel.medium;
                  } else {
                    level = DangerLevel.high;
                  }
                  ref.read(reportFormProvider.notifier).setDangerLevel(level);
                },
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Faible',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Moyen',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Élevé',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Critique',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Comments Input Field
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF15161E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajouter un commentaire (optionnel)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Ex: Gros trou profond, attention!',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: ref.read(reportFormProvider.notifier).setDescription,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Publish Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandOrange,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 8,
            shadowColor: AppColors.brandOrange.withValues(alpha: 0.4),
          ),
          onPressed: _submitReport,
          child: const Text(
            'Publier le signalement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildSpecCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF15161E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    final position = _position ?? Position(
      latitude: 46.5587,
      longitude: -72.7368,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

    final potholeId = await ref.read(reportFormProvider.notifier).submit(
      latitude: position.latitude,
      longitude: position.longitude,
      city: 'Shawinigan',
      linkedPotholeId: widget.potholeId,
    );

    if (potholeId != null) {
      setState(() {
        _currentFlowStep = 4;
      });
    }
  }

  // STEP 4: Success Overlay
  Widget _buildSuccessOverlay() {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0F),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 20)
                  ],
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nid signalé !',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Merci pour votre contribution citoyenne.',
                style: TextStyle(color: Colors.white70, fontSize: 15, fontFamily: 'Outfit'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '+200 XP',
                style: TextStyle(color: AppColors.brandYellow, fontWeight: FontWeight.bold, fontSize: 28, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  context.go(widget.redirectPath ?? '/home/map');
                },
                child: const Text('Voir sur la carte', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Draw L-shaped corners for camera viewfinder
class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 24.0;
    const double radius = 16.0;

    // Top Left Corner
    final pathTL = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(cornerLength, 0);
    canvas.drawPath(pathTL, paint);

    // Top Right Corner
    final pathTR = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(pathTR, paint);

    // Bottom Left Corner
    final pathBL = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - radius)
      ..quadraticBezierTo(0, size.height, radius, size.height)
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(pathBL, paint);

    // Bottom Right Corner
    final pathBR = Path()
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Grid camera frame thirds
class _CameraGridThirdsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(2 * size.width / 3, 0), Offset(2 * size.width / 3, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, 2 * size.height / 3), Offset(size.width, 2 * size.height / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3D holographic wireframe mesh scan overlay
class _WireframeGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // 1. Perspective grid
    final paintGrid = Paint()
      ..color = const Color(0xFF007AFF).withValues(alpha: 0.22)
      ..strokeWidth = 0.8;

    final double vanishingX = width / 2;
    final double vanishingY = -height * 0.15; // perspective focus point

    const int verticalLines = 14;
    for (int i = 0; i <= verticalLines; i++) {
      final double xOffset = width * (i / verticalLines);
      canvas.drawLine(
        Offset(vanishingX, vanishingY),
        Offset(xOffset, height),
        paintGrid,
      );
    }

    const int horizontalLines = 12;
    for (int i = 1; i <= horizontalLines; i++) {
      final double ratio = math.pow(i / horizontalLines, 2).toDouble();
      final double y = height * ratio;
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        paintGrid,
      );
    }

    // 2. Glowing neon red contour around the pothole (at center)
    final paintGlow = Paint()
      ..color = const Color(0xFFFF3B30).withValues(alpha: 0.35)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final paintMain = Paint()
      ..color = const Color(0xFFFF3B30)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Path contourPath = Path();
    final double cx = width / 2;
    final double cy = height * 0.55;

    // Irregular closed contour mimicking the pothole detection wireframe
    contourPath.moveTo(cx - 60, cy - 25);
    contourPath.quadraticBezierTo(cx - 90, cy + 5, cx - 50, cy + 35);
    contourPath.quadraticBezierTo(cx - 15, cy + 48, cx + 40, cy + 30);
    contourPath.quadraticBezierTo(cx + 80, cy + 8, cx + 60, cy - 20);
    contourPath.quadraticBezierTo(cx + 25, cy - 42, cx - 15, cy - 30);
    contourPath.close();

    canvas.drawPath(contourPath, paintGlow);
    canvas.drawPath(contourPath, paintMain);

    // Glowing mesh lines inside the contour to look like a 3D wireframe mesh
    final paintInnerMesh = Paint()
      ..color = const Color(0xFFFF3B30).withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    // Draw horizontal lines inside contour
    for (double y = cy - 25; y <= cy + 35; y += 10) {
      canvas.drawLine(Offset(cx - 50, y), Offset(cx + 50, y), paintInnerMesh);
    }
    // Draw vertical lines inside contour
    for (double x = cx - 50; x <= cx + 50; x += 15) {
      canvas.drawLine(Offset(x, cy - 20), Offset(x, cy + 30), paintInnerMesh);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom linear gradient slider with red circular thumb
class _DangerSlider extends StatefulWidget {
  const _DangerSlider({
    required this.initialValue,
    required this.onChanged,
  });

  final double initialValue;
  final ValueChanged<double> onChanged;

  @override
  State<_DangerSlider> createState() => _DangerSliderState();
}

class _DangerSliderState extends State<_DangerSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Map 0-10 to pixel position
        final double handlePos = width * (_value / 10);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            final double localX = details.localPosition.dx;
            final double newValue = ((localX / width) * 10).clamp(0.0, 10.0);
            setState(() {
              _value = newValue;
            });
            widget.onChanged(newValue);
          },
          onTapDown: (details) {
            final double localX = details.localPosition.dx;
            final double newValue = ((localX / width) * 10).clamp(0.0, 10.0);
            setState(() {
              _value = newValue;
            });
            widget.onChanged(newValue);
          },
          child: SizedBox(
            height: 36,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Gradient track
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF34C759), // Green
                        Color(0xFFFFCC00), // Yellow
                        Color(0xFFFF9500), // Orange
                        Color(0xFFFF3B30), // Red
                      ],
                    ),
                  ),
                ),
                // Handle/Thumb (Red circle with white dot)
                Positioned(
                  left: (handlePos - 13).clamp(0.0, width - 26),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
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
        );
      },
    );
  }
}

class _SimulatedCameraPreview extends StatefulWidget {
  const _SimulatedCameraPreview({required this.imageUrl});

  final String imageUrl;

  @override
  State<_SimulatedCameraPreview> createState() => _SimulatedCameraPreviewState();
}

class _SimulatedCameraPreviewState extends State<_SimulatedCameraPreview> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Subtle handheld shake simulation
        final dx = math.sin(_controller.value * 2 * math.pi) * 0.02;
        final dy = math.cos(_controller.value * 2 * math.pi) * 0.015;
        final scale = 1.08 + math.sin(_controller.value * math.pi) * 0.015;

        return Transform.scale(
          scale: scale,
          child: Transform.translate(
            offset: Offset(dx * 100, dy * 100),
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );
      },
    );
  }
}
