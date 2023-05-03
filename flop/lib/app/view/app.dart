import 'package:flop/flop/flop.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.setAppCheckDebugToken,
  });

  final void Function(String) setAppCheckDebugToken;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Color(0xFF13B9FF)),
        colorScheme: ColorScheme.fromSwatch(
          accentColor: const Color(0xFF13B9FF),
        ),
      ),
      home: FlopPage(
        setAppCheckDebugToken: setAppCheckDebugToken,
      ),
    );
  }
}