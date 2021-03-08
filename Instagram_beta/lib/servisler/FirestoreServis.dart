import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instegram_beta/modeller/Duyuru.dart';
import 'package:instegram_beta/modeller/Gonderi.dart';
import 'package:instegram_beta/modeller/Kullanici.dart';
import 'package:instegram_beta/sayfalar/Duyurular.dart';
import 'package:instegram_beta/servisler/StorageServis.dart';

class FirestoreServis{
  final FirebaseFirestore   _firestore=FirebaseFirestore.instance;
  final DateTime zaman=DateTime.now();//kayıt yapaılacgı tarihi almak için
  //kullanıcı bilgilerini firestore kaydetme

 Future<void> kullanaciOlustur({String id,String mail,String kullaniciAdi,String fotoUrl=""})async{

   await _firestore.collection("kullanicilar").doc(id).set({
      "kullaniciAdi":kullaniciAdi,
      "mail":mail,
      "fotoUrl":fotoUrl,
      "hakkinda":"",
      "olusturulmaZamani":zaman,
    });

  }
  Future<Kullanici> kullaniciGetir(id) async{
  DocumentSnapshot doc=await _firestore.collection("kullanicilar").doc(id).get();
  if (doc.exists){//eger boyle bir dokuman varsa kayıt yapmıs yan ilk defa girmiyo faha oncede girmis
 Kullanici kullanici= Kullanici.dokumandanUret(doc);
 return kullanici;
  }
    return null;

  }
 void kullaniciGuncelle({String kullnaiciId,String kullaniciAdi,String fotoUrl="",String hakkinda}){
      _firestore.collection("kullanicilar").doc(kullnaiciId).update({
        "kullaniciAdi":kullaniciAdi,
        "hakkinda":hakkinda,
        "fotoUrl":fotoUrl
      });
  }
 Future<List<Kullanici>> kullaniciAra(String arananKisi)async{
   //şimdi isEqualTo olursa kullanıcı adı tam girerse cıkacak ama sen isGreaterThanOrEqualTo eşit veya buuyk olanaları getir dedik
    QuerySnapshot snapshot=    await _firestore.collection("kullanicilar").where("kullaniciAdi",isGreaterThanOrEqualTo: arananKisi).get();
   List<Kullanici> kulaniciList= snapshot.docs.map((doc) => Kullanici.dokumandanUret(doc)).toList();
    return kulaniciList;

  }
 void takipEt(String aktifId,String profilSahibiID){
   _firestore.collection("takipciler").doc(profilSahibiID).collection("kullanicininTakipcileri").doc(aktifId).set({});
   _firestore.collection("takipedilenler").doc(aktifId).collection("kullanicininTakipleri").doc(profilSahibiID).set({});

   //duyuruekliyelim
   duyuruEkle(
     aktiviteTipi: "takip",
     aktiviteYapanId: aktifId,
     profilSahibiId: profilSahibiID,//burda gonderi olmayacagı için gonderi ekletmedik ki foto onları gostermiyeilm
     //bunun için gonderide gonderi1=null dedik
   );

  }
  void takiptenCik(String aktifId,String profilSahibiID){
    _firestore.collection("takipciler").doc(profilSahibiID).collection("kullanicininTakipcileri").doc(aktifId).get().then((DocumentSnapshot snapshot){
        if (snapshot.exists) {//eger boyle bir dokuman varsa
            snapshot.reference.delete();
        }  
    });
    _firestore.collection("takipedilenler").doc(aktifId).collection("kullanicininTakipleri").doc(profilSahibiID).get().then((value){
      if (value.exists) {
        value.reference.delete();
      }
    });


  }
  Future<bool> takipKontrol(String aktifId,String profilSahibiID) async{//aktif kullanıcı profilsahibinin i takip ettigi anda bizim haberimiz olmalı
   DocumentSnapshot doc= await _firestore.collection("takipedilenler").doc(aktifId).collection("kullanicininTakipleri").doc(profilSahibiID).get();
    if (doc.exists){
      return true;

    }
    return false;

  }
Future<int>  takipciSayisi(String id) async{
 QuerySnapshot snapshot=  await   _firestore.collection("takipciler").doc(id).collection("kullanicininTakipcileri").get();
  return  snapshot.docs.length;
  }
  Future<int>  takipEdilenSayisi(String id) async{
    QuerySnapshot snapshot=  await   _firestore.collection("takipedilenler").doc(id).collection("kullanicininTakipleri").get();
    return  snapshot.docs.length;
  }
  void duyuruEkle({String  aktiviteYapanId,String profilSahibiId,String aktiviteTipi,String yorum,Gonderi gonderi}){
   if (aktiviteYapanId==profilSahibiId){//kullanıcı kendi gonderisinde etkileşim yaparsa duyuru gelmesin diyecez
     return ;//duyuru yapmadan cıktık
     
   }  
   _firestore.collection("duyurular").doc(profilSahibiId).collection("kullanicininDuyurulari").add({
     "aktiviteYapanId":aktiviteYapanId,
     "aktiviteTipi":aktiviteTipi,
     "gonderiId":gonderi !=null ?gonderi.id : null,
      "gonderiFoto":gonderi!=null ? gonderi.gonderiResimUrl: null,
     "yorum":yorum,
     "olusturulmaZamani":zaman,
   });

  }
 Future<List<Duyuru>> duyurulariGetir(String profilId) async{
   //ilk 20 duyuruyu getirecez
  QuerySnapshot snapshot= await  _firestore.collection("duyurular").doc(profilId).collection("kullanicininDuyurulari").orderBy("olusturulmaZamani",descending: true).limit(25).get();
    List<Duyuru> duyuruList=snapshot.docs.map((doc) =>Duyuru.dokumandanUret(doc)).toList();
    return duyuruList;

  }
 Future<void> gonderiOlustur({gonderiResimUrl,aciklama,yayinlayanId,konum})async{
  await  _firestore.collection("gonderi").doc(yayinlayanId).collection("kullaniciGonderileri").add({
     "gonderiResimUrl":gonderiResimUrl,
     "aciklama":aciklama,
     "yayinlayanID":yayinlayanId,
     "begeniSayisi":0,
     "konum":konum,
     "olusturulmaZamani":zaman
   });

  }
  Future<List<Gonderi>> gonderileriGetir(String kullanici_id)async {
    QuerySnapshot snapshot=  await  _firestore.collection("gonderi").doc(kullanici_id).collection("kullaniciGonderileri").orderBy("olusturulmaZamani",descending: true).get();
   List<Gonderi> gonderi_list= snapshot.docs.map((doc) => Gonderi.dokumandanUret(doc)).toList();
   return gonderi_list;
  }
 Future<void> gonderileriSil(String aktifKullaniciId,Gonderi gonderi)async{
    _firestore.collection("gonderi").doc(aktifKullaniciId).collection("kullaniciGonderileri").doc(gonderi.id).get().then((doc){
      if (doc.exists) {//varmı
        doc.reference.delete();

      }
    });
    //gonderiye ait yorum ve begenileri desiliyoruz
 QuerySnapshot yorumlarsnaphot= await  _firestore.collection("yorumlar").doc(gonderi.id).collection("gonderiYorumlari").get();
 yorumlarsnaphot.docs.forEach((doc) {
   if (doc.exists) {//varmı
     doc.reference.delete();
   }
 });
 //silinen yorumlaara ait duyurularıda silelim.ama burda dikkat edilmesi gereken sey gonderiid gonderiid eşit olması lzım sart yapnii
 QuerySnapshot snapshot=   await  _firestore.collection("duyurular").doc(gonderi.yayinlayanID).collection("kullanicininDuyurulari").where("gonderiId",isEqualTo: gonderi.id).get();
    snapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //silinen gonderinin resmini storage servisinden de silmemmiz lazım
      StorageServis().gonderiResmiSil(gonderi.gonderiResimUrl);




  }
  Future<Gonderi>tekliGonderiGetir(String gonderiID,String gonderiSahibiId)async{
    DocumentSnapshot doc= await _firestore.collection("gonderi").doc(gonderiSahibiId).collection("kullaniciGonderileri").doc(gonderiID).get();
    Gonderi gonderi=Gonderi.dokumandanUret(doc);
    return gonderi;
  }


 Future<void> gonderiBegen(Gonderi gonderi,String aktif_kullanici_id)async{
    DocumentReference docRef=await _firestore.collection("gonderi").doc(gonderi.yayinlayanID).collection("kullaniciGonderileri").doc(gonderi.id);
  DocumentSnapshot doc=await docRef.get();
   if (doc.exists){//boyle bir dokuma varsa
   Gonderi gonderii=  Gonderi.dokumandanUret(doc);
   int yeniBegeniSayisi=   gonderii.begeniSayisi + 1;
   await docRef.update({
     "begeniSayisi":yeniBegeniSayisi
   });

   }
    //kullanıcı - gonderi ilişikisini koleksiyona ekleme
    _firestore.collection("begeniler").doc(gonderi.id).collection("gonderiBegenileri").doc(aktif_kullanici_id).set({});//içine bi dokuman elemanları olmuyacak
   //begeni olustuktan hemen sonra gonderiSAhibine iletiyoruz
   duyuruEkle(
     aktiviteYapanId:aktif_kullanici_id,
     profilSahibiId:gonderi.yayinlayanID,
     aktiviteTipi:"begeni",
     gonderi:gonderi
   );


 }
  Future<void> gonderiBegeniKaldir(Gonderi gonderi,String aktif_kullanici_id)async{
    DocumentReference docRef=await _firestore.collection("gonderi").doc(gonderi.yayinlayanID).collection("kullaniciGonderileri").doc(gonderi.id);
    DocumentSnapshot doc=await docRef.get();
    if (doc.exists){//boyle bir dokuma varsa
      Gonderi gonderii=  Gonderi.dokumandanUret(doc);
      int yeniBegeniSayisi=   gonderii.begeniSayisi - 1;
      await docRef.update({
        "begeniSayisi":yeniBegeniSayisi
      });

    }
    //eger kaldırılırsa da gonderi begenilerinden silmemiz lazım
  DocumentSnapshot docbegeni= await _firestore.collection("begeniler").doc(gonderi.id).collection("gonderiBegenileri").doc(aktif_kullanici_id).get();
    if (docbegeni.exists){
      docbegeni.reference.delete();
    }



  }
  Future<bool> begeniVarmi(Gonderi gonderi,String aktif_kullanici_id) async{
    DocumentSnapshot docbegeni= await _firestore.collection("begeniler").doc(gonderi.id).collection("gonderiBegenileri").doc(aktif_kullanici_id).get();
      if (docbegeni.exists){
        return true;

      }
      else{
        return false;
      }
  }
  Stream<QuerySnapshot> yorumlariGetir(String gonderiId){//yorunları canlı olarak anlık almak istedigimiz için get degil snaphot yaptık
    return   _firestore.collection("yorumlar").doc(gonderiId).collection("gonderiYorumlari").orderBy("olusturulmaZamani",descending: true).snapshots();

   }
   yorumEkle(String aktifKullaniciId,Gonderi gonderi,String icerik){//yorum eklerken beklemiyoz
   _firestore.collection("yorumlar").doc(gonderi.id).collection("gonderiYorumlari").add({
     "icerik":icerik,
     "yayınlayanId":aktifKullaniciId,
     "olusturulmaZamani":zaman
   });
   duyuruEkle(
     aktiviteTipi: "yorum",
     aktiviteYapanId: aktifKullaniciId,
     gonderi: gonderi,
     profilSahibiId: gonderi.yayinlayanID,
     yorum: icerik
   );

   }






}