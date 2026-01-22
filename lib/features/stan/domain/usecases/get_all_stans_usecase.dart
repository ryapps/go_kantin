import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stan.dart';
import '../repositories/i_stan_repository.dart';

/// Use case for fetching all active stans
class GetAllStansUseCase implements UseCaseNoParams<List<Stan>> {
  final IStanRepository repository;

  GetAllStansUseCase(this.repository);

  @override
  Future<Either<Failure, List<Stan>>> call() async {
    return repository.getAllStans();
  }
}
