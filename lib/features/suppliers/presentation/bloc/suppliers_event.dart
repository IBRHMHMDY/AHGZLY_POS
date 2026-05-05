import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';

abstract class SuppliersEvent extends Equatable {
  const SuppliersEvent();

  @override
  List<Object?> get props => [];
}

class LoadSuppliersEvent extends SuppliersEvent {}

class AddSupplierEvent extends SuppliersEvent {
  final SuppliersCompanion supplier;
  const AddSupplierEvent(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class UpdateSupplierEvent extends SuppliersEvent {
  final SuppliersCompanion supplier;
  const UpdateSupplierEvent(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class DeleteSupplierEvent extends SuppliersEvent {
  final int id;
  const DeleteSupplierEvent(this.id);

  @override
  List<Object?> get props => [id];
}
