import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("about_title".tr()),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 37, 192, 58),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.local_pharmacy,
                  size: 100,
                  color: Colors.green.shade400,
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  "Pharmas",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "about_mission_title".tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "about_mission_description".tr(),
                style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 30),
              Container(
                width: screenWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Text(
                  "about_footer".tr(),
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';

// class AboutPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("À propos de l'application"),
//         centerTitle: true,
//         backgroundColor: Color.fromARGB(255, 37, 192, 58),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Icon(
//                   Icons.local_pharmacy,
//                   size: 100,
//                   color: Colors.green.shade400,
//                 ),
//               ),
//               SizedBox(height: 30),
//               Center(
//                 child: Text(
//                   "Pharmas",
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green.shade800,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 "Notre mission",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.green.shade700,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 "Pharmas permet aux utilisateurs de trouver facilement les pharmacies ouvertes au Gabon et de se faire livrer via le service Pharmas. Après achat, le client peut récupérer en pharmacie ou choisir la livraison. Les pharmacies peuvent s’enregistrer pour recevoir des commandes et des clients via WhatsApp. Une application conçue par l'entrepreneur  Triphen Moussavou.",
//                 style: TextStyle(fontSize: 16, height: 1.5,fontWeight: FontWeight.bold,),
//                 textAlign: TextAlign.justify,
//               ),
//               SizedBox(height: 30),
//               Container(
//                 width: screenWidth,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.green.shade100),
//                 ),
//                 child: Text(
//                   "En connectant patients et pharmacies, Pharmas facilite l’accès rapide aux médicaments et à l’assistance pharmaceutique.",
//                   style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
