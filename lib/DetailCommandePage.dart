



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class DetailCommandePage extends StatelessWidget {
  final DocumentSnapshot commande;
  final Future<void> Function(DocumentSnapshot)? onAction;
  final Icon? icon;

  const DetailCommandePage({
    Key? key,
    required this.commande,
    this.onAction,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = commande.data() as Map<String, dynamic>;
    final date = DateTime.fromMillisecondsSinceEpoch(d['dateCommande'].seconds * 1000);

    return Scaffold(
      appBar: AppBar(
        title: Text('order_details'.tr()),
        backgroundColor: const Color.fromARGB(255, 37, 192, 58),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info('client'.tr(), '${d['prenom']} ${d['nom']}'),
            _info('phone'.tr(), d['telephone']),
            _info('pharmacy'.tr(), d['pharmacie']),
            _info('delivery_location'.tr(), d['lieuLivraison']),
            _info('order_date'.tr(), date.toLocal().toString().split('.')[0]),
            _info('status'.tr(), d['statut']),
            const SizedBox(height: 45),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.call),
                    label: Text('call'.tr()),
                    onPressed: () => _launch('tel:${d['telephone']}'),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.message),
                    label: Text('whatsapp'.tr()),
                    onPressed: () => _launch('https://wa.me/${d['telephone']}'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.navigation),
              label: Text('open_in_maps'.tr()),
              onPressed: () => _launch(
                'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(d['lieuLivraison'])}',
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const Spacer(),
            if (d['statut'] != 'livrée' && onAction != null)
              ElevatedButton.icon(
                icon: icon ?? const Icon(Icons.flash_on),
                label: Text('accept_order'.tr()),
                onPressed: () async {
                  await onAction!(commande);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 16),
            children: [
              TextSpan(text: '$title : ', style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: value),
            ],
          ),
        ),
      );

  Future<void> _launch(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

