import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uas_flutter_pos/cubit/income_cubit.dart';
import '../data/model/income_model.dart';

class IncomeFormScreen extends StatefulWidget {
  final Income? income;

  const IncomeFormScreen({this.income});

  @override
  _IncomeFormScreenState createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _source;
  late TextEditingController _amount;
  late TextEditingController _date;

  @override
  void initState() {
    _source = TextEditingController(text: widget.income?.source ?? '');
    _amount =
        TextEditingController(text: widget.income?.amount.toString() ?? '');
    _date = TextEditingController(text: widget.income?.date ?? '');
    super.initState();
  }

  @override
  void dispose() {
    _source.dispose();
    _amount.dispose();
    _date.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final income = Income(
        id: widget.income?.id,
        source: _source.text,
        amount: double.parse(_amount.text),
        date: _date.text,
      );

      final cubit = context.read<IncomeCubit>();
      if (widget.income == null) {
        cubit.addIncome(income);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adding income...')),
        );
      } else {
        cubit.updateIncome(widget.income!.id!, income);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updating income...')),
        );
      }

      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.income != null
          ? DateTime.parse(widget.income!.date)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _date.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.income != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Income' : 'Add Income',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.cyan[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _source,
                    decoration: _buildInputDecoration('Source', Icons.work),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter a valid source' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _amount,
                    decoration: _buildInputDecoration('Amount', Icons.money),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter a valid amount' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _date,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration:
                        _buildInputDecoration('Date', Icons.calendar_today),
                    validator: (value) =>
                        value!.isEmpty ? 'Select a valid date' : null,
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan[800],
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(isEditing ? Icons.save : Icons.add,
                          size: 20, color: Colors.white),
                      label: Text(
                        isEditing ? 'Update Income' : 'Add Income',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
