import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  runApp(Electriccalculator());
}

class Expense{
  final String pmonth;
  final String cmonth;

  Expense(this.pmonth,this.cmonth);
}

class Electriccalculator extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: ExpenseList(),
    );
  }
}

class ExpenseList extends StatefulWidget{
  @override
  _ExpenseListState createState() => _ExpenseListState();
}


class _ExpenseListState extends State<ExpenseList> {
  final List<Expense> expenses = [];
  final TextEditingController pmonthController = TextEditingController();
  final TextEditingController cmonthController = TextEditingController();
  final TextEditingController electricController = TextEditingController();
  String uservalue = '';

  @override
  void initState() {
    super.initState();
    _loadSaveData();
  }
  void _loadSaveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pmonthController.text = prefs.getString('_prevMonth') ?? '';
      cmonthController.text = prefs.getString('_currMonth') ?? '';
      uservalue = prefs.getString('_selectedRate') ?? '';

      electricController.text =
      'RM${(prefs.getDouble('_totalAmount') ?? 0.0).toStringAsFixed(2)}';
    });
  }


  void _addExpense()async {
    String pmonth = pmonthController.text.trim();
    String cmonth = cmonthController.text.trim();
    if (cmonth.isNotEmpty && pmonth.isNotEmpty) {
      double rate = 0.0;
      if (uservalue == 'Residential') {
        rate = 0.095;
      } else if (uservalue == 'Industrial') {
        rate = 0.125;
      }

      double totalKWhUsed = double.parse(cmonth) - double.parse(pmonth);
      double totalPrice = totalKWhUsed * rate;

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('_prevMonth', pmonth);
      await prefs.setString('_currMonth', cmonth);
      await prefs.setString('_selectedRate', uservalue);
      await prefs.setDouble('_totalAmount', totalPrice);

      setState(() {
        expenses.add(Expense(pmonth, cmonth));
        pmonthController.clear();
        cmonthController.clear();
        electricController.text = 'RM${totalPrice.toStringAsFixed(2)}';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Electric Usage Calculator'),
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: pmonthController,
                decoration: InputDecoration(
                  labelText: 'Previous Month Reading （kWh）',
                ),
              ),
          ),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: cmonthController,
                decoration: InputDecoration(
                  labelText: 'Current Month reading(kWh)',
                ),
              ),
          ),
          Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Radio<String>(value: "Residential", groupValue:uservalue, onChanged: (value) => setState(() => uservalue = value!)),
                        Text('Residential'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(value: "Industrial", groupValue:uservalue, onChanged: (value) => setState(() => uservalue = value!)),
                        Text('Industrial'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
              onPressed: _addExpense,
              child: Text('Calculate charge and save'),
          ),
          Container(
            child: _buildListView(),

          ),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: electricController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText:'RM',
                ),
              ),
          ),
        ],
      ),
    );
  }

  _buildListView() {}
}

