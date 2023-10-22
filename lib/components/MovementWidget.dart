import 'package:flutter/material.dart';
import 'package:gastos/data/models/MovementType.dart';

class MovementWidget extends StatelessWidget {
  final String description;
  final double amount;
  final int type;
  final String date;
  const MovementWidget(
      {Key? key,
      required this.description,
      required this.amount,
      required this.type,
      required this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(alignment:Alignment.topLeft ,child: Text(description, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold), textAlign: TextAlign.start,)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: TextStyle(color: Colors.grey),),
              Text(
                "${type == MovementType.CREDIT.index ? '-' : '+'} RD\$$amount",
                style: TextStyle(
                    color: type == MovementType.CREDIT.index
                        ? Colors.red
                        : Colors.green),
              )
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
