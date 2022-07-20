import 'package:flutter/material.dart';
import 'package:hehewhoknows/views/Login_view.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.pink,
    ),
    home: const LoginView(),
  ),
  );
}



