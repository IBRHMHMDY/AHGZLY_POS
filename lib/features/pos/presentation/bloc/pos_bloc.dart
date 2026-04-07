import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart'; // لاستيراد NoParams
import 'package:ahgzly_pos/features/pos/domain/usecases/save_order_usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final SaveOrderUseCase saveOrderUseCase;
  final GetSettingsUseCase getSettingsUseCase;

  // --- محتويات السلة وإعداداتها المحفوظة في الذاكرة ---
  final List<CartItem> _cartItems = [];
  String _orderType = 'صالة';
  int _discountAmount = 0;
  
  // إعدادات افتراضية (سيتم جلبها من قاعدة البيانات)
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
    
    // تسجيل مستمعي الأحداث للسلة والدفع
    on<ReloadSettingsEvent>(_onReloadSettings);
    on<AddItemToCartEvent>(_onAddItem);
    on<UpdateCartItemQuantityEvent>(_onUpdateQuantity);
    on<RemoveItemFromCartEvent>(_onRemoveItem);
    on<ChangeOrderTypeEvent>(_onChangeType);
    on<ApplyDiscountEvent>(_onApplyDiscount);
    on<ClearCartEvent>(_onClearCart);
    on<SubmitOrderEvent>(_onSubmitOrder);
    on<SaveOrderEvent>(_onSaveOrderLegacy); // للحفاظ على التوافق إذا تم استدعاؤه

    // جلب إعدادات المطعم عند تهيئة البلوك لأول مرة
    add(ReloadSettingsEvent());
  }

  // 1. جلب الإعدادات لحساب الضرائب بشكل دقيق
  Future<void> _onReloadSettings(ReloadSettingsEvent event, Emitter<PosState> emit) async {
    final result = await getSettingsUseCase(NoParams());
    result.fold(
      (failure) {
        // الاعتماد على القيم الافتراضية في حال الفشل
      },
      (settings) {
        _taxRate = settings.taxRate;
        _serviceRate = settings.serviceRate;
        _deliveryFee = settings.deliveryFee;
        _restaurantName = settings.restaurantName;
        _taxNumber = settings.taxNumber;
        _printMode = settings.printMode;
        _emitUpdatedState(emit); // تحديث الواجهة فوراً
      },
    );
  }

  // 2. إضافة منتج للسلة
  void _onAddItem(AddItemToCartEvent event, Emitter<PosState> emit) {
    final existingIndex = _cartItems.indexWhere((c) => c.item.id == event.item.id);
    if (existingIndex >= 0) {
      // إذا كان المنتج موجوداً، نزيد الكمية
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
    } else {
      // إذا كان جديداً، نضيفه
      _cartItems.add(CartItem(item: event.item, quantity: 1));
    }
    _emitUpdatedState(emit);
  }

  // 3. تحديث الكمية
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

  // 4. إزالة منتج نهائياً
  void _onRemoveItem(RemoveItemFromCartEvent event, Emitter<PosState> emit) {
    if (event.index >= 0 && event.index < _cartItems.length) {
      _cartItems.removeAt(event.index);
      _emitUpdatedState(emit);
    }
  }

  // 5. تغيير نوع الطلب (صالة، دليفري، الخ..)
  void _onChangeType(ChangeOrderTypeEvent event, Emitter<PosState> emit) {
    _orderType = event.orderType;
    _emitUpdatedState(emit);
  }

  // 6. تطبيق خصم مباشر
  void _onApplyDiscount(ApplyDiscountEvent event, Emitter<PosState> emit) {
    _discountAmount = event.discountAmount;
    _emitUpdatedState(emit);
  }

  // 7. تفريغ السلة بالكامل
  void _onClearCart(ClearCartEvent event, Emitter<PosState> emit) {
    _cartItems.clear();
    _discountAmount = 0;
    _orderType = 'صالة';
    _emitUpdatedState(emit);
  }

  // 8. الدالة المركزية لحساب الإجماليات وتحديث الشاشة (الـ Core Logic)
  void _emitUpdatedState(Emitter<PosState> emit) {
    int subTotal = _cartItems.fold(0, (sum, item) => sum + (item.item.price * item.quantity));
    
    int afterDiscount = subTotal - _discountAmount;
    if (afterDiscount < 0) afterDiscount = 0;

    // استخدام round() للتقريب لأقرب قرش وتجنب الكسور
    int taxAmount = (afterDiscount * _taxRate).round(); 
    int serviceFee = _orderType == 'صالة' ? (afterDiscount * _serviceRate).round() : 0;
    int deliveryFee = _orderType == 'دليفري' ? _deliveryFee : 0;
    
    // الإجمالي النهائي
    int total = subTotal - _discountAmount + taxAmount + serviceFee + deliveryFee;

    emit(PosUpdated(
      cartItems: List.from(_cartItems), // List.from لإجبار الواجهة على التحديث
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

  // 9. إتمام البيع والدفع (محصن بنظام الورديات)
  Future<void> _onSubmitOrder(SubmitOrderEvent event, Emitter<PosState> emit) async {
    // التقاط الحالة الحالية قبل الحفظ لاستخدام الأرقام المحسوبة بدقة
    if (state is! PosUpdated) return; 
    final currentState = state as PosUpdated;

    if (currentState.cartItems.isEmpty) {
      emit(PosError('لا يمكن إتمام البيع، السلة فارغة.'));
      _emitUpdatedState(emit);
      return;
    }

    emit(PosLoading());

    // بناء الكيان الذي سيتم حفظه بقاعدة البيانات
    final order = Order(
      orderType: currentState.orderType,
      subTotal: currentState.subTotal,
      discount: currentState.discountAmount,
      taxAmount: currentState.taxAmount,
      serviceFee: currentState.serviceFee,
      deliveryFee: currentState.deliveryFee,
      total: currentState.total,
      paymentMethod: event.paymentMethod,
      status: 'completed',
      createdAt: DateTime.now().toIso8601String(),
      customerName: event.customerName,
      customerPhone: event.customerPhone,
      customerAddress: event.customerAddress,
      // تحويل عناصر السلة إلى عناصر طلب خاصة بقاعدة البيانات
      items: currentState.cartItems.map((c) => OrderItem(
        itemId: c.item.id!,
        quantity: c.quantity,
        unitPrice: c.item.price,
        notes: c.notes,
      )).toList(),
    );

    // إرسال الطلب لطبقة الـ Domain التي ستتحقق من "الوردية"
    final result = await saveOrderUseCase(order);

    result.fold(
      (failure) {
        emit(PosError(failure.message));
        _emitUpdatedState(emit); // إعادة الشاشة لحالة السلة لعدم فقدان المنتجات
      },
      (orderId) {
        emit(PosCheckoutSuccess(orderId));
        // تفريغ السلة بعد نجاح الحفظ
        _cartItems.clear();
        _discountAmount = 0;
        _orderType = 'صالة';
        _emitUpdatedState(emit);
      },
    );
  }

  // 10. دعم الحدث القديم للحماية (اختياري، يوجه للحدث الجديد)
  Future<void> _onSaveOrderLegacy(SaveOrderEvent event, Emitter<PosState> emit) async {
    // إذا تم استدعاء هذا عن طريق الخطأ في أي مكان، نعالجه
    emit(PosLoading());
    final result = await saveOrderUseCase(event.order);
    result.fold(
      (error) => emit(PosError(error.message)),
      (id) => emit(PosCheckoutSuccess(id)),
    );
  }
}