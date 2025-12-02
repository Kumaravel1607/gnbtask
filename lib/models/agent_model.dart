class Agent {
  final String name;
  final String email;
  final String contact;

  Agent({required this.name, required this.email, required this.contact});

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
    );
  }
}
