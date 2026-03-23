import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:ahgzly_pos/features/orders/domain/usecases/refund_order_usecase.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrdersUseCase getOrdersUseCase;
  final RefundOrderUseCase refundOrderUseCase; // إضافة اليوزكيس

  OrdersBloc({required this.getOrdersUseCase, required this.refundOrderUseCase}) : super(OrdersInitial()) {
    
    on<LoadOrdersEvent>((event, emit) async {
      emit(OrdersLoading());
      final failureOrOrders = await getOrdersUseCase(NoParams());
      failureOrOrders.fold(
        (failure) => emit(OrdersError(failure.message)),
        (orders) => emit(OrdersLoaded(orders)),
      );
    });

    on<RefundOrderEvent>((event, emit) async {
      emit(OrdersLoading()); // تحميل مؤقت
      final failureOrSuccess = await refundOrderUseCase(event.orderId);
      failureOrSuccess.fold(
        (failure) => emit(OrdersError(failure.message)),
        (_) => add(LoadOrdersEvent()), // إعادة تحميل السجل بعد نجاح الاسترجاع
      );
    });
  }
}