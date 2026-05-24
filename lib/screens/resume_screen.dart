import 'package:flutter/material.dart';

class _ResumeFile {
  final String name;
  final String path;
  const _ResumeFile({required this.name, required this.path});
}

/// Exercise 7 — Resume/Files screen with a list of uploaded items and two
/// upload buttons at the bottom. Everything is in-memory / dummy; no real
/// uploads happen.
class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  static const _pink = Color(0xFFEC4899);

  final List<_ResumeFile> _files = [
    const _ResumeFile(
      name: 'CV_NoaSivan.pdf',
      path: '/storage/emulated/0/Documents/CV_NoaSivan.pdf',
    ),
    const _ResumeFile(
      name: 'Portfolio_2025.pdf',
      path: '/storage/emulated/0/Documents/Portfolio_2025.pdf',
    ),
    const _ResumeFile(
      name: 'Cover_Letter.pdf',
      path: '/storage/emulated/0/Documents/Cover_Letter.pdf',
    ),
  ];

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resume saved'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _uploadFromLink() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload from Link'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://example.com/file.pdf',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    final last = result.split('/').last;
    final filename = last.isEmpty ? 'untitled.pdf' : last;
    setState(() {
      _files.add(_ResumeFile(name: filename, path: result));
    });
  }

  void _uploadFromDevice() {
    // Simulate a device file picker by adding a placeholder file.
    final index = _files.length + 1;
    setState(() {
      _files.add(
        _ResumeFile(
          name: 'document_$index.pdf',
          path: '/storage/emulated/0/Downloads/document_$index.pdf',
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File added (demo)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(
                color: _pink,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _files.isEmpty
                ? Center(
                    child: Text(
                      'No files yet — upload something below',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _files.length,
                    itemBuilder: (context, i) {
                      final file = _files[i];
                      return Dismissible(
                        key: ValueKey('${file.name}_$i'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red.shade400,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) =>
                            setState(() => _files.removeAt(i)),
                        child: ListTile(
                          leading: const _PdfBadge(),
                          title: Text(
                            file.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            file.path,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _uploadFromLink,
                      style: _pinkButtonStyle(),
                      child: const Text('Upload from Link'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _uploadFromDevice,
                      style: _pinkButtonStyle(),
                      child: const Text('Upload from Device'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _pinkButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _pink,
      foregroundColor: Colors.white,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(vertical: 14),
      elevation: 0,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}

class _PdfBadge extends StatelessWidget {
  const _PdfBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.description_outlined,
              size: 22,
              color: Color(0xFF94A3B8),
            ),
          ),
          Positioned(
            left: 3,
            bottom: 3,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                'PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
