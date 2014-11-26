
library prompt.example.barista.coffee_order;

//enum CoffeeItem {Coffee, Espresso, Cappucino, Mocha, Chai}
//enum CoffeeSize {Short, Tall, Grande}
class CoffeeOrder {
  final String name;
  final String size;
  final bool iced;
  final String item;
  final bool double;
  final bool straw;

  CoffeeOrder({this.name, this.size, this.iced, this.item, this.double, this.straw});

  bool operator ==(CoffeeOrder other) =>
      other is CoffeeOrder &&
      name == other.name &&
      size == other.size  &&
      iced == other.iced &&
      item == other.item &&
      double == other.double &&
      straw == other.straw;

  int get hashCode => name.hashCode ^ size.hashCode ^ iced.hashCode ^
      item.hashCode ^ double.hashCode ^ straw.hashCode;

  String toString() => '$size ${iced ? 'iced ' : ''}${double ? 'double ' : ''}$item ${straw ? 'with a straw ' : ''}for $name';
}
