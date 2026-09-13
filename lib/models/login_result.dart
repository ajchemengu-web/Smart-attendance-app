class LoginResult {
  final String username;
  final String email;
  final String role;
  final String? adminTier;
  final String dashboard;
  final String accessToken;

  LoginResult({
    required this.username,
    required this.email,
    required this.role,
    required this.adminTier,
    required this.dashboard,
    required this.accessToken,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      adminTier: json['admin_tier'] as String?,
      dashboard: json['dashboard'] as String,
      accessToken: json['access_token'] as String,
    );
  }
}
