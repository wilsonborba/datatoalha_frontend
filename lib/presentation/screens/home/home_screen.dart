import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/services/voting_service.dart';
import '../../components/responsive_layout.dart';
import '../admin_settings/admin_settings_screen.dart';
import '../create_poll/create_poll_screen.dart';
import '../poll_detail/poll_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data on init
    Future.microtask(
      () => Provider.of<VotingService>(context, listen: false).fetchOpenPolls(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Apple-like grey
      appBar: AppBar(
        title: const Text("Voting App", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreatePollScreen()),
            ),
          ),
        ],
      ),
      body: ResponsiveLayout(mobile: HomeMobile(), desktop: HomeDesktop()),
    );
  }
}

// --- Mobile Implementation ---
class HomeMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<VotingService>();

    if (service.isLoading)
      return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: service.openPolls.length,
      itemBuilder: (context, index) {
        final poll = service.openPolls[index];
        return Card(
          elevation: 0, // Flat minimalist
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              poll.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${poll.options.length} Options • ${poll.status}"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PollDetailScreen(pollId: poll.id, title: poll.title),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// --- Desktop Implementation ---
class HomeDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<VotingService>();

    if (service.isLoading)
      return const Center(child: CircularProgressIndicator());

    return Center(
      child: Container(
        width: 800, // Limit width for cleaner desktop look
        child: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: service.openPolls.length,
          itemBuilder: (context, index) {
            final poll = service.openPolls[index];
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PollDetailScreen(pollId: poll.id, title: poll.title),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      poll.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Status: ${poll.status}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
