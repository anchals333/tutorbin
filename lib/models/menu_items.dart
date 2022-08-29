import 'package:hive/hive.dart';

part 'menu_items.g.dart';

@HiveType(typeId: 2)
class MenuItems extends HiveObject {
  MenuItems({ this.name,  this.price,  this.instock,  this.quantity, this.isBestseller = false});

  @HiveField(0)
  String? name;
  @HiveField(1)
  int? price;
  @HiveField(2)
  bool? instock;
  @HiveField(3)
  int? quantity;
  bool? isBestseller;

  factory MenuItems.fromJson(Map<String, dynamic> json) =>
      MenuItems(name: json["name"], price: json["price"], instock: json["instock"], quantity: 0);

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "instock": instock,
        "quantity": quantity,
      };

  void add() {
    quantity = quantity! + 1;
  }

  void remove() {
    quantity  = quantity! - 1;
  }
}

