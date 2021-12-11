part of 'authentication_cubit.dart';

@immutable
abstract class AuthenticationState extends Equatable {}

class AuthenticationInitial extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class AuthenticationUnauthenticated extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class AuthenticationAuthenticated extends AuthenticationState {

  final String email;
  final String password;


  AuthenticationAuthenticated.create(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}
