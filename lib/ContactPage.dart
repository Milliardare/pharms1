import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class ContactPage extends StatelessWidget {
  final String phoneNumber = "+24160088467";
  final String message = "Bonjour, j'aimerais avoir des informations concernant Pharmas.";

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("contact_title".tr()),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 37, 192, 58),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.contact_mail,
                  size: 100,
                  color: Colors.green.shade400,
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  "contact_us".tr(),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "contact_description".tr(),
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Icon(Icons.email, color: Colors.green.shade600),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "pharmasgabon@gmail.com",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: Text("whatsapp_button".tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final whatsappUrl =
                        'https://wa.me/${phoneNumber.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}';

                    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("whatsapp_error".tr())),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Text(
                    "contact_footer".tr(),
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
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
// import 'package:url_launcher/url_launcher.dart';

// class ContactPage extends StatelessWidget {
//   final String phoneNumber = "+24160088467"; // Numéro sans espaces ni tirets
//   final String message = "Bonjour, j'aimerais avoir des informations concernant Pharmas.";

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Contact"),
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
//                   Icons.contact_mail,
//                   size: 100,
//                   color: Colors.green.shade400,
//                 ),
//               ),
//               SizedBox(height: 30),
//               Center(
//                 child: Text(
//                   "Nous contacter",
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green.shade800,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 30),
//               Text(
//                 "Pour toute question ou assistance, n'hésitez pas à nous contacter via les moyens suivants :",
//                 style: TextStyle(
//                   fontSize: 16,
//                   height: 1.5,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.justify,
//               ),
//               SizedBox(height: 30),
//               Row(
//                 children: [
//                   Icon(Icons.email, color: Colors.green.shade600),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       "pharmasgabon@gmail.com",
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20),

//               /// 🔘 BOUTON WHATSAPP
//               Center(
//                 child: ElevatedButton.icon(
//                   icon: Icon(Icons.chat),
//                   label: Text("Contacter sur WhatsApp"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade600,
//                     minimumSize: Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () async {
//                     final whatsappUrl =
//                         'https://wa.me/${phoneNumber.replaceAll('+','')}?text=${Uri.encodeComponent(message)}';

//                     if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
//                       await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text("Impossible d'ouvrir WhatsApp.")),
//                       );
//                     }
//                   },
//                 ),
//               ),

//               SizedBox(height: 40),
//               Center(
//                 child: Container(
//                   width: screenWidth * 0.9,
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.green.shade100),
//                   ),
//                   child: Text(
//                     "Nous sommes là pour vous aider, 7j/7. Merci d'utiliser Pharmas.Toute l'equipe Pharmas vous remercie",
//                     style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

