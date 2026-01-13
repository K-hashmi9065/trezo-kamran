import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../feature/account/presentation/screens/account_screen.dart';
import '../../feature/account/presentation/screens/account_security_screen.dart';
import '../../feature/account/presentation/screens/app_appearance/app_appearance.dart';
import '../../feature/account/presentation/screens/app_appearance/app_language.dart';
import '../../feature/account/presentation/screens/help_support/help_support_screen.dart';
import '../../feature/account/presentation/screens/preference_screen.dart';
import '../../feature/account/presentation/screens/profile_screen.dart';
import '../../feature/account/presentation/screens/linked_account.dart';
import '../../feature/home/presentation/screens/archived_screen.dart';
import '../../feature/home/presentation/screens/empty_goal_screen.dart';
import '../../feature/home/presentation/screens/home_screen.dart';
import '../../feature/subscription/presentation/screens/payment_benifit_unlock_congratulation.dart';
import '../../feature/subscription/presentation/screens/review_summary_screen.dart';
import '../../feature/subscription/presentation/screens/upgrade_plan_screen.dart';
import '../../feature/splash_welcome/presentation/screens/splash_screen.dart';
import '../../feature/splash_welcome/presentation/screens/welcome_screen.dart';
import '../../feature/auth/presentation/screens/login_screen.dart';
import '../../feature/auth/presentation/screens/sign_up_screen.dart';
import '../../feature/auth/presentation/screens/forgot_passwd_screen.dart';
import '../../feature/home/presentation/screens/create_goal_screen.dart';
import '../../feature/home/presentation/screens/goal_detail_screen.dart';
import '../../feature/home/presentation/screens/records_screen.dart';
import '../../feature/home/domain/entities/goal.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  redirect: (context, state) {
    // Check if user is logged in
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final currentPath = state.matchedLocation;

    // List of auth-related paths that logged-in users shouldn't access
    // Note: forgotPasswdScreen is excluded so users can change password when logged in
    final authPaths = [
      RouteNames.welcomeScreen,
      RouteNames.loginScreen,
      RouteNames.signUpScreen,
      // RouteNames.forgotPasswdScreen, // Allow logged-in users for password changes
    ];

    // If user is logged in and trying to access auth screens, redirect to home
    if (isLoggedIn && authPaths.contains(currentPath)) {
      return RouteNames.emptyHomeScreen;
    }

    // No redirect needed
    return null;
  },
  routes: [
    // empty home screen route
    GoRoute(
      name: RouteNames.emptyHomeScreen,
      path: RouteNames.emptyHomeScreen,
      builder: (context, state) => const EmptyGoalScreen(),
    ),
    // home screen route
    GoRoute(
      name: RouteNames.homeScreen,
      path: RouteNames.homeScreen,
      builder: (context, state) => const HomeScreen(),
    ),
    // create goal screen route
    GoRoute(
      name: RouteNames.createGoalScreen,
      path: RouteNames.createGoalScreen,
      builder: (context, state) {
        final goal = state.extra as Goal?;
        return CreateGoalScreen(initialGoal: goal);
      },
    ),
    // goal detail screen route
    GoRoute(
      name: RouteNames.goalDetailScreen,
      path: RouteNames.goalDetailScreen,
      builder: (context, state) {
        final goal = state.extra as Goal;
        return GoalDetailScreen(goal: goal);
      },
    ),
    // goal records screen route
    GoRoute(
      name: RouteNames.goalRecordsScreen,
      path: RouteNames.goalRecordsScreen,
      builder: (context, state) {
        return RecordsScreen(extra: state.extra);
      },
    ),
    // help & support screen route
    GoRoute(
      name: RouteNames.helpSupportScreen,
      path: RouteNames.helpSupportScreen,
      builder: (context, state) => const HelpSupportScreen(),
    ),
    // app language screen route
    GoRoute(
      name: RouteNames.appLanguageScreen,
      path: RouteNames.appLanguageScreen,
      builder: (context, state) => const AppLanguageScreen(),
    ),
    // app appearance screen route
    GoRoute(
      name: RouteNames.appAppearanceScreen,
      path: RouteNames.appAppearanceScreen,
      builder: (context, state) => const AppAppearanceScreen(),
    ),
    // upgrade & upgrade plan screen route
    GoRoute(
      name: RouteNames.upgradePlanScreen,
      path: RouteNames.upgradePlanScreen,
      builder: (context, state) => const UpgradePlanScreen(),
    ),
    // upgrade & review summary screen route
    GoRoute(
      name: RouteNames.reviewSummaryScreen,
      path: RouteNames.reviewSummaryScreen,
      builder: (context, state) => const ReviewSummaryScreen(),
    ),
    // upgrade & benifit unlock screen route
    GoRoute(
      name: RouteNames.benifitUnlockScreen,
      path: RouteNames.benifitUnlockScreen,
      builder: (context, state) => const BenifitUnlockScreen(),
    ),
    // account & linked accounts screen route
    GoRoute(
      name: RouteNames.accountsLinkedScreen,
      path: RouteNames.accountsLinkedScreen,
      builder: (context, state) => const LinkedAccountScreen(),
    ),
    // account & security screen route
    GoRoute(
      name: RouteNames.accountSecurityScreen,
      path: RouteNames.accountSecurityScreen,
      builder: (context, state) => const AccountSecurityScreen(),
    ),
    // account & preference screen route
    GoRoute(
      name: RouteNames.accountPreferenceScreen,
      path: RouteNames.accountPreferenceScreen,
      builder: (context, state) => const PreferenceScreen(),
    ),
    // account & profile screen route
    GoRoute(
      name: RouteNames.accountProfileScreen,
      path: RouteNames.accountProfileScreen,
      builder: (context, state) => const ProfileScreen(),
    ),
    // account screen route
    GoRoute(
      name: RouteNames.accountScreen,
      path: RouteNames.accountScreen,
      builder: (context, state) => const AccountScreen(),
    ),
    // welcome screen route
    GoRoute(
      name: RouteNames.welcomeScreen,
      path: RouteNames.welcomeScreen,
      builder: (context, state) => const WelcomeScreen(),
    ),
    // login screen route
    GoRoute(
      name: RouteNames.loginScreen,
      path: RouteNames.loginScreen,
      builder: (context, state) => const LoginScreen(),
    ),
    // sign up screen route
    GoRoute(
      name: RouteNames.signUpScreen,
      path: RouteNames.signUpScreen,
      builder: (context, state) => const SignUpScreen(),
    ),
    // forgot password screen route
    GoRoute(
      name: RouteNames.forgotPasswdScreen,
      path: RouteNames.forgotPasswdScreen,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // splash screen route
    GoRoute(
      name: RouteNames.splash,
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    // archived screen route
    GoRoute(
      name: RouteNames.archivedScreen,
      path: RouteNames.archivedScreen,
      builder: (context, state) => const ArchivedScreen(),
    ),
  ],
);
