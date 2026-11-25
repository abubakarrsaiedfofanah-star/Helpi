import 'package:flutter/material.dart';
import 'case_create_screen.dart';
import 'explore_screen.dart';
import 'referral_screen.dart';
import '../widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('Helpi')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Connect with the Helpi community',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
                'Helpi connects people seeking support with helpers and NGOs. Details are discussed directly in chat.',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),
            ActionTile(
                icon: Icons.monetization_on,
                title: 'POST A REQUEST',
                subtitle: 'Choose a category and amount',
                onTap: () => Navigator.push(
                    c,
                    MaterialPageRoute(
                        builder: (_) => const CaseCreateScreen()))),
            const SizedBox(height: 10),
            ActionTile(
                icon: Icons.volunteer_activism,
                title: 'I WANT TO HELP',
                subtitle:
                    'Browse people by group, offer an amount and contact them',
                onTap: () => Navigator.push(c,
                    MaterialPageRoute(builder: (_) => const ExploreScreen()))),
            const SizedBox(height: 10),
            ActionTile(
                icon: Icons.group_add,
                title: 'REFER SOMEONE',
                subtitle: 'Share a request with their permission',
                onTap: () => Navigator.push(c,
                    MaterialPageRoute(builder: (_) => const ReferralScreen()))),
          ],
        ),
      );
}
