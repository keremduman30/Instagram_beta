import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instegram_beta/servisler/FirestoreServis.dart';
import 'package:instegram_beta/servisler/StorageServis.dart';
import 'package:instegram_beta/servisler/Yetkilendirme.dart';
import 'package:provider/provider.dart';

//image picker galeriden fotograf cekmemize izin verir veya kameradan fotograf cekmemize olanak saglıyor
class Yukle extends StatefulWidget {
  @override
  _YukleState createState() => _YukleState();
}

class _YukleState extends State<Yukle> {
  var tfAciklama=TextEditingController();
  var tfkonum=TextEditingController();
  File dosya;
  bool yukleniyor = false;

  @override
  Widget build(BuildContext context) {
    return dosya == null ? _yukleButonu() : gonderiFormu();
  }

  Widget _yukleButonu() {
    return IconButton(
        icon: Icon(
          Icons.file_upload,
          size: 50,
        ),
        onPressed: () => fotografSec());
  }

  Widget gonderiFormu() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "gönderi olustur",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              dosya =
                  null; //geri donerse işlem iptal olmus demek o yuzdn dosyayı null yaptık
            });
          },
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.send,color: Colors.black,),
              onPressed: _gonderiOlustur
              ),
        ],
      ),
      body: ListView(
        children: [
          yukleniyor ? LinearProgressIndicator() : SizedBox(height: 0,),
          AspectRatio(//resmin en ve boy ayarlamka iiçin kullnılır
            aspectRatio: 16.0/9.0,
            child: Image.file(dosya,fit: BoxFit.cover,),

          ),
          SizedBox(height: 10,),
          TextFormField(
            controller: tfAciklama,
            decoration: InputDecoration(
              hintText: "aciklama",
              contentPadding: EdgeInsets.only(left: 15,right: 15),
            ),
          ),
          TextFormField(
            controller: tfkonum,
            decoration: InputDecoration(
              hintText: "Foto nerede çekildi",
              contentPadding: EdgeInsets.only(left: 15,right: 15),
            ),
          ),

        ],
      ),
    );
  }

  void _gonderiOlustur() async{
    if (!yukleniyor){
      setState(() {
        yukleniyor=true;
      });
      String resimUrl= await StorageServis().gonderiResmiYukle(dosya);
    String aktif_kullanici=  Provider.of<Yetkilendirme>(context,listen: false).aktifKullaniciID;
   await FirestoreServis().gonderiOlustur(gonderiResimUrl: resimUrl,aciklama: tfAciklama.text,yayinlayanId: aktif_kullanici,konum: tfkonum.text);
   setState(() {
     //yukledigi anda yukleniyoru false yaptık ve konumve acıklamayı gelecek için temizlettik
     yukleniyor=false;
     tfAciklama.clear();
     tfkonum.clear();
     dosya=null;//çünkü gonderi işlemi itiginde dosya null yaptıkki yukle iconu cıksın ve işlem bittigini anlasınlar diye
   });

    }      
  }

  fotografSec() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Gönderi olustur"),
            children: [
              SimpleDialogOption(
                child: Text("Fotograf çek"),
                onPressed: () {
                  fotoCek();
                },
              ),
              SimpleDialogOption(
                child: Text("galeriden yukle "),
                onPressed: () {
                  galeridenSec();
                },
              ),
              SimpleDialogOption(
                child: Text("İptal "),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<PickedFile> fotoCek() async {
    Navigator.pop(context); //fotocek tıklandıgı anda dialog kapanacak
    //source kaynak dmek...imageQuality resmin kalitesi demek biraz azaltarak boyutunu dusuruyoruz
    var image = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality:
            80); //yani resmi fotograf cekerek yuklemek istıyoruz dedik
    setState(() {
      dosya = File(image.path); //yukledigimiz dosya yolunu dosya aktardık
    });
  }

  Future<PickedFile> galeridenSec() async {
    Navigator.pop(context); //fotocek tıklandıgı anda dialog kapanacak
    //source kaynak dmek...imageQuality resmin kalitesi demek biraz azaltarak boyutunu dusuruyoruz
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality:
            80); //yani resmi fotograf cekerek yuklemek istıyoruz dedik
    setState(() {
      dosya = File(image.path); //yukledigimiz dosya yolunu dosya aktardık
    });
  }
}
