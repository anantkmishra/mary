import "package:flutter/material.dart";
// import "package:mary/constants/constants.dart";
import "package:mary/routing/routes.dart";
import 'dart:developer' as dev;

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log(maryAppRouter.state.fullPath ?? "", name: "PATH ");

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                navigateTo(MaryAppRoutes.meldRxLogin);
              },
              child: Text("MeldRx Login"),
            ),
            ElevatedButton(
              onPressed: () {
                navigateTo(MaryAppRoutes.home);
              },
              child: Text("Home"),
            ),

            // ElevatedButton(
            //   onPressed: () {
            //     dev.log("${AppConstants().authURL}", name: "AUTH URL");
            //   },
            //   child: Text("authurl"),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     dev.log("${AppConstants().meldRxAccessToken}", name: "TOKEN");
            //   },
            //   child: Text("Token"),
            // ),
          ],
        ),
      ),
    );
  }
}
