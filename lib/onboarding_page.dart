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
                      //  const SizedBox(height: 20),

                      // Image.asset(
                      // 'assets/images/pays.png',
                      // height: 60,
                      // fit: BoxFit.contain,
                      //   ),
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

