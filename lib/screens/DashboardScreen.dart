import 'package:flutter/material.dart';
import 'package:gastos/components/MovementWidget.dart';
import 'package:gastos/data/database/DatabaseHelper.dart';
import 'package:gastos/data/models/MovementType.dart';
import 'package:gastos/data/models/Movements.dart';
import 'package:gastos/data/models/User.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  User? user = null;
  var amountController = TextEditingController();
  var descriptionController = TextEditingController();

  var databaseHelper = DatabaseHelper();
  MovementType? movementType = MovementType.CREDIT;
  List<Movement> movements = List.empty();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  String getDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);
    return formatted;
  }

  Future<void> saveMovement() async {
    if (amountController.text.isEmpty || descriptionController.text.isEmpty) {
    } else {
      var movement = Movement(
          id: 0,
          type: movementType?.index ?? 0,
          amount: double.parse(amountController.text),
          date: getDate(),
          description: descriptionController.text);
      await databaseHelper.insert(
          movement.toMap(), DatabaseHelper.tableMovement);
      amountController.clear();
      descriptionController.clear();
      var map = user!.toMap();
      map['amountTotal'] = movementType == MovementType.CREDIT
          ? user!.totalAmount - movement.amount
          : user!.totalAmount + movement.amount;
      await databaseHelper.update(map, DatabaseHelper.tableUser);
      getUser();
    }
  }

  Future<void> getUser() async {
    await databaseHelper.init();
    var rows = await databaseHelper.queryAllRows(DatabaseHelper.tableUser);
    print(rows);
    setState(() {
      user = User(
          id: rows[0]['id'] as int,
          name: rows[0]['name'] as String,
          totalAmount: double.parse(rows[0]['amountTotal'].toString()));
    });
    getMovements();
  }

  Future<void> getMovements() async {
    final List<Map<String, dynamic>> maps =
        await databaseHelper.queryAllRows(DatabaseHelper.tableMovement);

    setState(() {
      movements = List.generate(maps.length, (i) {
        return Movement(
            id: maps[i]['id'] as int,
            type: maps[i]['type'] as int,
            amount: double.parse(maps[i]['amount'].toString()),
            date: maps[i]['date'] as String,
            description: maps[i]['description'] is String
                ? maps[i]['description'] as String
                : "No tienes descripcion para este movimiento");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Spacer(),
            Text("Hola ${user?.name}"),
            Text("Cantidad total de dinero que tienes: ${user?.totalAmount}"),
            Text("Tus movimientos:"),
            Expanded(
                child: ListView.builder(
                    itemCount: movements.length,
                    itemBuilder: (context, i) {
                      return MovementWidget(
                          description: movements[i].description,
                          amount: movements[i].amount,
                          type: movements[i].type,
                          date: movements[i].date);
                    })),
            Column(
              children: [
                ListTile(
                  title: Text("Credito"),
                  leading: Radio<MovementType>(
                    groupValue: movementType,
                    value: MovementType.CREDIT,
                    onChanged: ((value) => setState(() {
                          movementType = value;
                        })),
                  ),
                ),
                ListTile(
                  title: Text("Debito"),
                  leading: Radio<MovementType>(
                    groupValue: movementType,
                    value: MovementType.DEBIT,
                    onChanged: ((value) => setState(() {
                          movementType = value;
                        })),
                  ),
                )
              ],
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Monto de movimiento'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hintText: 'Descripcion'),
            ),
            ElevatedButton(
                onPressed: () => {saveMovement()},
                child: Text("Agregar movimiento"))
          ],
        ),
      ),
    );
  }
}
