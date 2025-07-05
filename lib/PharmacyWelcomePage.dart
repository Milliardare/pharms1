import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:easy_localization/easy_localization.dart';
import 'EditPharmacyProfilePage2.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;

class PharmacyWelcomePage extends StatelessWidget {
  final String pharmacyId;

  const PharmacyWelcomePage({super.key, required this.pharmacyId});

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossible d’ouvrir le lien $url';
    }
  }

  Future<void> _downloadPdfWithPermission(
    BuildContext context, String assetPath, String fileName) async {
  try {
    if (kIsWeb) {
      await openUrl(assetPath);
      return;
    }

    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();

    Directory? directory;

    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permission refusée")),
          );
          return;
        }
      }
      directory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      directory = await getDownloadsDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'accéder au dossier Téléchargements")),
        );
        return;
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);

    // ✅ Ouvre automatiquement le fichier sur Android/iOS
    if (Platform.isAndroid || Platform.isIOS) {
      await OpenFilex.open(file.path);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ "$fileName" enregistré dans ${directory.path}')),
    );
  } catch (e) {
    debugPrint('Erreur téléchargement PDF : $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Erreur lors du téléchargement")),
    );
  }
    //   BuildContext context, String assetPath, String fileName) async {
    // try {
    //   if (kIsWeb) {
    //     // Sur le web, on ouvre directement le PDF dans un nouvel onglet
    //     await openUrl(assetPath);
    //     return;
    //   }

    //   final byteData = await rootBundle.load(assetPath);
    //   final bytes = byteData.buffer.asUint8List();

    //   Directory? directory;

    //   if (Platform.isAndroid) {
    //     var status = await Permission.storage.status;
    //     if (!status.isGranted) {
    //       status = await Permission.storage.request();
    //       if (!status.isGranted) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           const SnackBar(content: Text("Permission refusée")),
    //         );
    //         return;
    //       }
    //     }
    //     directory = Directory('/storage/emulated/0/Download');
    //   } else if (Platform.isIOS) {
    //     directory = await getApplicationDocumentsDirectory();
    //   } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    //     directory = await getDownloadsDirectory();
    //     if (directory == null) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text("Impossible d'accéder au dossier Téléchargements")),
    //       );
    //       return;
    //     }
    //   } else {
    //     directory = await getApplicationDocumentsDirectory();
    //   }

    //   if (!(await directory.exists())) {
    //     await directory.create(recursive: true);
    //   }

    //   final file = File('${directory.path}/$fileName');
    //   await file.writeAsBytes(bytes);

    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('✅ "$fileName" enregistré dans ${directory.path}')),
    //   );
    // } catch (e) {
    //   debugPrint('Erreur téléchargement PDF : $e');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("❌ Erreur lors du téléchargement")),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("pharmacy_space".tr()),
        backgroundColor: const Color.fromARGB(255, 102, 248, 109),
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade200,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade400.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_pharmacy,
                  size: 70,
                  color: Color.fromARGB(255, 88, 221, 97),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'welcome_pharmacy'.tr(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  shadows: [
                    Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(1, 1)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit, size: 26),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    "edit_info".tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 87, 221, 94),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                  shadowColor: const Color.fromARGB(255, 100, 223, 108).withOpacity(0.4),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditPharmacyProfilePage2()),
                  );
                },
              ),
              const SizedBox(height: 50),
              Text(
                "download_poster".tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _downloadPdfWithPermission(context, 'assets/pdfs/affiche_fr.pdf', 'affiche_fr.pdf');
                    },
                    child: Column(
                      children: [
                        Image.asset('assets/images/affiche_fr.png', width: 100, height: 140, fit: BoxFit.cover),
                        const SizedBox(height: 8),
                        const Text("Français", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      _downloadPdfWithPermission(context, 'assets/pdfs/affiche_en.pdf', 'affiche_en.pdf');
                    },
                    child: Column(
                      children: [
                        Image.asset('assets/images/affiche_en.png', width: 100, height: 140, fit: BoxFit.cover),
                        const SizedBox(height: 8),
                        const Text("English", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:easy_localization/easy_localization.dart';
// import 'EditPharmacyProfilePage2.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// // ignore: avoid_web_libraries_in_flutter
// // import 'dart:html' as html;

// class PharmacyWelcomePage extends StatelessWidget {
//   final String pharmacyId;

//   const PharmacyWelcomePage({super.key, required this.pharmacyId});

//   Future<void> _downloadPdfWithPermission(
//       BuildContext context, String assetPath, String fileName) async {
//     try {
//       if (kIsWeb) {
//           // Web : on ouvre directement l'URL du PDF dans un nouvel onglet/navigateur
//   await openUrl(assetPath);
//   return;
//         // Web : on ouvre directement l'URL du PDF
//         // html.window.open(assetPath, '_blank');
//         // return;
//       }

//       final byteData = await rootBundle.load(assetPath);
//       final bytes = byteData.buffer.asUint8List();

//       Directory? directory;

//       if (Platform.isAndroid) {
//         var status = await Permission.storage.status;
//         if (!status.isGranted) {
//           status = await Permission.storage.request();
//           if (!status.isGranted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Permission refusée")),
//             );
//             return;
//           }
//         }
//         directory = Directory('/storage/emulated/0/Download');
//       } else if (Platform.isIOS) {
//         directory = await getApplicationDocumentsDirectory();
//       } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
//         directory = await getDownloadsDirectory();
//         if (directory == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Impossible d'accéder au dossier Téléchargements")),
//           );
//           return;
//         }
//       } else {
//         directory = await getApplicationDocumentsDirectory();
//       }

//       if (!(await directory.exists())) {
//         await directory.create(recursive: true);
//       }

//       final file = File('${directory.path}/$fileName');
//       await file.writeAsBytes(bytes);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('✅ "$fileName" enregistré dans ${directory.path}')),
//       );
//     } catch (e) {
//       debugPrint('Erreur téléchargement PDF : $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("❌ Erreur lors du téléchargement")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("pharmacy_space".tr()),
//         backgroundColor: const Color.fromARGB(255, 102, 248, 109),
//         centerTitle: true,
//         elevation: 4,
//       ),
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.green.shade100, Colors.green.shade300],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 50),
//               Container(
//                 height: 120,
//                 width: 120,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.green.shade200,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.green.shade400.withOpacity(0.4),
//                       blurRadius: 12,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.local_pharmacy,
//                   size: 70,
//                   color: Color.fromARGB(255, 88, 221, 97),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               Text(
//                 'welcome_pharmacy'.tr(),
//                 style: const TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green,
//                   shadows: [
//                     Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(1, 1)),
//                   ],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 40),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.edit, size: 26),
//                 label: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   child: Text(
//                     "edit_info".tr(),
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 87, 221, 94),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                   elevation: 8,
//                   shadowColor: const Color.fromARGB(255, 100, 223, 108).withOpacity(0.4),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => EditPharmacyProfilePage2()),
//                   );
//                 },
//               ),
//               const SizedBox(height: 50),
//               Text(
//                 "download_poster".tr(),
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green.shade900,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       _downloadPdfWithPermission(context, 'assets/pdfs/affiche_fr.pdf', 'affiche_fr.pdf');
//                     },
//                     child: Column(
//                       children: [
//                         Image.asset('assets/images/affiche_fr.png', width: 100, height: 140, fit: BoxFit.cover),
//                         const SizedBox(height: 8),
//                         const Text("Français", style: TextStyle(fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 30),
//                   GestureDetector(
//                     onTap: () {
//                       _downloadPdfWithPermission(context, 'assets/pdfs/affiche_en.pdf', 'affiche_en.pdf');
//                     },
//                     child: Column(
//                       children: [
//                         Image.asset('assets/images/affiche_en.png', width: 100, height: 140, fit: BoxFit.cover),
//                         const SizedBox(height: 8),
//                         const Text("English", style: TextStyle(fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 50),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }









// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'EditPharmacyProfilePage2.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file_plus/open_file_plus.dart';
// import 'dart:io';

// class PharmacyWelcomePage extends StatelessWidget {
//   final String pharmacyId;

//   const PharmacyWelcomePage({super.key, required this.pharmacyId});

//   Future<void> _openPdfFromAssets(BuildContext context, String assetPath, String fileName) async {
//     final byteData = await rootBundle.load(assetPath);
//     final file = File('${(await getTemporaryDirectory()).path}/$fileName');
//     await file.writeAsBytes(byteData.buffer.asUint8List());
//     OpenFile.open(file.path);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("pharmacy_space".tr()),
//         backgroundColor: const Color.fromARGB(255, 102, 248, 109),
//         centerTitle: true,
//         elevation: 4,
//       ),
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.green.shade100, Colors.green.shade300],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 50),

//               Container(
//                 height: 120,
//                 width: 120,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.green.shade200,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.green.shade400.withOpacity(0.4),
//                       blurRadius: 12,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.local_pharmacy,
//                   size: 70,
//                   color: Color.fromARGB(255, 88, 221, 97),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               Text(
//                 'welcome_pharmacy'.tr(),
//                 style: const TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green,
//                   shadows: [
//                     Shadow(
//                       blurRadius: 4,
//                       color: Colors.black26,
//                       offset: Offset(1, 1),
//                     ),
//                   ],
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: 40),

//               ElevatedButton.icon(
//                 icon: const Icon(Icons.edit, size: 26),
//                 label: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   child: Text(
//                     "edit_info".tr(),
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 87, 221, 94),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   elevation: 8,
//                   shadowColor: const Color.fromARGB(255, 100, 223, 108).withOpacity(0.4),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => EditPharmacyProfilePage2(),
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 50),

//               Text(
//               "download_poster".tr(),
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green.shade900,
//                 ),
//               ),

//               const SizedBox(height: 20),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       _openPdfFromAssets(context, 'assets/pdfs/affiche_fr.pdf', 'affiche_fr.pdf');
//                     },
//                     child: Column(
//                       children: [
//                         Image.asset(
//                           'assets/images/affiche_fr.png',
//                           width: 100,
//                           height: 140,
//                           fit: BoxFit.cover,
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           "Français",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 30),
//                   GestureDetector(
//                     onTap: () {
//                       _openPdfFromAssets(context, 'assets/pdfs/affiche_en.pdf', 'affiche_en.pdf');
//                     },
//                     child: Column(
//                       children: [
//                         Image.asset(
//                           'assets/images/affiche_en.png',
//                           width: 100,
//                           height: 140,
//                           fit: BoxFit.cover,
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           "English",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 50),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'EditPharmacyProfilePage2.dart';

// class PharmacyWelcomePage extends StatelessWidget {
//   final String pharmacyId;

//   const PharmacyWelcomePage({super.key, required this.pharmacyId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("pharmacy_space".tr()),
//         backgroundColor: const Color.fromARGB(255, 102, 248, 109),
//         centerTitle: true,
//         elevation: 4,
//       ),
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.green.shade100, Colors.green.shade300],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               height: 120,
//               width: 120,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.green.shade200,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.green.shade400.withOpacity(0.4),
//                     blurRadius: 12,
//                     offset: Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 Icons.local_pharmacy,
//                 size: 70,
//                 color: const Color.fromARGB(255, 88, 221, 97),
//               ),
//             ),

//             const SizedBox(height: 30),

//             Text(
//               'welcome_pharmacy'.tr(),
//               style: const TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//                 shadows: [
//                   Shadow(
//                     blurRadius: 4,
//                     color: Colors.black26,
//                     offset: Offset(1, 1),
//                   ),
//                 ],
//               ),
//               textAlign: TextAlign.center,
//             ),

//             const SizedBox(height: 40),

//             ElevatedButton.icon(
//               icon: const Icon(Icons.edit, size: 26),
//               label: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 child: Text(
//                   "edit_info".tr(),
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color.fromARGB(255, 87, 221, 94),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 elevation: 8,
//                 shadowColor: const Color.fromARGB(255, 100, 223, 108).withOpacity(0.4),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => EditPharmacyProfilePage2(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'EditPharmacyProfilePage2.dart';

// class PharmacyWelcomePage extends StatelessWidget {
//   final String pharmacyId;

//   const PharmacyWelcomePage({super.key, required this.pharmacyId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Espace Pharmacie"),
//         backgroundColor: const Color.fromARGB(255, 102, 248, 109),
//         centerTitle: true,
//         elevation: 4,
//       ),
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.green.shade100, Colors.green.shade300],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Placeholder logo (tu peux mettre un Image.asset ou NetworkImage)
//             Container(
//               height: 120,
//               width: 120,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.green.shade200,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.green.shade400.withOpacity(0.4),
//                     blurRadius: 12,
//                     offset: Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 Icons.local_pharmacy,
//                 size: 70,
//                 color: const Color.fromARGB(255, 88, 221, 97),
//               ),
//             ),

//             const SizedBox(height: 30),

//             const Text(
//               'Bienvenue dans votre espace pharmacie 👋',
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//                 shadows: [
//                   Shadow(
//                     blurRadius: 4,
//                     color: Colors.black26,
//                     offset: Offset(1, 1),
//                   ),
//                 ],
//               ),
//               textAlign: TextAlign.center,
//             ),

//             const SizedBox(height: 40),

//             ElevatedButton.icon(
//               icon: const Icon(Icons.edit, size: 26),
//               label: const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 14),
//                 child: Text(
//                   "Modifier mes informations",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color.fromARGB(255, 87, 221, 94),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 elevation: 8,
//                 shadowColor: const Color.fromARGB(255, 100, 223, 108).withOpacity(0.4),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => EditPharmacyProfilePage2(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

