import 'package:ahgzly_pos/core/common/entities/payment_method_entity.dart';
import 'package:ahgzly_pos/core/extensions/print_mode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart'; 
import 'package:ahgzly_pos/features/pos/domain/usecases/save_order_usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_entity.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';
import 'package:ahgzly_pos/core/extensions/order_status.dart';
import 'package:ahgzly_pos/core/extensions/order_type.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final SaveOrderUseCase saveOrderUseCase;
  final GetSettingsUseCase getSettingsUseCase;

  // 🚀 [Sprint 3]: تحويل السلة لتعتمد على OrderItemEntity لدعم المقاسات والإضافات
  final List<OrderItemEntity> _cartItems = [];
  
  // 🚀 [Sprint 3]: متغيرات الفاتورة النشطة
  OrderType _orderType = OrderType.takeaway; 
  int? _selectedTableId;
  int? _selectedCustomerId;
  
  int _discountAmount = 0;
  double _taxRate = 0.0;
  double _serviceRate = 0.0;
  int _deliveryFee = 0;

  PrintMode _printMode = PrintMode.ask;
  String _restaurantName = '';
  String _taxNumber = '';

  PosBloc({
    required this.saveOrderUseCase,
    required this.getSettingsUseCase,
  }) : super(PosInitial()) {
    on<LoadPosDataEvent>(_onLoadPosData);
    on<AddItemToCartEvent>(_onAddItem);
    on<UpdateCartItemQuantityEvent>(_onUpdateQuantity);
    on<RemoveItemFromCartEvent>(_onRemoveItem);
    on<ChangeOrderTypeEvent>(_onChangeType);
    on<SelectTableEvent>(_onSelectTable);
    on<SelectCustomerEvent>(_onSelectCustomer);
    on<ClearCartEvent>(_onClearCart);
    on<CheckoutOrderEvent>(_onCheckoutOrder);

    add(LoadPosDataEvent()); // تحميل الإعدادات عند البدء
  }

  Future<void> _onLoadPosData(LoadPosDataEvent event, Emitter<PosState> emit) async {
    final result = await getSettingsUseCase(NoParams());
    
    result.fold(
      (failure) {
        emit(const PosError('فشل في تحميل إعدادات النظام (الضرائب والرسوم).'));
      },
      (settings) {
        _taxRate = settings.taxRate;
        _serviceRate = settings.serviceRate;
        _deliveryFee = settings.deliveryFee;
        // 🚀 جلب إعدادات الطباعة
        _printMode = settings.printMode;
        _restaurantName = settings.restaurantName;
        _taxNumber = settings.taxNumber;
        
        _emitDataLoadedState(emit); 
      },
    );
  }

  void _onAddItem(AddItemToCartEvent event, Emitter<PosState> emit) {
    // 🪄 دمج الأصناف المتطابقة (نفس الصنف، نفس المقاس، نفس الإضافات)
    final existingIndex = _cartItems.indexWhere((c) => 
      c.itemId == event.orderItem.itemId && 
      c.selectedVariant?.id == event.orderItem.selectedVariant?.id &&
      c.selectedAddons.length == event.orderItem.selectedAddons.length
    );

    if (existingIndex >= 0) {
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + event.orderItem.quantity);
    } else {
      _cartItems.add(event.orderItem);
    }
    _emitDataLoadedState(emit);
  }

  void _onUpdateQuantity(UpdateCartItemQuantityEvent event, Emitter<PosState> emit) {
    final index = _cartItems.indexOf(event.orderItem);
    if (index >= 0) {
      if (event.newQuantity > 0) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: event.newQuantity);
      } else {
        _cartItems.removeAt(index);
      }
      _emitDataLoadedState(emit);
    }
  }

  void _onRemoveItem(RemoveItemFromCartEvent event, Emitter<PosState> emit) {
    _cartItems.remove(event.orderItem);
    _emitDataLoadedState(emit);
  }

  void _onChangeType(ChangeOrderTypeEvent event, Emitter<PosState> emit) {
    _orderType = event.orderType;
    // تنظيف البيانات غير المرتبطة بنوع الطلب الجديد
    if (_orderType != OrderType.dineIn) _selectedTableId = null;
    if (_orderType != OrderType.delivery) _selectedCustomerId = null;
    _emitDataLoadedState(emit);
  }

  void _onSelectTable(SelectTableEvent event, Emitter<PosState> emit) {
    _selectedTableId = event.tableId;
    _emitDataLoadedState(emit);
  }

  void _onSelectCustomer(SelectCustomerEvent event, Emitter<PosState> emit) {
    _selectedCustomerId = event.customerId;
    _emitDataLoadedState(emit);
  }

  void _onClearCart(ClearCartEvent event, Emitter<PosState> emit) {
    _cartItems.clear();
    _discountAmount = 0;
    _orderType = OrderType.takeaway;
    _selectedTableId = null;
    _selectedCustomerId = null;
    _emitDataLoadedState(emit);
  }

  void _emitDataLoadedState(Emitter<PosState> emit) {
    emit(PosDataLoaded(
      categories: const [], 
      currentItems: const [], 
      cartItems: List.from(_cartItems),
      orderType: _orderType,
      selectedTableId: _selectedTableId,
      selectedCustomerId: _selectedCustomerId,
      // 🚀 [Fix]: تمرير المتغيرات للـ State
      discountAmount: _discountAmount,
      taxRate: _taxRate,
      serviceRate: _serviceRate,
      deliveryFee: _deliveryFee,
      // قائمة وهمية مؤقتة لطرق الدفع حتى يتم جلبها من الـ Database في هذا السبرينت
      paymentMethods: const [
        PaymentMethodEntity(id: 1, name: 'كاش'),
        PaymentMethodEntity(id: 2, name: 'بطاقة ائتمانية (فيزا)'),
      ],
      printMode: _printMode,
      restaurantName: _restaurantName,
      taxNumber: _taxNumber,
    ));
  }

  Future<void> _onCheckoutOrder(CheckoutOrderEvent event, Emitter<PosState> emit) async {
    if (_cartItems.isEmpty) {
      emit(const PosError('لا يمكن إتمام البيع، السلة فارغة.'));
      _emitDataLoadedState(emit);
      return;
    }

    emit(PosLoading());

    // 🪄 الحسابات الديناميكية بناءً على المقاسات والإضافات
    int subTotal = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
    int totalCost = _cartItems.fold(0, (sum, item) => sum + item.totalCost);

    int afterDiscount = subTotal - _discountAmount;
    if (afterDiscount < 0) afterDiscount = 0;

    int serviceFee = _orderType == OrderType.dineIn ? (afterDiscount * _serviceRate).round() : 0;
    int taxAmount = ((afterDiscount + serviceFee) * _taxRate).round(); 
    int deliveryFee = _orderType == OrderType.delivery ? _deliveryFee : 0;
    
    int total = afterDiscount + serviceFee + taxAmount + deliveryFee;

    // 🚀 تكوين الكيان النهائي للحفظ
    final order = OrderEntity(
      shiftId: event.shiftId,
      tableId: _selectedTableId,
      orderType: _orderType,
      subTotal: subTotal,
      discount: _discountAmount,
      taxAmount: taxAmount,
      serviceFee: serviceFee,
      deliveryFee: deliveryFee,
      total: total,
      totalCost: totalCost, 
      paymentMethodId: event.paymentMethodId,
      status: OrderStatus.completed,
      createdAt: DateTime.now(),
      items: List.from(_cartItems),
    );

    // ملاحظة: تأكد من أن SaveOrderUseCase يقبل OrderEntity مباشرة.
    final result = await saveOrderUseCase(SaveOrderParams(order: order));

    result.fold(
      (failure) {
        emit(PosError(failure.message));
        _emitDataLoadedState(emit); 
      },
      (orderId) {
        emit(PosCheckoutSuccess(orderId));
        _cartItems.clear();
        _discountAmount = 0;
        _orderType = OrderType.takeaway;
        _selectedTableId = null;
        _selectedCustomerId = null;
        _emitDataLoadedState(emit);
      },
    );
  }
}