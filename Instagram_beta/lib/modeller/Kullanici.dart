import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Kullanici {
  final String id;
  final String kullaniciAdi;
  final String fotoUrl;
  final String email;
  final String hakkinda;

  Kullanici(
      {@required this.id,
      this.kullaniciAdi,
      this.fotoUrl,
      this.email,
      this.hakkinda});

  factory Kullanici.firebasedenUret(User firebase_user) {
    return Kullanici(
      id: firebase_user.uid,
      kullaniciAdi: firebase_user.displayName.toString(),
      fotoUrl: firebase_user.photoURL,
      email: firebase_user.email,
    );
  }

  factory Kullanici.dokumandanUret(DocumentSnapshot doc) {
    return Kullanici(
      id: doc.id,
      kullaniciAdi: doc.data()["kullaniciAdi"],
      email: doc.data()["mail"],
      fotoUrl: doc.data()["fotoUrl"],
      hakkinda: doc.data()["hakkinda"],
    );
  }
}
