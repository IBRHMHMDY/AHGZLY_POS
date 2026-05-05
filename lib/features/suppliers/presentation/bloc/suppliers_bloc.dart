import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import '../../domain/usecases/suppliers_usecases.dart';
import 'suppliers_event.dart';
import 'suppliers_state.dart';

class SuppliersBloc extends Bloc<SuppliersEvent, SuppliersState> {
  final GetSuppliersUseCase getSuppliers;
  final AddSupplierUseCase addSupplier;
  final UpdateSupplierUseCase updateSupplier;
  final DeleteSupplierUseCase deleteSupplier;

  SuppliersBloc({
    required this.getSuppliers,
    required this.addSupplier,
    required this.updateSupplier,
    required this.deleteSupplier,
  }) : super(SuppliersInitial()) {
    on<LoadSuppliersEvent>(_onLoadSuppliers);
    on<AddSupplierEvent>(_onAddSupplier);
    on<UpdateSupplierEvent>(_onUpdateSupplier);
    on<DeleteSupplierEvent>(_onDeleteSupplier);
  }

  Future<void> _onLoadSuppliers(LoadSuppliersEvent event, Emitter<SuppliersState> emit) async {
    emit(SuppliersLoading());
    final failureOrSuppliers = await getSuppliers(NoParams());
    failureOrSuppliers.fold(
      (failure) => emit(SuppliersError(failure.message)),
      (suppliers) => emit(SuppliersLoaded(suppliers: suppliers)),
    );
  }

  Future<void> _onAddSupplier(AddSupplierEvent event, Emitter<SuppliersState> emit) async {
    if (state is SuppliersLoaded) {
      final failureOrSuccess = await addSupplier(event.supplier);
      failureOrSuccess.fold(
        (failure) => emit(SuppliersError(failure.message)),
        (_) => add(LoadSuppliersEvent()),
      );
    }
  }

  Future<void> _onUpdateSupplier(UpdateSupplierEvent event, Emitter<SuppliersState> emit) async {
    if (state is SuppliersLoaded) {
      final failureOrSuccess = await updateSupplier(event.supplier);
      failureOrSuccess.fold(
        (failure) => emit(SuppliersError(failure.message)),
        (_) => add(LoadSuppliersEvent()),
      );
    }
  }

  Future<void> _onDeleteSupplier(DeleteSupplierEvent event, Emitter<SuppliersState> emit) async {
    if (state is SuppliersLoaded) {
      final failureOrSuccess = await deleteSupplier(event.id);
      failureOrSuccess.fold(
        (failure) => emit(SuppliersError(failure.message)),
        (_) => add(LoadSuppliersEvent()),
      );
    }
  }
}
