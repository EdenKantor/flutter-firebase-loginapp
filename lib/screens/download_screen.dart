import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logionapp/main.dart';

/// Three visual/logical states a single app row can be in.
enum DownloadState { idle, downloading, downloaded }

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  // Hardcoded list of apps — this is a dummy screen, no real downloads happen.
  static const _apps = <_AppInfo>[
    _AppInfo(name: 'App 1', description: 'Lorem ipsum dolor sit amet'),
    _AppInfo(name: 'App 2', description: 'Lorem ipsum dolor sit amet'),
    _AppInfo(name: 'App 3', description: 'Lorem ipsum dolor sit amet'),
    _AppInfo(name: 'App 4', description: 'Lorem ipsum dolor sit amet'),
    _AppInfo(name: 'App 5', description: 'Lorem ipsum dolor sit amet'),
    _AppInfo(name: 'App 6', description: 'Lorem ipsum dolor sit amet'),
    _AppInfo(name: 'App 7', description: 'Lorem ipsum dolor sit amet'),
    _AppInfo(name: 'App 8', description: 'Lorem ipsum dolor sit amet'),
  ];

  // A palette so each row gets a slightly different gradient on its icon.
  static const _palette = <List<Color>>[
    [Color(0xFFE53935), Color(0xFFD81B60)],
    [Color(0xFF8E24AA), Color(0xFF5E35B1)],
    [Color(0xFF1E88E5), Color(0xFF00ACC1)],
    [Color(0xFF43A047), Color(0xFF7CB342)],
    [Color(0xFFFB8C00), Color(0xFFF4511E)],
    [Color(0xFF6D4C41), Color(0xFF8D6E63)],
    [Color(0xFF3949AB), Color(0xFF1E88E5)],
    [Color(0xFFD81B60), Color(0xFF8E24AA)],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apps')),
      body: ListView.separated(
        itemCount: _apps.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, indent: 80, endIndent: 16),
        itemBuilder: (context, i) => _AppDownloadTile(
          app: _apps[i],
          gradient: _palette[i % _palette.length],
        ),
      ),
    );
  }
}

class _AppInfo {
  final String name;
  final String description;
  const _AppInfo({required this.name, required this.description});
}

class _AppDownloadTile extends StatefulWidget {
  final _AppInfo app;
  final List<Color> gradient;

  const _AppDownloadTile({required this.app, required this.gradient});

  @override
  State<_AppDownloadTile> createState() => _AppDownloadTileState();
}

class _AppDownloadTileState extends State<_AppDownloadTile> {
  DownloadState _state = DownloadState.idle;
  double _progress = 0.0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onPressed() {
    switch (_state) {
      case DownloadState.idle:
        _startDownload();
      case DownloadState.downloading:
        _cancelDownload();
      case DownloadState.downloaded:
        _showOpenSnack();
    }
  }

  void _startDownload() {
    setState(() {
      _state = DownloadState.downloading;
      _progress = 0.0;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress += 0.04;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _state = DownloadState.downloaded;
          timer.cancel();
        }
      });
    });
  }

  void _cancelDownload() {
    _timer?.cancel();
    setState(() {
      _state = DownloadState.idle;
      _progress = 0.0;
    });
  }

  void _showOpenSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${widget.app.name}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.ac_unit, color: Colors.white, size: 28),
      ),
      title: Text(
        widget.app.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        widget.app.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: SizedBox(width: 72, child: Center(child: _buildButton())),
    );
  }

  Widget _buildButton() {
    switch (_state) {
      case DownloadState.idle:
        return TextButton(
          onPressed: _onPressed,
          style: TextButton.styleFrom(
            backgroundColor: kPrimaryColor.withValues(alpha: 0.08),
            foregroundColor: kPrimaryColor,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            minimumSize: const Size(0, 32),
          ),
          child: const Text(
            'GET',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        );
      case DownloadState.downloading:
        return GestureDetector(
          onTap: _onPressed,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  value: _progress,
                  color: kPrimaryColor,
                  strokeWidth: 3,
                  backgroundColor: kPrimaryColor.withValues(alpha: 0.15),
                ),
              ),
              const Icon(Icons.stop, color: kPrimaryColor, size: 14),
            ],
          ),
        );
      case DownloadState.downloaded:
        return ElevatedButton(
          onPressed: _onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            minimumSize: const Size(0, 32),
            elevation: 0,
          ),
          child: const Text(
            'OPEN',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        );
    }
  }
}
