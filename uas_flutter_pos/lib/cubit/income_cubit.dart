import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uas_flutter_pos/cubit/income_state.dart';
import 'package:uas_flutter_pos/data/model/income_model.dart';
import 'package:uas_flutter_pos/data/repository/income_repository.dart';

class IncomeCubit extends Cubit<IncomeState> {
  final IncomeRepository _repository;

  IncomeCubit(this._repository) : super(IncomeInitial());

  void fetchIncomes() async {
    try {
      emit(IncomeLoading());
      final incomes = await _repository.getIncome();
      emit(IncomeLoaded(incomes));
    } catch (e) {
      print('Fetch error: ${e.toString()}');
      emit(IncomeError("Failed to load incomes"));
    }
  }

  void addIncome(Income income) async {
    try {
      emit(IncomeLoading());
      await _repository.addIncome(income);
      fetchIncomes();
    } catch (e) {
      emit(IncomeError("Failed to add income"));
    }
  }

  void updateIncome(int id, Income income) async {
    try {
      emit(IncomeLoading());
      await _repository.updateIncome(id, income);
      fetchIncomes();
    } catch (e) {
      emit(IncomeError("Failed to update income"));
    }
  }

  void deleteIncome(int id) async {
    try {
      emit(IncomeLoading());
      await _repository.deleteIncome(id);
      fetchIncomes();
    } catch (e) {
      emit(IncomeError("Failed to delete income"));
    }
  }
}
