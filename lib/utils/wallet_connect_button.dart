import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import '../screen/home_screen.dart';
import '../screen/new_account.dart';
import '../models/my_account_obj.dart';

class WalletConnectButton extends StatefulWidget {
  const WalletConnectButton({Key? key}) : super(key: key);
  @override
  State<WalletConnectButton> createState() => _WalletConnectButtonState();
}

class _WalletConnectButtonState extends State<WalletConnectButton> {
  late WalletConnect connector;
  late SessionStatus session;
  late EthereumWalletConnectProvider provider;
  late String account;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return ElevatedButton(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Image.asset(
          "assets/wallet_connect.png",
          height: h / 20,
        ),
      ),
      onPressed: _connectWallet,
    );
  }

  _connectWallet() async {
    final connector = WalletConnect(
        bridge: 'https://bridge.walletconnect.org',
        clientMeta: const PeerMeta(
          name: 'Decent Bidding',
          description: 'WalletConnect Developer App',
          url: 'https://walletconnect.org',
          icons: [
            'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
          ],
        ));
    if (!connector.connected) {
      session = await connector.createSession(
          chainId: 4,
          onDisplayUri: (uri) async => await launchUrl(Uri.parse(uri)));
    }
    account = session.accounts[0];
    if (account != "") {
      provider = EthereumWalletConnectProvider(connector);
      Provider.of<MyWalletNotifier>(context, listen: false)
          .setProvider(provider, account);
      final docUser =
          FirebaseFirestore.instance.collection('users').doc(account);

      // Checks for existing user in firestore
      final doc = await docUser.get();
      if (doc.exists) {
        String name = doc['name'];
        String city = doc['city'];
        String profilePicUrl = doc['profile_pic'];
        Timestamp joiningDate = doc['join_date'];
        Provider.of<MyWalletNotifier>(context, listen: false)
            .setAccountDetails(name, city, profilePicUrl, joiningDate.toDate());
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const NewAccount()));
      }
    }
  }
}
