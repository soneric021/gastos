import 'package:flutter/material.dart';
import 'package:gastos/data/database/DatabaseHelper.dart';
import 'package:gastos/data/models/User.dart';
import 'package:gastos/screens/DashboardScreen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  var nameController = TextEditingController();
  var amountController = TextEditingController();
  var databaseHelper = DatabaseHelper();
  var canAdvance = false;

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  Future<void> checkUser() async {
    await databaseHelper.init();
    var users = await databaseHelper.queryRowCount(DatabaseHelper.tableUser);

    setState(() {
      canAdvance = users > 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (canAdvance) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
      }
    });
  }

  Future<void> addUser() async {
    await databaseHelper.init();
    if (nameController.text.isEmpty || amountController.text.isEmpty) {
    } else {
      var user = User(
          id: 4,
          name: nameController.text,
          totalAmount: double.parse(amountController.text));
      var result =
          await databaseHelper.insert(user.toMap(), DatabaseHelper.tableUser);
      print("SE GUARDO: ${result > 0}");
      setState(() {
        canAdvance = result > 0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (canAdvance) {
          // condition here
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DashboardScreen()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Aplicacion sin nombre"),
              Text("Agrega tu nombre "),
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: 'Nombre')),
              Text("Agrega tu monto total"),
              TextField(
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  decoration: InputDecoration(hintText: 'Monto total')),
              ElevatedButton(
                  onPressed: () => {addUser()}, child: Text("Guardar"))
            ],
          ),
        ),
      ),
    );
  }
}
