import 'package:cloud_firestore/cloud_firestore.dart';

class Gonderi {
  final String id;
  final String gonderiResimUrl;
  final String aciklama;
  final String yayinlayanID;
  final int begeniSayisi;
  final String konum;

  Gonderi({this.id, this.gonderiResimUrl, this.aciklama, this.yayinlayanID,
      this.begeniSayisi, this.konum});

  factory Gonderi.dokumandanUret(DocumentSnapshot doc) {
    return Gonderi(
      id: doc.id,
      gonderiResimUrl: doc.data()["gonderiResimUrl"],
      aciklama: doc.data()["aciklama"],
      yayinlayanID: doc.data()["yayinlayanID"],
      begeniSayisi: doc.data()["begeniSayisi"],
      konum: doc.data()["konum"]
    );
  }
}
