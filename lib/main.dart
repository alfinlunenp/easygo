import 'dart:async';
import 'package:easygonww/views/bottombar/home_bottombar.dart';
import 'package:easygonww/views/splashpage.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    // Handle deep links when app is already running
    _linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      debugPrint('Deep Link Received: $uri');
      handleDeepLink(uri);
    });

    // Handle initial link when app is launched via deep link
    final initialLink = await AppLinks().getInitialLink();
    if (initialLink != null) {
      debugPrint('Initial Deep Link: $initialLink');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleDeepLink(initialLink);
      });
    }
  }

  void handleDeepLink(Uri uri) {
    if (uri.host == 'payment_return') {
      // Navigate to MyBookings page with payment status using pushNamed
      _navigatorKey.currentState?.pushNamed(
        '/mybookings',
        arguments: {
          'payment_status': uri.queryParameters['status'] ?? 'unknown',
          'user_id': uri.queryParameters['user_id'],
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => Splashpage(),
        '/mybookings': (context) => HomebottomBar(navindex: 1),
      },
      onGenerateRoute: (RouteSettings settings) {
        // Handle routes with arguments
        if (settings.name == '/mybookings') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => HomebottomBar(navindex: 1),
          );
        }
        return null;
      },
    );
  }
}
