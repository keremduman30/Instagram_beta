import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instegram_beta/modeller/Kullanici.dart';
import 'package:instegram_beta/servisler/FirestoreServis.dart';
import 'package:instegram_beta/servisler/StorageServis.dart';
import 'package:instegram_beta/servisler/Yetkilendirme.dart';
import 'package:provider/provider.dart';

class ProfilDuzenle extends StatefulWidget {
  final Kullanici profil;

  const ProfilDuzenle({Key key, this.profil}) : super(key: key);
  @override
  _ProfilDuzenleState createState() => _ProfilDuzenleState();
}

class _ProfilDuzenleState extends State<ProfilDuzenle> {
  var formKey = GlobalKey<FormState>();
  var kullaniciAdi;
  var hakkinda;
  var tfAd=TextEditingController();
  var tfHakkinda=TextEditingController();
  File _secilmisFoto;
  bool _yukleniyor=false;
  @override
  void initState() {
    super.initState();
    tfAd.text=widget.profil.kullaniciAdi;
    tfHakkinda.text=widget.profil.hakkinda;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Profil Duzenle",
          style: TextStyle(color: Colors.black),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.cancel,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.black,
            ),
            onPressed: () {
              
              _kaydet();
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _yukleniyor ? LinearProgressIndicator():SizedBox(height: 0,),
          _profilFoto(),
          _kullaniciBilgileri(),
        ],
      ),
    );
  }
  Future<void> _kaydet()async {
    if (formKey.currentState.validate()){
      setState(() {
        _yukleniyor=true;
      });
      String profilFotoUrl;
      if (_secilmisFoto==null) {
        profilFotoUrl=widget.profil.fotoUrl;
      }
      else{
          profilFotoUrl= await StorageServis().profilResmiYUkle(_secilmisFoto);

      }
      kullaniciAdi=tfAd.text;
      hakkinda=tfHakkinda.text;
      var aktifKullanici=Provider.of<Yetkilendirme>(context,listen: false).aktifKullaniciID;

      FirestoreServis().kullaniciGuncelle(kullaniciAdi: kullaniciAdi,kullnaiciId:aktifKullanici ,fotoUrl: profilFotoUrl,hakkinda: hakkinda);
      setState(() {
        _yukleniyor=false;
      });
      Navigator.pop(context);
    }

  }

  Widget _profilFoto() {
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 25),
      child: Center(
        child: InkWell(
          onTap: (){
            _galeridenSec();
          },
          child: CircleAvatar(//center içine aldık ki fotoo ortalansın
            backgroundImage:_secilmisFoto==null ? NetworkImage(widget.profil.fotoUrl): FileImage(_secilmisFoto),
            backgroundColor: Colors.grey,
            radius: 55,
          ),
        ),
      ),
    );
  }
  _galeridenSec()async{
      //source kaynak dmek...imageQuality resmin kalitesi demek biraz azaltarak boyutunu dusuruyoruz
      var image = await ImagePicker().getImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 600,
          imageQuality:
          80); //yani resmi fotograf cekerek yuklemek istıyoruz dedik
      setState(() {
        _secilmisFoto = File(image.path); //yukledigimiz dosya yolunu dosya aktardık
      });

  }
  Widget _kullaniciBilgileri() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: tfAd,
                  decoration: InputDecoration(
                    labelText: "kullanıcı Adı ",
                  ),
                  validator: (girilenDeger){
                  return  girilenDeger.trim().length<=3 ? "kullancı adı en az dort karekter olmalı":null;
                  },
                ),
                TextFormField(
                  controller: tfHakkinda,
                  decoration: InputDecoration(
                    labelText: "Hakkında ",

                  ),
                  validator: (girilenDeger){
                    return girilenDeger.trim().length>100 ? "hakkkında en cok 100 karekter olabilir ": null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  
}
