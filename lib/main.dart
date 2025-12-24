import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State {
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

  Future _checkLoginStatus() async {
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
          primarySwatch: Colors.blue,
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
        routeInformationParser: RouteInformationParser(),
        backButtonDispatcher: RootBackButtonDispatcher(),
      ),
    );
  }
}