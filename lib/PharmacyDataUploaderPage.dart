
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacyDataUploaderPage extends StatelessWidget {
  const PharmacyDataUploaderPage({Key? key}) : super(key: key);

  // ⬇️ Fonction pour importer uniquement les pharmacies du Gabon
  Future<void> _uploadPharmacies() async {
    final List<Map<String, dynamic>> pharmacies = [
      {
        "name": "Pharmacie Centrale",
        "phone": "+241 77 31 26 33",
        "email": "",
        "location": "Libreville - Centre-ville, près du marché Mont-Bouët"
      },
      {
        "name": "Pharmacie de l’Orchidée",
        "phone": "+241 74 40 69 70",
        "email": "pharmalorchidee@gmail.com",
        "location": "Libreville - Quartier Louis, à côté de l’Hôtel Hibiscus"
      },
      {
        "name": "Pharmacie Sainte-Marie",
        "phone": "+241 60 05 44 26",
        "email": "phsaintemarie@yahoo.fr",
        "location": "Libreville - Montagne Sainte, proche de l’église Sainte-Marie"
      },
      {
        "name": "Pharmacie Montagne Sainte",
        "phone": "+241 74 38 79 01",
        "email": "",
        "location": "Libreville - Quartier Montagne Sainte"
      },
      {
        "name": "Pharmacie de la Gare Routière",
        "phone": "+241 77 67 53 48",
        "email": "phargar.ex@gmail.com",
        "location": "Libreville - Vers Gare Routière de Libreville"
      },
      {
        "name": "Pharmacie Akanda Santé",
        "phone": "+241 77 77 79 87",
        "email": "",
        "location": "Akanda - Derrière la clinique Medivision, Okala"
      },
      {
        "name": "Pharmacie de Franceville Centre",
        "phone": "+241 74 74 12 34",
        "email": "",
        "location": "Franceville - Centre-ville, près du marché"
      },
      {
        "name": "Pharmacie Les Marguerites",
        "phone": "+241 77 14 02, +241 66 43 47 01",
        "email": "phlesmarguerites@gmail.com",
        "location": "Libreville - Quartier Charbonnages"
      },
      {
        "name": "Pharmacie Royale",
        "phone": "+241 74 37 00 76",
        "email": "pharmacieroyalegabon@gmail.com",
        "location": "Libreville - Derrière École Publique de Dragages"
      },
      {
        "name": "Pharmacie d’Awondo",
        "phone": "+241 66 15 80 00",
        "email": "lanouvellepharmacieawondo@yahoo.com",
        "location": "Libreville - Quartier Awondo, proche station PetroGabon"
      },
      {
        "name": "Pharmacie de Sibang-Montalier",
        "phone": "+241 62 76 84 50",
        "email": "",
        "location": "Libreville - Sibang, à côté du centre de santé Montalier"
      },
      {
        "name": "Pharmacie d’Acaé",
        "phone": "+241 11 70 49 49",
        "email": "",
        "location": "Libreville - Quartier Acaé"
      },
      {
        "name": "Pharmacie d’Okala",
        "phone": "+241 66 55 55 55",
        "email": "",
        "location": "Akanda - Okala, près du Carrefour Okala"
      },
      {
        "name": "Pharmacie de Nkembé",
        "phone": "+241 11 74 11 60",
        "email": "",
        "location": "Libreville - Quartier Nkembé, non loin de l’Église Adventiste"
      },
      {
        "name": "Pharmacie Mbolo",
        "phone": "+241 77 33 22 11",
        "email": "",
        "location": "Port-Gentil - Vers le centre commercial Mbolo"
      },
      {
        "name": "Pharmacie des Charbonnages",
        "phone": "+241 77 34 84 91",
        "email": "",
        "location": "Libreville - Quartier Charbonnages, près de l’ancienne station BP"
      },
       {
    "name": "Grande Pharmacie des Forestiers",
    "phone": "+241 65 99 59 93",
    "email": "infos@pharmaforestiers.com",
    "location": "Mbolo, Libreville - Galerie Mbolo, ouvert 8h–19h30"
  },
  {
    "name": "Pharmacie Avolenzame",
    "phone": "+241 65 19 03 04",
    "email": "pharmacieavolenzame@gmail.com",
    "location": "Nkembo, Libreville – route Atong Abè"
  },
  {
    "name": "Pharmacie de la Grâce",
    "phone": "+241 62 94 94 24",
    "email": "",
    "location": "Angondjé, Libreville - 24h/24"
  },
  {
    "name": "Pharmacie du Lycée Technique",
    "phone": "+241 77 05 01 90",
    "email": "",
    "location": "Owendo - Avant le lycée technique"
  },
  {
    "name": "Pharmacie derrière l’Hôpital",
    "phone": "+241 74 68 46",
    "email": "",
    "location": "Libreville - Quartier derrière l’hôpital"
  },
  {
    "name": "Pharmacie de la Poste",
    "phone": "+241 72 83 30",
    "email": "",
    "location": "Libreville - Galerie Hollando, bord de mer"
  },
  {
    "name": "Pharmacie de Glass",
    "phone": "+241 74 87 98",
    "email": "",
    "location": "Glass, Libreville - Carrefour Glass"
  },
  {
    "name": "Pharmacie de la Plaine Niger",
    "phone": "+241 65 08 78 48",
    "email": "",
    "location": "Carrefour Boulingui, Libreville"
  }
    ];

    for (final pharmacie in pharmacies) {
      await FirebaseFirestore.instance.collection('pharmacies').add({
        'name': pharmacie['name'],
        'phone': pharmacie['phone'],
        'location': pharmacie['location'],
        'email': pharmacie['email'] ?? '',
        'imageUrl': '',
        'role': 'pharmacy',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    debugPrint("✅ Toutes les pharmacies du Gabon ont été enregistrées !");
  }

  // ⬇️ Fonction pour tout supprimer
  Future<void> _deleteAllPharmacies() async {
    final collection = FirebaseFirestore.instance.collection('pharmacies');
    final snapshot = await collection.get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    debugPrint("🗑️ Toutes les pharmacies ont été supprimées !");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📥 Gestion Pharmacies')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await _uploadPharmacies();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Pharmacies enregistrées")),
                );
              },
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Importer les pharmacies du Gabon"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await _deleteAllPharmacies();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🗑️ Pharmacies supprimées")),
                );
              },
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text("Supprimer toutes les pharmacies"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class PharmacyDataUploaderPage extends StatelessWidget {
//   const PharmacyDataUploaderPage({Key? key}) : super(key: key);

//   Future<void> _uploadPharmacies() async {
//     final List<Map<String, dynamic>> pharmacies = [
//       // 🇬🇦 Pharmacies du Gabon
//       {
//         "name": "Pharmacie Centrale",
//         "phone": "+241 77 31 26 33",
//         "email": "",
//         "location": "Libreville - Centre-ville, près du marché Mont-Bouët"
//       },
//       {
//         "name": "Pharmacie de l’Orchidée",
//         "phone": "+241 74 40 69 70",
//         "email": "pharmalorchidee@gmail.com",
//         "location": "Libreville - Quartier Louis, à côté de l’Hôtel Hibiscus"
//       },
//       {
//         "name": "Pharmacie Sainte-Marie",
//         "phone": "+241 60 05 44 26",
//         "email": "phsaintemarie@yahoo.fr",
//         "location": "Libreville - Montagne Sainte, proche de l’église Sainte-Marie"
//       },
//       {
//         "name": "Pharmacie Montagne Sainte",
//         "phone": "+241 74 38 79 01",
//         "email": "",
//         "location": "Libreville - Quartier Montagne Sainte"
//       },
//       {
//         "name": "Pharmacie de la Gare Routière",
//         "phone": "+241 77 67 53 48",
//         "email": "phargar.ex@gmail.com",
//         "location": "Libreville - Vers Gare Routière de Libreville"
//       },
//       {
//         "name": "Pharmacie Akanda Santé",
//         "phone": "+241 77 77 79 87",
//         "email": "",
//         "location": "Akanda - Derrière la clinique Medivision, Okala"
//       },
//       {
//         "name": "Pharmacie de Franceville Centre",
//         "phone": "+241 74 74 12 34",
//         "email": "",
//         "location": "Franceville - Centre-ville, près du marché"
//       },
//       {
//         "name": "Pharmacie Les Marguerites",
//         "phone": "+241 77 14 02, +241 66 43 47 01",
//         "email": "phlesmarguerites@gmail.com",
//         "location": "Libreville - Quartier Charbonnages"
//       },
//       {
//         "name": "Pharmacie Royale",
//         "phone": "+241 74 37 00 76",
//         "email": "pharmacieroyalegabon@gmail.com",
//         "location": "Libreville - Derrière École Publique de Dragages"
//       },
//       {
//         "name": "Pharmacie d’Awondo",
//         "phone": "+241 66 15 80 00",
//         "email": "lanouvellepharmacieawondo@yahoo.com",
//         "location": "Libreville - Quartier Awondo, proche station PetroGabon"
//       },
//       {
//         "name": "Pharmacie de Sibang-Montalier",
//         "phone": "+241 62 76 84 50",
//         "email": "",
//         "location": "Libreville - Sibang, à côté du centre de santé Montalier"
//       },
//       {
//         "name": "Pharmacie d’Acaé",
//         "phone": "+241 11 70 49 49",
//         "email": "",
//         "location": "Libreville - Quartier Acaé"
//       },
//       {
//         "name": "Pharmacie d’Okala",
//         "phone": "+241 66 55 55 55",
//         "email": "",
//         "location": "Akanda - Okala, près du Carrgiyefour Okala"
//       },
//       {
//         "name": "Pharmacie de Nkembé",
//         "phone": "+241 11 74 11 60",
//         "email": "",
//         "location": "Libreville - Quartier Nkembé, non loin de l’Église Adventiste"
//       },
//       {
//         "name": "Pharmacie Mbolo",
//         "phone": "+241 77 33 22 11",
//         "email": "",
//         "location": "Port-Gentil - Vers le centre commercial Mbolo"
//       },
//       {
//         "name": "Pharmacie des Charbonnages",
//         "phone": "+241 77 34 84 91",
//         "email": "",
//         "location": "Libreville - Quartier Charbonnages, près de l’ancienne station BP"
//       },


      
//     ];

//     for (final pharmacie in pharmacies) {
//       await FirebaseFirestore.instance.collection('pharmacies').add({
//         'name': pharmacie['name'],
//         'phone': pharmacie['phone'],
//         'location': pharmacie['location'],
//         'email': pharmacie['email'] ?? '',
//         'imageUrl': '',
//         'role': 'pharmacy',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     }

//     debugPrint("✅ Toutes les pharmacies ont été enregistrées !");
//   }

//   @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(title: const Text('📥 Enregistrement Pharmacies')),
//     body: Center(
//       child: ElevatedButton.icon(
//         onPressed: () async {
//           await _uploadPharmacies();

//           // ✅ Sécurité après async pour éviter les erreurs si le widget est démonté
//           if (!context.mounted) return;

//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("✅ Pharmacies enregistrées")),
//           );
//         },
//         icon: const Icon(Icons.cloud_upload),
//         label: const Text("Importer toutes les pharmacies"),
//       ),
//     ),
//   );
// }


//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     appBar: AppBar(title: const Text('📥 Enregistrement Pharmacies')),
//   //     body: Center(
//   //       child: ElevatedButton.icon(
//   //         onPressed: () async {
//   //           await _uploadPharmacies();
//   //           ScaffoldMessenger.of(context).showSnackBar(
//   //             const SnackBar(content: Text("✅ Pharmacies enregistrées")),
//   //           );
//   //         },
//   //         icon: const Icon(Icons.cloud_upload),
//   //         label: const Text("Importer toutes les pharmacies"),
//   //       ),
//   //     ),
//   //   );
//   // }
// }

