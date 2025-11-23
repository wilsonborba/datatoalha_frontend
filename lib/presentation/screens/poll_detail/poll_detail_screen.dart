import 'package:datatoalha_frontend/domain/models/poll_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/services/voting_service.dart';
import '../../components/responsive_layout.dart';

class PollDetailScreen extends StatelessWidget {
  final int pollId;
  final String title;

  const PollDetailScreen({
    super.key,
    required this.pollId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Vote"),
              Tab(text: "Results"),
              Tab(text: "My Vote"),
            ],
          ),
        ),
        body: ResponsiveLayout(
          mobile: PollDetailMobile(pollId: pollId),
          desktop: PollDetailDesktop(pollId: pollId),
        ),
      ),
    );
  }
}

// Logic for the Vote Tab
class VoteForm extends StatefulWidget {
  final int pollId;
  const VoteForm({required this.pollId});

  @override
  State<VoteForm> createState() => _VoteFormState();
}

class _VoteFormState extends State<VoteForm> {
  final _cpfCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  int? _selectedOption;
  // Note: In a real app, you'd fetch options here.
  // For MVP, we are assuming we passed options or fetch results to see options.
  // To keep it simple, I'll fetch results first to get the option list.

  @override
  Widget build(BuildContext context) {
    final service = context.watch<VotingService>();

    return FutureBuilder(
      future: service.getResults(
        widget.pollId,
      ), // Using getResults to get option list
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final poll = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              controller: _cpfCtrl,
              decoration: const InputDecoration(
                labelText: "CPF",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dobCtrl,
              decoration: const InputDecoration(
                labelText: "Birth Date (YYYY-MM-DD)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Choose an option:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...poll.options.map(
              (opt) => RadioListTile<int>(
                title: Text(opt.optionText),
                value: opt.optionId,
                groupValue: _selectedOption,
                onChanged: (v) => setState(() => _selectedOption = v),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_selectedOption == null) return;
                try {
                  await service.vote(
                    widget.pollId,
                    _cpfCtrl.text,
                    _dobCtrl.text,
                    _selectedOption!,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vote cast successfully!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error casting vote")),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("CONFIRM VOTE"),
              ),
            ),
            // Admin Only: Close Poll
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => service
                  .closePoll(widget.pollId)
                  .then((_) => Navigator.pop(context)),
              child: const Text(
                "Admin: Close Poll",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PollDetailMobile extends StatelessWidget {
  final int pollId;
  const PollDetailMobile({required this.pollId});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        VoteForm(pollId: pollId),
        ResultsView(pollId: pollId), // Define similar to VoteForm but ReadOnly
        MyVoteView(pollId: pollId), // Input CPF/Date -> Show Option
      ],
    );
  }
}

class PollDetailDesktop extends StatelessWidget {
  final int pollId;
  const PollDetailDesktop({required this.pollId});

  @override
  Widget build(BuildContext context) {
    // On Desktop, we might center the content and limit width
    return Center(
      child: Container(
        width: 600,
        child: PollDetailMobile(
          pollId: pollId,
        ), // Reuse mobile logic inside constrained width
      ),
    );
  }
}

class ResultsView extends StatelessWidget {
  final int pollId;
  const ResultsView({super.key, required this.pollId});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<VotingService>();

    return FutureBuilder(
      future: service.getResults(pollId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Could not load results."));
        }

        final result = snapshot.data!;
        // Calculate total for percentages
        int totalVotes = result.options.fold(
          0,
          (sum, item) => sum + item.votes,
        );

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Total Votes: $totalVotes",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...result.options.map((opt) {
                    final double percentage = totalVotes == 0
                        ? 0
                        : (opt.votes / totalVotes);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                opt.optionText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${(percentage * 100).toStringAsFixed(1)}% (${opt.votes})",
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage,
                              minHeight: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class MyVoteView extends StatefulWidget {
  final int pollId;
  const MyVoteView({super.key, required this.pollId});

  @override
  State<MyVoteView> createState() => _MyVoteViewState();
}

class _MyVoteViewState extends State<MyVoteView> {
  final _cpfCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  String? _statusMessage;
  bool _checking = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Check your participation",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your details to see if your vote was recorded.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _cpfCtrl,
            decoration: const InputDecoration(
              labelText: "CPF",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dobCtrl,
            decoration: const InputDecoration(
              labelText: "Birth Date (YYYY-MM-DD)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _checking ? null : _checkVote,
              child: _checking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("CHECK MY VOTE"),
            ),
          ),

          if (_statusMessage != null) ...[
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Text(
                _statusMessage!,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _checkVote() async {
    setState(() {
      _checking = true;
      _statusMessage = null;
    });
    final service = context.read<VotingService>();

    try {
      // 1. Get the Vote ID (Index)
      final optionIndex = await service.checkMyVote(
        widget.pollId,
        _cpfCtrl.text,
        _dobCtrl.text,
      );

      if (optionIndex == null) {
        setState(
          () => _statusMessage = "We found no vote record for these details.",
        );
      } else {
        // 2. Fetch Poll Details to map Index -> Name
        final result = await service.getResults(widget.pollId);
        // Find the text for that index
        final optionName = result?.options
            .firstWhere(
              (o) => o.optionId == optionIndex,
              orElse: () =>
                  OptionCount(optionId: -1, optionText: "Unknown", votes: 0),
            )
            .optionText;

        setState(
          () => _statusMessage = "Confirmed! You voted for: $optionName",
        );
      }
    } catch (e) {
      setState(
        () => _statusMessage = "Error checking vote. Please check format.",
      );
    } finally {
      setState(() => _checking = false);
    }
  }
}
