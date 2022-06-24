import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decent_bidding/models/my_contract.dart';
import 'package:web3dart/web3dart.dart' as web3;

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/contracts.dart';

import '../models/product_obj.dart';
import '../models/my_account_obj.dart';
import '../utils/signer.dart';

class MyBids extends StatefulWidget {
  const MyBids({Key? key}) : super(key: key);

  @override
  State<MyBids> createState() => _MyBidsState();
}

class _MyBidsState extends State<MyBids> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.yellow.shade100,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text("My Bids", style: TextStyle(color: Colors.grey.shade800)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: SizedBox(
            width: h / 1.5,
            child: StreamBuilder<List<Product>>(
                stream: readMyBids(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Product>? myBids = snapshot.data;
                    return ListView.builder(
                        itemCount: myBids!.length,
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
                                        image:
                                            NetworkImage(myBids[i].images[0])),
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
                                            Expanded(
                                              child: Text(
                                                myBids[i].title,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color:
                                                        Colors.grey.shade800),
                                                textScaleFactor: 2,
                                              ),
                                            ),
                                            () {
                                              if (!myBids[i].isRunning) {
                                                return ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          primary:
                                                              Colors.yellow),
                                                  onPressed: () =>
                                                      _confirmTransaction(
                                                          myBids[i].productId),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(20, 5, 20, 5),
                                                    child: Text(
                                                      "Offer Accepted\nTap to proceed further",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade800),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      myBids[i].price,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade800),
                                                      textScaleFactor: 1.75,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: Image.asset(
                                                        'assets/eth_ico.png',
                                                        height: 24,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                            }(),
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

  Stream<List<Product>> readMyBids() {
    final myWalletNotifier =
        Provider.of<MyWalletNotifier>(context, listen: false);

    final productsSnapshots = FirebaseFirestore.instance
        .collection('products')
        .where('curr_bidder', isEqualTo: myWalletNotifier.account)
        .where('seller_id', isNotEqualTo: myWalletNotifier.account)
        .snapshots();

    return productsSnapshots.map((snapshot) =>
        snapshot.docs.map((doc) => Product.jsonToMap(doc.data())).toList());
  }

  _confirmTransaction(String productId) async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();
    DateTime dueDate = (doc.data()!['due_date'] as Timestamp).toDate();
    String contactDetails = doc.data()!['contact_details'];
    if (DateTime.now().isBefore(dueDate)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
              'Complete your purchase before ${DateFormat('yMMMMd').format(dueDate)}'),
          content: Text('Seller contact details:\n$contactDetails'),
          actions: [
            TextButton(
              child: const Text('Failed'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Caution!'),
                    content: const Text(
                        'You are about to terminate the purchase\nDo you want to proceed?'),
                    actions: [
                      TextButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () async {
                          await _finish(false, productId);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          FirebaseFirestore.instance
                              .collection('products')
                              .doc(productId)
                              .delete();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Transaction Completed'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Caution!'),
                    content: const Text(
                        'After this step your bid amount will be transferred to the seller\nDo you want to proceed?'),
                    actions: [
                      TextButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () async {
                          await _finish(true, productId);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          FirebaseFirestore.instance
                              .collection('products')
                              .doc(productId)
                              .delete();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Due date gone'),
          content: const Text(
              'You can no longer make this purachase\nProceed to return back your amount'),
          actions: [
            TextButton(
              onPressed: () async {
                await _finish(false, productId);
                Navigator.pop(context);
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .delete();
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  _finish(bool completeTransaction, String productId) async {
    final myContract = MyContract();
    late ContractFunction myFunction;
    if (completeTransaction) {
      myFunction = myContract.deployedContract.function('completed');
    } else {
      myFunction = myContract.deployedContract.function('failed');
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Confirm'),
              content: const Text('Go to Metamask to complete.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                )
              ],
            ));

    final myWalletNotifier =
        Provider.of<MyWalletNotifier>(context, listen: false);
    final httpClient = Client();
    final ethClient = web3.Web3Client(
        "https://rinkeby.infura.io/v3/618a8e47885c4205898892390a5515b9",
        httpClient);
    final signer = Signer(provider: myWalletNotifier.provider);
    await ethClient.sendTransaction(
      signer,
      web3.Transaction.callContract(
        contract: myContract.deployedContract,
        function: myFunction,
        parameters: [productId],
        from: web3.EthereumAddress.fromHex(myWalletNotifier.account),
      ),
    );
  }
}
