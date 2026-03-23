import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/settings/domain/entities/app_settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class SaveSettingsEvent extends SettingsEvent {
  final AppSettings settings;
  const SaveSettingsEvent(this.settings);
  @override
  List<Object> get props => [settings];
}