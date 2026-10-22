import 'package:flutter/material.dart';
import 'package:anime_verse/providers/app_state_provider.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStateProvider(),
      child: MaterialApp.router(
        title: 'Anime Verse',
        theme: ThemeData(
          fontFamily: 'Urbanist',
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: createRouter(),
      ),
    );
  }
}
