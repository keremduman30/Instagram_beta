import 'package:cloud_firestore/cloud_firestore.dart';

class Duyuru {
  final String id;
  final String aktiviteYapanId;
  final String aktiviteTipi;
  final String gonderiId;
  final String gonderiFoto;
  final String yorum;
  final Timestamp olusturulmaZamani;

  Duyuru({this.id, this.aktiviteYapanId, this.aktiviteTipi, this.gonderiId,
      this.gonderiFoto, this.yorum, this.olusturulmaZamani});

  factory Duyuru.dokumandanUret(DocumentSnapshot doc) {
    return Duyuru(
        id:doc.id,
      aktiviteYapanId:doc.data()["aktiviteYapanId"],
      aktiviteTipi:doc.data()["aktiviteTipi"],
      gonderiId:doc.data()["gonderiId"],
      gonderiFoto:doc.data()["gonderiFoto"],
      yorum:doc.data()["yorum"],
      olusturulmaZamani:doc.data()["olusturulmaZamani"],
    );
  }
}
