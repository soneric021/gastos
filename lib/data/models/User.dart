
class User{
    final int id;
    final String name;
    final double totalAmount;

    const User({
        required this.id,
        required this.name,
        required this.totalAmount
    });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amountTotal': totalAmount,
    };
}

}