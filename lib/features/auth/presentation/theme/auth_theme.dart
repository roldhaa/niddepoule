import 'package:niddepoule/app/design_system/app_colors.dart';

/// Alias retrocompatibilite — utiliser [AppColors] directement.
abstract final class AuthTheme {
  static const yellow = AppColors.brandYellow;
  static const dark = AppColors.brandBlack;
  static const darkSoft = AppColors.brandBlackSoft;
  static const light = AppColors.surfaceElevated;
  static const grey = AppColors.textSecondary;
  static const error = AppColors.error;
  static const gradient = AppColors.authGradient;
  static const welcomeGradient = AppColors.welcomeGradient;
}
