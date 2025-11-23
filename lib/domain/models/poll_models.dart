class PollSummary {
  final int id;
  final String title;
  final List<String> options;
  final String status;

  PollSummary({
    required this.id,
    required this.title,
    required this.options,
    required this.status,
  });

  factory PollSummary.fromJson(Map<String, dynamic> json) {
    return PollSummary(
      id: json['id'],
      title: json['title'],
      options: List<String>.from(json['options']),
      status: json['status'],
    );
  }
}

class PollResult {
  final int id;
  final String title;
  final String status;
  final List<OptionCount> options;

  PollResult({
    required this.id,
    required this.title,
    required this.status,
    required this.options,
  });

  factory PollResult.fromJson(Map<String, dynamic> json) {
    return PollResult(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      options: (json['options'] as List)
          .map((e) => OptionCount.fromJson(e))
          .toList(),
    );
  }
}

class OptionCount {
  final int optionId;
  final String optionText;
  final int votes;

  OptionCount({
    required this.optionId,
    required this.optionText,
    required this.votes,
  });

  factory OptionCount.fromJson(Map<String, dynamic> json) {
    return OptionCount(
      optionId: json['option_id'],
      optionText: json['option_text'],
      votes: json['votes'],
    );
  }
}
