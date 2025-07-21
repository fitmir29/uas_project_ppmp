import 'package:dio/dio.dart';
import 'package:uas_flutter_pos/data/model/income_model.dart';
import 'package:uas_flutter_pos/dio/dio_client.dart';

class IncomeRepository {
  final Dio _dio = DioClient.dio;

  Future<List<Income>> getIncome() async {
    try {
      final res = await _dio.get('/item_income');
      print("Fetched incomes: ${res.data}");
      return (res.data as List).map((e) => Income.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching incomes: $e");
      throw Exception("Failed to fetch income");
    }
  }

  Future<void> addIncome(Income income) async {
    try {
      final res = await _dio.post('/item_income', data: income.toJson());
      print("Added income: ${res.data}");
    } catch (e) {
      print("Error adding income: $e");
      throw Exception("Failed to add income");
    }
  }

  Future<void> updateIncome(int id, Income income) async {
    try {
      final res = await _dio.put('/item_income/$id', data: income.toJson());
      print("Updated income: ${res.data}");
    } catch (e) {
      print("Error updating income: $e");
      throw Exception("Failed to update income");
    }
  }

  Future<void> deleteIncome(int id) async {
    try {
      final res = await _dio.delete('/item_income/$id');
      print("Deleted income: ${res.data}");
    } catch (e) {
      print("Error deleting income: $e");
      throw Exception("Failed to delete income");
    }
  }
}
