import 'package:cloud_firestore/cloud_firestore.dart';

class Yorum{
  final String id;
  final String icerik;
  final String yayinlayanId;
  final String olusturulmaZamani;

  Yorum({this.id, this.icerik, this.yayinlayanId, this.olusturulmaZamani});
  factory Yorum.dokumandanUret(DocumentSnapshot doc){
    return Yorum(
      id: doc.id,
      icerik: doc.data()["icerik"],
      yayinlayanId: doc.data()["yayinlayanId"],
      olusturulmaZamani: doc.data()["olusturulmaZamani"].toString()
    );

  }
}
