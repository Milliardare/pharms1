import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'DetailCommandePage.dart';

class LivreurPage extends StatefulWidget {
  const LivreurPage({Key? key}) : super(key: key);

  @override
  State<LivreurPage> createState() => _LivreurPageState();
}

class _LivreurPageState extends State<LivreurPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('delivery_space'.tr()),
        backgroundColor: const Color.fromARGB(255, 37, 192, 58),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(icon: Icon(Icons.list_alt), text: 'available'.tr()),
            Tab(icon: Icon(Icons.delivery_dining), text: 'in_progress'.tr()),
            Tab(icon: Icon(Icons.history), text: 'history'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _streamCommandes(
            query: FirebaseFirestore.instance
                .collection('commandes')
                .where('statut', isEqualTo: 'en_attente')
                .where('livreurId', isNull: true)
                .orderBy('dateCommande', descending: true),
            onTap: _claimCommande,
            trailingBuilder: (_) =>
                const Icon(Icons.flash_on, color: Colors.orange),
          ),
          _streamCommandes(
            query: FirebaseFirestore.instance
                .collection('commandes')
                .where('statut', isEqualTo: 'en_cours')
                .where('livreurId', isEqualTo: _uid)
                .orderBy('dateCommande', descending: true),
            onTap: _completeCommande,
            trailingBuilder: (_) => const Icon(Icons.check, color: Colors.blue),
          ),
          _streamCommandes(
            query: FirebaseFirestore.instance
                .collection('commandes')
                .where('statut', isEqualTo: 'livrée')
                .where('livreurId', isEqualTo: _uid)
                .orderBy('dateCommande', descending: true),
            onTap: null,
            trailingBuilder: (_) =>
                const Icon(Icons.check_circle, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _streamCommandes({
    required Query query,
    required Future<void> Function(DocumentSnapshot)? onTap,
    required Widget Function(DocumentSnapshot) trailingBuilder,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

        final now = DateTime.now();
        final docs = snap.data!.docs.where((doc) {
          if (doc['dateCommande'] == null) return false;
          final ts = doc['dateCommande'] as Timestamp;
          final age = now.difference(ts.toDate()).inDays;
          return age <= 35;
        }).toList();

        if (docs.isEmpty) return Center(child: Text('no_orders'.tr()));

        return ListView(
          children: docs.map((d) => _buildCard(d, onTap, trailingBuilder)).toList(),
        );
      },
    );
  }

  Widget _buildCard(
    DocumentSnapshot doc,
    Future<void> Function(DocumentSnapshot)? onTap,
    Widget Function(DocumentSnapshot) trailingBuilder,
  ) {
    final d = doc.data() as Map<String, dynamic>;
    final date = DateTime.fromMillisecondsSinceEpoch(
        d['dateCommande'].seconds * 1000);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.medical_services, color: Colors.green),
        title: Text('${d['prenom']} ${d['nom']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📞 ${d['telephone']}'),
            Text('🏥 ${d['pharmacie']}'),
            Text(
              '📅 ${date.toLocal().toString().split('.')[0]}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: trailingBuilder(doc),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailCommandePage(
              commande: doc,
              onAction: onTap, // Action confirmée uniquement depuis la page de détail
              icon: trailingBuilder(doc) as Icon?,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _completeCommande(DocumentSnapshot doc) async {
    await doc.reference.update({
      'statut': 'livrée',
      'dateLivraison': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('order_delivered'.tr())),
      );
    }
  }

  Future<void> _claimCommande(DocumentSnapshot doc) async {
    final ref = doc.reference;
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final fresh = await tx.get(ref);
        final data = fresh.data() as Map<String, dynamic>;
        if ((data['livreurId'] == null || data['livreurId'] == '') &&
            data['statut'] == 'en_attente') {
          tx.update(ref, {
            'livreurId': _uid,
            'statut': 'en_cours',
            'dateAcceptation': FieldValue.serverTimestamp(),
          });
        } else {
          throw Exception("Commande déjà prise.");
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('order_accepted'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('order_taken'.tr())),
        );
      }
    }
  }
}


