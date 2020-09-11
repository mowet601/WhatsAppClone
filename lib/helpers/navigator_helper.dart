import 'package:flutter/material.dart';

import 'package:WhatsAppClone/core/models/chat.dart';

import 'package:WhatsAppClone/core/shared/constants.dart';

import 'package:WhatsAppClone/pages/main/main_page.dart';
import 'package:WhatsAppClone/pages/screens/shared/select_contact_screen.dart';
import 'package:WhatsAppClone/pages/screens/chats/private_chat_page.dart';
import 'package:WhatsAppClone/pages/screens/login/login_page.dart';
import 'package:WhatsAppClone/pages/screens/loading/loading_page.dart';

class Routes {
  Routes._();

  // static variables
  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String privateChat = '/privateChat';
  static const String contacts = '/contatcs';

  // top level app routes
  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => LoadingPage(),
    login: (BuildContext context) => LoginPage(),
    main: (BuildContext context) => MainPage()
  };

  // on generate named routes handler
  static Route<dynamic> onGenerateRoute(
      RouteSettings settings, BuildContext context) {
    Map<String, dynamic> arguments = settings.arguments;
    if (settings.name == contacts) {
      return MaterialPageRoute(builder: (context) {
        return SelectContactScreen(arguments['mode']);
      });
    } else if (settings.name == privateChat) {
      return MaterialPageRoute(builder: (context) {
        return PrivateChatPage(Chat.fromJsonMap(arguments));
      });
    }
    return MaterialPageRoute(builder: (context) {
      return MainPage();
    });
  }

  /// navigate main page
  static void navigateMainPage(BuildContext context) {
    Navigator.pushReplacementNamed(context, main);
  }

  /// navigate login page
  static void navigateLoginPage(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }

  /// navigate contact screen
  static void navigateContactScreen(
      BuildContext context, ContactMode contactMode) {
    Navigator.pushNamed(context, contacts, arguments: {'mode': contactMode});
  }

  /// navigate private chat screen
  static void navigatePrivateChatSceen(BuildContext context, Chat chat) {
    Navigator.pushNamed(context, privateChat, arguments: chat.toJsonMap());
  }
}
