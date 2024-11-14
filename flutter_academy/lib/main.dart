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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  runApp(ProviderScope(child: MyApp()));
}

final routerDelegate = AppRouterDelegate();

class MyApp extends StatelessWidget {
  final _routeParser = AppRouteInformationParser();

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final themeModeVM = ref.watch(themeModeProvider);
      return AnimatedBuilder(
          animation: themeModeVM,
          builder: (context, child) {
            return MaterialApp.router(
              title: 'Lotel',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              darkTheme: ThemeData.dark().copyWith(
                primaryColor: Colors.blue,
              ),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                MonthYearPickerLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''), // English
                Locale('es', ''), // Spanish
                Locale('fr', ''), // French
                Locale('de', ''), // German
                // Add more locales as needed
              ],
              themeMode: themeModeVM.themeMode,
              routerDelegate: routerDelegate,
              routeInformationParser: _routeParser,
            );
          });
    });
  }
}
