abstract class GetUserStanState {}

class GetUserStanInitial extends GetUserStanState {}

class GetUserStanLoading extends GetUserStanState {}

class GetUserStanSuccess extends GetUserStanState {
  final String stanId;

  GetUserStanSuccess(this.stanId);
}

class GetUserStanError extends GetUserStanState {
  final String message;

  GetUserStanError(this.message);
}
