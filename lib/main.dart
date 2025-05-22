// lib/main.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'common/preferences_helper.dart';
import 'provider/auth_provider.dart';
import 'provider/story_provider.dart';
import 'ui/add_story_page.dart';
import 'ui/detail_page.dart';
import 'ui/home_page.dart';
import 'ui/login_page.dart';
import 'ui/register_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefsHelper = PreferencesHelper();
  final token = await prefsHelper.getToken();
  final initialLocation =
      (token != null && token.isNotEmpty) ? '/home' : '/login';

  runApp(MyApp(initialLocation: initialLocation));
}

class MyApp extends StatelessWidget {
  final String initialLocation;

  const MyApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/add-story',
          name: 'addStory',
          builder: (context, state) => const AddStoryPage(),
        ),
        GoRoute(
          path: '/detail/:id',
          name: 'detail',
          builder: (context, state) {
            final storyId = state.pathParameters['id']!;
            return DetailPage(storyId: storyId);
          },
          routes: [
            GoRoute(
              path: 'address',
              name: 'addressDialog',
              pageBuilder: (context, state) {
                // address passed via `extra`
                final address =
                    state.extra as String? ?? 'Alamat tidak tersedia';
                return CustomTransitionPage(
                  key: state.pageKey,
                  opaque: false,
                  barrierDismissible: true,
                  barrierColor: Colors.black54,
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: AlertDialog(
                    title: const Text('Alamat'),
                    content: Text(address),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
      ],
      child: MaterialApp.router(
        title: 'Dicoding Story',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
