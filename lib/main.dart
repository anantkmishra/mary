import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mary/routing/router.dart';
import 'package:mary/routing/routes.dart';
import 'package:mary/style/style.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'MARY',
          theme: ThemeData(
            fontFamily: "PlusJakartaSans",
          ),
          routerConfig: maryAppRouter,
        );
      },
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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // AppConstants().initializeSharedPreferences();
      ScreenUtil().setWidth(428); //Adapted to screen width
      ScreenUtil().setHeight(926); //Adapted to screen height

      Future.delayed(const Duration(milliseconds: 500), () {
        navigateTo(MaryAppRoutes.home);
        // if (AppConstants().meldRxAccessToken != null &&
        //     !AppConstants().isMeldRxAccessTokenExpired) {
        //   navigateTo(MaryAppRoutes.home);
        // } else {
        //   navigateTo(MaryAppRoutes.meldRxLogin);
        // }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: MaryStyle().vividCrulian),
    );

    // Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    //     title: Text("MARY"),
    //   ),
    //   body: Center(
    //     child: ElevatedButton(
    //       onPressed: () {
    //         navigateTo(MaryAppRoutes.login);
    //       },
    //       child: Text('Start App'),
    //     ),
    //   ),
    // );
  }
}
