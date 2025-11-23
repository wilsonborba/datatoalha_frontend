import 'package:flutter/material.dart';
import '../../../dal/local/storage_adapter.dart';

// Simplified for brevity: Same class for mobile/desktop since it's just a form
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _controller = TextEditingController();
  final _storage = StorageAdapter();

  @override
  void initState() {
    super.initState();
    _storage.getAdminToken().then((val) => _controller.text = val ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Settings")),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                "Enter your Admin Token to enable creation and closing of polls.",
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "X-Admin-Token",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _storage.saveAdminToken(_controller.text.trim());
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Token Saved")),
                    );
                },
                child: const Text("Save Token"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
