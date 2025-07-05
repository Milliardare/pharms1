import 'package:flutter/material.dart';
import 'WelcomePage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.5,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/pharmasfemme.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            FadeInUp(
              duration: Duration(milliseconds: 800),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'welcome_title'.tr(),
                      style: GoogleFonts.lato(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 28, 150, 44),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'welcome_subtitle'.tr(),
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    SlideInUp(
                      duration: Duration(milliseconds: 1000),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 37, 192, 58),
                          padding: EdgeInsets.symmetric(horizontal: 60, vertical: 25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          final user = FirebaseAuth.instance.currentUser;

                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => WelcomePage()),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginPage()),
                            );
                          }
                        },
                        child: Text(
                          'enter_button'.tr(),
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    TextButton(
                      onPressed: () {
                        if (context.locale.languageCode == 'fr') {
                          context.setLocale(Locale('en'));
                        } else {
                          context.setLocale(Locale('fr'));
                        }
                      },
                      child: Image.asset(
                        context.locale.languageCode == 'fr'
                            ? 'assets/images/en_flag.jpg'
                            : 'assets/images/fr_flag.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'WelcomePage.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animate_do/animate_do.dart';
// import 'login_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:easy_localization/easy_localization.dart';

// class OnboardingPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: 
//       Column(
//         children: [
//           Container(
//             height: screenHeight * 0.5,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/images/pharmasfemme.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Expanded(
//             child: FadeInUp(
//               duration: Duration(milliseconds: 800),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     Column(
//                       children: [
//                         Text(
//                           'welcome_title'.tr(),
//                           style: GoogleFonts.lato(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                             color: const Color.fromARGB(255, 28, 150, 44),
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           'welcome_subtitle'.tr(),
//                           style: GoogleFonts.lato(
//                             fontSize: 16,
//                             color: Colors.grey[700],
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 40),

//                     SlideInUp(
//                       duration: Duration(milliseconds: 1000),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color.fromARGB(255, 37, 192, 58),
//                           padding: EdgeInsets.symmetric(horizontal: 60, vertical: 25),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                         ),
//                         onPressed: () {
//                           final user = FirebaseAuth.instance.currentUser;

//                           if (user != null) {
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(builder: (_) => WelcomePage()),
//                             );
//                           } else {
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(builder: (_) => LoginPage()),
//                             );
//                           }
//                         },
//                         child: Text(
//                           'enter_button'.tr(),
//                           style: TextStyle(fontSize: 18, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 30),
//                     TextButton(
//                    onPressed: () {
//                      if (context.locale.languageCode == 'fr') {
//                      context.setLocale(Locale('en'));
//                        } else {
//                         context.setLocale(Locale('fr'));
//                          }
//                          },
//                           child: Image.asset(
//                           context.locale.languageCode == 'fr'
//                               ? 'assets/images/en_flag.jpg' // on montre le drapeau anglais si on est en français (le bouton sert à passer en anglais)
//                           : 'assets/images/fr_flag.png', // inversement
//                         width: 40,
//                           height: 40,
//                           ),
//                             ),
//                     // SizedBox(height: 30),
//                     // TextButton(
//                     //   onPressed: () {
//                     //     if (context.locale.languageCode == 'fr') {
//                     //       context.setLocale(Locale('en'));
//                     //     } else {
//                     //       context.setLocale(Locale('fr'));
//                     //     }
//                     //   },
//                     //   child: Text(
//                     //     'change_language'.tr(),
//                     //     style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'WelcomePage.dart'; // change selon ta route réelle
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animate_do/animate_do.dart';
// import 'login_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:easy_localization/easy_localization.dart'; 


// class OnboardingPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // IMAGE EN HAUT
//           Container(
//             height: screenHeight * 0.5,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/images/pharmasfemme.png'), // ton image ici
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           // TEXTE DE BIENVENUE AVEC ANIMATION
//           Expanded(
//             child: FadeInUp(
//               duration: Duration(milliseconds: 800),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       children: [
//                         Text(
//                           'Bienvenue sur Pharmas',
//                           style: GoogleFonts.lato(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
                           
//                             color: const Color.fromARGB(255, 28, 150, 44),
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           'Achat de médicaments dans toutes les pharmacies .Faite vous livrer ou  recuperer en pharmacie',
//                           style: GoogleFonts.lato(
//                             fontSize: 16,
//                             color: Colors.grey[700],
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 40),

//                     // BOUTON ENTRER AVEC ANIMATION
//                     SlideInUp(
//                       duration: Duration(milliseconds: 1000),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color.fromARGB(255, 37, 192, 58),
//                           padding: EdgeInsets.symmetric(horizontal: 60, vertical: 25),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                         ),
//                         onPressed: () {

//                             final user = FirebaseAuth.instance.currentUser;

//                                       if (user != null) {
//     // L'utilisateur est déjà connecté
//                                        Navigator.pushReplacement(
//                                         context,
//                                     MaterialPageRoute(builder: (_) => WelcomePage()),
//                                               );
//                                        } else {
//                                                     // L'utilisateur n'est pas connecté
//                                      Navigator.pushReplacement(
//                                           context,
//                                     MaterialPageRoute(builder: (_) => LoginPage()),
//                                              );
//                                            }
                          
//                           // Navigator.pushReplacement(
//                           //   context,
//                           //   MaterialPageRoute(builder: (_) => WelcomePage()),
//                           // );
//                         },
//                         child: Text(
//                           'Entrer',
//                           style: TextStyle(fontSize: 18, color: Colors.white),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
