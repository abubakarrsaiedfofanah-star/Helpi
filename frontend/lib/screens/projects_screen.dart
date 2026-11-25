import 'package:flutter/material.dart';
import '../core/theme.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final projects = [
      {'name': 'School Construction', 'org': 'Global Hope NGO', 'progress': 0.65, 'status': 'Active', 'milestone': '3 / 5'},
      {'name': 'Clinic Renovation', 'org': 'City Health Clinic', 'progress': 0.40, 'status': 'Active', 'milestone': '2 / 5'},
      {'name': 'Water Project', 'org': 'Hope Foundation', 'progress': 0.85, 'status': 'Planning', 'milestone': '4 / 5'},
      {'name': 'Community Center', 'org': 'Bright Future School', 'progress': 0.90, 'status': 'Active', 'milestone': '5 / 5'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Community Projects')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Institutional & Community Projects', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Browse support requests from people in the Helpi community.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          ...projects.map((p) => Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(p['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: green.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
                          child: Text(p['status'] as String, style: const TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Text('Organization: ${p['org']}', style: const TextStyle(color: orange, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Text('Progress: ${(double.parse(p['progress'].toString()) * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Spacer(),
                        Text('Milestones: ${p['milestone']}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(value: double.parse(p['progress'].toString()), minHeight: 8, color: orange, backgroundColor: orange.withValues(alpha: .10)),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
