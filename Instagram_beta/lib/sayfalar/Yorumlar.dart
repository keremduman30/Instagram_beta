import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instegram_beta/modeller/Gonderi.dart';
import 'package:instegram_beta/modeller/Kullanici.dart';
import 'package:instegram_beta/modeller/Yorum.dart';
import 'package:instegram_beta/servisler/FirestoreServis.dart';
import 'package:instegram_beta/servisler/Yetkilendirme.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class Yorumlar extends StatefulWidget {
  final Gonderi gonderi;

  Yorumlar({this.gonderi});

  @override
  _YorumlarState createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  var tfYorum=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text("Yorumlar",style: TextStyle(color: Colors.black ),),
        iconTheme: IconThemeData(
          color: Colors.black
        ),
      ),
      body: Column(//niye listview degil de column cunku sayfa en basından kaydırılmasını istemiyoruz o yuzden columndan baslıyarak listview yapcak
        children: [
          _yorumlariGoster(),
          _yorumEkle(), 
        ],
      ),
    );
  }


 Widget _yorumlariGoster() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreServis().yorumlariGetir(widget.gonderi.id),
        builder: (context,snaphot){
          if (!snaphot.hasData){
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snaphot.data.docs.length,
            itemBuilder: (context,index){
          Yorum yorum=Yorum.dokumandanUret(snaphot.data.docs[index]);
              return _yorumSatiri(yorum);

            },

          );
        },
      ),
    );
 }
 Widget _yorumSatiri(Yorum yorum){

      return FutureBuilder<Kullanici>(
        future: FirestoreServis().kullaniciGetir(yorum.yayinlayanId),
        builder: (context,snaphot){

          Kullanici yayinlayan=snaphot.data;
          
       return  ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage:AssetImage("assets/image/profil.jpg"),


          ),
          title: RichText(
            text: TextSpan(

                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black),
                children: [
                  TextSpan(
                      text: yorum.icerik,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      )),
                ]),
          ),

     
        );
 }
      );
 }

 Widget _yorumEkle() {
    return ListTile(
      title: TextFormField(
        controller: tfYorum,
        decoration: InputDecoration(
           hintText:"yorumu buraya yazın"

        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.send,),
        onPressed: _yorumGonder,
        
      ),
    );
  }

 void _yorumGonder(){
       String aktifId=Provider.of<Yetkilendirme>(context,listen: false).aktifKullaniciID;
       FirestoreServis().yorumEkle(aktifId, widget.gonderi, tfYorum.text);
       tfYorum.clear();

     }
}
