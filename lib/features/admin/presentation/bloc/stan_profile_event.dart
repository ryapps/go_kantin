import 'package:equatable/equatable.dart';

abstract class StanProfileEvent extends Equatable {
  const StanProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadStanProfile extends StanProfileEvent {
  final String userId;

  const LoadStanProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateStanProfile extends StanProfileEvent {
  final String stanId;
  final String namaStan;
  final String namaPemilik;
  final String telp;
  final String description;
  final String location;
  final String openTime;
  final String closeTime;
  final String imageUrl;

  const UpdateStanProfile({
    required this.stanId,
    required this.namaStan,
    required this.namaPemilik,
    required this.telp,
    required this.description,
    required this.location,
    required this.openTime,
    required this.closeTime,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [
        stanId,
        namaStan,
        namaPemilik,
        telp,
        description,
        location,
        openTime,
        closeTime,
        imageUrl,
      ];
}

class PickStanImage extends StanProfileEvent {
  const PickStanImage();
}
