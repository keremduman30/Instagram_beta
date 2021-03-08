import 'package:flutter/material.dart';
import 'package:instegram_beta/modeller/Kullanici.dart';
import 'package:instegram_beta/servisler/FirestoreServis.dart';
import 'package:instegram_beta/servisler/Yetkilendirme.dart';
import 'package:provider/provider.dart';

class HesapOlustur extends StatefulWidget {
  @override
  _HesapOlusturState createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  bool yukleniyormMu = false;
  var formKey = GlobalKey<FormState>();
  var scaffoldAnahtari=GlobalKey<ScaffoldState>();
  var tfMail = TextEditingController();
  var tfparola = TextEditingController();
  var tfAd = TextEditingController();
  String kullaniciAdi;
  String mailAdres;
  String parola;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldAnahtari,
      appBar: AppBar(
        title: Text("Hesap Olustur"),
      ),
      body: ListView(
        children: [
          //circleprogressbar dairesel di animasyon yuklenmesi
          //ama linear yatay olarak dogrusal
          yukleniyormMu
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0,
                ),
          Padding(
            padding: EdgeInsets.all(25),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: tfAd,
                    autocorrect: true,
                    //otomatik tamamlama
                    keyboardType: TextInputType.emailAddress,
                    //kalvye tipini mail olarak turettik
                    decoration: InputDecoration(
                      hintText: "Kullanici Adi Giriniz",
                      errorStyle: TextStyle(fontSize: 16),
                      labelText: "Ad ",
                      prefixIcon: Icon(Icons.mail),
                    ),
                    validator: (girlendeger) {
                      if (girlendeger.isEmpty) {
                        return "Kullanıcı adı bos bırakılamaz";
                      } else if (girlendeger.trim().length < 4 ||
                          girlendeger.trim().length > 20) {
                        return "en az 4 en fazla 10 karekter olablir";
                      } else {
                        return null; //buradaki sorun yoksa null doner
                      }
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: tfMail,
                    //otomatik tamamlama
                    keyboardType: TextInputType.emailAddress,
                    //kalvye tipini mail olarak turettik
                    decoration: InputDecoration(
                      hintText: "Mail adresinizi Giriniz",
                      errorStyle: TextStyle(fontSize: 16),
                      labelText: "Mail ",
                      prefixIcon: Icon(Icons.mail),
                    ),
                    validator: (girlendeger) {
                      if (girlendeger.isEmpty) {
                        return "Mail alanı  bos bırakılamaz";
                      } else if (!girlendeger.contains("@")) {
                        return "lütfen mail formatında  yazın";
                      } else {
                        return null; //buradaki sorun yoksa null doner
                      }
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: tfparola,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "parola giriniz",
                      errorStyle: TextStyle(fontSize: 16),
                      labelText: "Parola ",
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (girlendeger) {
                      if (girlendeger.isEmpty) {
                        return "Şifre alanı bos bırakılamaz";
                      }
                      if (girlendeger.trim().length < 6) {
                        return "Şifre 5 karekterden kucuk olamaz";
                      } else {
                        return null; //buradaki sorun yoksa null doner
                      }
                    },
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      //columnda expanded kullanamıyacagımız için container içine alıp double.infity yapcaz
                      onPressed: hesapOlustur,
                      child: Text("Hesap Olustur"),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void hesapOlustur() async {
    final _yetkilendirmeServisi=Provider.of<Yetkilendirme>(context,listen: false);
    bool sorunVarmi = formKey.currentState.validate();
    if (sorunVarmi) {
      kullaniciAdi = tfAd.text;
      parola = tfparola.text;
      mailAdres = tfMail.text;
      setState(() {
        yukleniyormMu=true;
      });
      try{
     Kullanici kullanici=   await _yetkilendirmeServisi.mailIleKayit(mailAdres , parola);
     if (kullanici!=null){
      FirestoreServis().kullanaciOlustur(id:kullanici.id,mail: kullanici.email,kullaniciAdi: kullanici.kullaniciAdi );
       
     }  
        Navigator.pop(context);
      }
      catch(e){
        setState(() {
          yukleniyormMu=false;
        });
        debugPrint("${e.code}");
        uyariGoster(e.code);
      }

    }
  }
  uyariGoster(hatakodu){
    String hataMesaj;
   if (hatakodu=="emaıl-already-ın-use") {
     hataMesaj="bu mail zaten var ";
   }
   if (hatakodu=="invalid-email") {
     hataMesaj="girdiğiniz mail geçersiz ";
   }
   else if (hatakodu=="weak-password") {
     hataMesaj="daha zor bir parola girin oneririlir ";

   }
    var snackbar= SnackBar(content: Text("${hataMesaj}"));
   scaffoldAnahtari.currentState.showSnackBar(snackbar);
    

  }
}
