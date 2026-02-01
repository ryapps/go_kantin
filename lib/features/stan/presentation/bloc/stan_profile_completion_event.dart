import 'package:equatable/equatable.dart';

abstract class StanProfileCompletionEvent extends Equatable {
  const StanProfileCompletionEvent();

  @override
  List<Object?> get props => [];
}

class SaveStanProfileRequested extends StanProfileCompletionEvent {
  final Map<String, dynamic> profileData;

  const SaveStanProfileRequested({required this.profileData});

  @override
  List<Object?> get props => [profileData];
}

class CheckStanProfileRequested extends StanProfileCompletionEvent {
  final String userId;

  const CheckStanProfileRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}