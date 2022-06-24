import 'package:decent_bidding/screen/my_bids.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screen/help_screen.dart';
import 'my_products.dart';
import '../screen/login_screeen.dart';

import '../models/my_account_obj.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Drawer(
      backgroundColor: Colors.yellow.shade100,
      child: Column(
        children: [
          Stack(children: [
            Container(
              color: Colors.yellow,
              height: h / 3.5,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(bottom: h / 60),
                // User Details
                child: Consumer<MyWalletNotifier>(
                  builder: (context, myWalletNotifier, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'profile-pic',
                          child: CircleAvatar(
                              radius: h / 15,
                              backgroundColor: Colors.yellow.shade100,
                              foregroundImage:
                                  NetworkImage(myWalletNotifier.profilePicUrl)),
                        ),
                        SizedBox(
                          height: h / 60,
                        ),
                        Text(
                          myWalletNotifier.name,
                          style: TextStyle(color: Colors.grey.shade800),
                          textScaleFactor: 1.25,
                        ),
                        Text(
                          myWalletNotifier.city,
                          style: TextStyle(color: Colors.grey.shade800),
                          textScaleFactor: 0.8,
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
            // Edit Account
            // Positioned(
            //   right: 0,
            //   bottom: 0,
            //   child: Hero(
            //     tag: 'edit',
            //     child: ElevatedButton(
            //       onPressed: () {
            //         Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //                 builder: (context) => const EditAccount()));
            //       },
            //       child: const Icon(Icons.edit),
            //       style: ElevatedButton.styleFrom(shape: const CircleBorder()),
            //     ),
            //   ),
            // )
          ]),
          SizedBox(height: h / 60),

          // Links to other Pages
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(
              'Home',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.amp_stories_rounded),
            title: Text(
              'My Items',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyProducts()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(
              'My Bids',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyBids()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text(
              'Help',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.format_align_justify_rounded),
            title: Text(
              'Application Source Code',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            onTap: () => launchUrl(
                Uri.parse("https://github.com/parthstark/decent_bidding"),
                mode: LaunchMode.externalApplication),
          )
        ],
      ),
    );
  }
}
