class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;
  final DateTime trialEndsAt;
  final bool isSubscribed;
  final String? subscriptionType;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.trialEndsAt,
    this.isSubscribed = false,
    this.subscriptionType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'created_at': createdAt.toIso8601String(),
      'trial_ends_at': trialEndsAt.toIso8601String(),
      'is_subscribed': isSubscribed ? 1 : 0,
      'subscription_type': subscriptionType,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      trialEndsAt: DateTime.parse(map['trial_ends_at'] as String),
      isSubscribed: (map['is_subscribed'] as int) == 1,
      subscriptionType: map['subscription_type'] as String?,
    );
  }

  bool get isTrialActive => DateTime.now().isBefore(trialEndsAt);
  bool get hasAccess => isSubscribed || isTrialActive;

  int get trialDaysRemaining {
    final remaining = trialEndsAt.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    DateTime? createdAt,
    DateTime? trialEndsAt,
    bool? isSubscribed,
    String? subscriptionType,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionType: subscriptionType ?? this.subscriptionType,
    );
  }
}
