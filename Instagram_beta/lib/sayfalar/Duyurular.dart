import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instegram_beta/modeller/Duyuru.dart';
import 'package:instegram_beta/modeller/Kullanici.dart';
import 'package:instegram_beta/sayfalar/Profil.dart';
import 'package:instegram_beta/sayfalar/TekliGonderi.dart';
import 'package:instegram_beta/servisler/FirestoreServis.dart';
import 'package:instegram_beta/servisler/Yetkilendirme.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;


class Duyurular extends StatefulWidget {
//refresh yapmak için de resfresindicator kullanacaz ama bu  kaydırılabilir dısında olmalı
//time ago yapılma zamanı ve bunu kullanmak içib de olsuturulma zamanını todate() ye cevirmek ve imitstate de  timeago.setLocaleMessages("tr", timeago.TrMessages());
//yazarak turkce olarak gosterilmesini saglıyoruz
//kendi kullanıcı gonderisini begnerise veya yorum yaparsa duturu gelmesine gerek yok o yuzden firestorerdn bunu yapıyoz


  @override
  _DuyurularState createState() => _DuyurularState();
}

class _DuyurularState extends State<Duyurular> {
  List<Duyuru> duyuruList;
  String aktifKullaniciId;
  bool _yukleniyor=true;


  @override
  void initState() {
    super.initState();
    aktifKullaniciId=Provider.of<Yetkilendirme>(context,listen: false).aktifKullaniciID;
    _duyurulariGetir();
    timeago.setLocaleMessages("tr", timeago.TrMessages());

  }
 Future<void> _duyurulariGetir() async{//refresh yapacagımız yer veritabanının duyuru getir kısmı refres future dondugu için donusu future oolmalı
    List<Duyuru> duyurular=  await  FirestoreServis().duyurulariGetir(aktifKullaniciId);
    if (mounted) {
      setState(() {
        duyuruList=duyurular;
        _yukleniyor=false;
      });
    }
  }
  _duyurlariGoster(){
   if (_yukleniyor) {
     return Center(child: CircularProgressIndicator(),);
   }
   if (duyuruList.isEmpty) {
     return Center(child: Text("hiç duyurunuz bulunmamaktadır"));
   }
   return Padding(
     padding: EdgeInsets.only(top: 8),
     child: RefreshIndicator(
       onRefresh: _duyurulariGetir,
       child: ListView.builder(
         itemCount: duyuruList.length,
         itemBuilder: (context,index){
           Duyuru duyuru=duyuruList[index];
           return _duyuruSatiri(duyuru);

         },
       ),
     ),
   );
  }
 Widget _duyuruSatiri(Duyuru duyuru){
   String mesaj= mesajOlustur(duyuru.aktiviteTipi);

    return FutureBuilder(
      future: FirestoreServis().kullaniciGetir(duyuru.aktiviteYapanId),
      builder: (context,snaphot){
        if (!snaphot.hasData) {
          return SizedBox(height: 0,);
        }
        Kullanici aktiviteYapanId=snaphot.data;
        return ListTile(
          leading: GestureDetector(
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>Profil(poriflSahibiId: duyuru.aktiviteYapanId,))),
            child: CircleAvatar(
              backgroundImage: NetworkImage(aktiviteYapanId.fotoUrl),

            ),
          ),
          title: RichText(//cok stilli metin demekk kaydırmalı tıklnama cift tklanma cizme hersey var bu fonksiyonlar recongnizerde mevcut
            text: TextSpan(
              recognizer: TapGestureRecognizer()..onTap=(){//tıklanma olayı biraz degilis.tıklanınca profile gitsin
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Profil(poriflSahibiId: duyuru.aktiviteYapanId,)));
              },
              text: "${aktiviteYapanId.kullaniciAdi}",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text:duyuru.yorum==null ?  "  $mesaj":" ${mesaj}  ${duyuru.yorum}",style: TextStyle(fontWeight: FontWeight.normal)
                )
              ]
            ),
          ),
          subtitle: Text(timeago.format(duyuru.olusturulmaZamani.toDate(),locale: "tr")),//
          trailing: gonderiGorsel(duyuru.aktiviteTipi, duyuru.gonderiFoto,duyuru.gonderiId),

        );
      },
    );
  }
  gonderiGorsel(String aktiviteTipi,String gonderiFoto,String gonderiID){
      if (aktiviteTipi=="takip") {
        return null;
      }  
      else if (aktiviteTipi=="begeni" || aktiviteTipi=="yorum"){
        return GestureDetector(
          onTap: (){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>TekliGonderi(gonderiId: gonderiID,gonderiSahibiID: aktifKullaniciId,))) ;
          },
            child: Image.network(gonderiFoto,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
        );
      }  

  }
  mesajOlustur(String aktiviteTipi){
    if (aktiviteTipi=="begeni") {
      return "gonderini beğendi";
    }  
    else if (aktiviteTipi=="takip") {
      return "seni takip etti";
    }  
    else if (aktiviteTipi=="yorum") {
      return "gonderine yorum yaptı";
      
    }
    else return null;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text("duyurular",style: TextStyle(color: Colors.black),),

      ),
      body: _duyurlariGoster()
    );
  }
}
