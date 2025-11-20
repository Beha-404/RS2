import 'package:desktop/pages/login_page.dart';
import 'package:desktop/providers/support_provider.dart';
import 'package:desktop/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SupportProvider()),
      ],
      child: MaterialApp(
        title: 'EasyPC - Desktop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: false).copyWith(
          primaryColor: const Color(0xFFFFCC00),
          scaffoldBackgroundColor: const Color(0xFF2F2626),
        ),
        home: const LoginPage(),
      ),
    );
  }
}
