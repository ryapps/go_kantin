import 'dart:io';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kantin_app/core/services/cloudinary_service.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/core/widgets/custom_textfield.dart';
import 'package:kantin_app/core/widgets/primary_button.dart';
import 'package:kantin_app/features/category/domain/entities/category.dart';
import 'package:kantin_app/features/category/presentation/bloc/category_management_bloc.dart';
import 'package:kantin_app/features/category/presentation/bloc/category_management_event.dart';
import 'package:kantin_app/features/category/presentation/bloc/category_management_state.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryManagementBloc>().add(LoadAllCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CategoryManagementBloc, CategoryManagementState>(
        listener: (context, state) {
          if (state is CategoryCreatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Kategori "${state.category.name}" berhasil dibuat',
                ),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is CategoryUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Kategori "${state.category.name}" berhasil diperbarui',
                ),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is CategoryManagementError) {
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
          if (state is CategoryManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryManagementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CategoryManagementBloc>().add(
                        LoadAllCategoriesEvent(),
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final categories = state is CategoryManagementLoaded
              ? state.categories
              : <Category>[];

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CategoryManagementBloc>().add(
                RefreshCategoriesEvent(),
              );
            },
            child: Column(
              children: [
                // Header with Add Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kelola Kategori',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${categories.length} kategori',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddCategoryDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Kategori'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category List
                Expanded(
                  child: categories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada kategori',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambahkan kategori untuk mulai mengelola menu',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showAddCategoryDialog(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Kategori'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return _buildCategoryCard(context, category);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Category Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              clipBehavior: Clip.antiAlias,
              child: category.imageUrl.isNotEmpty
                  ? Image.network(
                      category.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.category,
                          color: Colors.grey[400],
                          size: 30,
                        );
                      },
                    )
                  : Icon(Icons.category, color: Colors.grey[400], size: 30),
            ),
            const SizedBox(width: 16),

            // Category Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: category.isActive
                              ? AppTheme.successColor.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category.isActive ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            fontSize: 12,
                            color: category.isActive
                                ? AppTheme.successColor
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Urutan: ${category.order}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditCategoryDialog(context, category);
                } else if (value == 'delete') {
                  // TODO: Implement delete
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur hapus segera hadir')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _AddCategoryDialog(
        onAdd: (name, icon, imageUrl, order) {
          context.read<CategoryManagementBloc>().add(
            CreateCategoryEvent(
              name: name,
              icon: icon,
              imageUrl: imageUrl,
              order: order,
            ),
          );
        },
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) => _EditCategoryDialog(
        category: category,
        onUpdate: (name, icon, imageUrl, order, isActive) {
          context.read<CategoryManagementBloc>().add(
            UpdateCategoryEvent(
              categoryId: category.id,
              name: name,
              icon: icon,
              imageUrl: imageUrl,
              order: order,
              isActive: isActive,
            ),
          );
        },
      ),
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  final Function(String name, String icon, String imageUrl, int order) onAdd;

  const _AddCategoryDialog({required this.onAdd});

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final _orderController = TextEditingController(text: '0');
  final _imageUrlController = TextEditingController();

  XFile? _pickedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _orderController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  Future<String> _uploadImage() async {
    if (_pickedImage == null) return '';

    setState(() {
      _isUploading = true;
    });

    try {
      String imageUrl;
      if (kIsWeb) {
        final bytes = await _pickedImage!.readAsBytes();
        imageUrl = await CloudinaryService.uploadImageFromBytes(
          bytes,
          _pickedImage!.name,
        );
      } else {
        imageUrl = await CloudinaryService.uploadImageFromPath(
          _pickedImage!.path,
        );
      }

      setState(() {
        _isUploading = false;
        _imageUrlController.text = imageUrl;
      });

      return imageUrl;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Kategori Baru',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _isUploading ? null : _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: _pickedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pilih Gambar',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: kIsWeb
                                  ? FutureBuilder<Uint8List>(
                                      future: _pickedImage!.readAsBytes(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          );
                                        }
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    )
                                  : Image.file(
                                      File(_pickedImage!.path),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Name Field
                CustomTextField(
                  controller: _nameController,
                  label: 'Nama Kategori',
                  hint: 'Contoh: Makanan Berat',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama kategori wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Icon Field
                CustomTextField(
                  controller: _iconController,
                  label: 'Icon Emoji',
                  hint: 'Contoh: 🍛',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Icon wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Order Field
                CustomTextField(
                  controller: _orderController,
                  label: 'Urutan',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Urutan wajib diisi';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Urutan harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Image URL Field (readonly, filled after upload)
                CustomTextField(
                  controller: _imageUrlController,
                  label: 'URL Gambar',
                  hint: 'Akan terisi otomatis setelah upload',
                  enabled: false,
                  maxLines: 2,
                  minLines: 2,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isUploading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Simpan',
                        isLoading: _isUploading,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String imageUrl = _imageUrlController.text;

                            // Upload image if selected
                            if (_pickedImage != null &&
                                _imageUrlController.text.isEmpty) {
                              imageUrl = await _uploadImage();
                              if (imageUrl.isEmpty) {
                                return; // Upload failed
                              }
                            }

                            widget.onAdd(
                              _nameController.text.trim(),
                              _iconController.text.trim(),
                              imageUrl,
                              int.parse(_orderController.text),
                            );

                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditCategoryDialog extends StatefulWidget {
  final Category category;
  final Function(
    String name,
    String icon,
    String imageUrl,
    int order,
    bool isActive,
  )
  onUpdate;

  const _EditCategoryDialog({required this.category, required this.onUpdate});

  @override
  State<_EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<_EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _iconController;
  late final TextEditingController _orderController;
  late final TextEditingController _imageUrlController;

  XFile? _pickedImage;
  bool _isUploading = false;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _iconController = TextEditingController(text: widget.category.icon);
    _orderController = TextEditingController(
      text: widget.category.order.toString(),
    );
    _imageUrlController = TextEditingController(text: widget.category.imageUrl);
    _isActive = widget.category.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _orderController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  Future<String> _uploadImage() async {
    if (_pickedImage == null) return _imageUrlController.text.trim();

    setState(() {
      _isUploading = true;
    });

    try {
      String imageUrl;
      if (kIsWeb) {
        final bytes = await _pickedImage!.readAsBytes();
        imageUrl = await CloudinaryService.uploadImageFromBytes(
          bytes,
          _pickedImage!.name,
        );
      } else {
        imageUrl = await CloudinaryService.uploadImageFromPath(
          _pickedImage!.path,
        );
      }

      setState(() {
        _isUploading = false;
        _imageUrlController.text = imageUrl;
      });

      return imageUrl;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return _imageUrlController.text.trim();
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
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

    if (_imageUrlController.text.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _imageUrlController.text,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image_outlined,
              size: 40,
              color: Colors.grey[400],
            );
          },
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'Pilih Gambar',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Kategori',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _isUploading ? null : _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: _buildImagePreview(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Ketuk gambar untuk mengganti',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  controller: _nameController,
                  label: 'Nama Kategori',
                  hint: 'Contoh: Makanan Berat',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama kategori wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _iconController,
                  label: 'Icon Emoji',
                  hint: 'Contoh: 🍛',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Icon wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _orderController,
                  label: 'Urutan',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Urutan wajib diisi';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Urutan harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(Icons.visibility_outlined),
                    const SizedBox(width: 8),
                    const Text('Status Aktif'),
                    const Spacer(),
                    Switch(
                      value: _isActive,
                      onChanged: _isUploading
                          ? null
                          : (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _imageUrlController,
                  label: 'URL Gambar',
                  hint: 'Akan terisi otomatis setelah upload',
                  enabled: false,
                  maxLines: 2,
                  minLines: 2,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isUploading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Simpan',
                        isLoading: _isUploading,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String imageUrl = _imageUrlController.text.trim();

                            if (_pickedImage != null) {
                              imageUrl = await _uploadImage();
                              if (imageUrl.isEmpty) {
                                return;
                              }
                            }

                            widget.onUpdate(
                              _nameController.text.trim(),
                              _iconController.text.trim(),
                              imageUrl,
                              int.parse(_orderController.text),
                              _isActive,
                            );

                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
