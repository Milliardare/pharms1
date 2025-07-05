import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class BoutiquePage extends StatefulWidget {
  @override
  _BoutiquePageState createState() => _BoutiquePageState();
}

class _BoutiquePageState extends State<BoutiquePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Toutes';
  String numeroWhatsApp = '';

  final List<String> _categories = [
    'Toutes',
    'Crème',
    'Lotion',
    'Sirop',
    'Complément',
    'Hygiène'
  ];

  @override
  void initState() {
    super.initState();
    _chargerNumeroWhatsApp();
  }

  Future<void> _chargerNumeroWhatsApp() async {
    final doc = await FirebaseFirestore.instance.collection('config').doc('whatsapp').get();
    if (doc.exists) {
      setState(() {
        numeroWhatsApp = doc['numero'] ?? '';
      });
    }
  }

  String _translateCategory(String cat) {
    switch (cat) {
      case 'Toutes':
        return 'all'.tr();
      case 'Crème':
        return 'cream'.tr();
      case 'Lotion':
        return 'lotion'.tr();
      case 'Sirop':
        return 'syrup'.tr();
      case 'Complément':
        return 'supplement'.tr();
      case 'Hygiène':
        return 'hygiene'.tr();
      default:
        return cat;
    }
  }

  Future<void> _ouvrirDetailsProduit(BuildContext context, Map<String, dynamic> produit) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.5,
          maxChildSize: 0.90,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if ((produit['imageUrl'] ?? '').toString().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        produit['imageUrl'],
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    produit['nom'] ?? '',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    produit['description'] ?? '',
                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 24, 23, 23)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (numeroWhatsApp.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("whatsapp_not_defined".tr())));
                        return;
                      }
                      final nom = produit['nom'] ?? 'un produit';
                      final message = Uri.encodeComponent("Bonjour, je suis intéressé par le produit '$nom'.");
                      final url = 'https://wa.me/$numeroWhatsApp?text=$message';

                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("open_whatsapp_error".tr())));
                      }
                    },
                    icon: Icon(Icons.chat),
                    label: Text('order_via_whatsapp'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('boutique_title'.tr()),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'search_product_hint'.tr(),
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: ChoiceChip(
                          label: Text(_translateCategory(cat)),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          selectedColor: Colors.green[700],
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('boutique').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return Center(child: Text('no_products'.tr(), style: TextStyle(fontSize: 18)));

                final produits = snapshot.data!.docs.where((doc) {
                  final data = doc.data()! as Map<String, dynamic>;
                  final nom = (data['nom'] ?? '').toString().toLowerCase();
                  final categorie = (data['categorie'] ?? 'Autre');

                  final matchSearch = _searchQuery.isEmpty || nom.contains(_searchQuery);
                  final matchCategorie = _selectedCategory == 'Toutes' || categorie == _selectedCategory;

                  return matchSearch && matchCategorie;
                }).toList();

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: produits.map((doc) {
                        final p = doc.data()! as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () => _ouvrirDetailsProduit(context, p),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2 - 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  child: p['imageUrl'] != null && p['imageUrl'] != ''
                                      ? Image.network(
                                          p['imageUrl'],
                                          fit: BoxFit.cover,
                                          height: 130,
                                          width: double.infinity,
                                        )
                                      : Container(
                                          height: 130,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.medical_services, size: 60, color: Colors.grey[600]),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    p['nom'] ?? '',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.green[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart';

// class BoutiquePage extends StatefulWidget {
//   @override
//   _BoutiquePageState createState() => _BoutiquePageState();
// }

// class _BoutiquePageState extends State<BoutiquePage> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _selectedCategory = 'Toutes';
//   String numeroWhatsApp = '';

//   final List<String> _categories = [
//     'Toutes',
//     'Crème',
//     'Lotion',
//     'Sirop',
//     'Complément',
//     'Hygiène'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _chargerNumeroWhatsApp();
//   }

//   Future<void> _chargerNumeroWhatsApp() async {
//     final doc = await FirebaseFirestore.instance.collection('config').doc('whatsapp').get();
//     if (doc.exists) {
//       setState(() {
//         numeroWhatsApp = doc['numero'] ?? '';
//       });
//     }
//   }

//   Future<void> _ouvrirDetailsProduit(BuildContext context, Map<String, dynamic> produit) async {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (_) {
//         return DraggableScrollableSheet(
//           expand: false,
//           initialChildSize: 0.6,
//           minChildSize: 0.5,
//           maxChildSize: 0.90,
//           builder: (_, scrollController) {
//             return SingleChildScrollView(
//               controller: scrollController,
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   if ((produit['imageUrl'] ?? '').toString().isNotEmpty)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Image.network(
//                         produit['imageUrl'],
//                         height: 160,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   const SizedBox(height: 16),
//                   Text(
//                     produit['nom'] ?? '',
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 18),
//                   Text(
//                     produit['description'] ?? '',
//                     style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 24, 23, 23)),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton.icon(
//                     onPressed: () async {
//                       if (numeroWhatsApp.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Numéro WhatsApp non défini")));
//                         return;
//                       }
//                       final nom = produit['nom'] ?? 'un produit';
//                       final message = Uri.encodeComponent("Bonjour, je suis intéressé par le produit '$nom'.");
//                       final url = 'https://wa.me/$numeroWhatsApp?text=$message';

//                       if (await canLaunchUrl(Uri.parse(url))) {
//                         await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Impossible d'ouvrir WhatsApp")));
//                       }
//                     },
//                     icon: Icon(Icons.chat),
//                     label: Text('Commander via WhatsApp'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green.shade700,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
//                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
//                     ),
//                   )
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('Bienvenue dans Boutique Pharmas'),
//         backgroundColor: Colors.green[700],
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: 'Rechercher un produit...',
//                     prefixIcon: Icon(Icons.search),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
//                 ),
//                 const SizedBox(height: 10),
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: _categories.map((cat) {
//                       final isSelected = _selectedCategory == cat;
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 6.0),
//                         child: ChoiceChip(
//                           label: Text(cat),
//                           selected: isSelected,
//                           onSelected: (_) => setState(() => _selectedCategory = cat),
//                           selectedColor: Colors.green[700],
//                           backgroundColor: Colors.grey[200],
//                           labelStyle: TextStyle(
//                             color: isSelected ? Colors.white : Colors.black,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance.collection('boutique').snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting)
//                   return Center(child: CircularProgressIndicator());

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
//                   return Center(child: Text('Aucun produit disponible, vérifiez votre connexion', style: TextStyle(fontSize: 18)));

//                 final produits = snapshot.data!.docs.where((doc) {
//                   final data = doc.data()! as Map<String, dynamic>;
//                   final nom = (data['nom'] ?? '').toString().toLowerCase();
//                   final categorie = (data['categorie'] ?? 'Autre');

//                   final matchSearch = _searchQuery.isEmpty || nom.contains(_searchQuery);
//                   final matchCategorie = _selectedCategory == 'Toutes' || categorie == _selectedCategory;

//                   return matchSearch && matchCategorie;
//                 }).toList();

//                 return SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: Wrap(
//                       spacing: 12,
//                       runSpacing: 12,
//                       children: produits.map((doc) {
//                         final p = doc.data()! as Map<String, dynamic>;
//                         return GestureDetector(
//                           onTap: () => _ouvrirDetailsProduit(context, p),
//                           child: Container(
//                             width: MediaQuery.of(context).size.width / 2 - 24,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.shade300,
//                                   blurRadius: 4,
//                                   offset: Offset(2, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                                   child: p['imageUrl'] != null && p['imageUrl'] != ''
//                                       ? Image.network(
//                                           p['imageUrl'],
//                                           fit: BoxFit.cover,
//                                           height: 130,
//                                           width: double.infinity,
//                                         )
//                                       : Container(
//                                           height: 130,
//                                           color: Colors.grey[300],
//                                           child: Icon(Icons.medical_services, size: 60, color: Colors.grey[600]),
//                                         ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     p['nom'] ?? '',
//                                     textAlign: TextAlign.center,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 14,
//                                       color: Colors.green[900],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart';

// class BoutiquePage extends StatefulWidget {
//   final String numeroWhatsApp = '24160088467';

//   @override
//   _BoutiquePageState createState() => _BoutiquePageState();
// }

// class _BoutiquePageState extends State<BoutiquePage> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _selectedCategory = 'Toutes';

//   final List<String> _categories = [
//     'Toutes',
//     'Crème',
//     'Lotion',
//     'Sirop',
//     'Complément',
//     'Hygiène'
//   ];
//   Future<void> _ouvrirDetailsProduit(BuildContext context, Map<String, dynamic> produit) async {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true, // ✅ rend la fiche plus grande
//     backgroundColor: Colors.white,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//     builder: (_) {
//       return DraggableScrollableSheet(
//         expand: false,
//         initialChildSize: 0.6, // ✅ commence à 80% de l’écran
//         minChildSize: 0.5,
//         maxChildSize: 0.90,
//         builder: (_, scrollController) {
//           return SingleChildScrollView(
//             controller: scrollController,
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 if ((produit['imageUrl'] ?? '').toString().isNotEmpty)
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: Image.network(
//                       produit['imageUrl'],
//                       height: 160,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 const SizedBox(height: 16),
//                 Text(
//                   produit['nom'] ?? '',
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 18),
//                 Text(
//                   produit['description'] ?? '',
//                   style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 24, 23, 23)),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton.icon(
//                   onPressed: () async {
//                 final nom = produit['nom'] ?? 'un produit';
//                 final message = Uri.encodeComponent("Bonjour, je suis intéressé par le produit '$nom'.");
//                final url = 'https://wa.me/${widget.numeroWhatsApp}?text=$message';

//                if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//                  } else {
//                    ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Impossible d'ouvrir WhatsApp")),
//                     );
//                     }
//                     },
//                     icon: Icon(Icons.chat),
//                     label: Text('Commander via WhatsApp'),
//                     style: ElevatedButton.styleFrom(
//                      backgroundColor: Colors.green.shade700,
//                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
//                         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
//                        ),
//                   // onPressed: () async {
//                   //   final msg = Uri.encodeComponent("Bonjour, je suis intéressé par le produit '${produit['nom']}'");
//                   //   final url = 'https://wa.me/${widget.numeroWhatsApp}?text=$msg';
//                   //   if (await canLaunchUrl(Uri.parse(url))) {
//                   //     await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//                   //   }
//                   // },
//                   // icon: Icon(Icons.chat),
//                   // label: Text('Commander via WhatsApp'),
//                   // style: ElevatedButton.styleFrom(
//                   //   backgroundColor: Colors.green.shade700,
//                   //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   //   padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                   // ),
//                 )
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('Bienvenue dans Boutique Pharmas'),
//         backgroundColor: Colors.green[700],
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: 'Rechercher un produit...',
//                     prefixIcon: Icon(Icons.search),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
//                 ),
//                 const SizedBox(height: 10),
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: _categories.map((cat) {
//                       final isSelected = _selectedCategory == cat;
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 6.0),
//                         child: ChoiceChip(
//                           label: Text(cat),
//                           selected: isSelected,
//                           onSelected: (_) => setState(() => _selectedCategory = cat),
//                           selectedColor: Colors.green[700],
//                           backgroundColor: Colors.grey[200],
//                           labelStyle: TextStyle(
//                             color: isSelected ? Colors.white : Colors.black,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance.collection('boutique').snapshots(), // 👈 plus de orderBy
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting)
//                   return Center(child: CircularProgressIndicator());

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
//                   return Center(child: Text('Aucun produit disponible,verifeir votre connection', style: TextStyle(fontSize: 18)));

//                 final produits = snapshot.data!.docs.where((doc) {
//                   final data = doc.data()! as Map<String, dynamic>;
//                   final nom = (data['nom'] ?? '').toString().toLowerCase();
//                   final categorie = (data['categorie'] ?? 'Autre');

//                   final matchSearch = _searchQuery.isEmpty || nom.contains(_searchQuery);
//                   final matchCategorie = _selectedCategory == 'Toutes' || categorie == _selectedCategory;

//                   return matchSearch && matchCategorie;
//                 }).toList();

//                 return SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: Wrap(
//                       spacing: 12,
//                       runSpacing: 12,
//                       children: produits.map((doc) {
//                         final p = doc.data()! as Map<String, dynamic>;
//                         return GestureDetector(
//                           onTap: () => _ouvrirDetailsProduit(context, p),
//                           child: Container(
//                             width: MediaQuery.of(context).size.width / 2 - 24,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.shade300,
//                                   blurRadius: 4,
//                                   offset: Offset(2, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                                   child: p['imageUrl'] != null && p['imageUrl'] != ''
//                                       ? Image.network(
//                                           p['imageUrl'],
//                                           fit: BoxFit.cover,
//                                           height: 130,
//                                           width: double.infinity,
//                                         )
//                                       : Container(
//                                           height: 130,
//                                           color: Colors.grey[300],
//                                           child: Icon(Icons.medical_services, size: 60, color: Colors.grey[600]),
//                                         ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     p['nom'] ?? '',
//                                     textAlign: TextAlign.center,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 14,
//                                       color: Colors.green[900],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


