import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instegram_beta/modeller/Kullanici.dart';

class Yetkilendirme{
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;
   String aktifKullaniciID;

  Kullanici _kullaniciOlustur(User firebase_user){
    return firebase_user==null ? null :  Kullanici.firebasedenUret(firebase_user);
  }
 Stream<Kullanici> get durumTakipcisi{
    return _firebaseAuth.authStateChanges().map(_kullaniciOlustur);
  }
  //kayıt
 Future<Kullanici> mailIleKayit(String eposta,String parola) async{
   var girisKarti=await _firebaseAuth.createUserWithEmailAndPassword(email: eposta, password: parola);
  return _kullaniciOlustur(girisKarti.user);
  }
  //eger giris yapmıs ise yani kayıtlı ise mail ve sifresiyle giris yapabilecek
  Future<Kullanici> mailIleGiris(String eposta,String parola) async{
    var girisKarti=await _firebaseAuth.signInWithEmailAndPassword(email: eposta, password: parola);
    return _kullaniciOlustur(girisKarti.user);
  }

  //cıkıs işlemleri
 Future<void> cikisYap(){
    return _firebaseAuth.signOut();
  }
  Future<void> sifremiSifirla(String eposta) async{
   await _firebaseAuth.sendPasswordResetEmail(email: eposta);
  }
  //googel ile giriş
  Future<Kullanici> googleIleGiris() async{
    GoogleSignInAccount google_hesabi= await GoogleSignIn().signIn();//once izin
    //sonra google yetki kartı almamız laızm
    GoogleSignInAuthentication googleYetkiKartim=await google_hesabi.authentication;
    //sonra belgeyi aliyoz
    OAuthCredential sifresizGirisBelgesi=GoogleAuthProvider.credential(idToken: googleYetkiKartim.idToken,accessToken: googleYetkiKartim.accessToken);
    //giris karti
    UserCredential giris_karti=  await _firebaseAuth.signInWithCredential(sifresizGirisBelgesi);
    return _kullaniciOlustur(giris_karti.user);
  }

}