import 'dart:io';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kantin_app/core/di/injection_container.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/core/widgets/custom_textfield.dart';
import 'package:kantin_app/core/widgets/primary_button.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kantin_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';
import 'package:kantin_app/features/category/domain/usecases/get_all_categories_usecase.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_bloc.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_event.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_state.dart';

class CompleteStanProfileScreen extends StatefulWidget {
  const CompleteStanProfileScreen({super.key});

  @override
  State<CompleteStanProfileScreen> createState() =>
      _CompleteStanProfileScreenState();
}

class _CompleteStanProfileScreenState extends State<CompleteStanProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaStanController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _telpController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _openTimeController = TextEditingController();
  final _closeTimeController = TextEditingController();

  XFile? _pickedImage;
  final List<String> _selectedCategories = [];
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _checkExistingProfile();
  }

  void _checkExistingProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      // Check if profile already exists
      context.read<StanProfileCompletionBloc>().add(
        CheckStanProfileRequested(userId: authState.user.id),
      );
    }
  }

  Future<void> _loadCategories() async {
    try {
      final getAllCategoriesUseCase = sl<GetAllCategoriesUseCase>();
      final result = await getAllCategoriesUseCase();

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _isLoadingCategories = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal memuat kategori: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (categories) {
          if (mounted) {
            setState(() {
              _categories = categories.where((c) => c.isActive).toList();
              _isLoadingCategories = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaStanController.dispose();
    _namaPemilikController.dispose();
    _telpController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    super.dispose();
  }

  void _handleSaveProfile() {
    if (_formKey.currentState!.validate()) {
      // if (_selectedCategories.isEmpty) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Pilih minimal 1 kategori'),
      //       backgroundColor: Colors.red,
      //       behavior: SnackBarBehavior.floating,
      //     ),
      //   );
      //   return;
      // }

      if (_openTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jam buka wajib diisi'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_closeTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jam tutup wajib diisi'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

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
        'openTime': _formatTimeOfDay(_openTime!),
        'closeTime': _formatTimeOfDay(_closeTime!),
        'location': _locationController.text.trim(),
        'categories': _selectedCategories,
        'imagePath': _pickedImage?.path,
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
        _pickedImage = pickedFile;
      });
    }
  }

  Widget _buildProfileImage() {
    if (_pickedImage == null) {
      return const Icon(Icons.store, size: 60, color: AppTheme.textSecondary);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: kIsWeb
          ? FutureBuilder<Uint8List>(
              future: _pickedImage!.readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(snapshot.data!, fit: BoxFit.cover);
                }
                return const Center(child: CircularProgressIndicator());
              },
            )
          : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: (isOpenTime ? _openTime : _closeTime) ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
          _openTimeController.text = _formatTimeOfDay(picked);
        } else {
          _closeTime = picked;
          _closeTimeController.text = _formatTimeOfDay(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lengkapi Profil Stan')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                context.go('/login');
              }
            },
          ),
          BlocListener<StanProfileCompletionBloc, StanProfileCompletionState>(
            listener: (context, state) {
              if (state is StanProfileSavedSuccessfully) {
                // Profile already exists or just saved, redirect to dashboard
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  if (authState.user.isAdminStan) {
                    context.go('/admin');
                  } else if (authState.user.isSiswa) {
                    context.go('/siswa-home');
                  } else if (authState.user.isSuperAdmin) {
                    context.go('/admin');
                  }
                }
              } else if (state is StanProfileCompletionError) {
                // Only show error if not from initial check
                // Error from initial check means profile doesn't exist yet (expected)
                if (state.message.contains('tidak ditemukan') ||
                    state.message.contains('belum')) {
                  // Profile doesn't exist, stay on this screen to fill it
                  // Don't show error snackbar for this case
                  return;
                }

                // Show error for other cases (save failed, etc)
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
                    Text(
                      'Silakan lengkapi profil stan Anda untuk memulai menggunakan aplikasi',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
                            child: _buildProfileImage(),
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

                    // Nama Stan
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

                    // Nama Pemilik
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

                    // Telepon
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
                        if (!RegExp(r'^\+?[0-9]{10,16}$').hasMatch(value)) {
                          return 'Nomor telepon tidak valid (10-16 digit)';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Deskripsi Stan',
                      hint: 'Deskripsikan tentang stan Anda',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 3,
                      minLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi stan wajib diisi';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Jam Buka (Time Picker)
                    InkWell(
                      onTap: isLoading
                          ? null
                          : () => _selectTime(context, true),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _openTimeController,
                          readOnly: true,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Jam Buka',
                            hintText: 'Pilih jam buka',
                            alignLabelWithHint: true,
                            prefixIcon: const Icon(
                              Icons.access_time_outlined,
                              color: AppTheme.textSecondary,
                            ),
                            suffixIcon: const Icon(
                              Icons.schedule,
                              color: AppTheme.primaryColor,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Jam Tutup (Time Picker)
                    InkWell(
                      onTap: isLoading
                          ? null
                          : () => _selectTime(context, false),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _closeTimeController,
                          readOnly: true,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Jam Tutup',
                            hintText: 'Pilih jam tutup',
                            alignLabelWithHint: true,
                            prefixIcon: const Icon(
                              Icons.access_time_outlined,
                              color: AppTheme.textSecondary,
                            ),
                            suffixIcon: const Icon(
                              Icons.schedule,
                              color: AppTheme.primaryColor,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lokasi
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

                    // Kategori (Multiple selection with chips)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Kategori Makanan',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            if (_isLoadingCategories) ...[
                              const SizedBox(width: 8),
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _isLoadingCategories
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : _categories.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.category_outlined,
                                          size: 48,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Belum ada kategori tersedia',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton.icon(
                                          onPressed: _loadCategories,
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Muat Ulang'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _categories.map((category) {
                                    // Cek berdasarkan category.id, bukan category.name
                                    final isSelected = _selectedCategories
                                        .contains(category.id);
                                    return FilterChip(
                                      label: Text(category.name),
                                      selected: isSelected,
                                      onSelected: isLoading
                                          ? null
                                          : (selected) {
                                              setState(() {
                                                if (selected) {
                                                  // Simpan category.id, bukan category.name
                                                  _selectedCategories.add(
                                                    category.id,
                                                  );
                                                } else {
                                                  _selectedCategories.remove(
                                                    category.id,
                                                  );
                                                }
                                              });
                                            },
                                      selectedColor: AppTheme.primaryColor
                                          .withOpacity(0.2),
                                      checkmarkColor: AppTheme.primaryColor,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : AppTheme.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                        if (_selectedCategories.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${_selectedCategories.length} kategori dipilih',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.primaryColor),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    PrimaryButton(
                      text: 'Simpan Profil',
                      onPressed: _handleSaveProfile,
                      isLoading: isLoading,
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
