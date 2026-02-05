import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/core/utils/validators.dart';
import 'package:kantin_app/core/widgets/custom_textfield.dart';
import 'package:kantin_app/core/widgets/primary_button.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:kantin_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kantin_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:kantin_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:kantin_app/features/siswa/domain/entities/siswa.dart';

class EditProfileScreen extends StatefulWidget {
  final Siswa siswa;

  const EditProfileScreen({super.key, required this.siswa});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _telpController;
  String? _selectedImagePath;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.siswa.namaSiswa);
    _alamatController = TextEditingController(text: widget.siswa.alamat);
    _telpController = TextEditingController(text: widget.siswa.telp);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _telpController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
      }
    }
  }

  void _handleUpdate() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        UpdateSiswaProfileRequested(
          siswaId: widget.siswa.id,
          namaSiswa: _namaController.text.trim(),
          alamat: _alamatController.text.trim(),
          telp: _telpController.text.trim(),
          fotoPath: _selectedImagePath,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profil berhasil diperbarui'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Refresh auth state untuk update user data
            context.read<AuthBloc>().add(const AuthStatusChecked());
            // Kembali ke halaman profile
            context.pop(true); // Pass true to indicate success
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Photo
                  GestureDetector(
                    onTap: isLoading ? null : _pickImage,
                    child: Stack(
                      children: [
                        FutureBuilder<Widget>(
                          future: _buildProfileImage(),
                          builder: (context, snapshot) {
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                              ),
                              child:
                                  snapshot.data ??
                                  const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ketuk untuk mengubah foto',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nama Field
                  CustomTextField(
                    controller: _namaController,
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    prefixIcon: Icons.person_outline,
                    validator: Validators.validateName,
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  // Alamat Field
                  CustomTextField(
                    controller: _alamatController,
                    label: 'Alamat',
                    hint: 'Masukkan alamat lengkap',
                    prefixIcon: Icons.location_on_outlined,
                    validator: (value) =>
                        Validators.validateRequired(value, fieldName: 'Alamat'),
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Telepon Field
                  CustomTextField(
                    controller: _telpController,
                    label: 'Nomor Telepon',
                    hint: 'Masukkan nomor telepon',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  PrimaryButton(
                    text: 'Simpan Perubahan',
                    onPressed: _handleUpdate,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Widget> _buildProfileImage() async {
    if (_selectedImage != null) {
      if (kIsWeb) {
        // Untuk web, gunakan Network.image dari bytes
        final bytes = await _selectedImage!.readAsBytes();
        return ClipOval(
          child: Image.memory(
            bytes,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      } else {
        // Untuk mobile, gunakan File
        return ClipOval(
          child: Image.file(
            File(_selectedImage!.path),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      }
    } else if (widget.siswa.foto.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          widget.siswa.foto,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    return const Icon(Icons.person, size: 60, color: Colors.grey);
  }
}
