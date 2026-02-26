import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  void setIndex(int index) {
    if (index == state) {
      return;
    }
    emit(index);
  }
}
