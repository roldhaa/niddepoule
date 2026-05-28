import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/core/widgets/civic_avatar.dart';
import 'package:niddepoule/core/widgets/civic_button.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';
import 'package:niddepoule/core/widgets/civic_text_field.dart';
import 'package:niddepoule/features/auth/presentation/providers/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  File? _newPhoto;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.read(currentUserProvider);
    if (_nameCtrl.text.isEmpty && user != null) {
      _nameCtrl.text = user.fullName;
      _bioCtrl.text = user.bio;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _newPhoto = File(picked.path));
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _saving = true);
    try {
      var photoUrl = user.photoUrl;
      if (_newPhoto != null) {
        photoUrl = await ref.read(storageServiceProvider).uploadProfilePhoto(
              file: _newPhoto!,
              userId: user.uid,
            );
      }
      final updated = user.copyWith(
        fullName: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        photoUrl: photoUrl,
      );
      await ref.read(userServiceProvider).save(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return CivicScaffold(
      title: 'Modifier le profil',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickPhoto,
              child: _newPhoto != null
                  ? CircleAvatar(
                      radius: 48,
                      backgroundImage: FileImage(_newPhoto!),
                    )
                  : CivicAvatar(
                      radius: 48,
                      photoUrl: user?.photoUrl,
                      name: user?.fullName,
                      showRing: true,
                    ),
            ),
          ),
          AppSpacing.vSm,
          const Center(child: Text('Changer la photo')),
          AppSpacing.vLg,
          CivicTextField(
            controller: _nameCtrl,
            label: 'Nom complet',
          ),
          AppSpacing.vMd,
          CivicTextField(
            controller: _bioCtrl,
            label: 'Bio',
            maxLines: 5,
          ),
          AppSpacing.vXl,
          CivicButton(
            label: 'Enregistrer',
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
