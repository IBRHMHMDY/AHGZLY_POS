import 'dart:developer' as developer; 
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_entity.dart';
import 'package:ahgzly_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:ahgzly_pos/features/pos/data/datasources/pos_local_data_source.dart';
import 'package:ahgzly_pos/features/pos/data/models/order_model.dart';
import 'package:ahgzly_pos/core/common/entities/customer_entity.dart';
import 'package:ahgzly_pos/core/common/entities/payment_method_entity.dart';
import 'package:ahgzly_pos/core/common/entities/restaurant_table_entity.dart';
import 'package:ahgzly_pos/core/common/entities/zone_entity.dart';
import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:drift/drift.dart';

class PosRepositoryImpl implements PosRepository {
  final PosLocalDataSource localDataSource;

  PosRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, int>> saveOrder(OrderEntity order) async {
    try {
      final orderModel = OrderModel.fromEntity(order);
      final orderId = await localDataSource.saveOrder(orderModel);
      return Right(orderId);
    } catch (e, stackTrace) {
      developer.log('Database Error during saveOrder', error: e, stackTrace: stackTrace, name: 'PosRepositoryImpl');
      return const Left(DatabaseFailure('فشل في حفظ الطلب. يرجى المحاولة مرة أخرى.'));
    }
  }

  // ==========================================
  // 🚀 [Fix]: تنفيذ الدوال المفقودة للـ Contract
  // ==========================================
  
  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers() async {
    try {
      final data = await localDataSource.getCustomers();
      final entities = data.map((c) => CustomerEntity(id: c.id, name: c.name, phone: c.phone, address: c.address)).toList();
      return Right(entities);
    } catch (e) {
      return const Left(DatabaseFailure('فشل في جلب العملاء'));
    }
  }

  @override
  Future<Either<Failure, List<ZoneEntity>>> getZones() async {
    try {
      final data = await localDataSource.getZones();
      final entities = data.map((z) => ZoneEntity(id: z.id, name: z.name)).toList();
      return Right(entities);
    } catch (e) {
      return const Left(DatabaseFailure('فشل في جلب المناطق'));
    }
  }

  @override
  Future<Either<Failure, List<RestaurantTableEntity>>> getTablesByZone(int zoneId) async {
    try {
      final data = await localDataSource.getTablesByZone(zoneId);
      final entities = data.map((t) => RestaurantTableEntity(id: t.id, zoneId: t.zoneId, tableNumber: t.tableNumber, capacity: t.capacity, status: t.status)).toList();
      return Right(entities);
    } catch (e) {
      return const Left(DatabaseFailure('فشل في جلب الطاولات'));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods() async {
    try {
      final data = await localDataSource.getPaymentMethods();
      final entities = data.map((p) => PaymentMethodEntity(id: p.id, name: p.name, isActive: p.isActive)).toList();
      return Right(entities);
    } catch (e) {
      return const Left(DatabaseFailure('فشل في جلب طرق الدفع'));
    }
  }

  @override
  Future<Either<Failure, int>> addCustomer(CustomerEntity customer) async {
    try {
      final companion = CustomersCompanion.insert(
        name: customer.name,
        phone: Value(customer.phone),
        address: Value(customer.address),
      );
      final id = await localDataSource.addCustomer(companion);
      return Right(id);
    } catch (e) {
      return const Left(DatabaseFailure('فشل في إضافة العميل'));
    }
  }
}