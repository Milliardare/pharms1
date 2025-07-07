import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupprimerProduitPage extends StatefulWidget {
  @override
  _SupprimerProduitPageState createState() => _SupprimerProduitPageState();
}

class _SupprimerProduitPageState extends State<SupprimerProduitPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedProductIds = {};
  bool _isDeleting = false;

  Future<void> _deleteProducts(List<String> docIds) async {
    try {
      for (final id in docIds) {
        await FirebaseFirestore.instance.collection('boutique').doc(id).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${docIds.length} produit(s) supprimé(s).")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression.")),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirmation"),
        content: Text("Supprimer ${_selectedProductIds.length} produit(s) ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      await _deleteProducts(_selectedProductIds.toList());
      setState(() {
        _selectedProductIds.clear();
        _isDeleting = false;
      });
    }
  }

  void _toggleSelection(String docId) {
    setState(() {
      if (_selectedProductIds.contains(docId)) {
        _selectedProductIds.remove(docId);
      } else {
        _selectedProductIds.add(docId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Supprimer un produit"),
        backgroundColor: Colors.red.shade700,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Rechercher un produit...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('boutique')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nom = (data['nom'] ?? '').toString().toLowerCase();
                  final description = (data['description'] ?? '').toString().toLowerCase();
                  return _searchQuery.isEmpty ||
                      nom.contains(_searchQuery) ||
                      description.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return Center(child: Text("Aucun produit trouvé."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isSelected = _selectedProductIds.contains(doc.id);

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: isSelected ? Colors.red.shade100 : null,
                      child: ListTile(
                        onTap: () => _toggleSelection(doc.id),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: data['imageUrl'] != null && data['imageUrl'] != ''
                              ? Image.network(
                                  data['imageUrl'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.broken_image, size: 40),
                                )
                              : Icon(Icons.image_not_supported, size: 40),
                        ),
                        title: Text(data['nom'] ?? ''),
                        subtitle: Text(
                          data['description'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleSelection(doc.id),
                          activeColor: Colors.red,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_selectedProductIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                icon: _isDeleting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.delete),
                label: Text(_isDeleting
                    ? "Suppression..."
                    : "Supprimer ${_selectedProductIds.length} produit(s)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _isDeleting ? null : _confirmDelete,
              ),
            ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SupprimerProduitPage extends StatefulWidget {
//   @override
//   _SupprimerProduitPageState createState() => _SupprimerProduitPageState();
// }

// class _SupprimerProduitPageState extends State<SupprimerProduitPage> {
//   String _searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();

//   // Liste des produits sélectionnés (ids)
//   final Set<String> _selectedProductIds = {};
//   bool _isDeleting = false;

//   Future<void> _deleteProducts(BuildContext context, List<String> docIds) async {
//     try {
//       for (final docId in docIds) {
//         await FirebaseFirestore.instance.collection('boutique').doc(docId).delete();
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("${docIds.length} produit(s) supprimé(s).")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Erreur lors de la suppression.")),
//       );
//     }
//   }

//   Future<void> _confirmDeleteMultiple(BuildContext context, List<String> docIds) async {
//     final bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Confirmer la suppression'),
//         content: Text('Êtes-vous sûr de vouloir supprimer ${docIds.length} produit(s) ?'),
//         actions: [
//           TextButton(
//             child: Text('Annuler'),
//             onPressed: () => Navigator.of(ctx).pop(false),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: Text('Supprimer'),
//             onPressed: () => Navigator.of(ctx).pop(true),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       setState(() => _isDeleting = true);
//       await _deleteProducts(context, docIds);
//       setState(() {
//         _selectedProductIds.clear();
//         _isDeleting = false;
//       });
//     }
//   }

//   void _toggleSelection(String docId) {
//     setState(() {
//       if (_selectedProductIds.contains(docId)) {
//         _selectedProductIds.remove(docId);
//       } else {
//         _selectedProductIds.add(docId);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Supprimer un produit"),
//         backgroundColor: Colors.red.shade700,
//         centerTitle: true,
//         elevation: 5,
//       ),
//       body: Column(
//         children: [
//           // Barre de recherche
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Rechercher un produit...',
//                 prefixIcon: Icon(Icons.search),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//               onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('boutique')
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting)
//                   return Center(child: CircularProgressIndicator());

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
//                   return Center(
//                     child: Text(
//                       "Aucun produit trouvé.",
//                       style: TextStyle(fontSize: 18, color: Colors.grey[700]),
//                     ),
//                   );

//                 final docs = snapshot.data!.docs.where((doc) {
//                   final data = doc.data()! as Map<String, dynamic>;
//                   final nom = (data['nom'] ?? '').toString().toLowerCase();
//                   final description = (data['description'] ?? '').toString().toLowerCase();

//                   return _searchQuery.isEmpty ||
//                       nom.contains(_searchQuery) ||
//                       description.contains(_searchQuery);
//                 }).toList();

//                 return ListView.builder(
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     final data = docs[index].data()! as Map<String, dynamic>;
//                     final docId = docs[index].id;
//                     final isSelected = _selectedProductIds.contains(docId);

//                     return Card(
//                       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       elevation: 4,
//                       color: isSelected ? Colors.red.shade100 : null,
//                       child: ListTile(
//                         contentPadding: EdgeInsets.all(12),
//                         leading: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: data['imageUrl'] != null && data['imageUrl'] != ''
//                               ? Image.network(
//                                   data['imageUrl'],
//                                   width: 70,
//                                   height: 70,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (ctx, error, _) =>
//                                       Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
//                                 )
//                               : Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
//                         ),
//                         title: Text(
//                           data['nom'] ?? '',
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         subtitle: Text(
//                           data['description'] ?? '',
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(color: Colors.grey[700]),
//                         ),
//                         trailing: Checkbox(
//                           value: isSelected,
//                           onChanged: (_) => _toggleSelection(docId),
//                           activeColor: Colors.red.shade700,
//                         ),
//                         onTap: () => _toggleSelection(docId),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           if (_selectedProductIds.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: ElevatedButton.icon(
//                 icon: _isDeleting
//                     ? SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                       )
//                     : Icon(Icons.delete),
//                 label: Text(_isDeleting
//                     ? 'Suppression...'
//                     : 'Supprimer ${_selectedProductIds.length} produit(s) sélectionné(s)'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red.shade700,
//                   minimumSize: Size(double.infinity, 50),
//                 ),
//                 onPressed: _isDeleting
//                     ? null
//                     : () => _confirmDeleteMultiple(context, _selectedProductIds.toList()),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

