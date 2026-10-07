import 'package:flutter/material.dart';
import 'case_create_screen.dart';
import 'offer_screen.dart';
import 'referral_screen.dart';
import 'emergency_screen.dart';
import '../widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Financial Help & Giving')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('How can Helpi assist?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Secure monetary assistance, donations, and verified fundraising.', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),
            ActionTile(icon: Icons.monetization_on, title: 'I NEED FINANCIAL HELP', subtitle: 'Create a private request for monetary verification', onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const CaseCreateScreen()))),
            const SizedBox(height: 10),
            ActionTile(icon: Icons.volunteer_activism, title: 'I WANT TO DONATE', subtitle: 'Provide secure financial support & contributions', onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const OfferScreen()))),
            const SizedBox(height: 10),
            ActionTile(icon: Icons.group_add, title: 'SOMEONE NEEDS MONEY', subtitle: 'Refer a financial case with their consent', onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const ReferralScreen()))),
            const SizedBox(height: 10),
            Card(
              color: const Color(0xFFFFE9E1),
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
                title: const Text('Urgent or emergency situation?', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Use emergency assistance routing and local official services where available.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
              ),
            ),
          ],
        ),
      );
}
