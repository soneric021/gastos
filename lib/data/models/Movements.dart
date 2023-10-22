class Movement{
     final int id;
     final int type;
     final double amount;
     final String date;
     final String description;

     Movement({
        required this.id,
        required this.type,
        required this.amount,
        required this.date,
        required this.description
    });

      Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'date': date,
      'description': description
    };
}

}