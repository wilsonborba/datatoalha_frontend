import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/services/voting_service.dart';
import '../../components/responsive_layout.dart';

class CreatePollScreen extends StatelessWidget {
  const CreatePollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Poll")),
      body: ResponsiveLayout(
        mobile: CreatePollMobile(),
        desktop: CreatePollDesktop(),
      ),
    );
  }
}

// Shared Form Logic to avoid code duplication
class CreatePollForm extends StatefulWidget {
  const CreatePollForm({super.key});

  @override
  State<CreatePollForm> createState() => _CreatePollFormState();
}

class _CreatePollFormState extends State<CreatePollForm> {
  final _titleCtrl = TextEditingController();
  // Initialize with 2 empty options
  final List<TextEditingController> _optionCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isLoading = false;

  void _addOption() {
    setState(() {
      _optionCtrls.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionCtrls.length > 2) {
      setState(() {
        _optionCtrls.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Minimum 2 options required")),
      );
    }
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final options = _optionCtrls
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (title.isEmpty || options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill title and at least 2 options"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<VotingService>().createPoll(title, options);
      if (mounted) {
        Navigator.pop(context); // Go back to Home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Poll Created Successfully")),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed. Check Admin Token.")),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          "Poll Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(
            labelText: "Poll Title",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Options",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              label: const Text("Add Option"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._optionCtrls.asMap().entries.map((entry) {
          int idx = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: "Option ${idx + 1}",
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                if (_optionCtrls.length > 2)
                  IconButton(
                    onPressed: () => _removeOption(idx),
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                  ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 40),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("PUBLISH POLL"),
          ),
        ),
      ],
    );
  }
}

// --- Mobile Implementation ---
class CreatePollMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const CreatePollForm();
  }
}

// --- Desktop Implementation ---
class CreatePollDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        margin: const EdgeInsets.all(32),
        // We wrap the form in a container with styling for desktop
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: const CreatePollForm(),
        ),
      ),
    );
  }
}
