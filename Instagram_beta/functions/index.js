const functions = require("firebase-functions");//fonksiyonları nasıl yazacagımızı belirler
//cloud fonksiyonlarımızı bu dosya içinde yazıcaz
const admin=require("firebase-adimn");//firebase verilerimzii yonetmemizi saglar ekleme guncelle vb
admin.initializeApp();
functions.firestore.doc('deneme/{doc-id}').onCreate((snapshot,context)=>{
console.log("deneme koleksiyonua kayıt girildi");
});
