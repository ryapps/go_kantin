import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/menu/domain/entities/menu.dart';

abstract class CanteenDetailState extends Equatable {
  const CanteenDetailState();

  @override
  List<Object> get props => [];
}

class CanteenDetailInitial extends CanteenDetailState {
  const CanteenDetailInitial();
}

class CanteenDetailLoading extends CanteenDetailState {
  const CanteenDetailLoading();
}

class CanteenDetailLoaded extends CanteenDetailState {
  final List<Menu> foodItems;
  final List<Menu> beverageItems;
  final Map<String, int> itemQuantities;
  final int totalItemsCount;
  final double cartTotal;
  final String stanName;
  final String stanId;

  const CanteenDetailLoaded({
    required this.foodItems,
    required this.beverageItems,
    required this.itemQuantities,
    required this.totalItemsCount,
    required this.cartTotal,
    required this.stanName,
    required this.stanId,
  });

  CanteenDetailLoaded copyWith({
    List<Menu>? foodItems,
    List<Menu>? beverageItems,
    Map<String, int>? itemQuantities,
    int? totalItemsCount,
    double? cartTotal,
    String? stanName,
    String? stanId,
  }) {
    return CanteenDetailLoaded(
      foodItems: foodItems ?? this.foodItems,
      beverageItems: beverageItems ?? this.beverageItems,
      itemQuantities: itemQuantities ?? this.itemQuantities,
      totalItemsCount: totalItemsCount ?? this.totalItemsCount,
      cartTotal: cartTotal ?? this.cartTotal,
      stanName: stanName ?? this.stanName,
      stanId: stanId ?? this.stanId,
    );
  }

  @override
  List<Object> get props => [
    foodItems,
    beverageItems,
    itemQuantities,
    totalItemsCount,
    cartTotal,
    stanName,
    stanId,
  ];
}

class CanteenDetailError extends CanteenDetailState {
  final String message;

  const CanteenDetailError(this.message);

  @override
  List<Object> get props => [message];
}

class CanteenDetailEmpty extends CanteenDetailState {
  const CanteenDetailEmpty();
}

class StanSwitchConfirmation extends CanteenDetailState {
  final String currentStanName;
  final Menu newItem;

  const StanSwitchConfirmation(this.currentStanName, this.newItem);

  String get newItemName => newItem.namaItem;

  @override
  List<Object> get props => [currentStanName, newItem];
}
