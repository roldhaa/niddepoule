import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:niddepoule/app/app.dart';
import 'package:niddepoule/core/config/app_env.dart';
import 'package:niddepoule/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppEnv.mapboxAccessToken.isNotEmpty) {
    MapboxOptions.setAccessToken(AppEnv.mapboxAccessToken);
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // App Check:
  // - Android: Play Integrity (prod) / Debug (dev)
  // - Apple: App Attest (prod) / Debug (dev)
  // - Web: reCAPTCHA v3 (site key via dart-define)
  const isDebugAppCheck =
      bool.fromEnvironment('APP_CHECK_DEBUG', defaultValue: true);
  const webSiteKey =
      String.fromEnvironment('APP_CHECK_WEB_RECAPTCHA_SITE_KEY', defaultValue: '');

  // En dev, on ne doit pas bloquer toute l'app si App Check n'est pas encore
  // active/authorisee cote Console (API desactivee, token debug non allowlist, etc.).
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: isDebugAppCheck
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: isDebugAppCheck
          ? const AppleDebugProvider()
          : const AppleAppAttestProvider(),
      providerWeb: webSiteKey.isEmpty ? null : ReCaptchaV3Provider(webSiteKey),
    );
  } catch (e) {
    debugPrint('AppCheck activation failed (dev non-bloquant): $e');
  }

  runApp(const ProviderScope(child: CivicRoadApp()));
}
