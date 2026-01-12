import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases with parameters
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class for use cases without parameters
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// Base class for stream use cases
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// Base class for stream use cases without parameters
abstract class StreamUseCaseNoParams<Type> {
  Stream<Either<Failure, Type>> call();
}