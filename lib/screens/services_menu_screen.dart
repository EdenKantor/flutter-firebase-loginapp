import 'package:flutter/material.dart';
import 'package:logionapp/main.dart';

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _MenuItem(this.title, this.subtitle, this.icon, this.color);
}

class ServicesMenuScreen extends StatelessWidget {
  /// The service the user selected on the Dashboard screen — shown at the top
  /// so the menu feels connected to the previous choice.
  final String selected;

  const ServicesMenuScreen({super.key, required this.selected});

  static const _items = <_MenuItem>[
    _MenuItem(
      'Schedule a visit',
      'Pick a date and a time slot',
      Icons.event_available,
      Color(0xFF3B82F6),
    ),
    _MenuItem(
      'Get a quote',
      'See estimated price for the job',
      Icons.request_quote,
      Color(0xFF22C55E),
    ),
    _MenuItem(
      'Chat with a pro',
      'Open chat with a verified professional',
      Icons.chat_bubble_outline,
      Color(0xFFFBBF24),
    ),
    _MenuItem(
      'My bookings',
      'View past and upcoming bookings',
      Icons.bookmark_border,
      Color(0xFF8B5CF6),
    ),
    _MenuItem(
      'Support',
      'Talk to customer support',
      Icons.support_agent,
      Color(0xFFEF4444),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Options'),
        // Explicit back button to match the exercise requirement.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: kPrimaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Selected service: $selected',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._items.map(
              (item) => Card(
                elevation: 0,
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(item.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.title} (not implemented)'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
