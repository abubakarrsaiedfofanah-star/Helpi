import 'package:flutter/material.dart';
import '../../core/theme.dart';

class OrganizationDirectoryScreen extends StatefulWidget {
  const OrganizationDirectoryScreen({super.key});

  @override
  State<OrganizationDirectoryScreen> createState() => _OrganizationDirectoryScreenState();
}

class _OrganizationDirectoryScreenState extends State<OrganizationDirectoryScreen> {
  final List<Map<String, dynamic>> _orgs = [
    {
      'name': 'Nairobi Community Medical Clinic',
      'type': 'CLINIC',
      'country': 'KE',
      'city': 'Nairobi',
      'verified': true,
      'description': 'Providing emergency healthcare and subsidized medicine to vulnerable families.',
    },
    {
      'name': 'St. Jude Primary Community School',
      'type': 'SCHOOL',
      'country': 'KE',
      'city': 'Mombasa',
      'verified': true,
      'description': 'Verified community school supporting educational materials and school nutrition programs.',
    },
    {
      'name': 'Hope Relief & Food Foundation',
      'type': 'NGO',
      'country': 'KE',
      'city': 'Kisumu',
      'verified': true,
      'description': 'Coordinating emergency food distribution and clean water access across western regions.',
    },
    {
      'name': 'Kajiado Safe Haven Shelter',
      'type': 'SHELTER',
      'country': 'KE',
      'city': 'Kajiado',
      'verified': true,
      'description': 'Providing temporary emergency housing, safeguarding protection, and casework support.',
    },
  ];

  String _filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'ALL' ? _orgs : _orgs.where((o) => o['type'] == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Organization Network')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['ALL', 'CLINIC', 'SCHOOL', 'NGO', 'SHELTER'].map((cat) {
                  final selected = _filter == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: orange,
                      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                      onSelected: (_) => setState(() => _filter = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: filtered.length,
              itemBuilder: (_, index) {
                final org = filtered[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(org['type'], style: const TextStyle(color: orange, fontWeight: FontWeight.w900, fontSize: 11)),
                            ),
                            const Spacer(),
                            if (org['verified']) ...[
                              const Icon(Icons.verified, color: green, size: 18),
                              const SizedBox(width: 4),
                              const Text('Verified Institution', style: TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(org['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text('${org['city']}, ${org['country']}', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(org['description'], style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      ],
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
