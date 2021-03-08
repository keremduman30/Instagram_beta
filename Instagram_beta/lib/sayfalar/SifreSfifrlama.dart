import 'package:flutter/material.dart';
import 'package:instegram_beta/servisler/Yetkilendirme.dart';
import 'package:provider/provider.dart';

class SifreSifirlama extends StatefulWidget {
  @override
  _SifreSifirlamaState createState() => _SifreSifirlamaState();
}

class _SifreSifirlamaState extends State<SifreSifirlama> {
  bool yukleniyormMu = false;
  var formKey = GlobalKey<FormState>();
  var scaffoldAnahtari=GlobalKey<ScaffoldState>();
  var tfMail = TextEditingController();
  String _mailAdress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldAnahtari,
      appBar: AppBar(
        title: Text("Şifre Sıfırlama"),
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
                    height: 50,
                  ),
                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      //columnda expanded kullanamıyacagımız için container içine alıp double.infity yapcaz
                      onPressed: sifreUnut,
                      child: Text("Sifremi Unuttum",style: TextStyle(color: Colors.white),),
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
  void sifreUnut() async {
    final _yetkilendirmeServisi=Provider.of<Yetkilendirme>(context,listen:  false);
    bool sorunVarmi = formKey.currentState.validate();
    if (sorunVarmi) {

      _mailAdress = tfMail.text;
      setState(() {
        yukleniyormMu=true;
      });
      try{
     await  _yetkilendirmeServisi.sifremiSifirla(_mailAdress);
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
    if (hatakodu=="user_not_found") {
      hataMesaj="boyle bir mail bulunmamaktadır";
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
