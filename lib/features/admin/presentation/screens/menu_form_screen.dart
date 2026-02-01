import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/core/services/cloudinary_service.dart';
import 'package:kantin_app/core/theme/app_theme.dart';
import 'package:kantin_app/features/admin/presentation/bloc/menu_management_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/menu_management_event.dart';
import 'package:kantin_app/features/admin/presentation/bloc/menu_management_state.dart';
import 'package:kantin_app/features/menu/domain/entities/menu.dart';

class MenuFormScreen extends StatefulWidget {
  final String stanId;
  final Menu? menu; // null for add, non-null for edit
  final Function(
    String namaItem,
    double harga,
    String jenis,
    String fotoPath,
    String deskripsi,
  )
  onSave;

  const MenuFormScreen({
    super.key,
    required this.stanId,
    this.menu,
    required this.onSave,
  });

  @override
  State<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends State<MenuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String _jenis = 'makanan';
  String? _imagePath;
  String _currentImageUrl = '';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      _namaController.text = widget.menu!.namaItem;
      _hargaController.text = widget.menu!.harga.toStringAsFixed(0);
      _deskripsiController.text = widget.menu!.deskripsi;
      _jenis = widget.menu!.jenis;
      _currentImageUrl = widget.menu!.foto;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _pickImage() {
    context.read<MenuManagementBloc>().add(const PickMenuImage());
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      String imagePath = _imagePath ?? _currentImageUrl;

      if (imagePath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih gambar menu'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      // Check if the image path is a local file path that needs to be uploaded to Cloudinary
      if (_imagePath != null && _imagePath!.isNotEmpty) {
        setState(() {
          _isUploading = true;
        });

        try {
          // Upload the image to Cloudinary
          final uploadedImageUrl = await CloudinaryService.uploadImage(File(_imagePath!));
          imagePath = uploadedImageUrl;
        } catch (e) {
          setState(() {
            _isUploading = false;
          });
          // Capture the context before the async gap to avoid the warning
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal mengunggah gambar: ${e.toString()}'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
          return;
        }
      }

      // Call the onSave callback with the image URL (either from Cloudinary or existing URL)
      widget.onSave(
        _namaController.text.trim(),
        double.parse(_hargaController.text.trim()),
        _jenis,
        imagePath,
        _deskripsiController.text.trim(),
      );

      // Reset upload state
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: BlocListener<MenuManagementBloc, MenuManagementState>(
        listener: (context, state) {
          if (state is MenuImagePicked) {
            setState(() => _imagePath = state.imagePath);
          }
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.menu == null ? 'Tambah Menu' : 'Edit Menu',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image Picker
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.borderColor,
                                  width: 2,
                                ),
                              ),
                              child: _isUploading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : _imagePath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.file(
                                            File(_imagePath!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : _currentImageUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                _currentImageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(
                                                      Icons.restaurant,
                                                      size: 64,
                                                      color: AppTheme.textSecondary,
                                                    ),
                                              ),
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.add_a_photo,
                                                  size: 48,
                                                  color: AppTheme.textSecondary,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Pilih Gambar',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Nama Item
                        TextFormField(
                          controller: _namaController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Menu',
                            prefixIcon: Icon(Icons.restaurant_menu),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama menu wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Jenis
                        DropdownButtonFormField<String>(
                          value: _jenis,
                          decoration: const InputDecoration(
                            labelText: 'Jenis',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'makanan',
                              child: Text('Makanan'),
                            ),
                            DropdownMenuItem(
                              value: 'minuman',
                              child: Text('Minuman'),
                            ),
                          ],
                          onChanged: (value) => setState(() => _jenis = value!),
                        ),
                        const SizedBox(height: 16),

                        // Harga
                        TextFormField(
                          controller: _hargaController,
                          decoration: const InputDecoration(
                            labelText: 'Harga',
                            prefixIcon: Icon(Icons.payments),
                            prefixText: 'Rp ',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Harga wajib diisi';
                            }
                            final harga = double.tryParse(value);
                            if (harga == null || harga <= 0) {
                              return 'Harga harus lebih dari 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Deskripsi
                        TextFormField(
                          controller: _deskripsiController,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                            hintText: 'Deskripsikan menu Anda...',
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : () => _save(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(widget.menu == null ? 'Tambah' : 'Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
