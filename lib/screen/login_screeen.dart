import 'package:decent_bidding/screen/help_screen.dart';
import 'package:flutter/material.dart';
import '../utils/wallet_connect_button.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.yellow.shade100,
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: h / 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Expanded(
                      child: SizedBox(
                    height: 1,
                  )),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HelpScreen()));
                      },
                      icon: const Icon(Icons.help))
                ],
              ),
            ),
            Column(
              children: [
                Image.asset(
                  "assets/transfer_money.png",
                  height: h / 2.5,
                ),
                Text("Decent Bid",
                    textScaleFactor: 4,
                    style: TextStyle(color: Colors.grey.shade800)),
                SizedBox(height: h / 150),
                Text("Decentralized Auction App",
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500)),
                SizedBox(height: h / 5),

                // WALLET - CONNECT
                const WalletConnectButton(),
                SizedBox(height: h / 150),
                Text("Securely login to your crypto wallet with Wallet-Connect",
                    style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
