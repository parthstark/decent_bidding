import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'video.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.yellow,
          title: Text("Help", style: TextStyle(color: Colors.grey.shade800))),
      backgroundColor: Colors.yellow.shade100,
      body: Center(
        child: SizedBox(
          width: h / 1.5,
          child: Padding(
            padding: EdgeInsets.all(h / 50),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: h / 100),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(h / 50),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: h / 60),
                            child: Text(
                                "First, Make sure you've installed Metamask and created an account",
                                textAlign: TextAlign.center,
                                textScaleFactor: 1.4,
                                style: TextStyle(color: Colors.grey.shade800)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.yellow.shade100),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 16, 24, 16),
                              child: Image.asset(
                                "assets/metamask.png",
                                height: h / 30,
                              ),
                            ),
                            onPressed: () => launchUrl(
                                Uri.parse(
                                    "https://play.google.com/store/apps/details?id=io.metamask"),
                                mode: LaunchMode.externalApplication),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: h / 100),
                  child: Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.all(h / 100),
                        child: Column(
                          children: [
                            Text("Copy your Public Wallet Address",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade800)),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.yellow.shade100),
                                child: Text("Click here to know how",
                                    textScaleFactor: 0.75,
                                    style:
                                        TextStyle(color: Colors.grey.shade800)),
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          content: const Video(),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("OK",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade800)))
                                          ],
                                        ))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(h / 50),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: h / 60),
                          child: Text(
                              "Next, let's get some ether from Rinkeby Test-Network faucet",
                              textAlign: TextAlign.center,
                              textScaleFactor: 1.4,
                              style: TextStyle(color: Colors.grey.shade800)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.yellow.shade100),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                            child: Image.asset(
                              "assets/eth.png",
                              height: h / 30,
                            ),
                          ),
                          onPressed: () => launchUrl(
                              Uri.parse("https://rinkebyfaucet.com/"),
                              mode: LaunchMode.externalApplication),
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(
                  child: SizedBox(
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: h / 50),
                  child: Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.all(h / 50),
                        child: Column(
                          children: [
                            Text("Great!",
                                textScaleFactor: 1.6,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade800)),
                            Padding(
                              padding: EdgeInsets.only(bottom: h / 60),
                              child: Text(
                                  "You can now transact with fake ether in your account",
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: Colors.grey.shade800)),
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.yellow.shade100),
                                child: Text("Go to Home Page",
                                    textScaleFactor: 0.75,
                                    style:
                                        TextStyle(color: Colors.grey.shade800)),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
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
      ),
    );
  }
}
