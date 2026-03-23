import 'package:ahgzly_pos/features/pos/domain/entities/order.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item.dart';
import 'package:ahgzly_pos/features/pos/domain/usecases/save_order_usecase.dart';
import 'pos_event.dart';
import 'pos_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final SaveOrderUseCase saveOrderUseCase;

  // الحالة المبدئية للسلة
  final List<CartItem> _currentCart = [];
  String _currentOrderType = 'تيك أواي';

  // ثوابت الحسابات (يمكن نقلها لاحقاً لجدول الإعدادات في قاعدة البيانات)
  final double _taxRate = 0.14; // ضريبة 14%
  final double _serviceRate = 0.12; // خدمة صالة 12%
  final double _fixedDeliveryFee = 20.0; // رسوم توصيل ثابتة 20 جنيه

  PosBloc({required this.saveOrderUseCase}) : super(PosInitial()) {
    on<AddItemToCartEvent>(_onAddItemToCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
    on<RemoveItemFromCartEvent>(_onRemoveItemFromCart);
    on<ChangeOrderTypeEvent>(_onChangeOrderType);
    on<ClearCartEvent>(_onClearCart);
    on<SubmitOrderEvent>(_onSubmitOrder);

    // تهيئة السلة عند البداية
    _emitUpdatedCart();
  }

  void _onAddItemToCart(AddItemToCartEvent event, Emitter<PosState> emit) {
    final existingIndex = _currentCart.indexWhere((c) => c.item.id == event.item.id);
    if (existingIndex >= 0) {
      // إذا كان الصنف موجوداً، زد الكمية
      final currentItem = _currentCart[existingIndex];
      _currentCart[existingIndex] = currentItem.copyWith(quantity: currentItem.quantity + 1);
    } else {
      // صنف جديد
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
    if (_currentCart.isEmpty) {
      emit(const PosError('سلة المشتريات فارغة'));
      _emitUpdatedCart(emit: emit);
      return;
    }

    emit(PosLoading());

    // 1. إجراء الحسابات النهائية
    final calculations = _calculateTotals();
    
    // 2. تحويل الـ CartItems إلى OrderItems (الكيان الخاص بالدومين)
    final List<OrderItem> orderItems = _currentCart.map((cartItem) {
      return OrderItem(
        itemId: cartItem.item.id!,
        quantity: cartItem.quantity,
        unitPrice: cartItem.item.price,
        notes: cartItem.notes,
      );
    }).toList();

    // 3. إنشاء كيان الطلب (Order Entity)
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

    // 4. حفظ الطلب في قاعدة البيانات عبر الـ UseCase
    final failureOrOrderId = await saveOrderUseCase(order);

    failureOrOrderId.fold(
      (failure) {
        emit(PosError(failure.message));
        _emitUpdatedCart(emit: emit);
      },
      (orderId) {
        emit(PosCheckoutSuccess(orderId));
        // تفريغ السلة بعد النجاح
        _currentCart.clear();
        _currentOrderType = 'تيك أواي';
        _emitUpdatedCart(emit: emit);
      },
    );
  }

  // دالة مساعدة لحساب القيم وإصدار الحالة الجديدة
  void _emitUpdatedCart({Emitter<PosState>? emit}) {
    final calculations = _calculateTotals();
    final state = PosUpdated(
      cartItems: List.from(_currentCart), // تمرير نسخة جديدة لضمان تحديث الـ UI
      orderType: _currentOrderType,
      subTotal: calculations['subTotal']!,
      taxAmount: calculations['taxAmount']!,
      serviceFee: calculations['serviceFee']!,
      deliveryFee: calculations['deliveryFee']!,
      total: calculations['total']!,
    );
    
    if (emit != null) {
      emit(state);
    } else {
      // تستخدم فقط في تهيئة البلوك
      this.emit(state);
    }
  }

  // دالة الحسابات الرياضية الأساسية
  Map<String, double> _calculateTotals() {
    double subTotal = 0.0;
    for (var cartItem in _currentCart) {
      subTotal += (cartItem.item.price * cartItem.quantity);
    }

    double taxAmount = subTotal * _taxRate;
    double serviceFee = (_currentOrderType == 'صالة') ? (subTotal * _serviceRate) : 0.0;
    double deliveryFee = (_currentOrderType == 'دليفري') ? _fixedDeliveryFee : 0.0;
    
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