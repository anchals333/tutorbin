import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tutorbin/models/menu_items.dart';
import 'package:tutorbin/models/menu_model.dart';
import 'package:tutorbin/provider/menu_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MenuItemsAdapter());
  await Hive.openBox<MenuItems>('menu_items');
  runApp(
    ChangeNotifierProvider(
      create: (context) => MenuProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutorbin Assessment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Tutorbin Assessment'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(builder: (_, items, child) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.title,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: GestureDetector(
          onTap: () async {
            if (items.totalPrice > 0) {
              bool saveStatus = await Provider.of<MenuProvider>(context, listen: false).saveOrderDetails();
              if (saveStatus) {
                refresh();
                Fluttertoast.showToast(msg: "Order is placed successfully");
              } else {
                Fluttertoast.showToast(msg: "Failed to save the order. Please retry");
              }
            } else {
              Fluttertoast.showToast(msg: "Please add products in cart.");
            }
          },
          child: Container(
            padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 20),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(50)),
            child: Text(
              "Place Order:  Rs.${items.totalPrice}",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 100),
          itemCount: items.menuItems.length,
          itemBuilder: (_, index) {
            MenuModel model = items.menuItems[index];
            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(10)),
              child: ExpandablePanel(
                  theme: const ExpandableThemeData(
                      iconColor: Colors.black, headerAlignment: ExpandablePanelHeaderAlignment.center),
                  header: Text(
                    model.categoryName.toUpperCase(),
                    style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  collapsed: const SizedBox(),
                  expanded: getMenuList(list: model.menuItems)),
            );
          },
        ),
      );
    });
  }

  Widget getMenuList({required List<MenuItems> list}) {
    return ListView.builder(
        padding: const EdgeInsets.all(10),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (_, index) {
          MenuItems menu = list[index];
          return Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.only(left: 10, right: 10, top: 25, bottom: 25),
            margin: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          menu.name!,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if (menu.isBestseller!)
                          Container(
                            padding: EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 5),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.red),
                            child: const Text(
                              'Bestseller',
                              style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.normal),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Rs. ${menu.price}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                if (menu.quantity == 0)
                  GestureDetector(
                    onTap: () {
                      menu.add();
                      Provider.of<MenuProvider>(context, listen: false).notifyListeners();
                    },
                    child: Container(
                        padding: const EdgeInsets.only(left: 40, right: 40, top: 6, bottom: 6),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(40)),
                        child: const Text(
                          'Add',
                          style: TextStyle(color: Colors.orange),
                        )),
                  ),
                if (menu.quantity! > 0)
                  Container(
                    padding: const EdgeInsets.only(left: 5, right: 5, top: 4, bottom: 4),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(40)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (menu.quantity! > 0) {
                              menu.remove();
                              Provider.of<MenuProvider>(context, listen: false).notifyListeners();
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 15.0, left: 5),
                            child: Icon(
                              Icons.remove,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        Text(
                          menu.quantity.toString(),
                          style: const TextStyle(color: Colors.orange),
                        ),
                        GestureDetector(
                          onTap: () {
                            menu.add();
                            Provider.of<MenuProvider>(context, listen: false).notifyListeners();
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 15.0, right: 5),
                            child: Icon(
                              Icons.add,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          );
        });
  }

  void refresh(){
    Provider.of<MenuProvider>(context, listen: false).resetQuantity();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => super.widget));
  }

  @override
  dispose() {
    super.dispose();
    Hive.close();
  }
}
