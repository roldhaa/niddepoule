import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/features/potholes/data/models/pothole.dart';

/// Flux des nids-de-poule agreges pour la carte.
final potholesProvider = StreamProvider<List<Pothole>>((ref) {
  return ref.watch(potholeServiceProvider).watchPotholes();
});

/// Alias pour compatibilite.
final potholesStreamProvider = potholesProvider;
