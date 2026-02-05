import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/core/usecases/usecase.dart';
import 'package:kantin_app/features/diskon/domain/repositories/i_diskon_repository_new.dart';

class DeleteDiskonUseCase implements UseCase<void, DeleteDiskonParams> {
  final IDiskonRepository repository;

  DeleteDiskonUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteDiskonParams params) async {
    return await repository.deleteDiskon(params.diskonId);
  }
}

class DeleteDiskonParams extends Equatable {
  final String diskonId;

  const DeleteDiskonParams({required this.diskonId});

  @override
  List<Object?> get props => [diskonId];
}
