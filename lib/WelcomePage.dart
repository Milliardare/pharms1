import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharmacietest1/AdminDashboardPage.dart';
import 'package:pharmacietest1/BoutiquePage.dart';
import 'package:easy_localization/easy_localization.dart';

// Pages
import 'login_page.dart';
import 'ClientPharmacyList.dart';
import 'LivreurPage.dart';
import 'ContactPage.dart';
import 'AboutPage.dart';
import 'PharmacyWelcomePage.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _floatAnim;
  String? userRole; // 👈 Ajout de la variable pour le rôle


  @override
  void initState() {
    super.initState();
  _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  _floatAnim = Tween<Offset>(
    begin: const Offset(0, 0),
    end: const Offset(0, 0.03),
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  _loadUserRole(); // 👈 On récupère le rôle ici
}

Future<void> _loadUserRole() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (doc.exists) {
    setState(() {
      userRole = doc['role'];
    });
  }

  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
  // 🔴 Attente du chargement du rôle
  if (userRole == null) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('loading'.tr()),
        backgroundColor: const Color.fromARGB(255, 37, 192, 58),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:  Text('welcome_title2'.tr()),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 37, 192, 58),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // --- BANNIÈRE ANIMÉE ----------------------------------------
              SizedBox(
                height: screenHeight * 0.45,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/servente.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SlideTransition(
                      position: _floatAnim,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Image.asset(
                          'assets/images/para.jpg',
                          height: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

               Text(
                'pharmas_gabon'.tr()
                ,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 34, 112, 54),
                ),
              ),
              const SizedBox(height: 8),
               Text(
               "welcome_subtitle3".tr() ,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
           

              const SizedBox(height: 35),


              const SizedBox(height: 35),

              _buildMainButton(
                icon: Icons.search,
                label: 'find_pharmacy'.tr(),
                color: const Color.fromARGB(255, 37, 192, 58),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ClientPharmacyList()));
                },
                screenWidth: screenWidth,
              ),
              
              const SizedBox(height: 35),

              _buildMainButton(
                icon: Icons.store,
                label: "shop".tr(),
                color: const Color.fromARGB(255, 64, 167, 226),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => BoutiquePage()));
                },
                screenWidth: screenWidth,
              ),
              
              const SizedBox(height: 20),

              _buildMainButton(
                icon: Icons.store,
                label: "pharmacy_space2".tr(),
                color: const Color(0xFFD4FCD5),
                textColor: Colors.black87,
                onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
               if (user == null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
               return;
                }

               final doc = await FirebaseFirestore.instance
               .collection('users')
             .doc(user.uid)
              .get();

             if (doc.exists && (doc['role'] == 'pharmacy' || doc['role'] == 'admin')) {
               Navigator.push(
             context,
             MaterialPageRoute(
             builder: (_) => PharmacyWelcomePage(pharmacyId: user.uid),
              ),
             );
             } else {
               _showDenied(context);
                }
              },


                screenWidth: screenWidth,
              ),
              const SizedBox(height: 20),

              _buildMainButton(
                icon: Icons.delivery_dining,
                label: "delivery_space2".tr(),
                color: const Color(0xFFD4FCD5),
                textColor: Colors.black87,
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LoginPage()));
                    return;
                  }

                  final doc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get();

                  if (doc.exists &&
                      (doc['role'] == 'livreur' || doc['role'] == 'admin')) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LivreurPage()));
                  } else {
                    _showDenied(context);
                  }
                },
                screenWidth: screenWidth,
              ),
              const SizedBox(height: 30),

              Row(
                
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    _buildOutlineButton(
      label: "about2".tr(),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => AboutPage()));
      },
    ),
    if (userRole == 'admin') ...[
      const SizedBox(width: 20),
      _buildOutlineButton(
        label: "more2".tr(),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => AdminDashboardPage()));
        },
      ),
    ],
    const SizedBox(width: 20),
    _buildOutlineButton(
      label: "contact_title".tr(),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ContactPage()));
      },
    ),
   
    
  ],
  

                
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    required double screenWidth,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: textColor, size: 26),
      label: Text(
        label,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(screenWidth * 0.85, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  void _showDenied(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:  Text("access_denied_title2".tr()),
        content:  Text("access_denied_msg2".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
