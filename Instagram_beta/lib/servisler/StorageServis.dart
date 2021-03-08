import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
//resimlerdde eklenme adları farklı olmalı yoksa bir onceki silinir aynı olursa .bunu mumkun kılmak için uuid eklentisini yukluyoruz
//bu her resimin adını (idsini) farklı kılacak ve cakısma olmuyacaktır
class StorageServis{
  String resim_id;

  Reference _storage=FirebaseStorage.instance.ref();//ref ile depolama alanına ulasıyoruz
Future<String> gonderiResmiYukle(File resimDosyasi) async{
  resim_id=Uuid().v4();
  UploadTask yuklemeYoneticisi=  _storage.child("resimler/gonderiler/gonderi_$resim_id.jpg").putFile(resimDosyasi); //gonderi.jpg e gelen dosyayolunu aktardık
  //yukleme yoneticisi yukleme tamalandımı iptaledilmi devammı ediyor diye her sey var;
  TaskSnapshot snaphot= await  yuklemeYoneticisi;
   String yuklenenResimUrl= await snaphot.ref.getDownloadURL();
   return yuklenenResimUrl;

}
  Future<String> profilResmiYUkle(File resimDosyasi) async{
    resim_id=Uuid().v4();
    UploadTask yuklemeYoneticisi=  _storage.child("resimler/profil/profil_$resim_id.jpg").putFile(resimDosyasi); //gonderi.jpg e gelen dosyayolunu aktardık
    //yukleme yoneticisi yukleme tamalandımı iptaledilmi devammı ediyor diye her sey var;
    TaskSnapshot snaphot= await  yuklemeYoneticisi;
    String yuklenenResimUrl= await snaphot.ref.getDownloadURL();
    return yuklenenResimUrl;

  }
  /*şimdi bize silinmesi için dosya urlsi lazım ama biz bunu içn bir kayıt yapmadık ancak gnderiresimurl içinde oda cok uzun metin oldugu için
  biraz zor bu yuzden duzenlimetinleri kullanacaz RegExp ile metin içinde urlyi almaya calısacz
  \d jokerdi tum rakamları temsil eder orn 123 ben 1\d3 yazdım d 2 oldguunu anlıyor 123 getiriyor
  . ise tum karekterleri temsil eder orn abc ise a.c yazarsam . byi anlar ve abc cıkarır
  peki ya . getirlmesini istiyorsak a.c gibi bu sefer \a yazcaz

  * */
  //şimdi linkten dosya adını  getirecez
  gonderiResmiSil(String gonderiResimUrl){
    //. joker karekter idi gonderi_ dn .jpg kadar 36 karekter var biz 36. yapmıyacz .{36} defa nokta demek sonra gerçek . olacagı için \.jpg dedik
    //ama buda pratik degil .+ demek 1 veya daha fazlası demek oyuzden .+\jpg dedik
    RegExp arama=RegExp(r"gonderi_.+\.jpg");
    var eslesme=arama.firstMatch(gonderiResimUrl);//tumu degil sadece ilgili resimurl dedk
    String dosya_adi=eslesme[0];//aktardık
    if (dosya_adi.isNotEmpty){
      _storage.child("resimler/gonderiler/$dosya_adi").delete();//siliyoruz

    }

  }
}