import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/api/api_service.dart';
import 'data/preferences/auth_preferences.dart';
import 'provider/auth_provider.dart';
import 'provider/story_provider.dart';
import 'provider/upload_provider.dart';
import 'routes/router_delegate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MyRouterDelegate myRouterDelegate;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    myRouterDelegate = MyRouterDelegate();
    authProvider = AuthProvider(
      authPreferences: AuthPreferences(),
      apiService: ApiService(),
    );

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await authProvider.isLoggedIn();
    myRouterDelegate.setLoggedIn(isLoggedIn);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(
          create: (_) => StoryProvider(apiService: ApiService()),
        ),
        ChangeNotifierProvider(
          create: (_) => UploadProvider(apiService: ApiService()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Story App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('id', ''),
        ],
        routerDelegate: myRouterDelegate,
        routeInformationParser: MyRouteInformationParser(),
        backButtonDispatcher: RootBackButtonDispatcher(),
      ),
    );
  }
}

class MyRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) async {
    return routeInformation.uri.toString();
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(uri: Uri.parse(configuration));
  }
}