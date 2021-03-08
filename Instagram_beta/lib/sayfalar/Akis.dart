import 'package:flutter/material.dart';
//akıs meseka bir kullanıcıyı takip ettin ve o kullanıcının tum gonderileri akısa gelecek ama bu mesela 500 gonderilik bir kullanıcıysa bu mumkun gibi
/*
degil çunku baya agır olacak o yuzdne biz firebasefunctionu kullanacaz ve firebase e fonksiyon yazarak o bize halledecek
ama bunuun kurulumları var node js ve firebase terminalden once npm install -g firebase-tools
yazıp entere basyırz ve yukleme tamamlanıyor
* */
class Akis extends StatefulWidget {
  @override
  _AkisState createState() => _AkisState();
}

class _AkisState extends State<Akis> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("akıs sayfası"));
  }
}
