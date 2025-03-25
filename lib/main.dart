import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mary/constants/constants.dart';
import 'package:mary/routing/routes.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MARY',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: "PlusJakartaSans",
      ),
      routerConfig: maryAppRouter,
      // home: const MyHomePage(),
    );
  }
}

class Mary extends StatefulWidget {
  const Mary({super.key});

  @override
  State<Mary> createState() => _MaryState();
}

class _MaryState extends State<Mary> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppConstants().isSharedPreferencesInitialized
          ? null
          : AppConstants().initializeSharedPreferences();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (AppConstants().meldRxAccessToken != null &&
            !AppConstants().isMeldRxAccessTokenExpired) {
          navigateTo(MaryAppRoutes.home);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("MARY"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            navigateTo(MaryAppRoutes.login);
          },
          child: Text('Start App'),
        ),
      ),
    );
  }
}
