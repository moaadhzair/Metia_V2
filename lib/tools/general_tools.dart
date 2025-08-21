import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metia/anilist/anime.dart';
import 'package:metia/data/user/user_library.dart';
import 'package:metia/models/login_provider.dart';
import 'package:metia/models/theme_provider.dart';
import 'package:provider/provider.dart';

class Tools {
  static Future<String> fetchAniListAccessToken(
    String authorizationCode,
  ) async {
    final Uri tokenEndpoint = Uri.https('anilist.co', '/api/v2/oauth/token');
    final Map<String, String> payload = {
      'grant_type': 'authorization_code',
      'client_id': '25588',
      'client_secret': 'QCzgwOKG6kJRzRL91evKRXXGfDCHlmgXfi44A0Ok',
      'redirect_uri': 'metia://',
      'code': authorizationCode,
    };

    try {
      final http.Response response = await http.post(
        tokenEndpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['access_token'] as String;
      } else {
        throw Exception('Failed to retrieve access token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  // static void Toast(BuildContext context, String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Center(
  //         child: Text(
  //           message,
  //           style: const TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: MyColors.appbarTextColor,
  //             fontSize: 16,
  //           ),
  //         ),
  //       ),
  //       duration: const Duration(seconds: 1),
  //       backgroundColor: MyColors.appbarColor,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //     ),
  //   );
  // }

  static getResponsiveCrossAxisVal(double width, {required double itemWidth}) {
    return (width / itemWidth).round();
  }

  static String insertAt(String original, String toInsert, int index) {
    if (index < 0 || index > original.length) {
      throw ArgumentError("Index out of range");
    }
    return original.substring(0, index) + toInsert + original.substring(index);
  }

  static transferToAnotherList(
    MediaListEntry anime,
    BuildContext context,
    bool shouldPopOnceMore,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              child: Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController _listNameController =
                            TextEditingController();
                        return AlertDialog(
                          title: const Text('Create New Custom List'),
                          content: TextField(
                            controller: _listNameController,
                            decoration: const InputDecoration(
                              labelText: 'List Name',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              onPressed: () async {
                                String newListName = _listNameController.text
                                    .trim();
                                if (newListName.isNotEmpty) {
                                  await Provider.of<UserProvider>(
                                    context,
                                    listen: false,
                                  ).createCustomList(newListName);
                                  await Provider.of<UserProvider>(
                                    context,
                                    listen: false,
                                  ).reloadUserData();
                                  Navigator.of(context).pop();
                                  if (shouldPopOnceMore)
                                    Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Icon(Icons.add),
                ),
                body: Stack(
                  children: [
                    AbsorbPointer(
                      absorbing: isLoading, // disables all taps
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Select the List:",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  Map listDetails = Provider.of<UserProvider>(
                                    context,
                                  ).user.userLists[index];

                                  bool isCurrent =
                                      listDetails["name"]
                                          .toString()
                                          .toLowerCase() ==
                                      anime.getGroup()!.name.toLowerCase();

                                  return SizedBox(
                                    height: 50,
                                    child: Opacity(
                                      opacity: isCurrent ? 0.5 : 1,
                                      child: ElevatedButton(
                                        onLongPress: () {
                                          if (listDetails["isCustom"] == true) {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    'Delete Custom List',
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to delete the custom list "${listDetails["name"]}"? This action cannot be undone.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                      onPressed: () async {
                                                        setModalState(
                                                          () =>
                                                              isLoading = true,
                                                        );
                                                        await Provider.of<
                                                              UserProvider
                                                            >(
                                                              context,
                                                              listen: false,
                                                            )
                                                            .deleteCustomList(
                                                              listDetails["name"],
                                                            );
                                                        await Provider.of<
                                                              UserProvider
                                                            >(
                                                              context,
                                                              listen: false,
                                                            )
                                                            .reloadUserData();
                                                        Navigator.of(
                                                          context,
                                                        ).pop(); // close dialog
                                                        setModalState(
                                                          () =>
                                                              isLoading = false,
                                                        );
                                                      },
                                                      child: Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color:
                                                              Provider.of<
                                                                    ThemeProvider
                                                                  >(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  )
                                                                  .isDarkMode
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                        onPressed: isCurrent
                                            ? null
                                            : () async {
                                                setModalState(
                                                  () => isLoading = true,
                                                );

                                                await anime
                                                    .getGroup()!
                                                    .changeEntryStatus(
                                                      context,
                                                      anime,
                                                      listDetails["name"],
                                                      listDetails["isCustom"],
                                                    );

                                                await Provider.of<UserProvider>(
                                                  context,
                                                  listen: false,
                                                ).reloadUserData();

                                                if (context.mounted) {
                                                  Navigator.of(
                                                    context,
                                                  ).pop(); // pop modal
                                                }
                                                if (shouldPopOnceMore)
                                                  Navigator.of(context).pop();
                                              },
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Text(
                                                listDetails["name"],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if (isCurrent)
                                              const Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Icon(Icons.check),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemCount: Provider.of<UserProvider>(
                                  context,
                                ).user.userLists.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // LOADING INDICATOR OVERLAY
                    if (isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
