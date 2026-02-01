import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/core/widgets/custom_textfield.dart';
import 'package:kantin_app/core/widgets/primary_button.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_bloc.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_event.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_state.dart';

class CompleteStanProfileScreen extends StatefulWidget {
  const CompleteStanProfileScreen({super.key});

  @override
  State<CompleteStanProfileScreen> createState() => _CompleteStanProfileScreenState();
}

class _CompleteStanProfileScreenState extends State<CompleteStanProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaStanController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _telpController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _openTimeController = TextEditingController();
  final _closeTimeController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoriesController = TextEditingController();

  String? _pickedImagePath;

  @override
  void dispose() {
    _namaStanController.dispose();
    _namaPemilikController.dispose();
    _telpController.dispose();
    _descriptionController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _locationController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  void _handleSaveProfile() {
    if (_formKey.currentState!.validate()) {
      // Get current user ID from the auth state
      String userId = '';
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        userId = authState.user.id;
      }

      final profileData = {
        'userId': userId,
        'namaStan': _namaStanController.text.trim(),
        'namaPemilik': _namaPemilikController.text.trim(),
        'telp': _telpController.text.trim(),
        'description': _descriptionController.text.trim(),
        'openTime': _openTimeController.text.trim(),
        'closeTime': _closeTimeController.text.trim(),
        'location': _locationController.text.trim(),
        'categories': _categoriesController.text.trim().split(',').map((e) => e.trim()).toList(),
        'imagePath': _pickedImagePath, // Include image path if available
      };

      context.read<StanProfileCompletionBloc>().add(
        SaveStanProfileRequested(profileData: profileData),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lengkapi Profil Stan'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              // If user is not authenticated, redirect to login
              if (state is Unauthenticated) {
                context.go('/login');
              }
            },
          ),
          BlocListener<StanProfileCompletionBloc, StanProfileCompletionState>(
            listener: (context, state) {
              if (state is StanProfileSavedSuccessfully) {
                // Get current user to determine navigation based on role
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  if (authState.user.isSiswa) {
                    context.go('/siswa-home');
                  } else if (authState.user.isAdminStan) {
                    context.go('/admin');
                  } else if (authState.user.isSuperAdmin) {
                    context.go('/admin');
                  }
                }
              } else if (state is StanProfileCompletionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<StanProfileCompletionBloc, StanProfileCompletionState>(
          builder: (context, state) {
            final isLoading = state is StanProfileCompletionLoading;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'Silakan lengkapi profil stan Anda untuk memulai menggunakan aplikasi',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Image Picker
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.borderColor,
                                width: 2,
                              ),
                            ),
                            child: _pickedImagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(_pickedImagePath!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.store,
                                    size: 60,
                                    color: AppTheme.textSecondary,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: isLoading ? null : _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nama Stan Field
                    CustomTextField(
                      controller: _namaStanController,
                      label: 'Nama Stan',
                      hint: 'Masukkan nama stan Anda',
                      prefixIcon: Icons.store_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama stan wajib diisi';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Nama Pemilik Field
                    CustomTextField(
                      controller: _namaPemilikController,
                      label: 'Nama Pemilik',
                      hint: 'Masukkan nama pemilik stan',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama pemilik wajib diisi';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Telepon Field
                    CustomTextField(
                      controller: _telpController,
                      label: 'Nomor Telepon',
                      hint: 'Masukkan nomor telepon stan',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon wajib diisi';
                        }
                        if (!RegExp(r'^[\+]?[1-9][\d]{0,15}$').hasMatch(value)) {
                          return 'Nomor telepon tidak valid';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi Field
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Deskripsi Stan',
                      hint: 'Deskripsikan tentang stan Anda',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi stan wajib diisi';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Jam Buka Field
                    CustomTextField(
                      controller: _openTimeController,
                      label: 'Jam Buka',
                      hint: 'Contoh: 07:00',
                      prefixIcon: Icons.access_time_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jam buka wajib diisi';
                        }
                        if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
                          return 'Format jam tidak valid (HH:MM)';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Jam Tutup Field
                    CustomTextField(
                      controller: _closeTimeController,
                      label: 'Jam Tutup',
                      hint: 'Contoh: 17:00',
                      prefixIcon: Icons.access_time_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jam tutup wajib diisi';
                        }
                        if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
                          return 'Format jam tidak valid (HH:MM)';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Lokasi Field
                    CustomTextField(
                      controller: _locationController,
                      label: 'Lokasi Stan',
                      hint: 'Masukkan lokasi stan Anda',
                      prefixIcon: Icons.location_on_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi wajib diisi';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Kategori Field (comma-separated)
                    CustomTextField(
                      controller: _categoriesController,
                      label: 'Kategori Makanan',
                      hint: 'Contoh: Makanan Berat, Minuman, Camilan',
                      prefixIcon: Icons.category_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori wajib diisi';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    PrimaryButton(
                      text: 'Simpan Profil',
                      onPressed: _handleSaveProfile,
                      isLoading: isLoading,
                      icon: Icons.save,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}