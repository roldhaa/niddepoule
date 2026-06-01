import 'package:niddepoule/app/design_system/app_colors.dart';

/// Alias retrocompatibilite — utiliser [AppColors] directement.
abstract final class AuthTheme {
  static get yellow => AppColors.brandYellow;
  static get dark => AppColors.brandBlack;
  static get darkSoft => AppColors.brandBlackSoft;
  static get light => AppColors.surfaceElevated;
  static get grey => AppColors.textSecondary;
  static get error => AppColors.error;
  static get gradient => AppColors.authGradient;
  static get welcomeGradient => AppColors.welcomeGradient;
}
