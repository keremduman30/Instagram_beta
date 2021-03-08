import 'package:flutter/material.dart';
import 'package:instegram_beta/Widgetlar/GonderiKarti.dart';
import 'package:instegram_beta/modeller/Gonderi.dart';
import 'package:instegram_beta/modeller/Kullanici.dart';
import 'package:instegram_beta/servisler/FirestoreServis.dart';

class TekliGonderi extends StatefulWidget {
  final String gonderiId;
  final String gonderiSahibiID;

  const TekliGonderi({Key key, this.gonderiId, this.gonderiSahibiID}) : super(key: key);

  @override
  _TekliGonderiState createState() => _TekliGonderiState();
}


class _TekliGonderiState extends State<TekliGonderi> {
  Gonderi _gonderi;
  Kullanici _gonderiSahibi;
  bool _yukleniyor=true;


  gonderileriGetir() async{
   Gonderi gonderi= await FirestoreServis().tekliGonderiGetir(widget.gonderiId, widget.gonderiSahibiID);
   if (gonderi!=null){
       Kullanici gonderiSahibi= await FirestoreServis().kullaniciGetir(gonderi.yayinlayanID);
       setState(() {
         _gonderi=gonderi;
         _gonderiSahibi=gonderiSahibi;
         _yukleniyor=false;

       });

   }

  }
  @override
  void initState() {
    super.initState();
    gonderileriGetir();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text("gonderi",style: TextStyle(color: Colors.black),),
        iconTheme: IconThemeData(color: Colors.black),

      ),
      body:_yukleniyor==false ? GonderiKarti(gonderi: _gonderi,yayinlayan: _gonderiSahibi,): Center(child: CircularProgressIndicator(),),
    );
  }
}
