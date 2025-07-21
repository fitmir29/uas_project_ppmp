import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uas_flutter_pos/cubit/income_cubit.dart';
import 'package:uas_flutter_pos/cubit/income_state.dart';
import 'package:uas_flutter_pos/screens/income_detail_screen.dart';
import '../screens/income_form_screen.dart';

class IncomeListScreen extends StatefulWidget {
  @override
  _IncomeListScreenState createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends State<IncomeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List _filteredIncomes = [];

  @override
  void initState() {
    super.initState();
    context.read<IncomeCubit>().fetchIncomes();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final cubit = context.read<IncomeCubit>();
    final state = cubit.state;
    if (state is IncomeLoaded) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredIncomes = state.incomes
            .where((income) => income.source.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    return DateFormat('dd MMMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Incomes", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.cyan[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: BlocListener<IncomeCubit, IncomeState>(
        listener: (context, state) {
          if (state is IncomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<IncomeCubit, IncomeState>(
          builder: (context, state) {
            if (state is IncomeLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is IncomeLoaded) {
              final data = _searchController.text.isEmpty
                  ? state.incomes
                  : _filteredIncomes;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search income source...",
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: data.isEmpty
                        ? Center(child: Text('No income records found.'))
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: data.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final income = data[index];
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => IncomeDetailScreen(
                                              income: income),
                                        ),
                                      );
                                    },
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      income.source,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${income.amount} - ${formatDate(income.date)}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.blueGrey),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    IncomeFormScreen(
                                                        income: income),
                                              ),
                                            ).then((_) {
                                              context
                                                  .read<IncomeCubit>()
                                                  .fetchIncomes();
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: Text("Hapus Pendapatan"),
                                                content: Text(
                                                    "Yakin ingin menghapus ini?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child: Text("Batal"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                    child: Text("Hapus"),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              context
                                                  .read<IncomeCubit>()
                                                  .deleteIncome(income.id!);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text('Income deleted')),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            } else if (state is IncomeError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return Center(child: Text('No data'));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan[800],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => IncomeFormScreen()),
          ).then((_) {
            context.read<IncomeCubit>().fetchIncomes();
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
