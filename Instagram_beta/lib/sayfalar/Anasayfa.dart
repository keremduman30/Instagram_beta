import 'package:flutter/material.dart';
import 'package:instegram_beta/sayfalar/Akis.dart';
import 'package:instegram_beta/sayfalar/Ara.dart';
import 'package:instegram_beta/sayfalar/Duyurular.dart';
import 'package:instegram_beta/sayfalar/Profil.dart';
import 'package:instegram_beta/sayfalar/Yukle.dart';
import 'package:instegram_beta/servisler/Yetkilendirme.dart';
import 'package:provider/provider.dart';
//normalde bottom navigation barda biz sayfaları liste aktarıp bodye dizi halinde yollamıstık ama artık page view kullanacaz bodyde
//page zaten sayfa demek.bunun için pagecontroller olması lazım ve botom ontapbına guncel sayfa noyu bilfirmek lazım
//ama bu eger sayfa ile ilişki bitmisse dispose da kapatılması lazım  kumandayı dispose yapıyozcunku kasmaya neden olabilir
//dikkat super.disposedan once yazılmalıdır
class Anasayfa extends StatefulWidget {
  @override
  _AnasayfaState createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  int aktifNo=0;
  PageController sayfa_kumandasi=new PageController();
  @override
  void initState() {
    super.initState();
    sayfa_kumandasi;//baslar baslaamaz aktif edioz
  }
  @override
  void dispose() {
    sayfa_kumandasi.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    String aktifKullanciID=Provider.of<Yetkilendirme>(context).aktifKullaniciID;

    return Scaffold(
      body:PageView(
        onPageChanged: (kaydirilanSayfaNo){
          setState(() {
            aktifNo=kaydirilanSayfaNo;
          });
        },
        controller: sayfa_kumandasi,
        children: [
          Akis(),
          Ara(),
          Yukle(),
          Duyurular(),
          Profil(poriflSahibiId: aktifKullanciID,),
        ],

      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        currentIndex: aktifNo,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Akış"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Keşfet"),
          BottomNavigationBarItem(icon: Icon(Icons.file_upload), label: "Yükle "),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Duyurular"),
          BottomNavigationBarItem(icon: Icon(Icons.person ), label: "Profil"),

        ],
        onTap: (secilenindex){
          //bu sadece tıklanma eger kaydrıma yaparsan alt menu değişmiyecek parmak ile kaydırma pageview içindde onpagechanged dir
          setState(() {
          //  aktifNo=secilenindex; //buna artık gerek yok pageview deki onpagedhanged e zaten dedik
            sayfa_kumandasi.jumpToPage(secilenindex);//jump atla demek hangi sayfaya atlıyayım diyor bizde sralama gore aktifnoyaptık
          });
        },
      ),
    );
  }
}
