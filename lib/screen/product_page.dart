import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart' as web3;

import '../models/my_contract.dart';
import '../models/my_account_obj.dart';
import '../models/product_obj.dart';
import '../utils/signer.dart';
import 'home_screen.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({required this.viewProduct, Key? key}) : super(key: key);
  final Product viewProduct;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final myWalletNotifier = Provider.of<MyWalletNotifier>(context);
    return Scaffold(
      backgroundColor: Colors.yellow.shade100,
      appBar: AppBar(backgroundColor: Colors.yellow),
      // Floating Action Button
      floatingActionButton:
          widget.viewProduct.sellerId != myWalletNotifier.account
              ? SizedBox(
                  child: FloatingActionButton(
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          size: h * 0.04,
                        ),
                        const Text(
                          "  Place a\n Bid",
                          textAlign: TextAlign.right,
                          textScaleFactor: 0.75,
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    onPressed: () => _placeBid(),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(h * 0.07)),
                  ),
                  height: h * 0.07,
                  width: h * 0.14,
                )
              : null,
      // Body
      body: SingleChildScrollView(
        child: SizedBox(
          width: h / 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Horizontal ListView
              SizedBox(
                width: w,
                height: h / 2.5,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.viewProduct.images.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image(
                            image: NetworkImage(widget.viewProduct.images[i]),
                            fit: BoxFit.cover,
                            height: h / 3,
                            width: h / 3,
                          ),
                        ),
                      );
                    }),
              ),
              // Price
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.viewProduct.price,
                      style: TextStyle(color: Colors.grey.shade800),
                      textScaleFactor: 3,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        'assets/eth_ico.png',
                        height: 36,
                      ),
                    ),
                  ],
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 8),
                child: Row(
                  children: [
                    Text(
                      widget.viewProduct.title,
                      textScaleFactor: 1.75,
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),
              // Location and Date of posting
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.viewProduct.location,
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    Text(
                      DateFormat("yMMMMd")
                          .format(widget.viewProduct.datePosted),
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),
              // Current Bidder
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Text('Current Bidder: ${widget.viewProduct.currBidder}'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Text(
                    'Last Bid: ${(double.parse(widget.viewProduct.price) - 0.01).toStringAsFixed(4)}'),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 8),
                child: Row(
                  children: [
                    Text(
                      "Description",
                      textScaleFactor: 1.75,
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),
              // Product Description
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.viewProduct.description,
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Seller Description
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Row(
                  children: [
                    Text(
                      "Seller",
                      textScaleFactor: 1.75,
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 12, 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            foregroundImage:
                                NetworkImage(widget.viewProduct.sellerImage),
                            radius: h / 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.viewProduct.sellerName,
                                  textScaleFactor: 1.25,
                                  style: TextStyle(color: Colors.grey.shade800),
                                ),
                                Text(
                                  'Member Since: ${DateFormat("yMMMMd").format(widget.viewProduct.sellerDate)}',
                                  textScaleFactor: 0.8,
                                  style: TextStyle(color: Colors.grey.shade800),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _placeBid() async {
    final myWalletNotifier =
        Provider.of<MyWalletNotifier>(context, listen: false);

    // SnackBar - Go to metamask
    SnackBar snackBar = const SnackBar(
        content: Text('Go to Metamask and confirm the transaction'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Web3 Plugin
    final myContract = MyContract();
    final httpClient = Client();
    final ethClient = web3.Web3Client(
        "https://rinkeby.infura.io/v3/618a8e47885c4205898892390a5515b9",
        httpClient);
    final myFunction = myContract.deployedContract.function('place_bid');
    final signer = Signer(provider: myWalletNotifier.provider);
    final sender = web3.EthereumAddress.fromHex(myWalletNotifier.account);
    double price = double.parse(widget.viewProduct.price);
    await ethClient.sendTransaction(
      signer,
      web3.Transaction.callContract(
        value: web3.EtherAmount.inWei(BigInt.from(price * 1e18)),
        contract: myContract.deployedContract,
        function: myFunction,
        parameters: [widget.viewProduct.productId, BigInt.from(price * 1e18)],
        from: sender,
      ),
    );

    // Update price inside firestore
    final newPrice = double.parse(widget.viewProduct.price) + 0.01;
    final docUser = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.viewProduct.productId.trim());
    await docUser.update({
      'price': newPrice.toStringAsFixed(4),
      'curr_bidder': myWalletNotifier.account
    });

    // Done Snackbar
    snackBar = const SnackBar(content: Text('Done'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // Go to Home
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
}
