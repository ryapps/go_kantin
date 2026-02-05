import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/core/services/cloudinary_service.dart';
import 'package:kantin_app/core/usecases/usecase.dart';
import 'package:kantin_app/features/siswa/domain/entities/siswa.dart';
import 'package:kantin_app/features/siswa/domain/repositories/i_student_repository.dart';

class UpdateSiswaProfileUseCase
    implements UseCase<Siswa, UpdateSiswaProfileParams> {
  final ISiswaRepository repository;

  UpdateSiswaProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Siswa>> call(UpdateSiswaProfileParams params) async {
    try {
      String? fotoUrl;

      // Upload foto ke Cloudinary jika ada path foto baru
      if (params.fotoPath != null && params.fotoPath!.isNotEmpty) {
        if (kIsWeb) {
          // Untuk web, baca bytes dari XFile
          final xFile = XFile(params.fotoPath!);
          final bytes = await xFile.readAsBytes();

          // Dapatkan filename dengan ekstensi
          String filename = xFile.name;
          if (!filename.contains('.')) {
            // Jika tidak ada ekstensi, tambahkan .jpg sebagai default
            filename = '${filename}.jpg';
          }

          print(
            'Web upload - filename: $filename, bytes length: ${bytes.length}',
          );

          fotoUrl = await CloudinaryService.uploadImageFromBytes(
            bytes,
            filename,
          );
        } else {
          // Untuk mobile, gunakan path biasa
          fotoUrl = await CloudinaryService.uploadImageFromPath(
            params.fotoPath!,
          );
        }
      }

      return await repository.updateSiswa(
        siswaId: params.siswaId,
        namaSiswa: params.namaSiswa,
        alamat: params.alamat,
        telp: params.telp,
        fotoPath: fotoUrl,
      );
    } catch (e) {
      return Left(ServerFailure('Gagal mengupdate profil: ${e.toString()}'));
    }
  }
}

class UpdateSiswaProfileParams {
  final String siswaId;
  final String? namaSiswa;
  final String? alamat;
  final String? telp;
  final String? fotoPath; // Local file path

  UpdateSiswaProfileParams({
    required this.siswaId,
    this.namaSiswa,
    this.alamat,
    this.telp,
    this.fotoPath,
  });
}
