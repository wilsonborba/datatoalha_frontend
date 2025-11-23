import 'package:datatoalha_frontend/core/logs.dart';
import 'package:flutter/foundation.dart';
import '../../dal/remote/api_client.dart';
import '../models/poll_models.dart';

class VotingService extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<PollSummary> openPolls = [];
  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> fetchOpenPolls() async {
    _setLoading(true);
    try {
      final response = await _api.get('/polls');
      openPolls = (response.data as List)
          .map((e) => PollSummary.fromJson(e))
          .toList();
    } catch (e) {
      error("Error fetching polls: $e");
    }
    _setLoading(false);
  }

  Future<void> createPoll(String title, List<String> options) async {
    _setLoading(true);
    await _api.post('/polls', data: {"title": title, "options": options});
    await fetchOpenPolls(); // Refresh list
    _setLoading(false);
  }

  Future<void> vote(
    int pollId,
    String cpf,
    String birthDate,
    int optionIndex,
  ) async {
    _setLoading(true);
    await _api.post(
      '/polls/$pollId/vote',
      data: {
        "cpf": cpf,
        "birth_date":
            birthDate, // Format: YYYY-MM-DD likely expected by backend logic
        "option_index": optionIndex,
      },
    );
    _setLoading(false);
  }

  Future<PollResult?> getResults(int pollId) async {
    final response = await _api.get('/polls/$pollId/results');
    return PollResult.fromJson(response.data);
  }

  Future<int?> checkMyVote(int pollId, String cpf, String birthDate) async {
    final response = await _api.post(
      '/polls/$pollId/mine',
      data: {"cpf": cpf, "birth_date": birthDate},
    );
    return response.data; // Returns option_id or null
  }

  Future<void> closePoll(int pollId) async {
    await _api.delete('/polls/$pollId/close');
    await fetchOpenPolls();
  }
}
