import 'dart:io';
import 'package:decent_bidding/models/my_contract.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart' as web3;

import '../screen/home_screen.dart';
import '../models/product_obj.dart';
import '../models/my_account_obj.dart';
import '../utils/signer.dart';

class SellNewItem extends StatefulWidget {
  const SellNewItem({Key? key}) : super(key: key);

  @override
  State<SellNewItem> createState() => _SellNewItemState();
}

class _SellNewItemState extends State<SellNewItem> {
  final List<XFile> _images = [];
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.yellow.shade100,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
      ),

      // Floating Action Button
      floatingActionButton: SizedBox(
        height: h * 0.07,
        width: h * 0.14,
        child: FloatingActionButton(
          onPressed: () => _uploadData(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upgrade,
                size: h * 0.04,
              ),
              const Text(
                "Confirm",
              )
            ],
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(h * 0.07)),
        ),
      ),

      // Body
      body: SingleChildScrollView(
        child: SizedBox(
          width: h / 1.5,
          child: Column(
            children: [
              SizedBox(
                height: h / 2.5,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),

                  // List of Picked Images
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length <= 6 ? _images.length + 1 : 6,
                      itemBuilder: (context, index) {
                        if (index == 6) {
                          return Container(
                            width: 10,
                          );
                        } else if (index == _images.length) {
                          // Last Container is used to pick images from device
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: InkWell(
                              onTap: () => _pickImages(),
                              child: Container(
                                width: h / 3,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 20, 0, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Tap to Add\nProduct Images",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 24),
                                      ),
                                      const SizedBox(height: 20),
                                      Icon(
                                        Icons.add_a_photo,
                                        size: h / 8,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          // Image Container
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image(
                                    image: FileImage(File(_images[index].path)),
                                    fit: BoxFit.cover,
                                    height: h / 2.5,
                                    width: h / 3,
                                  ),
                                ),
                              ),
                              // Cross Button
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(h)),
                                  child: IconButton(
                                    onPressed: () => _removeImg(index),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                      }),
                ),
              ),

              // Input Details
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: titleController,
                  style: TextStyle(fontSize: 24, color: Colors.grey.shade700),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.title_rounded),
                    border: InputBorder.none,
                    hintText: "Product Title",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: priceController,
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.payments),
                    suffixText: "ethereum",
                    border: InputBorder.none,
                    hintText: "Price",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: descController,
                  style: TextStyle(color: Colors.grey.shade700),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.description_outlined),
                    border: InputBorder.none,
                    hintText: "Description",
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final imgList = await _picker.pickMultiImage(maxHeight: 500, maxWidth: 500);
    int n = imgList!.length;
    int rem = 6 - _images.length;
    int i = 0;
    setState(() {
      while (i < n && rem > 0) {
        _images.add(imgList[i]);
        i++;
        rem--;
      }
    });
  }

  _removeImg(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  _uploadData() async {
    // Check if any of the field is not empty
    if (titleController.text.isEmpty ||
        priceController.text.isEmpty ||
        descController.text.isEmpty ||
        _images.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Incomplete Information"),
          content: const Text("Please fill all the details"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"))
          ],
        ),
      );
      return;
    }

    // Check if price is of correct type
    double? price = double.tryParse(priceController.text);
    if (price == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Incorrect price value"),
          content: const Text("Price must be a decimal point number"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"))
          ],
        ),
      );
      return;
    }

    final myWalletNotifier =
        Provider.of<MyWalletNotifier>(context, listen: false);
    List<String> imageUrls = [];

    // Firebase Document initialized
    final docUser = FirebaseFirestore.instance.collection('products').doc();

    // SnackBar to go to metamask
    SnackBar snackBar = const SnackBar(
        content: Text('Go to Metamask and confirm the transaction'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print(docUser.id);
    // Web3 Plugin
    final myContract = MyContract();
    final httpClient = Client();
    final ethClient = web3.Web3Client(
        "https://rinkeby.infura.io/v3/618a8e47885c4205898892390a5515b9",
        httpClient);
    final myFunction = myContract.deployedContract.function('sell_new_item');
    final signer = Signer(provider: myWalletNotifier.provider);
    await ethClient.sendTransaction(
      signer,
      web3.Transaction.callContract(
        value: web3.EtherAmount.inWei(BigInt.from(price * 1e18)),
        contract: myContract.deployedContract,
        function: myFunction,
        parameters: [docUser.id, BigInt.from(price * 1e18)],
        from: web3.EthereumAddress.fromHex(myWalletNotifier.account),
      ),
    );

    // Uploading SnackBar
    snackBar = const SnackBar(content: Text('Uploading... Please wait!'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    Product newProduct = Product(
      productId: docUser.id,
      isRunning: true,
      title: titleController.text,
      price: priceController.text,
      description: descController.text,
      location: myWalletNotifier.city,
      datePosted: DateTime.now(),
      currBidder: myWalletNotifier.account,
      sellerName: myWalletNotifier.name,
      sellerId: myWalletNotifier.account,
      sellerDate: myWalletNotifier.joiningDate,
      sellerImage: myWalletNotifier.profilePicUrl,
      images: imageUrls,
    );
    docUser.set(newProduct.toJson());

    for (int i = 0; i < _images.length; i++) {
      final path = 'products/${docUser.id}/$i';
      final ref = FirebaseStorage.instance.ref().child(path);
      final task = ref.putFile(File(_images[i].path));

      task.whenComplete(() async {
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
        docUser.update({'images': imageUrls});
        // After last image is uploaded
        if (i == _images.length - 1) {
          // Done Snackbar
          snackBar = const SnackBar(content: Text('Done'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          // Go to Home
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      });
    }
  }
}
