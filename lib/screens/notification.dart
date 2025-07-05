import 'package:flutter/material.dart';
import 'package:to_do_list_app/theme/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultText,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          title: Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              'Notification',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          centerTitle: true,
          leadingWidth: 55,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: EdgeInsets.only(left: 8, top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primary,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: AppColors.defaultText,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 2),
            child: Divider(height: 2, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
