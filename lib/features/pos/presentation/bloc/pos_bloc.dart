import 'package:ahgzly_pos/core/common/entities/customer_entity.dart';
import 'package:ahgzly_pos/core/common/entities/restaurant_table_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/category_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';
import 'package:ahgzly_pos/core/common/entities/payment_method_entity.dart';
import 'package:ahgzly_pos/core/extensions/print_mode.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart'; 
import 'package:ahgzly_pos/features/pos/domain/usecases/save_order_usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
// 🚀 استيراد الـ UseCases الجديدة
import 'package:ahgzly_pos/features/pos/domain/usecases/get_customers_usecase.dart';
import 'package:ahgzly_pos/features/pos/domain/usecases/get_payment_methods_usecase.dart';
import 'package:ahgzly_pos/features/menu/domain/usecases/category_usecases.dart'; // افترض وجودها
import 'package:ahgzly_pos/features/menu/domain/usecases/item_usecases.dart'; // افترض وجودها

import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_entity.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_item_entity.dart';
import 'package:ahgzly_pos/core/extensions/order_status.dart';
import 'package:ahgzly_pos/core/extensions/order_type.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final SaveOrderUseCase saveOrderUseCase;
  final GetSettingsUseCase getSettingsUseCase;
  
  // 🚀 [Sprint 2]: إضافة UseCases لجلب البيانات الأساسية
  final GetCustomersUseCase getCustomersUseCase;
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetItemsUseCase getItemsUseCase;

  // القوائم المحفوظة في الذاكرة (Memory Cache)
  List<CategoryEntity> _categories = [];
  List<ItemEntity> _allItems = [];
  List<ItemEntity> _currentItems = [];
  List<CustomerEntity> _customers = [];
  final List<RestaurantTableEntity> _restTables = []; // سيتم جلبها لاحقاً
  List<PaymentMethodEntity> _paymentMethods = [];
  
  final List<OrderItemEntity> _cartItems = [];
  
  // متغيرات الفاتورة النشطة
  int? _selectedCategoryId;
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
    required this.getCustomersUseCase,
    required this.getPaymentMethodsUseCase,
    required this.getCategoriesUseCase,
    required this.getItemsUseCase,
  }) : super(PosInitial()) {
    on<LoadPosDataEvent>(_onLoadPosData);
    on<ChangeCategoryEvent>(_onChangeCategory); // 🚀 تفعيل حدث تغيير القسم
    on<AddItemToCartEvent>(_onAddItem);
    on<UpdateCartItemQuantityEvent>(_onUpdateQuantity);
    on<RemoveItemFromCartEvent>(_onRemoveItem);
    on<ChangeOrderTypeEvent>(_onChangeType);
    on<SelectTableEvent>(_onSelectTable);
    on<SelectCustomerEvent>(_onSelectCustomer);
    on<ClearCartEvent>(_onClearCart);
    on<CheckoutOrderEvent>(_onCheckoutOrder);

    add(LoadPosDataEvent()); 
  }

  Future<void> _onLoadPosData(LoadPosDataEvent event, Emitter<PosState> emit) async {
    emit(PosLoading());
    
    // 🚀 [Sprint 2]: جلب كافة البيانات بالتوازي (Parallel Execution) لتحسين الأداء
    final results = await Future.wait([
      getSettingsUseCase(NoParams()),
      getCategoriesUseCase(NoParams()),
      getItemsUseCase(const GetItemsParams(categoryId: 0)),
      getCustomersUseCase(NoParams()),
      getPaymentMethodsUseCase(NoParams()),
    ]);

    // معالجة الإعدادات
    results[0].fold((l) => null, (settings) {
      final s = settings as AppSettingsEntity;
      _taxRate = s.taxRate;
      _serviceRate = s.serviceRate;
      _deliveryFee = s.deliveryFee;
      _printMode = s.printMode;
      _restaurantName = s.restaurantName;
      _taxNumber = s.taxNumber;
    });

    // معالجة الأقسام
    results[1].fold((l) => null, (cats) {
      _categories = cats as List<CategoryEntity>;
      if (_categories.isNotEmpty) _selectedCategoryId = _categories.first.id;
    });

    // معالجة الأصناف
    results[2].fold((l) => null, (items) {
      _allItems = items as List<ItemEntity>;
      _filterItemsByCategory();
    });

    // معالجة العملاء
    results[3].fold((l) => null, (custs) {
      _customers = custs as List<CustomerEntity>;
    });

    // معالجة طرق الدفع
    results[4].fold((l) => null, (methods) {
      _paymentMethods = methods as List<PaymentMethodEntity>;
    });

    _emitDataLoadedState(emit); 
  }

  // 🚀 [Sprint 2]: دالة فلترة الأصناف عند اختيار قسم
  void _onChangeCategory(ChangeCategoryEvent event, Emitter<PosState> emit) {
    _selectedCategoryId = event.categoryId;
    _filterItemsByCategory();
    _emitDataLoadedState(emit);
  }

  void _filterItemsByCategory() {
    if (_selectedCategoryId != null) {
      _currentItems = _allItems.where((item) => item.categoryId == _selectedCategoryId).toList();
    } else {
      _currentItems = List.from(_allItems);
    }
  }

  void _onAddItem(AddItemToCartEvent event, Emitter<PosState> emit) {
    // دمج الأصناف المتطابقة
    final existingIndex = _cartItems.indexWhere((c) => 
      c.itemId == event.orderItem.itemId && 
      c.selectedVariant?.id == event.orderItem.selectedVariant?.id &&
      _areAddonsEqual(c.selectedAddons, event.orderItem.selectedAddons) // 🚀 دالة أعمق للتحقق من تطابق الإضافات
    );

    if (existingIndex >= 0) {
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + event.orderItem.quantity);
    } else {
      _cartItems.add(event.orderItem);
    }
    _emitDataLoadedState(emit);
  }

  // دالة مساعدة للتحقق من تطابق الإضافات
  bool _areAddonsEqual(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) return false;
    final ids1 = list1.map((e) => e.id).toSet();
    final ids2 = list2.map((e) => e.id).toSet();
    return ids1.containsAll(ids2);
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
      categories: List.from(_categories), 
      currentItems: List.from(_currentItems),
      selectedCategoryId: _selectedCategoryId,
      cartItems: List.from(_cartItems),
      orderType: _orderType,
      selectedTableId: _selectedTableId,
      selectedCustomerId: _selectedCustomerId,
      customers: List.from(_customers),
      tables: List.from(_restTables),
      paymentMethods: List.from(_paymentMethods), 
      discountAmount: _discountAmount,
      taxRate: _taxRate,
      serviceRate: _serviceRate,
      deliveryFee: _deliveryFee,
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

    // 🚀 [Bug Fix]: يجب أن نستخرج البيانات *قبل* أن نحول الحالة إلى PosLoading
    // لكي لا يتم عمل Return صامت للكود ويضيع الطلب.
    final currentState = state;
    if (currentState is! PosDataLoaded) return;

    // الآن يمكننا إظهار التحميل بأمان
    emit(PosLoading());

    // تكوين الفاتورة وربط كافة البيانات
    final order = OrderEntity(
      shiftId: event.shiftId,
      tableId: event.tableId ?? _selectedTableId, // استلام الطاولة من الواجهة
      orderType: _orderType,
      subTotal: currentState.subTotal,
      discount: currentState.discountAmount,
      taxAmount: currentState.taxAmount,
      serviceFee: currentState.serviceFeeAmount,
      deliveryFee: currentState.deliveryFeeAmount,
      total: currentState.total,
      totalCost: currentState.totalCost, 
      paymentMethodId: event.paymentMethodId,
      status: OrderStatus.completed,
      // 🚀 استلام بيانات التوصيل إن وجدت
      customerId: event.customerId,
      customerName: event.customerName,
      customerPhone: event.customerPhone,
      customerAddress: event.customerAddress,
      createdAt: DateTime.now(),
      items: List.from(_cartItems),
    );

    final result = await saveOrderUseCase(SaveOrderParams(order: order));

    result.fold(
      (failure) {
        emit(PosError(failure.message));
        _emitDataLoadedState(emit); 
      },
      (orderId) {
        // 🚀 سيعمل هذا السطر الآن، وسيلتقطه الـ CartSection ويطبع الفاتورة!
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