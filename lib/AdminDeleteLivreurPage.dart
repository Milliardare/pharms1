import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDeleteLivreurPage extends StatefulWidget {
  @override
  _AdminDeleteLivreurPageState createState() => _AdminDeleteLivreurPageState();
}

class _AdminDeleteLivreurPageState extends State<AdminDeleteLivreurPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allLivreurs = [];
  List<Map<String, dynamic>> _filteredLivreurs = [];
  List<Map<String, dynamic>> _selectedLivreurs = [];
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadLivreurs();
  }

  Future<void> _loadLivreurs() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'livreur')
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nom': data['nom'] ?? 'Nom inconnu',
          'telephone': data['telephone'] ?? 'Non défini',
        };
      }).toList();

      setState(() {
        _allLivreurs = list;
        _filteredLivreurs = list;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement : $e')),
      );
    }
  }

  void _filterLivreurs(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _filteredLivreurs = _allLivreurs.where((livreur) {
        final nom = (livreur['nom'] ?? '').toLowerCase();
        return nom.contains(lower);
      }).toList();
    });
  }

  void _toggleSelection(Map<String, dynamic> livreur) {
    setState(() {
      if (_selectedLivreurs.any((l) => l['id'] == livreur['id'])) {
        _selectedLivreurs.removeWhere((l) => l['id'] == livreur['id']);
      } else {
        _selectedLivreurs.add(livreur);
      }
    });
  }

  Future<void> _deleteSelectedLivreurs() async {
    if (_selectedLivreurs.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Supprimer ${_selectedLivreurs.length} livreur(s) sélectionné(s) ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      for (final livreur in _selectedLivreurs) {
        final docId = livreur['id'];
        await FirebaseFirestore.instance.collection('users').doc(docId).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedLivreurs.length} livreur(s) supprimé(s).')),
      );

      setState(() {
        final idsToRemove = _selectedLivreurs.map((l) => l['id']).toSet();
        _allLivreurs.removeWhere((l) => idsToRemove.contains(l['id']));
        _filteredLivreurs.removeWhere((l) => idsToRemove.contains(l['id']));
        _selectedLivreurs.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Supprimer des livreurs')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterLivreurs,
              decoration: InputDecoration(
                labelText: 'Rechercher un livreur par nom',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterLivreurs('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredLivreurs.isEmpty
                  ? Center(child: Text('Aucun livreur trouvé.'))
                  : ListView.builder(
                      itemCount: _filteredLivreurs.length,
                      itemBuilder: (context, index) {
                        final livreur = _filteredLivreurs[index];
                        final isSelected = _selectedLivreurs.any((l) => l['id'] == livreur['id']);
                        return Card(
                          color: isSelected ? Colors.green[100] : null,
                          child: ListTile(
                            title: Text(livreur['nom']),
                            subtitle: Text('Téléphone : ${livreur['telephone']}'),
                            onTap: () => _toggleSelection(livreur),
                            trailing: isSelected
                                ? Icon(Icons.check_box, color: Colors.green)
                                : Icon(Icons.check_box_outline_blank),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
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
                  : 'Supprimer ${_selectedLivreurs.length} livreur(s) sélectionné(s)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _selectedLivreurs.isEmpty || _isDeleting ? null : _deleteSelectedLivreurs,
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AdminDeleteLivreurPage extends StatefulWidget {
//   @override
//   _AdminDeleteLivreurPageState createState() => _AdminDeleteLivreurPageState();
// }

// class _AdminDeleteLivreurPageState extends State<AdminDeleteLivreurPage> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> _allLivreurs = [];
//   List<Map<String, dynamic>> _filteredLivreurs = [];
//   Map<String, dynamic>? _selectedLivreur;
//   bool _isDeleting = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadLivreurs();
//   }

//   Future<void> _loadLivreurs() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('role', isEqualTo: 'livreur')
//           .get();

//       final list = snapshot.docs.map((doc) {
//         final data = doc.data();
//         return {
//           'id': doc.id,
//           'nom': data['nom'] ?? 'Nom inconnu',
//           'telephone': data['telephone'] ?? 'Non défini',
//         };
//       }).toList();

//       setState(() {
//         _allLivreurs = list;
//         _filteredLivreurs = list;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erreur de chargement : $e')),
//       );
//     }
//   }

//   void _filterLivreurs(String query) {
//     final lower = query.toLowerCase();
//     setState(() {
//       _filteredLivreurs = _allLivreurs.where((livreur) {
//         final nom = (livreur['nom'] ?? '').toLowerCase();
//         return nom.contains(lower);
//       }).toList();
//     });
//   }

//   Future<void> _deleteSelectedLivreur() async {
//     if (_selectedLivreur == null) return;

//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('Confirmer la suppression'),
//         content: Text('Supprimer ${_selectedLivreur!['nom']} ?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('Annuler'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () => Navigator.pop(context, true),
//             child: Text('Supprimer'),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     setState(() => _isDeleting = true);
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(_selectedLivreur!['id'])
//           .delete();

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Livreur supprimé.')),
//       );

//       setState(() {
//         _allLivreurs.removeWhere((item) => item['id'] == _selectedLivreur!['id']);
//         _filteredLivreurs.removeWhere((item) => item['id'] == _selectedLivreur!['id']);
//         _selectedLivreur = null;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erreur : $e')),
//       );
//     } finally {
//       setState(() => _isDeleting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Supprimer un livreur')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: _searchController,
//               onChanged: _filterLivreurs,
//               decoration: InputDecoration(
//                 labelText: 'Rechercher un livreur par nom',
//                 prefixIcon: Icon(Icons.search),
//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                         icon: Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           _filterLivreurs('');
//                         },
//                       )
//                     : null,
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: _filteredLivreurs.isEmpty
//                   ? Center(child: Text('Aucun livreur trouvé.'))
//                   : ListView.builder(
//                       itemCount: _filteredLivreurs.length,
//                       itemBuilder: (context, index) {
//                         final livreur = _filteredLivreurs[index];
//                         final isSelected = _selectedLivreur != null &&
//                             _selectedLivreur!['id'] == livreur['id'];
//                         return Card(
//                           color: isSelected ? Colors.green[100] : null,
//                           child: ListTile(
//                             title: Text(livreur['nom']),
//                             subtitle: Text('Téléphone : ${livreur['telephone']}'),
//                             onTap: () {
//                               setState(() {
//                                 _selectedLivreur = livreur;
//                               });
//                             },
//                           ),
//                         );
//                       },
//                     ),
//             ),
//             const SizedBox(height: 10),
//             if (_selectedLivreur != null)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Livreur sélectionné : ${_selectedLivreur!['nom']}',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text('Téléphone : ${_selectedLivreur!['telephone']}'),
//                   const SizedBox(height: 10),
//                   ElevatedButton.icon(
//                     icon: _isDeleting
//                         ? SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : Icon(Icons.delete),
//                     label: Text(_isDeleting ? 'Suppression...' : 'Supprimer ce livreur'),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                     onPressed: _isDeleting ? null : _deleteSelectedLivreur,
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


