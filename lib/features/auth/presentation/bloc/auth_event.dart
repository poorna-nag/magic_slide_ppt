import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheck extends AuthEvent {}

class AuthSignup extends AuthEvent {
  final String email;
  final String password;
  const AuthSignup(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;
  const AuthLogin(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class AuthLogout extends AuthEvent {}
