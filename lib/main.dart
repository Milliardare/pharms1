import 'package:flutter/foundation.dart'; // Pour détecter si on est sur le Web
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pharmacietest1/onboarding_page.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation EasyLocalization (charger les assets/lang)
  await EasyLocalization.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDb0EIp1RPAu4U5j2EqBoT_BDXWQ1lIX2I",
        authDomain: "pharmas-f8951.firebaseapp.com",
        projectId: "pharmas-f8951",
        storageBucket: "pharmas-f8951.firebasestorage.app",
        messagingSenderId: "9039114320",
        appId: "1:9039114320:web:1c63c9f1c1c9ed7287e155",
        databaseURL: "https://pharmas-f8951-default-rtdb.europe-west1.firebasedatabase.app",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('en')],
      path: 'assets/lang', // <- dossier où tu mets tes JSON
      fallbackLocale: const Locale('fr'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LivraisonPharma',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color.fromARGB(255, 204, 253, 164),
        fontFamily: 'Arial',
      ),
      // important : pour easy_localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      
      home: OnboardingPage(), // Ta page d'accueil
    );
  }
}







// import 'package:flutter/foundation.dart'; // Pour détecter si on est sur le Web
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:pharmacietest1/onboarding_page.dart';
// import 'package:easy_localization/easy_localization.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Initialisation EasyLocalization (charger les assets/lang)
//   await EasyLocalization.ensureInitialized();

//   if (kIsWeb) {
//     // 🔥 Initialisation Firebase pour le Web avec les bons paramètres
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: "AIzaSyDb0EIp1RPAu4U5j2EqBoT_BDXWQ1lIX2I",
//         authDomain: "pharmas-f8951.firebaseapp.com",
//         projectId: "pharmas-f8951",
//         storageBucket: "pharmas-f8951.firebasestorage.app",
//         messagingSenderId: "9039114320",
//         appId: "1:9039114320:web:1c63c9f1c1c9ed7287e155",
//         databaseURL: "https://pharmas-f8951-default-rtdb.europe-west1.firebasedatabase.app",
//       ),
//     );
//   } else {
//     // 🔥 Initialisation Firebase classique pour Android/iOS
//     await Firebase.initializeApp();
//   }

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'LivraisonPharma',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//         scaffoldBackgroundColor: const Color.fromARGB(255, 204, 253, 164),
//         fontFamily: 'Arial',
//       ),
//       home: OnboardingPage(), // Page d’accueil
//     );
//   }
// }




