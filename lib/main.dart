import 'package:flutter/material.dart';
import 'interface/limousine.dart';
import './user/login.dart';
import './interface/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'interface/graphGenerator.dart';
import 'interface/userInfo.dart';
import 'interface/liveStream.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: '/login',
      routes: {
        '/' :(context) => UserLogin(),
        '/login': (context) => UserLogin(),
        '/home': (context) => HomeScreen(),
        '/home/intro': (context) => IntroData(),
        '/user': (context) => UserInfo(),
        // '/graph': (context) => Fila(),
        '/graph': (context) => GraphGenerator(),
        '/stream': (context) => LiveStream(),
        '/stream/page': (context) => LiveStreamPage()
      },
    );
  }
}