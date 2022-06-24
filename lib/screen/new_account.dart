import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../screen/home_screen.dart';
import '../models/my_account_obj.dart';

class NewAccount extends StatefulWidget {
  const NewAccount({Key? key}) : super(key: key);
  @override
  State<NewAccount> createState() => _NewAccountState();
}

class _NewAccountState extends State<NewAccount> {
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  FileImage? _fileImage;
  late String account;
  late String imageUrl;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    account = Provider.of<MyWalletNotifier>(context).account;
    return Scaffold(
      backgroundColor: Colors.yellow.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Center(
            child: SizedBox(
              width: h / 1.5,
              child: Padding(
                padding: EdgeInsets.all(h / 30),
                // Column
                child: Column(
                  children: [
                    Stack(children: [
                      // Profile Image
                      CircleAvatar(
                          radius: h / 10,
                          backgroundColor: Colors.yellow,
                          foregroundImage: _fileImage),
                      // Image Picker Button
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: ElevatedButton(
                          onPressed: () => _pickImage(),
                          child: const Icon(Icons.add),
                          style: ElevatedButton.styleFrom(
                              shape: const CircleBorder()),
                        ),
                      )
                    ]),
                    SizedBox(
                      height: h / 40,
                    ),
                    // Wallet Address
                    Consumer<MyWalletNotifier>(
                      builder: (context, myWalletNotifier, _) {
                        return Text(
                          myWalletNotifier.account,
                        );
                      },
                    ),
                    const Text(
                      "Public Wallet Address",
                      textScaleFactor: 0.75,
                    ),
                    SizedBox(
                      height: h / 17,
                    ),

                    // Input -> Name
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: TextField(
                          cursorColor: Colors.yellow.shade800,
                          controller: nameController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.person),
                            border: InputBorder.none,
                            hintText: "Name",
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          "Please enter your real name by which people will recognize you",
                          textScaleFactor: 0.75,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: h / 20,
                    ),

                    // Input -> City
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: TextField(
                          cursorColor: Colors.yellow.shade800,
                          controller: cityController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.pin_drop),
                            border: InputBorder.none,
                            hintText: "City",
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          "Enter the city where you will facilitate the trades",
                          textScaleFactor: 0.75,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.send_rounded),
          onPressed: () {
            // If details are entered, proceed
            if (nameController.text != "" &&
                cityController.text != "" &&
                _fileImage != null) {
              _uploadProfilePic();
            }
            // Else alert dialog
            else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Incomplete Information"),
                  content: const Text(
                      "Please enter your Full Name, City and add appropriate Profile Image"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"))
                  ],
                ),
              );
            }
          }),
    );
  }

  // Pick image from device
  _pickImage() async {
    ImagePicker _picker = ImagePicker();
    final XFile? im = await _picker.pickImage(
        source: ImageSource.gallery, maxHeight: 400, maxWidth: 400);
    setState(() {
      if (im != null) _fileImage = FileImage(File(im.path));
    });
  }

  // Upload profile picture to Firebase Storage
  _uploadProfilePic() async {
    final path = 'profile-pics/$account';
    final ref = FirebaseStorage.instance.ref().child(path);
    final task = ref.putFile(_fileImage!.file);

    // SnackBar displayed to wait
    const snackBar = SnackBar(content: Text('Uploading... Please wait!'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    task.whenComplete(() async {
      imageUrl = await ref.getDownloadURL();
      // Update provider with new Image
      Provider.of<MyWalletNotifier>(context, listen: false)
          .updateAccountDetails(
              nameController.text, cityController.text, imageUrl);

      // Update user details in FireStore Database
      _addToFirebase();

      // Go to Home
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    });
  }

  _addToFirebase() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(account);
    final json = {
      'name': nameController.text,
      'city': cityController.text,
      'join_date': DateTime.now(),
      'profile_pic': imageUrl
    };
    await docUser.set(json);
  }
}
