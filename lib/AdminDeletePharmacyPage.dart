import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDeletePharmacyPage extends StatefulWidget {
  @override
  _AdminDeletePharmacyPageState createState() => _AdminDeletePharmacyPageState();
}

class _AdminDeletePharmacyPageState extends State<AdminDeletePharmacyPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allPharmacies = [];
  List<Map<String, dynamic>> _filteredPharmacies = [];
  List<Map<String, dynamic>> _selectedPharmacies = [];
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadPharmacies();
  }

  Future<void> _loadPharmacies() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('pharmacies').get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown Name',
          'phone': data['phone'] ?? 'Not defined',
          'email': data['email'] ?? 'No email',
        };
      }).toList();

      setState(() {
        _allPharmacies = list;
        _filteredPharmacies = list;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pharmacies: $e')),
      );
    }
  }

  void _filterPharmacies(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _filteredPharmacies = _allPharmacies.where((pharmacy) {
        final name = (pharmacy['name'] ?? '').toLowerCase();
        return name.contains(lower);
      }).toList();
    });
  }

  void _toggleSelection(Map<String, dynamic> pharmacy) {
    setState(() {
      if (_selectedPharmacies.any((p) => p['id'] == pharmacy['id'])) {
        _selectedPharmacies.removeWhere((p) => p['id'] == pharmacy['id']);
      } else {
        _selectedPharmacies.add(pharmacy);
      }
    });
  }

  Future<void> _deleteSelectedPharmacies() async {
    if (_selectedPharmacies.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Delete ${_selectedPharmacies.length} selected pharmacies?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      for (final pharmacy in _selectedPharmacies) {
        final docId = pharmacy['id'];
        await FirebaseFirestore.instance.collection('users').doc(docId).delete();
        await FirebaseFirestore.instance.collection('pharmacies').doc(docId).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedPharmacies.length} pharmacies deleted.')),
      );

      setState(() {
        final idsToRemove = _selectedPharmacies.map((p) => p['id']).toSet();
        _allPharmacies.removeWhere((p) => idsToRemove.contains(p['id']));
        _filteredPharmacies.removeWhere((p) => idsToRemove.contains(p['id']));
        _selectedPharmacies.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Supprimer Pharmacies')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterPharmacies,
              decoration: InputDecoration(
                labelText: 'Rechercher une pharmacie par nom',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterPharmacies('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _filteredPharmacies.isEmpty
                  ? Center(child: Text('Aucune pharmacie trouvée.'))
                  : ListView.builder(
                      itemCount: _filteredPharmacies.length,
                      itemBuilder: (context, index) {
                        final pharmacy = _filteredPharmacies[index];
                        final isSelected = _selectedPharmacies.any((p) => p['id'] == pharmacy['id']);
                        return Card(
                          color: isSelected ? Colors.lightBlue[100] : null,
                          child: ListTile(
                            title: Text(pharmacy['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Téléphone : ${pharmacy['phone']}'),
                                Text('Email : ${pharmacy['email']}'),
                              ],
                            ),
                            onTap: () => _toggleSelection(pharmacy),
                            trailing: isSelected ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: _isDeleting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.delete),
              label: Text(_isDeleting
                  ? 'Suppression...'
                  : 'Supprimer ${_selectedPharmacies.length} pharmacie(s) sélectionnée(s)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _selectedPharmacies.isEmpty || _isDeleting ? null : _deleteSelectedPharmacies,
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AdminDeletePharmacyPage extends StatefulWidget {
//   @override
//   _AdminDeletePharmacyPageState createState() => _AdminDeletePharmacyPageState();
// }

// class _AdminDeletePharmacyPageState extends State<AdminDeletePharmacyPage> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> _allPharmacies = [];
//   List<Map<String, dynamic>> _filteredPharmacies = [];
//   Map<String, dynamic>? _selectedPharmacy;
//   bool _isDeleting = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadPharmacies();
//   }

//   Future<void> _loadPharmacies() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('pharmacies')
//           .get();

//       final list = snapshot.docs.map((doc) {
//         final data = doc.data();
//         return {
//           'id': doc.id,
//           'name': data['name'] ?? 'Unknown Name',
//           'phone': data['phone'] ?? 'Not defined',
//           'email': data['email'] ?? 'No email',   // <-- Ajout email ici
//         };
//       }).toList();

//       setState(() {
//         _allPharmacies = list;
//         _filteredPharmacies = list;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading pharmacies: $e')),
//       );
//     }
//   }

//   void _filterPharmacies(String query) {
//     final lower = query.toLowerCase();
//     setState(() {
//       _filteredPharmacies = _allPharmacies.where((pharmacy) {
//         final name = (pharmacy['name'] ?? '').toLowerCase();
//         return name.contains(lower);
//       }).toList();
//     });
//   }

//   Future<void> _deleteSelectedPharmacy() async {
//     if (_selectedPharmacy == null) return;

//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('Confirm Deletion'),
//         content: Text('Delete ${_selectedPharmacy!['name']}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () => Navigator.pop(context, true),
//             child: Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     setState(() => _isDeleting = true);

//     try {
//       final docId = _selectedPharmacy!['id'];

//       await FirebaseFirestore.instance.collection('users').doc(docId).delete();
//       await FirebaseFirestore.instance.collection('pharmacies').doc(docId).delete();

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Pharmacy deleted.')),
//       );

//       setState(() {
//         _allPharmacies.removeWhere((item) => item['id'] == docId);
//         _filteredPharmacies.removeWhere((item) => item['id'] == docId);
//         _selectedPharmacy = null;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() => _isDeleting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Supprimer Pharmacie')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: _searchController,
//               onChanged: _filterPharmacies,
//               decoration: InputDecoration(
//                 labelText: 'Rechercher une pharmacie par nom',
//                 prefixIcon: Icon(Icons.search),
//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                         icon: Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           _filterPharmacies('');
//                         },
//                       )
//                     : null,
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: _filteredPharmacies.isEmpty
//                   ? Center(child: Text('Aucune pharmacie trouvée.'))
//                   : ListView.builder(
//                       itemCount: _filteredPharmacies.length,
//                       itemBuilder: (context, index) {
//                         final pharmacy = _filteredPharmacies[index];
//                         final isSelected = _selectedPharmacy != null &&
//                             _selectedPharmacy!['id'] == pharmacy['id'];
//                         return Card(
//                           color: isSelected ? Colors.lightBlue[100] : null,
//                           child: ListTile(
//                             title: Text(pharmacy['name']),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Téléphone : ${pharmacy['phone']}'),
//                                 Text('Email : ${pharmacy['email']}'),  // <-- affichage email
//                               ],
//                             ),
//                             onTap: () {
//                               setState(() {
//                                 _selectedPharmacy = pharmacy;
//                               });
//                             },
//                           ),
//                         );
//                       },
//                     ),
//             ),
//             SizedBox(height: 10),
//             if (_selectedPharmacy != null)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Pharmacie sélectionnée : ${_selectedPharmacy!['name']}',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text('Téléphone : ${_selectedPharmacy!['phone']}'),
//                   Text('Email : ${_selectedPharmacy!['email']}'), // <-- affichage email sélectionné
//                   SizedBox(height: 10),
//                   ElevatedButton.icon(
//                     icon: _isDeleting
//                         ? SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : Icon(Icons.delete),
//                     label: Text(_isDeleting ? 'Suppression...' : 'Supprimer cette pharmacie'),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                     onPressed: _isDeleting ? null : _deleteSelectedPharmacy,
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }



