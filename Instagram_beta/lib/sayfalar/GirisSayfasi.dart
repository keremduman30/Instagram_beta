import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instegram_beta/modeller/Kullanici.dart';
import 'package:instegram_beta/sayfalar/HesapOlustur.dart';
import 'package:instegram_beta/sayfalar/SifreSfifrlama.dart';
import 'package:instegram_beta/servisler/FirestoreServis.dart';
import 'package:instegram_beta/servisler/Yetkilendirme.dart';
import 'package:provider/provider.dart';

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  var formKey = GlobalKey<FormState>();
  var tfAd = TextEditingController();
  var tfParola = TextEditingController();
  String ad;
  String parola;
  bool yukleniyor = false;
  var scafoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafoldKey,
      body: Stack(
        children: [
          _sayfaElemanlari(),
          _yuklemeAnimasyonu(),
        ],
      ),
    );
  }

  Widget _yuklemeAnimasyonu() {
    if (yukleniyor) {
      return Center(child: CircularProgressIndicator());
    } else {
      return SizedBox(
        height: 0,
      );
    }
  }

  Widget _sayfaElemanlari() {
    return ListView(
      padding: EdgeInsets.only(left: 25, right: 25, top: 60),
      children: [
        FlutterLogo(
          size: 90,
        ),
        SizedBox(
          height: 80,
        ),
        Form(
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
                controller: tfParola,
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
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: FlatButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HesapOlustur()));
                      },
                      child: Text("Hesap Olustur",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: _girisYap,
                      child: Text(
                        "Giriş Yap",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                  child: Text(
                "veya",
              )),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: googleIleGiris,
                child: Center(
                    child: Text(
                  "Google ile Giriş Yap",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.grey[600]),
                )),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>SifreSifirlama()));
                    },
                    child: Text(
                "Şifremi Unuttum",
              ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> googleIleGiris() async {
    final _yetkilendirmeServisi = Provider.of<Yetkilendirme>(context, listen: false);
    setState(() {
      yukleniyor = true;
    });
    try {
      Kullanici kullanici = await _yetkilendirmeServisi.googleIleGiris();
      if (kullanici != null) {
        Kullanici _firestoreKullanici = await FirestoreServis().kullaniciGetir(kullanici.id);
        if (_firestoreKullanici == null) {
          FirestoreServis().kullanaciOlustur(
              id: kullanici.id,
              mail: kullanici.email,
              kullaniciAdi: kullanici.kullaniciAdi,
              fotoUrl: kullanici.fotoUrl);
        }

      }
    } catch (e) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(e.code);
    }
  }

  void _girisYap() async {
    final _yetkilendirmeServisi = Provider.of<Yetkilendirme>(context, listen: false);

    bool sorunVarmi = formKey.currentState.validate();

    if (sorunVarmi) {
      //eger null ise sorun yok nulll deilse sorun var demek
      ad = tfAd.text;
      parola = tfParola.text;
      setState(() {
        yukleniyor = true;
      });
      try {
        await _yetkilendirmeServisi.mailIleGiris(ad, parola);
      } catch (e) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(e.code);
      }
    }
  }

  uyariGoster(hatakodu) {
    String hataMesaj;

    if (hatakodu == "invalid-email") {
      hataMesaj = "girdiğiniz mail geçersiz ";
    } else if (hatakodu == "weak-password") {
      hataMesaj = "daha zor bir parola girin oneririlir ";
    } else if (hatakodu == "wrong-password") {
      hataMesaj = "yanlıs parola";
    }
    //user-disabled
    else if (hatakodu == "user-disabled") {
      hataMesaj = "bu kullanıcı engellenmis";
    }
    var snackbar = SnackBar(content: Text("${hataMesaj}"));
    scafoldKey.currentState.showSnackBar(snackbar);
  }
}
