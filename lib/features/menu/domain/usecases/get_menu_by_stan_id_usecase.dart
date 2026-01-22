import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/menu.dart';
import '../repositories/i_menu_repository.dart';

/// Use case for fetching menu items by stan ID
class GetMenuByStanIdUseCase implements UseCase<List<Menu>, MenuByStanParams> {
  final IMenuRepository repository;

  GetMenuByStanIdUseCase(this.repository);

  @override
  Future<Either<Failure, List<Menu>>> call(MenuByStanParams params) async {
    return repository.getMenuByStanId(params.stanId);
  }
}

class MenuByStanParams extends Equatable {
  final String stanId;

  const MenuByStanParams({required this.stanId});

  @override
  List<Object?> get props => [stanId];
}
