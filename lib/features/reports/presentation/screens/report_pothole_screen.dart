import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/core/utils/danger_colors.dart';
import 'package:niddepoule/core/widgets/civic_banner.dart';
import 'package:niddepoule/core/widgets/civic_bottom_sheet.dart';
import 'package:niddepoule/core/widgets/civic_button.dart';
import 'package:niddepoule/core/widgets/civic_card.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';
import 'package:niddepoule/core/widgets/civic_section_title.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';
import 'package:niddepoule/features/reports/presentation/providers/report_form_provider.dart';

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

class _ReportPotholeScreenState extends ConsumerState<ReportPotholeScreen> {
  Position? _position;
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() => _loadingLocation = true);
    final position = await ref.read(locationServiceProvider).getCurrentPosition();
    if (mounted) {
      setState(() {
        _position = position;
        _loadingLocation = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      ref.read(reportFormProvider.notifier).setPhoto(File(picked.path));
    }
  }

  void _showImageSourceSheet() {
    showCivicBottomSheet<void>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Prendre une photo'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Galerie'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(reportFormProvider);

    return CivicScaffold(
      title: widget.potholeId != null ? 'Signaler ce nid' : 'Signaler',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          CivicCard(
            variant: CivicCardVariant.muted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CivicSectionTitle(title: 'Localisation'),
                if (_loadingLocation)
                  const Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Récupération GPS...'),
                    ],
                  )
                else if (_position != null)
                  Text(
                    'Lat: ${_position!.latitude.toStringAsFixed(5)}\n'
                    'Lng: ${_position!.longitude.toStringAsFixed(5)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Text(
                    'Position indisponible',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                AppSpacing.vSm,
                TextButton.icon(
                  onPressed: _loadingLocation ? null : _loadLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Actualiser'),
                ),
              ],
            ),
          ),
          AppSpacing.vMd,
          CivicCard(
            variant: CivicCardVariant.muted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CivicSectionTitle(title: 'Niveau de danger'),
                SegmentedButton<DangerLevel>(
                  segments: DangerLevel.values
                      .map(
                        (d) => ButtonSegment(
                          value: d,
                          label: Text(DangerColors.label(d)),
                        ),
                      )
                      .toList(),
                  selected: {form.dangerLevel},
                  onSelectionChanged: (value) {
                    ref
                        .read(reportFormProvider.notifier)
                        .setDangerLevel(value.first);
                  },
                ),
              ],
            ),
          ),
          AppSpacing.vMd,
          CivicCard(
            variant: CivicCardVariant.muted,
            child: TextFormField(
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description (optionnelle)',
                border: InputBorder.none,
              ),
              onChanged: ref.read(reportFormProvider.notifier).setDescription,
            ),
          ),
          AppSpacing.vMd,
          CivicCard(
            variant: CivicCardVariant.muted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: _showImageSourceSheet,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(
                    form.photo == null ? 'Ajouter une photo' : 'Photo sélectionnée',
                  ),
                ),
                if (form.photo != null) ...[
                  AppSpacing.vMd,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(form.photo!, height: 180, fit: BoxFit.cover),
                  ),
                ],
              ],
            ),
          ),
          if (form.error != null) ...[
            AppSpacing.vMd,
            CivicBanner(message: form.error!, type: CivicBannerType.error),
          ],
          if (form.successMessage != null) ...[
            AppSpacing.vMd,
            CivicBanner(message: form.successMessage!, type: CivicBannerType.success),
          ],
          AppSpacing.vXl,
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: CivicButton(
            label: 'Signaler',
            icon: Icons.send_rounded,
            isLoading: form.isSubmitting,
            onPressed: form.isSubmitting
                ? null
                : () async {
                    if (_position == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Position GPS requise.')),
                      );
                      return;
                    }
                    final potholeId = await ref
                        .read(reportFormProvider.notifier)
                        .submit(
                          latitude: _position!.latitude,
                          longitude: _position!.longitude,
                          city: 'Québec',
                          linkedPotholeId: widget.potholeId,
                        );
                    if (!context.mounted) return;
                    if (potholeId != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signalement enregistré.')),
                      );
                      context.push(widget.redirectPath ?? '/pothole/$potholeId');
                    }
                  },
          ),
        ),
      ),
    );
  }
}
