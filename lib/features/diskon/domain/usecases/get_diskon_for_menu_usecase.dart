import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/menu_diskon.dart';
import '../repositories/i_diskon_repository.dart';

/// Use case for fetching a discount for a menu
class GetDiskonForMenuUseCase implements UseCase<Diskon?, MenuDiscountParams> {
  final IDiskonRepository repository;

  GetDiskonForMenuUseCase(this.repository);

  @override
  Future<Either<Failure, Diskon?>> call(MenuDiscountParams params) async {
    return repository.getDiskonForMenu(params.menuId);
  }
}

class MenuDiscountParams extends Equatable {
  final String menuId;

  const MenuDiscountParams({required this.menuId});

  @override
  List<Object?> get props => [menuId];
}
