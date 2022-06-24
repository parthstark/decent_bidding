import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_obj.dart';
import '../models/my_account_obj.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({Key? key}) : super(key: key);

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    final myWalletNotifier = Provider.of<MyWalletNotifier>(context);
    return Scaffold(
      backgroundColor: Colors.yellow.shade100,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text("My Items", style: TextStyle(color: Colors.grey.shade800)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: SizedBox(
            width: h / 1.5,
            child: StreamBuilder<List<Product>>(
                stream: readMyProducts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Product>? myProducts = snapshot.data;
                    return ListView.builder(
                        itemCount: myProducts!.length,
                        itemBuilder: (context, i) {
                          // Card
                          return Card(
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
                                            myProducts[i].images[0])),
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
                                            Text(
                                              myProducts[i].title,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.grey.shade800),
                                              textScaleFactor: 2,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  myProducts[i].price,
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey.shade800),
                                                  textScaleFactor: 1.5,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: Image.asset(
                                                    'assets/eth_ico.png',
                                                    height: 20,
                                                  ),
                                                )
                                              ],
                                            ),
                                            const Expanded(child: SizedBox()),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                () {
                                                  if (myProducts[i]
                                                              .currBidder !=
                                                          myWalletNotifier
                                                              .account &&
                                                      myProducts[i].isRunning) {
                                                    return ElevatedButton(
                                                      onPressed: () =>
                                                          _acceptOffer(
                                                              myProducts[i]
                                                                  .productId),
                                                      child: Text(
                                                        "Accept current offer",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade800),
                                                      ),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              primary: Colors
                                                                  .yellow),
                                                    );
                                                  } else {
                                                    return Container();
                                                  }
                                                }()
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
    );
  }

  Stream<List<Product>> readMyProducts() {
    final myWalletNotifier =
        Provider.of<MyWalletNotifier>(context, listen: false);
    final productsSnapshots = FirebaseFirestore.instance
        .collection('products')
        .where('seller_id', isEqualTo: myWalletNotifier.account)
        .snapshots();
    return productsSnapshots.map((snapshot) =>
        snapshot.docs.map((doc) => Product.jsonToMap(doc.data())).toList());
  }

  _acceptOffer(String productId) async {
    final alertDialogController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter your contact details'),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Column(
            children: [
              const Text(
                  'Mobile/Email or any other means of communication for buyer to reach you'),
              TextField(
                controller: alertDialogController,
                decoration: const InputDecoration(hintText: 'type here'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                await _updateFirestore(productId, alertDialogController.text);
                Navigator.pop(context);
              },
              child: const Text('Send'))
        ],
      ),
    );
  }

  _updateFirestore(String productId, String text) async {
    if (text.isEmpty) return;
    // Update price inside firestore
    final docUser =
        FirebaseFirestore.instance.collection('products').doc(productId.trim());

    final now = DateTime.now();
    final dueDate = DateTime(now.year, now.month, now.day + 15);
    await docUser.update(
      {'is_running': false, 'due_date': dueDate, 'contact_details': text},
    );

    // Done Snackbar
    SnackBar snackBar = const SnackBar(content: Text('Done'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
