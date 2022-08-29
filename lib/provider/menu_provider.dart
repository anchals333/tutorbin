import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:tutorbin/models/menu_items.dart';
import 'package:tutorbin/models/menu_model.dart';

class MenuProvider extends ChangeNotifier {
  // late Box<CartModel> cartBox;
  late Box<MenuItems> menuBox;

  final List<MenuModel> _items = [];

  UnmodifiableListView<MenuModel> get menuItems => UnmodifiableListView(_items);

  /// The current total price of all items.
  int get totalPrice => _items.fold(0, (total, current) => total + current.totalPrice);

  MenuProvider() {
    getPopularCategories();
    getMenu();
  }

  Future<void> openHiveBoxes() async {
    try {
      menuBox = await Hive.openBox<MenuItems>('menu_items');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /// Fetch content from the json file
  Future<void> getMenu() async {
    final String response = await rootBundle.loadString('assets/menu.json');
    final data = await json.decode(response);
    for (int i = 0; i < data.length; i++) {
      String categoryName = "cat${i + 1}";
      _items.add(MenuModel.fromJson(data, categoryName));
    }
    notifyListeners();
  }

  Future<void> getPopularCategories() async {
    try {
      var menuItems = Hive.box<MenuItems>("menu_items");
      if (menuItems.isOpen) {
        _items.clear();
        List<MenuItems> list = menuItems.values.toList().cast<MenuItems>();
        if (list.isNotEmpty) {
          list.sort((a, b) => b.quantity!.compareTo(a.quantity!));
          int len = list.length > 3 ? 3 : list.length;
          MenuModel model = MenuModel(categoryName: "Popular Categories", menuItems: list.getRange(0, len).toList());
          model.menuItems.first.isBestseller = true;
          model.menuItems.forEach((element) {
            element.quantity = 0;
          });
          _items.add(model);
        }
      } else {
        openHiveBoxes();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /// Get all selected items
  List<MenuItems> getSelectedItems() {
    List<MenuItems> list = [];
    for (MenuModel item in menuItems) {
      if (item.getSelectedItems().isNotEmpty) {
        list.addAll(item.getSelectedItems());
      }
    }
    return list;
  }

  /// Saving order details using Hive database
  Future<bool> saveOrderDetails() async {
    try {
      var menuItemBox = Hive.box<MenuItems>('menu_items');
      List<MenuItems> list = getSelectedItems();
      for (MenuItems menu in list) {
        MenuItems model = MenuItems()
          ..quantity = menu.quantity
          ..isBestseller = false
          ..name = menu.name
          ..instock = menu.instock
          ..price = menu.price;

        menuItemBox.add(model);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  resetQuantity(){
    getPopularCategories();
    getMenu();
    notifyListeners();
  }
}
