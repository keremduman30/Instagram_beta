import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instegram_beta/Widgetlar/GonderiKarti.dart';
import 'package:instegram_beta/modeller/Gonderi.dart';
import 'package:instegram_beta/modeller/Kullanici.dart';
import 'package:instegram_beta/sayfalar/ProfilDuzenle.dart';
import 'package:instegram_beta/servisler/FirestoreServis.dart';
import 'package:instegram_beta/servisler/Yetkilendirme.dart';
import 'package:provider/provider.dart';
//gmail ile acan ın gmail hesaptaki profili olmasını istemiyoruz oyuzden yarı bir lokal assets dosyası olusturup yaopcaz
class Profil extends StatefulWidget {
  final String poriflSahibiId;


  const Profil({Key key, this.poriflSahibiId}) : super(key: key);
  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _gonderiSayisi=0;
  int _takipSayisi=0;
  int _takipEdilenSayisi=0;
  //gonderilistesi
  List<Gonderi> _gonderiList=[];
  String gonderiStili="liste";
  String _aktifKullaniciID;
   Kullanici _profilSahibi;
   bool _takipEdildi=false;



  //gonderileri getirme
  _gonderileriGetir()async{
   List<Gonderi> gelenGonderiler=await FirestoreServis().gonderileriGetir(widget.poriflSahibiId);
   if (mounted) {
     setState(() {
       _gonderiList=gelenGonderiler;
       _gonderiSayisi=_gonderiList.length;
     });
   }


  }


  //takipci sayisi
  _takipciSayisiGetir() async{
    int takip=  await FirestoreServis().takipciSayisi(widget.poriflSahibiId);
    if (mounted) {//geri sayfalar arası hızlı  geçişlerde hata vermemek için
      setState(() {
        _takipSayisi=takip;
      });
    }

  }
  //takipedilen sayisi
  _takipciEdilenlerSayisiGetir() async{
    int takipEdilen=  await FirestoreServis().takipEdilenSayisi(widget.poriflSahibiId);
    if (mounted) {
      setState(() {
        _takipEdilenSayisi=takipEdilen;
      });
    }

  }
  _takipKontrol() async{
  bool takipVarmi= await FirestoreServis().takipKontrol(_aktifKullaniciID, widget.poriflSahibiId);
  setState(() {
    _takipEdildi=takipVarmi;
  });
  }
  @override
  void initState() {
    super.initState();
    _takipciSayisiGetir();
    _takipciEdilenlerSayisiGetir();
    _gonderileriGetir();
    setState(() {
      _aktifKullaniciID=Provider.of<Yetkilendirme>(context,listen: false).aktifKullaniciID;

    });
    _takipKontrol();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color:Colors.black),
        title: Text(
          "Profil",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[100],
        actions: [
         widget.poriflSahibiId==_aktifKullaniciID ? IconButton(icon: Icon(Icons.exit_to_app), color: Colors.black, onPressed: _cikisYap,):SizedBox(height: 0,),
        ],
      ),
      body: FutureBuilder<Kullanici>(
        future: FirestoreServis().kullaniciGetir(widget.poriflSahibiId),
       builder: (context,snaphot){
        _profilSahibi=snaphot.data;
        return  ListView(
          children: [
            _profilDetaylari(snaphot.data),
            _gonderileriGoster(snaphot.data),
          ],
        );
      }
      ),
    );
  }
  //takipci foto onları ayrı gonderi ayrı bolume aldık
  Widget _profilDetaylari(Kullanici kullaniciData){
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 50,
               backgroundImage:kullaniciData.fotoUrl.isNotEmpty ? NetworkImage(kullaniciData.fotoUrl): AssetImage("assets/image/profil.jpg"),
              ),
              Expanded(//row içince row varsa mainaxis calısmaz cunku alanı ne kadar bilmiyor o yuzden expanded içine aldık
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sosyalSayac(_gonderiSayisi, "gonderi"),
                    _sosyalSayac(_takipSayisi, "takipci"),
                    _sosyalSayac(_takipEdilenSayisi, "takip"),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 10,),
          Text(
              kullaniciData.kullaniciAdi,
            style:  TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 5,),
          Text(
            kullaniciData.hakkinda,
            style:  TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 25,),

       widget.poriflSahibiId == _aktifKullaniciID ? _profilDuzenleButon() : _takipButonu(),


        ],
      ),
    );
  }
  Widget _takipButonu(){
    return _takipEdildi ? _takiptenCik():_takipEtButonu();

  }

  Widget _takipEtButonu(){
    //bu sade yazi ve ince çizgili butonlar Qutlinebutton denir cerceve anlamı oldgu için iç kkısmıda seffaftır
    return Container(
      width: double.infinity,
      child: FlatButton(
        color: Theme.of(context).primaryColor,
        onPressed: (){
          FirestoreServis().takipEt(_aktifKullaniciID, widget.poriflSahibiId);
          setState(() {
            _takipEdildi=true;
            _takipSayisi+=1;
             
          });
        },
        child: Text("Takip Et",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      ),
    );
  }
  Widget _takiptenCik(){
    //bu sade yazi ve ince çizgili butonlar Qutlinebutton denir cerceve anlamı oldgu için iç kkısmıda seffaftır
    return Container(//outline butonda color verilmiyor o yuzden flatbuton yaptım
      width: double.infinity,
      child: OutlineButton(
        onPressed: (){
          FirestoreServis().takiptenCik(_aktifKullaniciID, widget.poriflSahibiId);
          setState(() {
            _takipEdildi=false;
            _takipSayisi-=1;
          });
        },
        child: Text("Takibi Bırak",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
      ),
    );
  }
  Widget _profilDuzenleButon(){
    //bu sade yazi ve ince çizgili butonlar Qutlinebutton denir cerceve anlamı oldgu için iç kkısmıda seffaftır
    return Container(
      width: double.infinity,
      child: OutlineButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilDuzenle(profil: _profilSahibi,)));
          },
        child: Text("Profili Düzenle"),
      ),
    );
  }
 Widget _gonderileriGoster(Kullanici snapshot) {
   if (gonderiStili=="liste") {
      return ListView.builder(//list view içine list view ekledigimiz için scrollar birbirne girdi bunun için
        shrinkWrap: true,//yapmak lazım scrolll için
          //tabi scroll da içinden yapamıyor bunun içinde
          primary: false,
        itemCount: _gonderiList.length,
          itemBuilder: (context,index){
          return GonderiKarti(gonderi: _gonderiList[index],yayinlayan: snapshot,);
          }
      );

   }
   else{
     //şimdi listview içindede kaydırma var gridview.countta ve bu soruna neden oluyuor bunun için
     //physics: NeverScrollableScrollPhysics(),yapmamız laızm
     List<GridTile> fayanslar=[];
     _gonderiList.forEach((gonderi) {
       fayanslar.add(_fayansOlustur(gonderi));
     });
     return GridView.count(
       crossAxisCount: 3,
       crossAxisSpacing: 3.0,
       mainAxisSpacing: 3.0,
       childAspectRatio: 1.0,
       physics: NeverScrollableScrollPhysics(),
       shrinkWrap: true,//sadece ihtiyacın olan alan kadar kapla eger bu true olması scrol olmuyacak ve bisey gozukmuyecektir
       children: fayanslar,
     );
   }
  }
 GridTile _fayansOlustur(Gonderi gonderi){
return GridTile(
  child: Image.network(gonderi.gonderiResimUrl,fit: BoxFit.cover ,),


);
  }
  void _cikisYap(){
   var _yetkilendirmeServisi=Provider.of<Yetkilendirme>(context,listen: false);
    _yetkilendirmeServisi.cikisYap();

  }
  Widget _sosyalSayac(int sayac,String baslik){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
      Text("${sayac}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
      SizedBox(height: 2,),
      Text("${baslik}",style: TextStyle(color: Colors.black,fontSize: 15,),),
      ],
    );
  }


}
//not listview içine listview yada gridview vb scrollu eklerseniz scrollar birbirne girer ve calısmaz bunun için
//sadce ilgili alanı kapsaması için shrinkWrap: true, olması lazım
//ve birinin scrolunu iptal etmek içinde   physics: NeverScrollableScrollPhysics(), yabunu yada primary:false yapılmalı çümkü iki scroll var
//genelde içindeki scroll iptal edilir

