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
  
  // الإعدادات الديناميكية
  AppSettings? _settings;

  PosBloc({
    required this.saveOrderUseCase,
    required this.getSettingsUseCase,
  }) : super(PosInitial()) {
    on<AddItemToCartEvent>(_onAddItemToCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
    on<RemoveItemFromCartEvent>(_onRemoveItemFromCart);
    on<ChangeOrderTypeEvent>(_onChangeOrderType);
    on<ClearCartEvent>(_onClearCart);
    on<SubmitOrderEvent>(_onSubmitOrder);
    on<ReloadSettingsEvent>((event, emit) async {
      final result = await getSettingsUseCase(NoParams());
      result.fold(
        (failure) {}, // في حالة الفشل نحتفظ بالإعدادات القديمة
        (settings) {
          _settings = settings;
        },
      );
      // إعادة حساب السلة وإصدار الحالة الجديدة
      _emitUpdatedCart(emit: emit);
    });

    _initSettings();
  }

  Future<void> _initSettings() async {
    final result = await getSettingsUseCase(NoParams());
    result.fold(
      (failure) {
        // إعدادات افتراضية للطوارئ
        _settings = const AppSettings(taxRate: 0.14, serviceRate: 0.12, deliveryFee: 20.0, printerName: 'Unknown Printer', restaurantName: 'Ahgzly Restaurants', taxNumber: '123 456 789');
      },
      (settings) {
        _settings = settings;
      },
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

  void _onClearCart(ClearCartEvent event, Emitter<PosState> emit) {
    _currentCart.clear();
    _currentOrderType = 'تيك أواي';
    _emitUpdatedCart(emit: emit);
  }

  Future<void> _onSubmitOrder(SubmitOrderEvent event, Emitter<PosState> emit) async {
    if (_currentCart.isEmpty) return;
    
    // نمرر الإعدادات كجزء من عملية الدفع لطباعتها
    emit(PosLoading());
    final calculations = _calculateTotals();
    
    final List<OrderItem> orderItems = _currentCart.map((cartItem) {
      return OrderItem(
        itemId: cartItem.item.id!,
        quantity: cartItem.quantity,
        unitPrice: cartItem.item.price,
        notes: cartItem.notes,
      );
    }).toList();

    final order = Order(
      orderType: _currentOrderType,
      subTotal: calculations['subTotal']!,
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
        // نُمرر اسم الطابعة مع النجاح
        final _ = _settings?.printerName ?? 'EPSON Printer';
        emit(PosCheckoutSuccess(orderId));
        _currentCart.clear();
        _currentOrderType = 'تيك أواي';
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
      taxAmount: calculations['taxAmount']!,
      serviceFee: calculations['serviceFee']!,
      deliveryFee: calculations['deliveryFee']!,
      total: calculations['total']!,
      restaurantName: _settings!.restaurantName, // تمرير اسم المطعم
      taxNumber: _settings!.taxNumber,           // تمرير الرقم الضريبي
    );
    
    if (emit != null) {
      emit(state);
    } else {
      this.emit(state);
    }
  }
  
  Map<String, double> _calculateTotals() {
    double subTotal = 0.0;
    for (var cartItem in _currentCart) {
      subTotal += (cartItem.item.price * cartItem.quantity);
    }

    final tax = _settings?.taxRate ?? 0.14;
    final service = _settings?.serviceRate ?? 0.12;
    final delivery = _settings?.deliveryFee ?? 20.0;

    double taxAmount = subTotal * tax;
    double serviceFee = (_currentOrderType == 'صالة') ? (subTotal * service) : 0.0;
    double deliveryFee = (_currentOrderType == 'دليفري') ? delivery : 0.0;
    
    double total = subTotal + taxAmount + serviceFee + deliveryFee;

    return {
      'subTotal': double.parse(subTotal.toStringAsFixed(2)),
      'taxAmount': double.parse(taxAmount.toStringAsFixed(2)),
      'serviceFee': double.parse(serviceFee.toStringAsFixed(2)),
      'deliveryFee': double.parse(deliveryFee.toStringAsFixed(2)),
      'total': double.parse(total.toStringAsFixed(2)),
    };
  }
}