import 'package:equatable/equatable.dart';

abstract class StanProfileCompletionState extends Equatable {
  const StanProfileCompletionState();

  @override
  List<Object?> get props => [];
}

class StanProfileCompletionInitial extends StanProfileCompletionState {
  const StanProfileCompletionInitial();
}

class StanProfileCompletionLoading extends StanProfileCompletionState {
  const StanProfileCompletionLoading();
}

class StanProfileSavedSuccessfully extends StanProfileCompletionState {
  const StanProfileSavedSuccessfully();
}

class StanProfileCompletionError extends StanProfileCompletionState {
  final String message;

  const StanProfileCompletionError(this.message);

  @override
  List<Object?> get props => [message];
}