import 'package:WhatsAppClone/helpers/navigator_helper.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:WhatsAppClone/core/provider/main.dart';
import 'package:WhatsAppClone/core/shared/theme.dart';

import 'package:WhatsAppClone/pages/screens/loading/loading_page.dart';
import 'package:WhatsAppClone/pages/main/main_page.dart';
import 'package:WhatsAppClone/pages/screens/login/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainModel(),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WhatsApp',
          theme: lightTheme,
          darkTheme: darkTheme,
          // TODO: CHANGE TO THEMEMODE.SYSTEM ON RELEASE
          themeMode: ThemeMode.light,
          routes: {
            '/': (BuildContext context) => LoadingPage(),
            '/login_page': (BuildContext context) => LoginPage(),
            '/main_page': (BuildContext context) => MainPage()
          },
          onGenerateRoute: (RouteSettings settings) {
            return NavigatorHelper.onGenerateRoute(settings, context);
          },
        );
      },
    );
  }
}
