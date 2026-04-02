// main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Controllers
import 'controllers/auth_controller.dart';
import 'controllers/habit_controller.dart';
import 'controllers/mood_controller.dart';
import 'controllers/garden_controller.dart';
import 'controllers/kindness_controller.dart';
import 'controllers/settings_controller.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

// Utils
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = await _initializeFirebase();
  _setupErrorHandling();

  if (firebaseReady) {
    runApp(const MyApp());
  } else {
    runApp(const _FirebaseErrorApp());
  }
}

Future<bool> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    if (kDebugMode) {
      debugPrint('✅ Firebase initialized successfully');
    }
    return true;
  } on FirebaseException catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Firebase initialization failed: ${e.message}');
      debugPrint('Error code: ${e.code}');
    }
    return false;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Unexpected error initializing Firebase: $e');
    }
    return false;
  }
}

class _FirebaseErrorApp extends StatelessWidget {
  const _FirebaseErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌸', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 24),
                const Text(
                  'Unable to connect',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please check your internet connection and restart the app.\n\n'
                      'If this keeps happening, make sure Firebase is properly configured '
                      '(google-services.json / GoogleService-Info.plist).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _setupErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('🔴 Platform Error: $error');
      debugPrint('Stack trace: $stack');
    }
    return true;
  };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => HabitController(),
        ),
        ChangeNotifierProvider(
          create: (_) => MoodController(),
        ),
        ChangeNotifierProvider(
          create: (_) => GardenController(),
        ),
        ChangeNotifierProvider(
          create: (_) => KindnessController(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsController(),
        ),
      ],
      child: MaterialApp(
        title: 'Thyme',
        theme: CuteTheme.themeData,
        debugShowCheckedModeBanner: false,

        home: const AppEntry(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/auth': (context) => const AuthScreen(),
          '/home': (context) => const HomeScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const AppEntry(),
          );
        },
        navigatorObservers: [
          if (kDebugMode) _DebugNavigatorObserver(),
        ],
        builder: (context, child) {
          final currentScale = MediaQuery.of(context).textScaler.scale(1.0);
          final clampedScale = currentScale.clamp(0.8, 1.3);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(clampedScale),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

/// App SplashScreen -> Onboarding -> Auth
class AppEntry extends StatefulWidget {
  const AppEntry({Key? key}) : super(key: key);

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _showSplash = true;

  // Onboarding 檢查狀態
  bool _checkingOnboarding = true;
  bool _needsOnboarding = false;

  // ✅ FIXED: 防止 SettingsController.loadSettings 被重复调用
  bool _settingsLoaded = false;

  void _onSplashComplete() {
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
      _checkOnboardingStatus();
    }
  }


  Future<void> _checkOnboardingStatus() async {
    try {
      final needs = await shouldShowOnboarding();
      if (mounted) {
        setState(() {
          _needsOnboarding = needs;
          _checkingOnboarding = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Onboarding check failed: $e');
      }
      if (mounted) {
        setState(() {
          _needsOnboarding = false;
          _checkingOnboarding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. 啟動頁
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }

    // 2. 檢查 onboarding
    if (_checkingOnboarding) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: CuteTheme.primaryGradient,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🌸', style: TextStyle(fontSize: 48)),
                SizedBox(height: 20),
                CircularProgressIndicator(
                  color: CuteTheme.primaryGreen,
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3. 需要 onboarding → 显示 onboarding 页面
    if (_needsOnboarding) {
      return const OnboardingScreen();
    }

    // 4. Onboarding 完成，檢查登錄狀態
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        // 檢查認證狀態
        if (authController.isLoading) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: CuteTheme.primaryGradient,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🌸', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 20),
                    CircularProgressIndicator(
                      color: CuteTheme.primaryGreen,
                      strokeWidth: 3,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ✅ FIXED: 已登录 -> 仅加载一次设置，避免每次 rebuild 都触发
        if (authController.isAuthenticated) {
          final user = authController.currentUser;
          if (user != null && !_settingsLoaded) {
            _settingsLoaded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<SettingsController>().loadSettings(user.uid);
              }
            });
          }
          return const HomeScreen();
        }

        // ✅ FIXED: 用户登出后重置 flag，下次登录时重新加载设置
        _settingsLoaded = false;

        // 未登录 → 登录/注册页
        return const AuthScreen();
      },
    );
  }
}

/// Debug
class _DebugNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('📱 Navigation: Push ${route.settings.name ?? 'unknown'}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('📱 Navigation: Pop ${route.settings.name ?? 'unknown'}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    debugPrint(
      '📱 Navigation: Replace ${oldRoute?.settings.name ?? 'unknown'} '
          'with ${newRoute?.settings.name ?? 'unknown'}',
    );
  }
}