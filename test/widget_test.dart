import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niddepoule/app/app.dart';
import 'package:niddepoule/features/auth/data/models/user_profile.dart';
import 'package:niddepoule/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('CivicRoad render welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream<UserProfile?>.value(null),
          ),
        ],
        child: const CivicRoadApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('CivicRoad'), findsWidgets);
    expect(find.text('Créer un compte'), findsOneWidget);
  });
}
