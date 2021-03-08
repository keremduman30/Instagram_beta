import 'package:flutter/material.dart';
import 'package:instegram_beta/modeller/Kullanici.dart';
import 'package:instegram_beta/sayfalar/Profil.dart';
import 'package:instegram_beta/servisler/FirestoreServis.dart';

class Ara extends StatefulWidget {
  @override
  _AraState createState() => _AraState();
}

class _AraState extends State<Ara> {
  var tfArama=TextEditingController();
  String arama;
  Future<List<Kullanici>> aramaSonu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:_apparOlustur(),
      body: aramaSonu !=null ? sonuclariGoster():aramaYok(),


    );

  }
  sonuclariGoster() {
    return FutureBuilder<List<Kullanici>>(
        future: aramaSonu,
      builder: (context,snaphot){
          if (!snaphot.hasData) {
            return Center(child: CircularProgressIndicator(),);
          }
          if (snaphot.data.length==0) {
              return Center(child: Text("boyle bir kullanıcı bulmadık "),);
          }
          else{
            return ListView.builder(
              itemCount: snaphot.data.length,
              itemBuilder: (context,index){
                Kullanici kullanici=snaphot.data[index];
                return kullaniciSatiri(kullanici);
              },
            );
          }
      },
    );
  }
  kullaniciSatiri(Kullanici kullanici){
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Profil(poriflSahibiId: kullanici.id,)));
      },
      child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(kullanici.fotoUrl),

          ),
        title: Text(kullanici.kullaniciAdi,style: TextStyle(fontWeight: FontWeight.bold ),),

      ),
    );

  }

  aramaYok() {
    return Center(child: Text("Kullanıcı Ara "));
  }
 AppBar _apparOlustur() {
    return AppBar(
      titleSpacing: 0, //yatay eksende boslık olmamasını sagladık
      backgroundColor: Colors.grey[100],
      title:TextFormField(
        onFieldSubmitted: (girilenDeger){//entere basılırsa bu fonksiton calısacak
          setState(() {
            aramaSonu=  FirestoreServis().kullaniciAra(girilenDeger);

          });
        },
        controller: tfArama,
         decoration: InputDecoration(
           //text yanında eger icon olmasını istersek prefixIcon
           prefixIcon: Icon(Icons.search,size: 25,color: Colors.grey,),
             //textin sonunda da icon olmasını istiyorsak suffixIcon
             suffixIcon: IconButton(
              icon: Icon(Icons.clear),
               onPressed: (){
                tfArama.clear();
                setState(() {
                  aramaSonu=null;
                });
               },
         ),
           border: InputBorder.none,//asagıdan cizgi olmaması için
           fillColor: Colors.white,//textform içindeki reng ne ile doldurursun
           filled: true,
          hintText: "kullanıcı ara",
           contentPadding: EdgeInsets.only(top: 16)
         ),

      ),
    );

 }



}
