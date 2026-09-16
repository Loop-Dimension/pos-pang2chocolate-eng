import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/registration_screen.dart';
import '../../features/auth/presentation/screens/waiting_approval_screen.dart';
import '../../features/pos/presentation/screens/pos_dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStatusProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';
      final isWaitingRoute = state.matchedLocation == '/waiting';

      switch (authState) {
        case AuthStatus.unauthenticated:
          if (!isLoginRoute && !isRegisterRoute) return '/login';
          break;
        case AuthStatus.pendingApproval:
          if (!isWaitingRoute) return '/waiting';
          break;
        case AuthStatus.approved:
          if (isLoginRoute || isWaitingRoute) return '/pos';
          break;
      }
      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/waiting',
        builder: (context, state) => const WaitingApprovalScreen(),
      ),
      GoRoute(
        path: '/pos',
        builder: (context, state) => const PosDashboardScreen(),
      ),
    ],
  );
});
