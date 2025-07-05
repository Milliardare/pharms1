import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupprimerProduitPage extends StatefulWidget {
  @override
  _SupprimerProduitPageState createState() => _SupprimerProduitPageState();
}

class _SupprimerProduitPageState extends State<SupprimerProduitPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  Future<void> _deleteProduct(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('boutique').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produit supprimé.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression.")),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, String docId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce produit ?'),
        actions: [
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteProduct(context, docId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Supprimer un produit"),
        backgroundColor: Colors.red.shade700,
        centerTitle: true,
        elevation: 5,
      ),
      body: Column(
        children: [
          // ✅ Barre de recherche
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('boutique')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return Center(
                    child: Text(
                      "Aucun produit trouvé.",
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  );

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data()! as Map<String, dynamic>;
                  final nom = (data['nom'] ?? '').toString().toLowerCase();
                  final description = (data['description'] ?? '').toString().toLowerCase();

                  return _searchQuery.isEmpty ||
                      nom.contains(_searchQuery) ||
                      description.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data()! as Map<String, dynamic>;
                    final docId = docs[index].id;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: data['imageUrl'] != null && data['imageUrl'] != ''
                              ? Image.network(
                                  data['imageUrl'],
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, error, _) =>
                                      Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                                )
                              : Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                        ),
                        title: Text(
                          data['nom'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          data['description'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red.shade700, size: 28),
                          tooltip: 'Supprimer ce produit',
                          onPressed: () => _confirmDelete(context, docId),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

