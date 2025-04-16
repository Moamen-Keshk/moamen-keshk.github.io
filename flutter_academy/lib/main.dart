import 'package:flutter/material.dart';
import 'package:flutter_academy/app/courses/routes/app_route_parser.router.dart';
import 'package:flutter_academy/app/courses/routes/router_delegate.router.dart';
import 'package:flutter_academy/app/users/view_models/theme_mode.vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

final routerProvider = Provider<AppRouterDelegate>((ref) {
  throw UnimplementedError(); // Overridden in MyApp
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouterDelegate _routerDelegate;
  final _routeParser = AppRouteInformationParser();

  @override
  void initState() {
    super.initState();
    _routerDelegate = AppRouterDelegate();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        routerProvider.overrideWithValue(_routerDelegate),
      ],
      child: Consumer(builder: (context, ref, _) {
        final themeModeVM = ref.watch(themeModeProvider);

        return AnimatedBuilder(
          animation: themeModeVM,
          builder: (context, _) {
            return MaterialApp.router(
              title: 'Lotel',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(primarySwatch: Colors.blue),
              darkTheme: ThemeData.dark().copyWith(primaryColor: Colors.blue),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                MonthYearPickerLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
                Locale('es', ''),
                Locale('fr', ''),
                Locale('de', ''),
              ],
              themeMode: themeModeVM.themeMode,
              routerDelegate: _routerDelegate,
              routeInformationParser: _routeParser,
            );
          },
        );
      }),
    );
  }
}
