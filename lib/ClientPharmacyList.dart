import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'OrderFormPage.dart';
import 'BoutiquePage.dart';
import 'package:easy_localization/easy_localization.dart';

class ClientPharmacyList extends StatefulWidget {
  @override
  _ClientPharmacyListState createState() => _ClientPharmacyListState();
}

class _ClientPharmacyListState extends State<ClientPharmacyList>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allPharmacies = [];
  List<Map<String, dynamic>> filteredPharmacies = [];
  String searchQuery = '';
  late AnimationController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..forward();
    fetchPharmacies();
  }

  Future<void> fetchPharmacies() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('pharmacies').get();

      final pharmacies = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? '',
          'phone': data['phone'] ?? '',
          'imagePath': 'assets/images/pharmasfemme.png',
          'location': data['location'] ?? '',
          'openHour': data['openHour'] ?? '',
          'closeHour': data['closeHour'] ?? '',
        };
      }).toList();

      setState(() {
        allPharmacies = pharmacies;
        filteredPharmacies = pharmacies;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_loading_pharmacies'.tr())),
      );
    }
  }

  void filterSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredPharmacies = allPharmacies.where((pharmacy) {
        final name = pharmacy['name'].toString().toLowerCase();
        final location = pharmacy['location'].toString().toLowerCase();
        return name.contains(searchQuery) || location.contains(searchQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('pharmacies_nearby'.tr()),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Color.fromARGB(255, 37, 192, 58),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: 'search_hint'.tr(),
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredPharmacies.isEmpty
                    ? Center(
                        child: Text(
                          'no_pharmacies_found'.tr(),
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredPharmacies.length,
                        itemBuilder: (context, index) {
                          final p = filteredPharmacies[index];
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(1, 0),
                              end: Offset(0, 0),
                            ).animate(CurvedAnimation(
                              parent: _controller,
                              curve: Interval(
                                (index / filteredPharmacies.length),
                                1.0,
                                curve: Curves.easeOut,
                              ),
                            )),
                            child: FadeTransition(
                              opacity: _controller,
                              child: Card(
                                elevation: 6,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(12),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      p['imagePath'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    p['name'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                  subtitle: Text(p['location']),
                                  onTap: () {
                                    _showPharmacyDialog(p);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 🟩 BOUTIQUE
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.storefront),
                label: Text('boutique'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 58, 152, 230),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BoutiquePage()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('boutique_coming_soon'.tr())),
                  );
                },
              ),
            ),
            SizedBox(width: 12),
            // 🟥 LIVRAISON
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.local_shipping),
                label: Text(
                  'delivery'.tr(),
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 253, 147, 147),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderFormPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPharmacyDialog(Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(p['name']),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    p['imagePath'],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green),
                    SizedBox(width: 9),
                    Expanded(child: Text(p['location'])),
                  ],
                ),
                if (p['openHour'] != '' && p['closeHour'] != '')
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                    child: Row(
                      children: [
                           Icon(Icons.access_time, color: Colors.green),
                          SizedBox(width: 6),
                          Expanded(
                        child: Text(
                              tr(
                              'open_hours',
                              namedArgs: {
                                'open': p['openHour'],
                                'close': p['closeHour'],
                                },
                                  ),
                                ),
                                ),
                             ],
                      //   Icon(Icons.access_time, color: Colors.green),
                      //   SizedBox(width: 6),
                      //   Text(
                      //     tr('open_hours'.tr(),
                      //         args: [p['openHour'], p['closeHour']]),
                      //   ),
                      // ],
                    ),
                  ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.chat),
                  label: Text('order_medicine'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    minimumSize: Size(double.infinity, 48),
                  ),
                  onPressed: () async {
                    final number =
                        p['phone'].toString().replaceAll(RegExp(r'[ +\-]'), '');
                    final message = Uri.encodeComponent(
                      "Bonjour ${p['name']}, je m'appelle ...., je voudrais commander un médicament.",
                    );
                    final url = 'https://wa.me/$number?text=$message';

                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('whatsapp_error'.tr())),
                      );
                    }
                  },
                ),
                SizedBox(height: 9),
                ElevatedButton.icon(
                  icon: Icon(Icons.call),
                  label: Text('call'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    minimumSize: Size(double.infinity, 36),
                  ),
                  onPressed: () async {
                    final number =
                        p['phone'].toString().replaceAll(RegExp(r'[^\d]'), '');
                    final url = 'tel:$number';

                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('call_error'.tr())),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'close'.tr(),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'OrderFormPage.dart';
// import 'BoutiquePage.dart';
// import 'package:easy_localization/easy_localization.dart';

// class ClientPharmacyList extends StatefulWidget {
//   @override
//   _ClientPharmacyListState createState() => _ClientPharmacyListState();
// }

// class _ClientPharmacyListState extends State<ClientPharmacyList>
//     with SingleTickerProviderStateMixin {
//   List<Map<String, dynamic>> allPharmacies = [];
//   List<Map<String, dynamic>> filteredPharmacies = [];
//   String searchQuery = '';
//   late AnimationController _controller;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     )..forward();
//     fetchPharmacies();
//   }

//   Future<void> fetchPharmacies() async {
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance.collection('pharmacies').get();

//       final pharmacies = snapshot.docs.map((doc) {
//         final data = doc.data();
//         return {
//           'name': data['name'] ?? '',
//           'phone': data['phone'] ?? '',
//           'imagePath': 'assets/images/pharmasfemme.png',
//           'location': data['location'] ?? '',
//           'openHour': data['openHour'] ?? '',
//           'closeHour': data['closeHour'] ?? '',
//         };
//       }).toList();

//       setState(() {
//         allPharmacies = pharmacies;
//         filteredPharmacies = pharmacies;
//         isLoading = false;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('error_loading_pharmacies'.tr())),
//       );
//     }
//   }

//   void filterSearch(String query) {
//     setState(() {
//       searchQuery = query.toLowerCase();
//       filteredPharmacies = allPharmacies.where((pharmacy) {
//         final name = pharmacy['name'].toString().toLowerCase();
//         final location = pharmacy['location'].toString().toLowerCase();
//         return name.contains(searchQuery) || location.contains(searchQuery);
//       }).toList();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text('pharmacies_nearby'.tr()),
//         centerTitle: true,
//         elevation: 4,
//         backgroundColor: Color.fromARGB(255, 37, 192, 58),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               onChanged: filterSearch,
//               decoration: InputDecoration(
//                 hintText: 'search_hint'.tr(),
//                 prefixIcon: Icon(Icons.search),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: EdgeInsets.symmetric(vertical: 12),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(14),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: isLoading
//                 ? Center(child: CircularProgressIndicator())
//                 : filteredPharmacies.isEmpty
//                     ? Center(
//                         child: Text(
//                           'no_pharmacies_found'.tr(),
//                           style: TextStyle(color: Colors.grey),
//                           textAlign: TextAlign.center,
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         itemCount: filteredPharmacies.length,
//                         itemBuilder: (context, index) {
//                           final p = filteredPharmacies[index];
//                           return SlideTransition(
//                             position: Tween<Offset>(
//                               begin: Offset(1, 0),
//                               end: Offset(0, 0),
//                             ).animate(CurvedAnimation(
//                               parent: _controller,
//                               curve: Interval(
//                                 (index / filteredPharmacies.length),
//                                 1.0,
//                                 curve: Curves.easeOut,
//                               ),
//                             )),
//                             child: FadeTransition(
//                               opacity: _controller,
//                               child: Card(
//                                 elevation: 6,
//                                 margin: EdgeInsets.symmetric(vertical: 8),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: ListTile(
//                                   contentPadding: EdgeInsets.all(12),
//                                   leading: ClipRRect(
//                                     borderRadius: BorderRadius.circular(15),
//                                     child: Image.asset(
//                                       p['imagePath'],
//                                       width: 80,
//                                       height: 80,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                   title: Text(
//                                     p['name'],
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 16),
//                                   ),
//                                   subtitle: Text(p['location']),
//                                   onTap: () {
//                                     _showPharmacyDialog(p);
//                                   },
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             // 🟩 BOUTIQUE
//             Expanded(
//               child: ElevatedButton.icon(
//                 icon: Icon(Icons.storefront),
//                 label: Text('boutique'.tr()),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 58, 152, 230),
//                   padding: EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => BoutiquePage()),
//                   );
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('boutique_coming_soon'.tr())),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(width: 12),
//             // 🟥 LIVRAISON
//             Expanded(
//               child: ElevatedButton.icon(
//                 icon: Icon(Icons.local_shipping),
//                 label: Text(
//                   'delivery'.tr(),
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color.fromARGB(255, 253, 147, 147),
//                   padding: EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => OrderFormPage()),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showPharmacyDialog(Map<String, dynamic> p) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: Text(p['name']),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.asset(
//                   p['imagePath'],
//                   width: 120,
//                   height: 120,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               SizedBox(height: 12),
//               Row(
//                 children: [
//                   Icon(Icons.location_on, color: Colors.green),
//                   SizedBox(width: 9),
//                   Expanded(child: Text(p['location'])),
//                 ],
//               ),
//               if (p['openHour'] != '' && p['closeHour'] != '')
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
//                   child: Row(
//                     children: [
//                       Icon(Icons.access_time, color: Colors.green),
//                       SizedBox(width: 6),
//                       Text(
//                         tr('open_hours'.tr(),
//                             args: [p['openHour'], p['closeHour']]),
//                       ),
//                     ],
//                   ),
//                 ),
//               SizedBox(height: 12),
//               ElevatedButton.icon(
//                 icon: Icon(Icons.chat),
//                 label: Text('order_medicine'.tr()),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green.shade600,
//                   minimumSize: Size(double.infinity, 48),
//                 ),
//                 onPressed: () async {
//                   final number =
//                       p['phone'].toString().replaceAll(RegExp(r'[ +\-]'), '');
//                   final message = Uri.encodeComponent(
//                     "Bonjour ${p['name']}, je m'appelle ...., je voudrais commander un médicament.",
//                   );
//                   final url = 'https://wa.me/$number?text=$message';

//                   if (await canLaunchUrl(Uri.parse(url))) {
//                     await launchUrl(Uri.parse(url),
//                         mode: LaunchMode.externalApplication);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('whatsapp_error'.tr())),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(
//                 'close'.tr(),
//                 style: TextStyle(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

// }
 

