import 'package:flutter/material.dart';
import 'package:logionapp/main.dart';

class _Service {
  final String name;
  final IconData icon;
  final Color color;
  const _Service(this.name, this.icon, this.color);
}

// Shared service catalogue. File-private constant reused by both the
// standalone DashboardScreen (Exercise 3) and DashboardContent (Exercise 4).
const _services = <_Service>[
  _Service('Cleaning', Icons.cleaning_services, Color(0xFF60A5FA)),
  _Service('Plumber', Icons.plumbing, Color(0xFFEF4444)),
  _Service('Electrician', Icons.electrical_services, Color(0xFFFBBF24)),
  _Service('Painter', Icons.format_paint, Color(0xFF3B82F6)),
  _Service('Carpenter', Icons.handyman, Color(0xFFF59E0B)),
  _Service('Gardener', Icons.yard, Color(0xFF22C55E)),
];

/// Reusable grid content (no Scaffold) — embedded inside both DashboardScreen
/// and the Home tab of MainNavScreen. Exposes the user's current selection
/// via [onServiceChanged] so the parent can wire a FAB or other action.
class DashboardContent extends StatefulWidget {
  final ValueChanged<String>? onServiceChanged;

  const DashboardContent({super.key, this.onServiceChanged});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Tell the parent about the initial selection on the next frame, so a
    // FAB built outside this widget can use a real service name from the
    // start (not the placeholder 'Cleaning' guess).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onServiceChanged?.call(_services[_selectedIndex].name);
    });
  }

  void _select(int i) {
    setState(() => _selectedIndex = i);
    widget.onServiceChanged?.call(_services[i].name);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Which service\ndo you need?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _services.length,
                itemBuilder: (context, i) {
                  final service = _services[i];
                  final selected = i == _selectedIndex;
                  return _ServiceTile(
                    service: service,
                    selected: selected,
                    onTap: () => _select(i),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final _Service service;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? kPrimaryColor.withValues(alpha: 0.08)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kPrimaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(service.icon, color: service.color, size: 44),
            const SizedBox(height: 14),
            Text(
              service.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
