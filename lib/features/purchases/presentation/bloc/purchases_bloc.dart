import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import '../../domain/usecases/purchases_usecases.dart';
import 'purchases_event.dart';
import 'purchases_state.dart';

class PurchasesBloc extends Bloc<PurchasesEvent, PurchasesState> {
  final GetPurchaseInvoicesUseCase getPurchaseInvoices;
  final SavePurchaseInvoiceUseCase savePurchaseInvoice;

  PurchasesBloc({
    required this.getPurchaseInvoices,
    required this.savePurchaseInvoice,
  }) : super(PurchasesInitial()) {
    on<LoadPurchasesEvent>(_onLoadPurchases);
    on<SavePurchaseInvoiceEvent>(_onSavePurchaseInvoice);
  }

  Future<void> _onLoadPurchases(LoadPurchasesEvent event, Emitter<PurchasesState> emit) async {
    emit(PurchasesLoading());
    final failureOrInvoices = await getPurchaseInvoices(NoParams());
    failureOrInvoices.fold(
      (failure) => emit(PurchasesError(failure.message)),
      (invoices) => emit(PurchasesLoaded(invoices: invoices)),
    );
  }

  Future<void> _onSavePurchaseInvoice(SavePurchaseInvoiceEvent event, Emitter<PurchasesState> emit) async {
    emit(PurchasesLoading());
    final failureOrSuccess = await savePurchaseInvoice(
      SavePurchaseInvoiceParams(
        supplierId: event.supplierId,
        totalAmount: event.totalAmount,
        paidAmount: event.paidAmount,
        notes: event.notes,
        items: event.items,
      ),
    );

    failureOrSuccess.fold(
      (failure) => emit(PurchasesError(failure.message)),
      (_) {
        emit(PurchaseInvoiceSavedSuccess());
        add(LoadPurchasesEvent());
      },
    );
  }
}
