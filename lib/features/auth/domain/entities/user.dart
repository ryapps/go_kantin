import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String role; // 'siswa' | 'admin_stan' | 'super_admin'
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.role,
    required this.createdAt,
  });

  bool get isSiswa => role == 'siswa';
  bool get isAdminStan => role == 'admin_stan';
  bool get isSuperAdmin => role == 'super_admin';

  @override
  List<Object?> get props => [id, username, role, createdAt];
}