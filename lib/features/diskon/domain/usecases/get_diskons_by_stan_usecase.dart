import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/core/usecases/usecase.dart';
import 'package:kantin_app/features/diskon/domain/entities/diskon.dart';
import 'package:kantin_app/features/diskon/domain/repositories/i_diskon_repository_new.dart';

class GetDiskonsByStanUseCase
    implements UseCase<List<Diskon>, GetDiskonsByStanParams> {
  final IDiskonRepository repository;

  GetDiskonsByStanUseCase(this.repository);

  @override
  Future<Either<Failure, List<Diskon>>> call(
    GetDiskonsByStanParams params,
  ) async {
    if (params.activeOnly) {
      return await repository.getActiveDiskonsByStan(params.stanId);
    }
    return await repository.getDiskonsByStan(params.stanId);
  }
}

class GetDiskonsByStanParams extends Equatable {
  final String stanId;
  final bool activeOnly;

  const GetDiskonsByStanParams({required this.stanId, this.activeOnly = false});

  @override
  List<Object?> get props => [stanId, activeOnly];
}
