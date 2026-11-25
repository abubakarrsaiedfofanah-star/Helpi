import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final emergencies = [
      {'title': 'Medical', 'icon': Icons.local_hospital_outlined, 'desc': 'Immediate ambulance & medical clinic dispatch'},
      {'title': 'Fire', 'icon': Icons.local_fire_department_outlined, 'desc': 'Fire rescue & emergency evacuation'},
      {'title': 'Accident', 'icon': Icons.car_crash_outlined, 'desc': 'Roadside crash & trauma response'},
      {'title': 'Abuse', 'icon': Icons.security_outlined, 'desc': 'Safeguarding & protective shelter assistance'},
      {'title': 'Missing', 'icon': Icons.person_search_outlined, 'desc': 'Search & rescue coordination'},
      {'title': 'Disaster', 'icon': Icons.flood_outlined, 'desc': 'Flood, earthquake & storm relief'},
      {'title': 'Food', 'icon': Icons.restaurant_outlined, 'desc': 'Emergency nutrition & potable water'},
      {'title': 'Shelter', 'icon': Icons.home_outlined, 'desc': 'Temporary housing & safe haven'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Access'), backgroundColor: Colors.red, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Semantics(
            label: 'Emergency SOS banner. Tap to initiate urgent dispatch.',
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.red, Color(0xFFB71C1C)]),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: .3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Text('SOS', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(height: 14),
                  const Text('I NEED URGENT HELP', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text('Find local emergency contacts and support.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: emergencies.length,
            itemBuilder: (_, index) {
              final e = emergencies[index];
              return Semantics(
                button: true,
                label: 'Emergency category ${e['title']}: ${e['desc']}',
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      showDialog(
                        context: c,
                        builder: (_) => AlertDialog(
                          title: Text('Emergency: ${e['title']}'),
                          content: Text('Connecting you with local emergency support.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () {
                                Navigator.pop(c);
                                ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('Emergency alert dispatched for ${e['title']}!')));
                              },
                              child: const Text('Confirm Emergency'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(e['icon'] as IconData, color: Colors.red, size: 28),
                          const SizedBox(height: 8),
                          Text(e['title'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(e['desc'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size.fromHeight(52)),
            onPressed: () {
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('Connecting to local emergency dispatch services...')));
            },
            icon: const Icon(Icons.phone_in_talk),
            label: const Text('CALL EMERGENCY SERVICES', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 12),
          const Center(child: Text('Or use Helpi emergency resources & accelerated safeguarding queue.', style: TextStyle(fontSize: 12, color: Colors.black54))),
        ],
      ),
    );
  }
}
