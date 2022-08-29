import 'package:flutter/material.dart';
import 'package:tutorbin/models/menu_items.dart';

class MenuModel {
  MenuModel({
    required this.categoryName,
    required this.menuItems,
  });

  String categoryName;
  List<MenuItems> menuItems;

  factory MenuModel.fromJson(Map<String, dynamic> json, String categoryName) => MenuModel(
        categoryName: categoryName,
        menuItems: List<MenuItems>.from(json[categoryName].map((x) => MenuItems.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categoryName": categoryName,
        "menuItems": List<dynamic>.from(menuItems.map((x) => x.toJson())),
      };

  /// The current total price of all items.
  int get totalPrice => menuItems.fold(0, (total, current){
    if(current.quantity! > 0){
      total += current.quantity! * current.price!;
    }
    return total;
  });

  List<MenuItems> getSelectedItems(){
    List<MenuItems> list = [];
    for(MenuItems item in menuItems){
      if(item.quantity! > 0){
        list.add(item);
      }
    }
    return list;
  }

}
