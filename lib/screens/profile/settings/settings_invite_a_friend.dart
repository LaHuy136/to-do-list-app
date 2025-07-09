import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class SettingsInviteAFriend extends StatefulWidget {
  const SettingsInviteAFriend({super.key});

  @override
  State<SettingsInviteAFriend> createState() => _SettingsInviteAFriendState();
}

class _SettingsInviteAFriendState extends State<SettingsInviteAFriend> {
  List<Contact> _contacts = [];
  List<Contact> filteredContacts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
        filteredContacts = contacts;
      });
    }
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query.toLowerCase().trim();
      filteredContacts =
          _contacts.where((c) {
            final name = c.displayName.toLowerCase();
            return name.contains(searchQuery);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: AppColors.primary,
          title: Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              'Invite a Friend',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.defaultText,
              ),
            ),
          ),
          centerTitle: true,
          leadingWidth: 55,
          leading: InkWell(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              margin: EdgeInsets.only(left: 8, top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.defaultText,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(56),
          topRight: Radius.circular(56),
        ),
        child: Container(
          height: double.infinity,
          color: AppColors.defaultText,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),

                // Search bar
                TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search contact name...',
                    hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    filled: true,
                    fillColor: AppColors.disabledTertiary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  ),
                ),

                SizedBox(height: 20),
                Text(
                  'From contact',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 12),

                // Danh sách contact
                Expanded(
                  child:
                      filteredContacts.isEmpty
                          ? Center(
                            child: Text(
                              'No contacts found',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.disabledSecondary,
                              ),
                            ),
                          )
                          : ListView.separated(
                            itemCount: filteredContacts.length,
                            separatorBuilder:
                                (_, __) => Divider(
                                  height: 1,
                                  color: AppColors.disabledSecondary,
                                ),
                            itemBuilder: (context, index) {
                              final contact = filteredContacts[index];
                              final phone =
                                  contact.phones.isNotEmpty
                                      ? contact.phones.first.number
                                      : 'No phone';
                              final initials =
                                  (contact.displayName.isNotEmpty)
                                      ? contact.displayName[0].toUpperCase()
                                      : '?';

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primary,
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          color: AppColors.defaultText,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            contact.displayName,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            phone,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
