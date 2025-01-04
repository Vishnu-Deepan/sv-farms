// Data class for MilkPlan
class Plans {
  final int litres;
  final int price;
  final int discount;

  Plans(this.litres, this.price, {this.discount = 0});
}