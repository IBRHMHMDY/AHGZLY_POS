import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/customers_local_data_source.dart';
import 'customers_event.dart';
import 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  final CustomersLocalDataSource dataSource;

  CustomersBloc({required this.dataSource}) : super(CustomersInitial()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<AddCustomerEvent>(_onAddCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
    on<LoadCustomerDetailEvent>(_onLoadDetail);
  }

  Future<void> _onLoadCustomers(LoadCustomersEvent event, Emitter<CustomersState> emit) async {
    emit(CustomersLoading());
    try {
      final customers = await dataSource.getCustomers(searchQuery: event.searchQuery);
      emit(CustomersLoaded(customers: customers, searchQuery: event.searchQuery));
    } catch (e) {
      emit(CustomersError('فشل في تحميل العملاء: $e'));
    }
  }

  Future<void> _onAddCustomer(AddCustomerEvent event, Emitter<CustomersState> emit) async {
    try {
      await dataSource.addCustomer(event.customer);
      add(const LoadCustomersEvent());
    } catch (e) {
      emit(CustomersError('فشل في إضافة العميل: $e'));
    }
  }

  Future<void> _onUpdateCustomer(UpdateCustomerEvent event, Emitter<CustomersState> emit) async {
    try {
      await dataSource.updateCustomer(event.customer);
      add(const LoadCustomersEvent());
    } catch (e) {
      emit(CustomersError('فشل في تحديث بيانات العميل: $e'));
    }
  }

  Future<void> _onDeleteCustomer(DeleteCustomerEvent event, Emitter<CustomersState> emit) async {
    try {
      await dataSource.deleteCustomer(event.id);
      add(const LoadCustomersEvent());
    } catch (e) {
      emit(CustomersError('فشل في حذف العميل: $e'));
    }
  }

  Future<void> _onLoadDetail(LoadCustomerDetailEvent event, Emitter<CustomersState> emit) async {
    emit(CustomersLoading());
    try {
      final detail = await dataSource.getCustomerDetail(event.customerId);
      emit(CustomerDetailLoaded(detail));
    } catch (e) {
      emit(CustomersError('فشل في تحميل تفاصيل العميل: $e'));
    }
  }
}
