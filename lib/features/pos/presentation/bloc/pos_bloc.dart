import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item.dart';
import 'package:ahgzly_pos/features/pos/domain/usecases/save_order_usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'pos_event.dart';
import 'pos_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final SaveOrderUseCase saveOrderUseCase;
  final GetSettingsUseCase getSettingsUseCase;

  final List<CartItem> _currentCart = [];
  String _currentOrderType = 'تيك أواي';
  double _currentDiscount = 0.0; // الخصم الحالي
  AppSettings? _settings;

  PosBloc({required this.saveOrderUseCase, required this.getSettingsUseCase}) : super(PosInitial()) {
    on<AddItemToCartEvent>(_onAddItemToCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
    on<RemoveItemFromCartEvent>(_onRemoveItemFromCart);
    on<ChangeOrderTypeEvent>(_onChangeOrderType);
    on<ClearCartEvent>(_onClearCart);
    on<ApplyDiscountEvent>(_onApplyDiscount); // حدث الخصم
    on<SubmitOrderEvent>(_onSubmitOrder);
    on<ReloadSettingsEvent>((event, emit) async {
      final result = await getSettingsUseCase(NoParams());
      result.fold((failure) {}, (settings) => _settings = settings);
      _emitUpdatedCart(emit: emit);
    });

    _initSettings();
  }

  Future<void> _initSettings() async {
    final result = await getSettingsUseCase(NoParams());
    result.fold(
      (failure) => _settings = const AppSettings(taxRate: 0.14, serviceRate: 0.12, deliveryFee: 20.0, printerName: 'EPSON Printer', restaurantName: 'مـطـعـم احـجـزلـي', taxNumber: '123-456-789', printMode: 'ask'),
      (settings) => _settings = settings,
    );
    _emitUpdatedCart();
  }

  void _onAddItemToCart(AddItemToCartEvent event, Emitter<PosState> emit) {
    final existingIndex = _currentCart.indexWhere((c) => c.item.id == event.item.id);
    if (existingIndex >= 0) {
      final currentItem = _currentCart[existingIndex];
      _currentCart[existingIndex] = currentItem.copyWith(quantity: currentItem.quantity + 1);
    } else {
      _currentCart.add(CartItem(item: event.item, quantity: 1));
    }
    _emitUpdatedCart(emit: emit);
  }

  void _onUpdateCartItemQuantity(UpdateCartItemQuantityEvent event, Emitter<PosState> emit) {
    if (event.quantity <= 0) {
      _currentCart.removeAt(event.index);
    } else {
      final currentItem = _currentCart[event.index];
      _currentCart[event.index] = currentItem.copyWith(quantity: event.quantity);
    }
    _emitUpdatedCart(emit: emit);
  }

  void _onRemoveItemFromCart(RemoveItemFromCartEvent event, Emitter<PosState> emit) {
    _currentCart.removeAt(event.index);
    _emitUpdatedCart(emit: emit);
  }

  void _onChangeOrderType(ChangeOrderTypeEvent event, Emitter<PosState> emit) {
    _currentOrderType = event.orderType;
    _emitUpdatedCart(emit: emit);
  }

  void _onApplyDiscount(ApplyDiscountEvent event, Emitter<PosState> emit) {
    _currentDiscount = event.discountAmount;
    _emitUpdatedCart(emit: emit);
  }

  void _onClearCart(ClearCartEvent event, Emitter<PosState> emit) {
    _currentCart.clear();
    _currentOrderType = 'تيك أواي';
    _currentDiscount = 0.0;
    _emitUpdatedCart(emit: emit);
  }

  Future<void> _onSubmitOrder(SubmitOrderEvent event, Emitter<PosState> emit) async {
    if (_currentCart.isEmpty) return;
    emit(PosLoading());
    final calculations = _calculateTotals();
    
    final List<OrderItem> orderItems = _currentCart.map((c) => OrderItem(itemId: c.item.id!, quantity: c.quantity, unitPrice: c.item.price, notes: c.notes)).toList();

    final order = Order(
      orderType: _currentOrderType,
      subTotal: calculations['subTotal']!,
      discount: calculations['discountAmount']!, // تمرير الخصم
      taxAmount: calculations['taxAmount']!,
      serviceFee: calculations['serviceFee']!,
      deliveryFee: calculations['deliveryFee']!,
      total: calculations['total']!,
      paymentMethod: event.paymentMethod,
      status: 'مكتمل',
      createdAt: DateTime.now().toIso8601String(),
      items: orderItems,
    );

    final failureOrOrderId = await saveOrderUseCase(order);

    failureOrOrderId.fold(
      (failure) {
        emit(PosError(failure.message));
        _emitUpdatedCart(emit: emit);
      },
      (orderId) {
        emit(PosCheckoutSuccess(orderId));
        _currentCart.clear();
        _currentOrderType = 'تيك أواي';
        _currentDiscount = 0.0; // تفريغ الخصم بعد الدفع
        _emitUpdatedCart(emit: emit);
      },
    );
  }

  void _emitUpdatedCart({Emitter<PosState>? emit}) {
    if (_settings == null) return; 
    final calculations = _calculateTotals();
    final state = PosUpdated(
      cartItems: List.from(_currentCart),
      orderType: _currentOrderType,
      subTotal: calculations['subTotal']!,
      discountAmount: calculations['discountAmount']!,
      taxAmount: calculations['taxAmount']!,
      serviceFee: calculations['serviceFee']!,
      deliveryFee: calculations['deliveryFee']!,
      total: calculations['total']!,
      restaurantName: _settings!.restaurantName,
      taxNumber: _settings!.taxNumber,
      printMode: _settings!.printMode,
    );
    if (emit != null) {
      emit(state); 
    }else{ 
      this.emit(state);
    }
  }

  Map<String, double> _calculateTotals() {
    double subTotal = 0.0;
    for (var cartItem in _currentCart) {
      subTotal += (cartItem.item.price * cartItem.quantity);
    }

    double discountAmount = _currentDiscount;
    if (discountAmount > subTotal) discountAmount = subTotal; // منع خصم أكبر من السعر

    double taxableAmount = subTotal - discountAmount; // الضرائب تُحسب بعد الخصم

    final tax = _settings?.taxRate ?? 0.14;
    final service = _settings?.serviceRate ?? 0.12;
    final delivery = _settings?.deliveryFee ?? 20.0;

    double taxAmount = taxableAmount * tax;
    double serviceFee = (_currentOrderType == 'صالة') ? (taxableAmount * service) : 0.0;
    double deliveryFee = (_currentOrderType == 'دليفري') ? delivery : 0.0;
    
    double total = taxableAmount + taxAmount + serviceFee + deliveryFee;

    return {
      'subTotal': double.parse(subTotal.toStringAsFixed(2)),
      'discountAmount': double.parse(discountAmount.toStringAsFixed(2)),
      'taxAmount': double.parse(taxAmount.toStringAsFixed(2)),
      'serviceFee': double.parse(serviceFee.toStringAsFixed(2)),
      'deliveryFee': double.parse(deliveryFee.toStringAsFixed(2)),
      'total': double.parse(total.toStringAsFixed(2)),
    };
  }
}