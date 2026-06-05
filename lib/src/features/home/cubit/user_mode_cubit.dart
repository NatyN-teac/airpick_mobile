import 'package:flutter_bloc/flutter_bloc.dart';

enum UserMode { sender, carrier }

extension UserModeX on UserMode {
  String get label => this == UserMode.sender ? 'Sender' : 'Carrier';
  String get pillLabel => this == UserMode.sender ? 'Sender mode' : 'Carrier mode';
  String get description => this == UserMode.sender
      ? 'I need items delivered'
      : "I'm traveling & can carry items";
}

class UserModeCubit extends Cubit<UserMode> {
  UserModeCubit() : super(UserMode.sender);

  void setMode(UserMode mode) => emit(mode);
}
