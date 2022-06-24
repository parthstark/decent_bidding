import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_drawer.dart';
import 'sell_new_item.dart';
import '../screen/product_page.dart';

import '../models/my_account_obj.dart';
import '../models/product_obj.dart';

// import '../utils/item_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: Colors.yellow.shade100,

      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Consumer<MyWalletNotifier>(
          builder: (context, myWalletNotifier, _) {
            String name = myWalletNotifier.name;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hi $name! ",
                    style: TextStyle(color: Colors.grey.shade800)),
                Text(
                  "What's on your mind today?",
                  style: TextStyle(color: Colors.grey.shade800),
                  textScaleFactor: 0.5,
                )
              ],
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Consumer<MyWalletNotifier>(
                  builder: (context, myWalletNotifier, _) {
                    return Text(
                      myWalletNotifier.city,
                      style: TextStyle(color: Colors.grey.shade800),
                      textScaleFactor: 0.75,
                    );
                  },
                ),
                Icon(Icons.pin_drop, color: Colors.grey.shade800)
              ],
            ),
          )
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SellNewItem()));
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(child: Icon(Icons.sell)),
              Text(
                "Sell",
                style: TextStyle(color: Colors.grey.shade800),
                textScaleFactor: 0.75,
              )
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: SizedBox(
            width: h / 1.5,
            child: StreamBuilder<List<Product>>(
              stream: readProducts(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  // List of products being sold
                  List<Product> products = snapshot.data!;
                  return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, i) {
                        // Card
                        return InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProductPage(viewProduct: products[i]))),
                          child: Card(
                            child: SizedBox(
                              height: h / 6,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Image(
                                        height: h / 8,
                                        width: h / 8,
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            products[i].images[0])),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Title and Price
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: Text(
                                                products[i].title,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color:
                                                        Colors.grey.shade800),
                                                textScaleFactor: 2,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  products[i].price,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey.shade800),
                                                  textScaleFactor: 1.75,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: Image.asset(
                                                    'assets/eth_ico.png',
                                                    height: 24,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Location and Date of posting
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          products[i].location,
                                          style: TextStyle(
                                              color: Colors.grey.shade800),
                                        ),
                                        Text(DateFormat("yMMMMd")
                                            .format(products[i].datePosted)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                } else {
                  return const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              }),
            ),
          ),
        ),
      ),
    );
  }

  Stream<List<Product>> readProducts() {
    final productsSnapshots = FirebaseFirestore.instance
        .collection('products')
        .orderBy('date_posted', descending: true)
        .where('is_running', isEqualTo: true)
        .snapshots();

    return productsSnapshots.map((snapshot) =>
        snapshot.docs.map((doc) => Product.jsonToMap(doc.data())).toList());
  }
}
