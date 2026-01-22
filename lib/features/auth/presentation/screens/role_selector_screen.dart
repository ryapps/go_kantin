import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kantin_app/core/utils/constants.dart';
import 'package:kantin_app/core/widgets/primary_button.dart';

class RoleSelectorScreen extends StatefulWidget {
  final String? email;

  const RoleSelectorScreen({super.key, this.email});

  @override
  State<RoleSelectorScreen> createState() => _RoleSelectorScreenState();
}

class _RoleSelectorScreenState extends State<RoleSelectorScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Peran Anda'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Apa peran Anda?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih peran untuk melanjutkan ke dashboard yang sesuai',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 32),
              // Role Cards
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Student Role Card
                  _buildRoleCard(
                    context: context,
                    role: AppConstants.roleSiswa,
                    title: 'Pelajar / Siswa',
                    description:
                        'Jelajahi menu kantin dan pesan makanan favorit Anda',
                    icon: Icons.school,
                    color: const Color(0xFF4CAF50),
                    isSelected: _selectedRole == AppConstants.roleSiswa,
                  ),
                  const SizedBox(height: 20),
              
                  // Admin Stan Role Card
                  _buildRoleCard(
                    context: context,
                    role: AppConstants.roleAdminStan,
                    title: 'Admin Stan',
                    description: 'Kelola stan kantin Anda dan lihat pesanan',
                    icon: Icons.store,
                    color: const Color(0xFF2196F3),
                    isSelected: _selectedRole == AppConstants.roleAdminStan,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Continue Button
              PrimaryButton(
                text: 'Lanjutkan',
                onPressed: _selectedRole != null
                    ? () => _handleContinue(context)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String role,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 3 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? color.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Checkbox
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey[300]!,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 18)
                  : const SizedBox(width: 18, height: 18),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue(BuildContext context) {
    if (_selectedRole != null) {
      // Show dialog to choose between login and register
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Apa yang ingin Anda lakukan?'),
          content: const Text('Apakah Anda sudah memiliki akun?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/register', extra: _selectedRole);
              },
              child: const Text('Daftar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/login', extra: _selectedRole);
              },
              child: const Text('Masuk'),
            ),
          ],
        ),
      );
    }
  }
}
