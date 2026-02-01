// Events
abstract class GetUserStanEvent {}

class LoadUserStanId extends GetUserStanEvent {
  final String userId;

  LoadUserStanId(this.userId);
}