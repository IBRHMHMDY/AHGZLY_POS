import 'package:ahgzly_pos/core/extensions/order_status.dart';
import 'package:ahgzly_pos/core/extensions/order_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart'; 
import 'package:ahgzly_pos/features/pos/domain/usecases/save_order_usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_entity.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final SaveOrderUseCase saveOrderUseCase;
  final GetSettingsUseCase getSettingsUseCase;

  final List<CartItem> _cartItems = [];
  OrderType _orderType = OrderType.takeaway;
  int _discountAmount = 0;
  
  double _taxRate = 0.0;
  double _serviceRate = 0.0;
  int _deliveryFee = 0;
  String _restaurantName = '';
  String _taxNumber = '';
  String _printMode = 'ask';

  PosBloc({
    required this.saveOrderUseCase,
    required this.getSettingsUseCase,
  }) : super(PosInitial()) {
    on<ReloadSettingsEvent>(_onReloadSettings);
    on<AddItemToCartEvent>(_onAddItem);
    on<UpdateCartItemQuantityEvent>(_onUpdateQuantity);
    on<RemoveItemFromCartEvent>(_onRemoveItem);
    on<ChangeOrderTypeEvent>(_onChangeType);
    on<ApplyDiscountEvent>(_onApplyDiscount);
    on<ClearCartEvent>(_onClearCart);
    on<SubmitOrderEvent>(_onSubmitOrder);
    on<SaveOrderEvent>(_onSaveOrderLegacy); 

    add(ReloadSettingsEvent());
  }

  Future<void> _onReloadSettings(ReloadSettingsEvent event, Emitter<PosState> emit) async {
    final result = await getSettingsUseCase(NoParams());
    result.fold(
      (failure) {},
      (settings) {
        _taxRate = settings.taxRate;
        _serviceRate = settings.serviceRate;
        _deliveryFee = settings.deliveryFee;
        _restaurantName = settings.restaurantName;
        _taxNumber = settings.taxNumber;
        _printMode = settings.printMode;
        _emitUpdatedState(emit); 
      },
    );
  }

  void _onAddItem(AddItemToCartEvent event, Emitter<PosState> emit) {
    final existingIndex = _cartItems.indexWhere((c) => c.item.id == event.item.id);
    if (existingIndex >= 0) {
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
    } else {
      _cartItems.add(CartItem(item: event.item, quantity: 1));
    }
    _emitUpdatedState(emit);
  }

  void _onUpdateQuantity(UpdateCartItemQuantityEvent event, Emitter<PosState> emit) {
    if (event.index >= 0 && event.index < _cartItems.length) {
      if (event.quantity > 0) {
        _cartItems[event.index] = _cartItems[event.index].copyWith(quantity: event.quantity);
      } else {
        _cartItems.removeAt(event.index);
      }
      _emitUpdatedState(emit);
    }
  }

  void _onRemoveItem(RemoveItemFromCartEvent event, Emitter<PosState> emit) {
    if (event.index >= 0 && event.index < _cartItems.length) {
      _cartItems.removeAt(event.index);
      _emitUpdatedState(emit);
    }
  }

  void _onChangeType(ChangeOrderTypeEvent event, Emitter<PosState> emit) {
    _orderType = event.orderType;
    _emitUpdatedState(emit);
  }

  void _onApplyDiscount(ApplyDiscountEvent event, Emitter<PosState> emit) {
    _discountAmount = event.discountAmount;
    _emitUpdatedState(emit);
  }

  void _onClearCart(ClearCartEvent event, Emitter<PosState> emit) {
    _cartItems.clear();
    _discountAmount = 0;
    _orderType = OrderType.takeaway;
    _emitUpdatedState(emit);
  }

  void _emitUpdatedState(Emitter<PosState> emit) {
    int subTotal = _cartItems.fold(0, (sum, item) => sum + (item.item.price * item.quantity));
    
    int afterDiscount = subTotal - _discountAmount;
    if (afterDiscount < 0) afterDiscount = 0;

    int taxAmount = (afterDiscount * _taxRate).round(); 
    int serviceFee = _orderType == OrderType.dineIn ? (afterDiscount * _serviceRate).round() : 0;
    int deliveryFee = _orderType == OrderType.delivery ? _deliveryFee : 0;
    
    int total = subTotal - _discountAmount + taxAmount + serviceFee + deliveryFee;

    emit(PosUpdated(
      cartItems: List.from(_cartItems), 
      orderType: _orderType,
      subTotal: subTotal,
      discountAmount: _discountAmount,
      taxAmount: taxAmount,
      serviceFee: serviceFee,
      deliveryFee: deliveryFee,
      total: total,
      restaurantName: _restaurantName,
      taxNumber: _taxNumber,
      printMode: _printMode,
    ));
  }

  Future<void> _onSubmitOrder(SubmitOrderEvent event, Emitter<PosState> emit) async {
    if (state is! PosUpdated) return; 
    final currentState = state as PosUpdated;

    if (currentState.cartItems.isEmpty) {
      emit(PosError('لا يمكن إتمام البيع، السلة فارغة.'));
      _emitUpdatedState(emit);
      return;
    }

    emit(PosLoading());

    final order = OrderEntity(
      orderType: currentState.orderType,
      subTotal: currentState.subTotal,
      discount: currentState.discountAmount,
      taxAmount: currentState.taxAmount,
      serviceFee: currentState.serviceFee,
      deliveryFee: currentState.deliveryFee,
      total: currentState.total,
      paymentMethod: event.paymentMethod,
      status: OrderStatus.completed,
      createdAt: DateTime.now(),
      customerName: event.customerName,
      customerPhone: event.customerPhone,
      customerAddress: event.customerAddress,
      items: currentState.cartItems.map((c) => OrderItemEntity(
        itemId: c.item.id!,
        quantity: c.quantity,
        unitPrice: c.item.price,
        notes: c.notes,
      )).toList(),
    );

    // Refactored: Pass SaveOrderParams instead of raw Order
    final result = await saveOrderUseCase(SaveOrderParams(order: order));

    result.fold(
      (failure) {
        emit(PosError(failure.message));
        _emitUpdatedState(emit); 
      },
      (orderId) {
        emit(PosCheckoutSuccess(orderId));
        _cartItems.clear();
        _discountAmount = 0;
        _orderType = OrderType.dineIn;
        _emitUpdatedState(emit);
      },
    );
  }

  Future<void> _onSaveOrderLegacy(SaveOrderEvent event, Emitter<PosState> emit) async {
    emit(PosLoading());
    // Refactored: Pass SaveOrderParams instead of raw Order
    final result = await saveOrderUseCase(SaveOrderParams(order: event.order));
    result.fold(
      (error) => emit(PosError(error.message)),
      (id) => emit(PosCheckoutSuccess(id)),
    );
  }
}