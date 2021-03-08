import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instegram_beta/Yonlendirme.dart';
import 'package:instegram_beta/servisler/Yetkilendirme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<Yetkilendirme>(
      create: (_)=>Yetkilendirme(),
      child: MaterialApp(
        title: 'come to English',
        debugShowCheckedModeBanner: false,

        home: Yonlendirme(),
      ),
    );
  }
}


