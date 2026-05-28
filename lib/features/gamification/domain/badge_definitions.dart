/// Definitions des badges CivicRoad.
class BadgeDefinitions {
  static const premierSignalement = 'Premier signalement';
  static const chasseurDeNids = 'Chasseur de nids';
  static const protecteurUrbain = 'Protecteur urbain';
  static const herosDeLaVille = 'Heros de la ville';

  static List<String> badgesForReportsCount(int reportsCount) {
    final badges = <String>[];
    if (reportsCount >= 1) badges.add(premierSignalement);
    if (reportsCount >= 10) badges.add(chasseurDeNids);
    if (reportsCount >= 25) badges.add(protecteurUrbain);
    if (reportsCount >= 50) badges.add(herosDeLaVille);
    return badges;
  }
}
