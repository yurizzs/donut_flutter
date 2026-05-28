class UserModel {
  final int? id;
  final String name;
  final String email;
  final String? avatar;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle nested 'user' object if the API returns it as { "user": { ... } }
    final data = json.containsKey('user') ? json['user'] : json;

    return UserModel(
      id: data['id'] is int ? data['id'] : (data['user_id'] is int ? data['user_id'] : int.tryParse(data['id']?.toString() ?? data['user_id']?.toString() ?? '')),
      name: data['name']?.toString() ?? data['full_name']?.toString() ?? 'Unknown User',
      email: data['email']?.toString() ?? '',
      avatar: data['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}
