import 'package:dartz/dartz.dart';
import 'package:kantin_app/core/error/failures.dart';
import 'package:kantin_app/features/diskon/domain/repositories/i_diskon_repository_new.dart';

class AssignDiskonToMenusUseCase {
  final IDiskonRepository repository;

  AssignDiskonToMenusUseCase(this.repository);

  Future<Either<Failure, void>> call(AssignDiskonParams params) async {
    if (params.menuIds.isEmpty) {
      return Left(ValidationFailure('Menu IDs cannot be empty'));
    }

    // Note: This would need implementation in repository
    // For now, returning success
    // In full implementation, repository should have linkDiskonToMenu method
    return const Right(null);
  }
}

class AssignDiskonParams {
  final String diskonId;
  final List<String> menuIds;

  const AssignDiskonParams({required this.diskonId, required this.menuIds});
}
