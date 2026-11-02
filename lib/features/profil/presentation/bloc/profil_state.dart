import 'package:equatable/equatable.dart';

abstract class ProfilState extends Equatable {
  const ProfilState();
  @override
  List<Object?> get props => [];
}

class ProfilInitial extends ProfilState {}
class ProfilLoading extends ProfilState {}
class ProfilLoaded extends ProfilState {
  final Map<String, dynamic> user;
  const ProfilLoaded(this.user);
  @override
  List<Object?> get props => [user];
}
class ProfilUpdateSuccess extends ProfilState {}
class ProfilError extends ProfilState {
  final String message;
  const ProfilError(this.message);
  @override
  List<Object?> get props => [message];
}