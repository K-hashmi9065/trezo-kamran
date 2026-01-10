import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trezo_saving_ai_app/main.dart' as app;
import 'package:trezo_saving_ai_app/core/router/route_names.dart';
import 'package:trezo_saving_ai_app/core/router/app_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('splash and welcome tests', () {
    testWidgets('splash navigates to welcome screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Splash shows app title
      expect(find.text('Trezo'), findsOneWidget);

      // Advance time to let the splash timer complete (originally 8s)
      await tester.pump(const Duration(seconds: 9));
      await tester.pumpAndSettle();

      // Verify navigation happened to welcome
      expect(appRouter.location, RouteNames.welcomeScreen);
      expect(find.text("Let's Get Started!"), findsOneWidget);
    });

    testWidgets(
      'welcome shows expected buttons and Sign up navigates to empty home',
      (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Navigate directly to welcome (avoid waiting for splash timer)
        appRouter.go(RouteNames.welcomeScreen);
        await tester.pumpAndSettle();

        expect(find.text("Let's Get Started!"), findsOneWidget);
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.text('Sign up'), findsOneWidget);
        expect(find.text('Sign in'), findsOneWidget);

        // Tap Sign up and verify navigation
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle();

        expect(appRouter.location, RouteNames.emptyHomeScreen);
      },
    );
  });
}

extension on GoRouter {
  String get location {
    return routerDelegate.currentConfiguration.uri.toString();
  }
}
