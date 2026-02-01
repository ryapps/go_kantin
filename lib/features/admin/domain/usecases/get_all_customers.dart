import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/admin_repository.dart';

class GetAllCustomers {
  final AdminRepository repository;
  GetAllCustomers(this.repository);

  Future<Either<Failure, List<dynamic>>> call() async {
    // Implementasi: Ambil data customer dari Firestore
    return await repository.getAllCustomers();
  }
}
