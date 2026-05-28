import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/features/auth/presentation/providers/auth_providers.dart';
import 'package:niddepoule/features/reports/data/models/report.dart' show DangerLevel, Report;

class ReportFormState {
  const ReportFormState({
    this.description = '',
    this.dangerLevel = DangerLevel.medium,
    this.photo,
    this.isSubmitting = false,
    this.error,
    this.successMessage,
  });

  final String description;
  final DangerLevel dangerLevel;
  final File? photo;
  final bool isSubmitting;
  final String? error;
  final String? successMessage;

  ReportFormState copyWith({
    String? description,
    DangerLevel? dangerLevel,
    File? photo,
    bool clearPhoto = false,
    bool? isSubmitting,
    String? error,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ReportFormState(
      description: description ?? this.description,
      dangerLevel: dangerLevel ?? this.dangerLevel,
      photo: clearPhoto ? null : (photo ?? this.photo),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearMessages ? null : (error ?? this.error),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

class ReportFormController extends StateNotifier<ReportFormState> {
  ReportFormController(this.ref) : super(const ReportFormState());

  final Ref ref;

  void setDescription(String value) =>
      state = state.copyWith(description: value, clearMessages: true);

  void setDangerLevel(DangerLevel value) =>
      state = state.copyWith(dangerLevel: value, clearMessages: true);

  void setPhoto(File? file) =>
      state = state.copyWith(photo: file, clearMessages: true);

  Future<String?> submit({
    required double latitude,
    required double longitude,
    required String city,
    String? linkedPotholeId,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = state.copyWith(
        error: 'Connectez-vous pour signaler un nid-de-poule.',
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearMessages: true);
    try {
      final Report report = await ref.read(reportServiceProvider).submitReport(
            user: user,
            latitude: latitude,
            longitude: longitude,
            dangerLevel: state.dangerLevel,
            description: state.description.isEmpty ? null : state.description,
            photoFile: state.photo,
            city: city,
            linkedPotholeId: linkedPotholeId,
          );
      state = const ReportFormState(
        successMessage: 'Signalement enregistre avec succes.',
      );
      return report.duplicateGroupId ?? report.id;
    } catch (e) {
      state = state.copyWith(
        error: _friendlyError(e),
        isSubmitting: false,
      );
      return null;
    } finally {
      if (state.isSubmitting) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }

  String _friendlyError(Object e) {
    final message = e.toString();
    if (message.contains('PERMISSION_DENIED')) {
      return 'Acces refuse. Verifie les regles Firestore/Storage.';
    }
    if (message.contains('network')) {
      return 'Connexion internet indisponible.';
    }
    if (message.contains('Firebase')) {
      return message;
    }
    return 'Erreur: $message';
  }
}

final reportFormProvider =
    StateNotifierProvider<ReportFormController, ReportFormState>(
  (ref) => ReportFormController(ref),
);
