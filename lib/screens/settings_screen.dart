import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logionapp/main.dart';

/// Exercise 6 — Settings screen with three dummy toggles. The toggles don't
/// control any real app behavior, but their on/off state is persisted to
/// Firestore (users/{uid}) so it survives app restarts and signs-in on
/// other devices.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Firestore field names — kept here so a typo is caught in one place.
  static const _notificationsField = 'notificationsEnabled';
  static const _darkModeField = 'darkModeEnabled';
  static const _emailUpdatesField = 'emailUpdatesEnabled';

  bool _notifications = false;
  bool _darkMode = false;
  bool _emailUpdates = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  DocumentReference<Map<String, dynamic>>? _userDocRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  Future<void> _loadSettings() async {
    final ref = _userDocRef();
    if (ref == null) {
      setState(() => _loaded = true);
      return;
    }
    try {
      final snap = await ref.get();
      final data = snap.data();
      setState(() {
        _notifications = data?[_notificationsField] as bool? ?? false;
        _darkMode = data?[_darkModeField] as bool? ?? false;
        _emailUpdates = data?[_emailUpdatesField] as bool? ?? false;
        _loaded = true;
      });
    } catch (_) {
      // Permission denied / network — just show defaults rather than crash.
      setState(() => _loaded = true);
    }
  }

  Future<void> _persist(String field, bool value) async {
    final ref = _userDocRef();
    if (ref == null) return;
    // merge:true creates the doc if it doesn't exist (e.g., for phone users)
    // and updates only this field if it does.
    await ref.set({field: value}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _sectionTitle('Preferences'),
        const SizedBox(height: 8),
        _ToggleTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Receive push alerts',
          value: _notifications,
          onChanged: (v) {
            setState(() => _notifications = v);
            _persist(_notificationsField, v);
          },
        ),
        _ToggleTile(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          subtitle: 'Use a darker theme',
          value: _darkMode,
          onChanged: (v) {
            setState(() => _darkMode = v);
            _persist(_darkModeField, v);
          },
        ),
        _ToggleTile(
          icon: Icons.mark_email_unread_outlined,
          title: 'Email Updates',
          subtitle: 'Newsletter & product news',
          value: _emailUpdates,
          onChanged: (v) {
            setState(() => _emailUpdates = v);
            _persist(_emailUpdatesField, v);
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Settings sync to Firestore',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: kPrimaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        secondary: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: kPrimaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: kPrimaryColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
