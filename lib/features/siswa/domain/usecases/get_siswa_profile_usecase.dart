import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/core/usecases/usecase.dart';
import 'package:kantin_app/features/siswa/domain/entities/siswa.dart';
import 'package:kantin_app/features/siswa/domain/repositories/i_student_repository.dart';

class GetSiswaProfileUseCase implements UseCase<Siswa, GetSiswaProfileParams> {
  final ISiswaRepository repository;

  GetSiswaProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Siswa>> call(GetSiswaProfileParams params) async {
    return await repository.getSiswaByUserId(params.userId);
  }
}

class GetSiswaProfileParams {
  final String userId;

  GetSiswaProfileParams({required this.userId});
}
