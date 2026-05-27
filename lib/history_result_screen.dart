import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ricecare/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

import '../../constants/colors.dart';
import '../../models/historymodel.dart';
import '../../services/history_service.dart';
import '../../services/token_service.dart';
import 'components/info_box.dart';

class HistoryResultScreen extends StatelessWidget {
  final HistoryModel history;

  const HistoryResultScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final isVietnamese = context.locale.languageCode == "vi";

    final title = history.titleVi;

    final hasReason = (history.reasonVi?.trim().isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: Stack(
        children: [
          /// IMAGE
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.network(
              history.imageUrl,
              fit: BoxFit.cover,

              errorBuilder: (_, __, ___) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50),
                  ),
                );
              },
            ),
          ),

          /// CLOSE
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),

              child: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),

          /// CONTENT
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 1,

            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.grey[100],

                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),

                child: SingleChildScrollView(
                  controller: scrollController,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HANDLE
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 10),

                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      /// HEADER
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,

                            backgroundColor: hasReason
                                ? Colors.red.shade100
                                : const Color(0xFFE8F5E9),

                            child: Icon(
                              hasReason ? Icons.close : Icons.check,
                              size: 14,
                              color: hasReason ? Colors.red : Colors.green,
                            ),
                          ),

                          const SizedBox(width: 6),

                          Text(
                            hasReason
                                ? "unable_to_identify".tr()
                                : "analysis_result".tr(),

                            style: TextStyle(
                              color: hasReason ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// TITLE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FutureBuilder<String>(
                              future: isVietnamese
                                  ? Future.value(title)
                                  : GoogleTranslator()
                                        .translate(title, to: "en")
                                        .then((value) => value.text),

                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? title,

                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "${"saved_result_on".tr()} "
                              "${history.time.day}/${history.time.month}/${history.time.year}",

                              textAlign: TextAlign.right,

                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// RESULT CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: hasReason
                            ? Column(
                                children: [
                                  Text(
                                    "unable_to_identify".tr(),
                                    textAlign: TextAlign.center,

                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  FutureBuilder<String>(
                                    future: isVietnamese
                                        ? Future.value(history.reasonVi ?? "")
                                        : GoogleTranslator()
                                              .translate(
                                                history.reasonVi ?? "",
                                                to: "en",
                                              )
                                              .then((value) => value.text),

                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data ?? history.reasonVi ?? "",

                                        textAlign: TextAlign.center,

                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey[700],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: InfoBox(
                                      title: "confidence".tr(),

                                      value:
                                          "${(history.confidence).toStringAsFixed(1)}%",

                                      color: Colors.green,
                                      icon: Icons.verified_rounded,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 20),

                      /// BUTTONS
                      Row(
                        children: [
                          /// DELETE
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final userId = await TokenService.getUserId();

                                if (userId == null) return;

                                await HistoryService().deleteHistory(
                                  userId,
                                  history.id,
                                );

                                if (context.mounted) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("deleted_success".tr()),
                                    ),
                                  );
                                }
                              },

                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,

                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),

                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),

                              child: Text(
                                "delete".tr(),

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          /// SHARE
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.btnbgrColor,
                                foregroundColor: Colors.white,

                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),

                              // onPressed: () async {
                              //   final prefs =
                              //       await SharedPreferences.getInstance();

                              //   final enabled =
                              //       prefs.getBool('notification_enabled') ??
                              //       false;

                              //   if (!enabled) {
                              //     print("Notification đang bị tắt");
                              //     return;
                              //   }

                              //   const AndroidNotificationDetails
                              //   androidDetails = AndroidNotificationDetails(
                              //     'channel_id',
                              //     'Reminder',
                              //     importance: Importance.max,
                              //     priority: Priority.high,
                              //   );

                              //   const NotificationDetails details =
                              //       NotificationDetails(
                              //         android: androidDetails,
                              //       );

                              //   await flutterLocalNotificationsPlugin.show(
                              //     id: 0,
                              //     title: 'Xin chào 👋',
                              //     body:
                              //         'Đây là Local Notification đầu tiên của bạn!',
                              //     notificationDetails: details,
                              //   );
                              // },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.share_outlined, size: 20),

                                  const SizedBox(width: 8),

                                  Text(
                                    "share_result".tr(),

                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
