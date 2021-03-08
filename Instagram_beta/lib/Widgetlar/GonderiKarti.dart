
import 'package:flutter/material.dart';
import 'package:instegram_beta/modeller/Gonderi.dart';
import 'package:instegram_beta/modeller/Kullanici.dart';
import 'package:instegram_beta/sayfalar/Yorumlar.dart';
import 'package:instegram_beta/servisler/FirestoreServis.dart';
import 'package:instegram_beta/servisler/Yetkilendirme.dart';
import 'package:provider/provider.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;

  const GonderiKarti({Key key, this.gonderi, this.yayinlayan})
      : super(key: key);

  @override
  _GonderiKartiState createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi = 0;
  bool _begendin = false;
  String _aktifKullaniciId;

  @override
  void initState() {
    super.initState();
    _begeniSayisi = widget.gonderi.begeniSayisi;
    _aktifKullaniciId=Provider.of<Yetkilendirme>(context,listen: false).aktifKullaniciID;
    begeniVarmi();
  }
  begeniVarmi() async{
    bool begeniVarmi=   await   FirestoreServis().begeniVarmi(widget.gonderi, _aktifKullaniciId);
    if (begeniVarmi){
      if (mounted) {
        setState(() {
          _begendin=true;
        });
      }

    }
    else{
      if (mounted) {
        setState(() {
          _begendin=false;
        });
      }

    }

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _gonderiBasligi(),
        _gonderiResmi(),
        _gonderiAlt(),
      ],
    );
  }
  gonderiSecenekleri(){
    showDialog(
        context: context,
      builder: (context){
          return SimpleDialog(
            title: Text("Seçiminiz Nedir"),
            children: [
              SimpleDialogOption(
                child: Text("Gonderi Sil"),
              onPressed: (){
                  FirestoreServis().gonderileriSil(_aktifKullaniciId, widget.gonderi);
                Navigator.pop(context);
              },
              ),

              SimpleDialogOption(
                child: Text("İptal",style: TextStyle(color: Colors.red),),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
            ],
          );
      }
    );
  }
  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: EdgeInsets.only(left: 8),
        child: CircleAvatar(
          backgroundImage: widget.yayinlayan.fotoUrl.isNotEmpty
              ? NetworkImage(widget.yayinlayan.fotoUrl)
              : AssetImage("assets/image/profil.jpg"),
        ),
      ),
      title: Text(
        widget.yayinlayan.kullaniciAdi,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      trailing: _aktifKullaniciId == widget.gonderi.yayinlayanID ? IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () {
          gonderiSecenekleri();
        },
      ):null,
      contentPadding: EdgeInsets.all(
          0), //listile paddigini kapattım ki uc noktalı ücon iyice saga yerlessin tabi circle avatarda sola yapısık olacak onu
      //padding içine alalım
    );
  }

  Widget _gonderiResmi() {//gonderi resmine çift tıklarsa da gene begeni sayısı +1 artsın diye gesture detectora aktaradık ve foubeltağ kullandıl
    return GestureDetector(
      onDoubleTap: ()=>_begeniDegistir(),
      child: Image.network(
        widget.gonderi.gonderiResimUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context)
            .size
            .width, //yani yuksekliğide genişliği kadar olacak
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                icon: !_begendin
                    ? Icon(
                        Icons.favorite_border,
                        size: 35,
                      )
                    : Icon(
                        Icons.favorite,
                        size: 35.0,
                        color: Colors.red,
                      ),
                onPressed: _begeniDegistir),
            IconButton(
                icon: Icon(
                  Icons.comment,
                  size: 35,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Yorumlar(gonderi: widget.gonderi ,)));
                }),
          ],
        ),
        Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              "${_begeniSayisi} begeni ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            )),
        SizedBox(
          height: 5,
        ),
        //birden fazla stile sahip metinler yazmak için richtext kullanıyoruz
        widget.gonderi.aciklama.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(left: 8),
                child: RichText(
                  text: TextSpan(
                      text: widget.yayinlayan.kullaniciAdi + " ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black),
                      children: [
                        TextSpan(
                            text: widget.gonderi.aciklama,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            )),
                      ]),
                ),
              )
            : SizedBox(
                height: 0.0,
              ),
      ],
    );
  }

  void _begeniDegistir() {
    //şimdi once begeni false oldugu  için ilk tıklamada setstate da begedin true olacak ve kırmızılasaacak sonra bi daha tıklarsan
    //begeni true oldgu için begendin false olacak içibos kalp olacak begeni sayısı -1 olacak
   if (_begendin) {//begendin true ise kullanıcıbegenmis bi daha basarsa begeniyi kaldıracak kodları yazalım
     setState(() {
       _begendin=false;
       _begeniSayisi-=1;
       FirestoreServis().gonderiBegeniKaldir(widget.gonderi,_aktifKullaniciId);
     });
   }
   else{
     setState(() {
       _begendin=true;
       _begeniSayisi+=1;
       FirestoreServis().gonderiBegen(widget.gonderi,_aktifKullaniciId);
     });
   }
  }


}
