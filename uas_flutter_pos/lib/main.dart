import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uas_flutter_pos/cubit/income_cubit.dart';
import 'package:uas_flutter_pos/data/repository/income_repository.dart';
import 'package:uas_flutter_pos/screens/income_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final IncomeRepository incomeRepository = IncomeRepository();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IncomeCubit>(
      create: (_) => IncomeCubit(incomeRepository)..fetchIncomes(),
      child: MaterialApp(
        title: 'Income Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: IncomeListScreen(),
      ),
    );
  }
}
