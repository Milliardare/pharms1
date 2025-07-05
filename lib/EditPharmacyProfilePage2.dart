import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class EditPharmacyProfilePage2 extends StatefulWidget {
  @override
  _EditPharmacyProfilePageState createState() => _EditPharmacyProfilePageState();
}

class _EditPharmacyProfilePageState extends State<EditPharmacyProfilePage2> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final openHourCtrl = TextEditingController();
  final closeHourCtrl = TextEditingController();

  bool _loading = true;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    loadPharmacyData();
  }

  Future<void> loadPharmacyData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("user_not_logged_in".tr()),
        ));
        Navigator.pop(context);
        return;
      }

      final uid = user.uid;
      final doc = await FirebaseFirestore.instance.collection('pharmacies').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        nameCtrl.text = data['name'] ?? '';
        phoneCtrl.text = data['phone'] ?? '';
        locationCtrl.text = data['location'] ?? '';
        openHourCtrl.text = data['openHour'] ?? '';
        closeHourCtrl.text = data['closeHour'] ?? '';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("no_data_found".tr()),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("load_error".tr(args: [e.toString()])),
      ));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> updatePharmacyData() async {
    setState(() => _updating = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('pharmacies').doc(uid).update({
        'name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'openHour': openHourCtrl.text.trim(),
        'closeHour': closeHourCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("profile_updated_success".tr())),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("update_error".tr(args: [e.toString()]))),
      );
    } finally {
      setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("edit_pharmacy_profile".tr())),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(labelText: 'name'.tr()),
                      validator: (v) => v!.isEmpty ? 'enter_name'.tr() : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: InputDecoration(labelText: 'phone'.tr()),
                      validator: (v) => v!.isEmpty ? 'enter_phone'.tr() : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: openHourCtrl,
                      decoration: InputDecoration(labelText: 'open_hour'.tr()),
                      validator: (v) => v!.isEmpty ? 'enter_hour'.tr() : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: closeHourCtrl,
                      decoration: InputDecoration(labelText: 'close_hour'.tr()),
                      validator: (v) => v!.isEmpty ? 'enter_hour'.tr() : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: locationCtrl,
                      decoration: InputDecoration(labelText: 'location'.tr()),
                      validator: (v) => v!.isEmpty ? 'enter_location'.tr() : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: _updating
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.save),
                      label: Text(_updating ? "updating".tr() : "update".tr()),
                      onPressed: _updating
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                updatePharmacyData();
                              }
                            },
                    )
                  ],
                ),
              ),
            ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class EditPharmacyProfilePage2 extends StatefulWidget {
//   @override
//   _EditPharmacyProfilePageState createState() => _EditPharmacyProfilePageState();
// }

// class _EditPharmacyProfilePageState extends State<EditPharmacyProfilePage2> {
//   final _formKey = GlobalKey<FormState>();
//   final nameCtrl = TextEditingController();
//   final phoneCtrl = TextEditingController();
//   final locationCtrl = TextEditingController();
//   final openHourCtrl = TextEditingController();
//   final closeHourCtrl = TextEditingController();

//   bool _loading = true;
//   bool _updating = false;

//   @override
//   void initState() {
//     super.initState();
//     loadPharmacyData();
//   }

//   Future<void> loadPharmacyData() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text("Utilisateur non connecté."),
//         ));
//         Navigator.pop(context);
//         return;
//       }

//       final uid = user.uid;
//       final doc = await FirebaseFirestore.instance.collection('pharmacies').doc(uid).get();

//       if (doc.exists) {
//         final data = doc.data()!;
//         nameCtrl.text = data['name'] ?? '';
//         phoneCtrl.text = data['phone'] ?? '';
//         locationCtrl.text = data['location'] ?? '';
//         openHourCtrl.text = data['openHour'] ?? '';
//         closeHourCtrl.text = data['closeHour'] ?? '';
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text("Aucune donnée trouvée pour ce compte."),
//         ));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Erreur lors du chargement : $e"),
//       ));
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> updatePharmacyData() async {
//     setState(() => _updating = true);
//     try {
//       final uid = FirebaseAuth.instance.currentUser?.uid;
//       if (uid == null) return;

//       await FirebaseFirestore.instance.collection('pharmacies').doc(uid).update({
//         'name': nameCtrl.text.trim(),
//         'phone': phoneCtrl.text.trim(),
//         'location': locationCtrl.text.trim(),
//         'openHour': openHourCtrl.text.trim(),
//         'closeHour': closeHourCtrl.text.trim(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Profil mis à jour avec succès")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Erreur de mise à jour : $e")),
//       );
//     } finally {
//       setState(() => _updating = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Modifier le profil pharmacie")),
//       body: _loading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: ListView(
//                   children: [
//                     TextFormField(
//                       controller: nameCtrl,
//                       decoration: InputDecoration(labelText: 'Nom'),
//                       validator: (v) => v!.isEmpty ? 'Entrez le nom' : null,
//                     ),
//                     SizedBox(height: 10),
//                     TextFormField(
//                       controller: phoneCtrl,
//                       decoration: InputDecoration(labelText: 'Téléphone'),
//                       validator: (v) => v!.isEmpty ? 'Entrez le numéro' : null,
//                     ),
//                     SizedBox(height: 10),
//                     TextFormField(
//                       controller: openHourCtrl,
//                       decoration: InputDecoration(labelText: 'Heure d\'ouverture'),
//                       validator: (v) => v!.isEmpty ? 'Entrez l\'heure' : null,
//                     ),
//                     SizedBox(height: 10),
//                     TextFormField(
//                       controller: closeHourCtrl,
//                       decoration: InputDecoration(labelText: 'Heure de fermeture'),
//                       validator: (v) => v!.isEmpty ? 'Entrez l\'heure' : null,
//                     ),
//                     SizedBox(height: 10),
//                     TextFormField(
//                       controller: locationCtrl,
//                       decoration: InputDecoration(labelText: 'Localisation'),
//                       validator: (v) => v!.isEmpty ? 'Entrez une localisation' : null,
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton.icon(
//                       icon: _updating
//                           ? SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             )
//                           : Icon(Icons.save),
//                       label: Text(_updating ? "Mise à jour..." : "Mettre à jour"),
//                       onPressed: _updating
//                           ? null
//                           : () {
//                               if (_formKey.currentState!.validate()) {
//                                 updatePharmacyData();
//                               }
//                             },
//                     )
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

