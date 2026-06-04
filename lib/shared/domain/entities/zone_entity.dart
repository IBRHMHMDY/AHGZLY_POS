import 'package:equatable/equatable.dart';

class ZoneEntity extends Equatable {
  final int? id;
  final String name;

  const ZoneEntity({
    this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}