import 'package:chat_app/functions/APIS.dart';
import 'package:chat_app/screen/profile_screen.dart';
import 'package:chat_app/widgets/general_widgets/export_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class KebabMenu extends StatelessWidget {
  /* We can change change it to accept the list of Button Text and Button function and then lay the menu accordingly.
  If needed otherwise till then this should work. */
  KebabMenu({super.key, this.isExport = false});

  bool isExport = false;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: const Offset(-15,
          0), // Move the button to left from right. Also set it as the padding set for the icon button below.
      menuChildren: [
        if (!isExport)
          MenuItemButton(
            child: const Text("Profile"),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    currentUser!,
                  ),
                ),
              );
            },
          ),
        if (!isExport)
          MenuItemButton(
            child: const Text("Logout"),
            onPressed: () {
              // Updating the User Status to offline and setting the variables to Initial value.
              APIs.updateUserOnlineStatus(currentUser!.uid, false);
              APIs.updateUserData(
                  {"push_token": "", "is_online": false}, currentUser!.uid);
              APIs.auth.signOut();

              currentUser = null;
              APIs.auth = FirebaseAuth.instance;
            },
          ),
        if (isExport)
          MenuItemButton(
            child: const Text("Export Data"),
            onPressed: () {
              showAdaptiveDialog(
                context: context,
                builder: (context) {
                  return ExportDataDialog(
                    currentUser: currentUser!,
                  );
                },
              ).then((value) {
                print("kebab Menu value : $value");
              });
            },
          ),
      ],
      builder: (context, controller, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 15),
          child: IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
          ),
        );
      },
    );
  }
}
