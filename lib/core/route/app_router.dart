
import 'package:go_router/go_router.dart';
import 'package:nombre_del_proyecto/screens/home_screen.dart';
import 'package:nombre_del_proyecto/screens/login_screen.dart';


abstract class Routes {
  static const String splashPath = '/splash';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String homePath = '/home';


  static final _router = GoRouter(
    initialLocation: splashPath,
    routes: [
      // GoRoute(
      //   path: splashPath,
      //   builder: (context, state) => const SplashScreen(),
      // ),
      GoRoute(
        path: loginPath,
        builder: (context, state) {
          return LoginScreen();
        },
      ),
      // GoRoute(
      //   path: registerPath,
      //   builder: (context, state) {
      //     return const RegisterScreen();
      //   },
      // ),
      GoRoute(
          path: homePath,
          builder: (context, state) {
            return const HomeScreen();
          },      
          )
    ],
  );
  static GoRouter get router => _router;
}
