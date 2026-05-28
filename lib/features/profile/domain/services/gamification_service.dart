import 'package:niddepoule/core/constants/app_constants.dart';
import 'package:niddepoule/features/auth/data/models/user_profile.dart';
import 'package:niddepoule/features/gamification/domain/badge_definitions.dart';

class GamificationService {
  UserProfile applyReportReward({
    required UserProfile profile,
    required bool hasPhoto,
    bool communityConfirmed = false,
  }) {
    var xpGain = AppConstants.xpValidatedReport;
    if (hasPhoto) xpGain += AppConstants.xpWithPhoto;
    if (communityConfirmed) xpGain += AppConstants.xpCommunityConfirmed;
    final nextReportsCount = profile.reportsCount + 1;
    final nextXp = profile.xp + xpGain;
    final badges = BadgeDefinitions.badgesForReportsCount(nextReportsCount);
    return profile.copyWith(
      xp: nextXp,
      reportsCount: nextReportsCount,
      badges: badges,
    );
  }

  List<String> badgesForReportsCount(int reportsCount) =>
      BadgeDefinitions.badgesForReportsCount(reportsCount);
}
