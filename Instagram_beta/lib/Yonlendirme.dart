import 'package:flutter/material.dart';
import 'package:instegram_beta/modeller/Kullanici.dart';
import 'package:instegram_beta/sayfalar/Anasayfa.dart';
import 'package:instegram_beta/sayfalar/GirisSayfasi.dart';
import 'package:instegram_beta/servisler/Yetkilendirme.dart';
import 'package:provider/provider.dart';

class Yonlendirme extends StatelessWidget {//hangi sayfaya yonelecegi bu sayfa belirliyecek
  String parola;
  @override
  Widget build(BuildContext context) {
    final _yetkilendirmeServisi=Provider.of<Yetkilendirme>(context,listen: false);
    return StreamBuilder<Kullanici>(
      stream: _yetkilendirmeServisi.durumTakipcisi,
      builder: (context,snaphot){
        if (snaphot.connectionState==ConnectionState.waiting) {
          return Scaffold(body:Center(child: CircularProgressIndicator(),));
        }
        if (snaphot.hasData){
          Kullanici aktif_kullanici=snaphot.data;
          _yetkilendirmeServisi.aktifKullaniciID=aktif_kullanici.id;
          return Anasayfa();

        }
        else{
          return GirisSayfasi();
        }

      },
    );
  }
}
