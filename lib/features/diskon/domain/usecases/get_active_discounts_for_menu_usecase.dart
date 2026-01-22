import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/menu_diskon.dart';
import '../repositories/i_diskon_repository.dart';

/// Use case for fetching active discounts for a menu
class GetActiveDiscountsForMenuUseCase
    implements UseCase<List<Diskon>, MenuDiscountParams> {
  final IDiskonRepository repository;

  GetActiveDiscountsForMenuUseCase(this.repository);

  @override
  Future<Either<Failure, List<Diskon>>> call(MenuDiscountParams params) async {
    return repository.getActiveDiscountsForMenu(params.menuId);
  }
}

class MenuDiscountParams extends Equatable {
  final String menuId;

  const MenuDiscountParams({required this.menuId});

  @override
  List<Object?> get props => [menuId];
}
