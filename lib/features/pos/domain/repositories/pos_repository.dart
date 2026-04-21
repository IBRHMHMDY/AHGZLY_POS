import 'package:ahgzly_pos/core/common/entities/customer_entity.dart';
import 'package:ahgzly_pos/core/common/entities/payment_method_entity.dart';
import 'package:ahgzly_pos/core/common/entities/restaurant_table_entity.dart';
import 'package:ahgzly_pos/core/common/entities/zone_entity.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/pos/domain/entities/order_entity.dart';

abstract class PosRepository {
  Future<Either<Failure, int>> saveOrder(OrderEntity order);
  Future<Either<Failure, List<CustomerEntity>>> getCustomers();
  Future<Either<Failure, List<ZoneEntity>>> getZones();
  Future<Either<Failure, List<RestaurantTableEntity>>> getTablesByZone(int zoneId);
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();

  // دوال مساعدة لإنشاء عميل جديد من شاشة الـ POS مباشرة للطلبات الخارجية (Delivery)
  Future<Either<Failure, int>> addCustomer(CustomerEntity customer);
}