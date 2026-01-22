import 'package:equatable/equatable.dart';
import 'package:kantin_app/features/menu/domain/entities/menu.dart';

abstract class CanteenDetailEvent extends Equatable {
  const CanteenDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadCanteenDetailEvent extends CanteenDetailEvent {
  final String stanId;

  const LoadCanteenDetailEvent(this.stanId);

  @override
  List<Object> get props => [stanId];
}

class AddItemToCartEvent extends CanteenDetailEvent {
  final Menu item;

  const AddItemToCartEvent(this.item);

  @override
  List<Object> get props => [item];
}

class UpdateItemQuantityEvent extends CanteenDetailEvent {
  final Menu item;
  final int newQuantity;

  const UpdateItemQuantityEvent(this.item, this.newQuantity);

  @override
  List<Object> get props => [item, newQuantity];
}

class RemoveItemFromCartEvent extends CanteenDetailEvent {
  final String menuId;

  const RemoveItemFromCartEvent(this.menuId);

  @override
  List<Object> get props => [menuId];
}

class ClearCartEvent extends CanteenDetailEvent {
  const ClearCartEvent();
}

class RefreshCartEvent extends CanteenDetailEvent {
  const RefreshCartEvent();
}

class SwitchStanEvent extends CanteenDetailEvent {
  final Menu item;

  const SwitchStanEvent(this.item);

  @override
  List<Object> get props => [item];
}
