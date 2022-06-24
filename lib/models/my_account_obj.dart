import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:flutter/material.dart';

class MyWalletNotifier extends ChangeNotifier {
  late EthereumWalletConnectProvider provider;
  String account = "0x0000000000000000";
  String name = "";
  String city = "";
  String profilePicUrl = "";
  DateTime joiningDate = DateTime(0, 0, 0);

  setProvider(provider, account) {
    this.provider = provider;
    this.account = account;
    notifyListeners();
  }

  setAccountDetails(name, city, profilePicUrl, joiningDate) {
    this.name = name;
    this.city = city;
    this.profilePicUrl = profilePicUrl;
    this.joiningDate = joiningDate;
    notifyListeners();
  }

  updateAccountDetails(name, city, profilePicUrl) {
    this.name = name;
    this.city = city;
    this.profilePicUrl = profilePicUrl;
    notifyListeners();
  }
}
