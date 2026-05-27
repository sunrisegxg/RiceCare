import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:readmore/readmore.dart';

import '../../models/guidemodel.dart';
import 'components/info_box.dart';
import 'components/section_title.dart';

class GuideResultScreen extends StatelessWidget {
  final GuideModel guide;
  final String imagePath;

  const GuideResultScreen({
    super.key,
    required this.guide,
    required this.imagePath,
  });

  String cleanValue(String? value) {
    if (value == null) return "";
    return value.split("(").first.trim();
  }

  @override
  Widget build(BuildContext context) {
    final symptomsList = (guide.symptoms ?? "")
        .split("\n")
        .where((e) => e.trim().isNotEmpty)
        .toList();

    final severity = cleanValue(guide.severity);
    final spreadRisk = cleanValue(guide.spreadRisk);
    final humidity = guide.humidity ?? "";

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: Stack(
        children: [
          /// BACKGROUND IMAGE
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),

          /// CLOSE BUTTON
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
                      /// DRAG HANDLE
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

                      /// TITLE
                      Text(
                        guide.title ?? "",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// DESCRIPTION
                      SectionTitle("description".tr()),

                      ReadMoreText(
                        guide.definition ?? "",
                        trimLines: 2,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'read_more'.tr(),
                        trimExpandedText: 'show_less'.tr(),
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),

                      const SizedBox(height: 16),

                      /// SYMPTOMS
                      SectionTitle("symptoms".tr()),

                      Text(
                        symptomsList.join("\n"),
                        style: const TextStyle(height: 1.5),
                      ),

                      const SizedBox(height: 16),

                      /// CAUSE
                      SectionTitle("cause".tr()),

                      Text(
                        guide.cause ?? "",
                        style: const TextStyle(height: 1.5),
                      ),

                      const SizedBox(height: 16),

                      /// RECOMMENDATION
                      SectionTitle("recommendation".tr()),

                      Text(
                        guide.measurement ?? "",
                        style: const TextStyle(height: 1.5),
                      ),

                      const SizedBox(height: 10),

                      const Divider(),

                      const SizedBox(height: 10),

                      /// SEVERITY + SPREAD RISK
                      Row(
                        children: [
                          Expanded(
                            child: InfoBox(
                              title: "severity".tr(),
                              value: severity,
                              color: Colors.orange,
                              icon: Icons.local_fire_department,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: InfoBox(
                              title: "spread_risk".tr(),
                              value: spreadRisk,
                              color: Colors.red,
                              icon: Icons.warning_amber_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// HUMIDITY
                      Row(
                        children: [
                          Expanded(
                            child: InfoBox(
                              title: "humidity".tr(),
                              value: humidity,
                              color: Colors.blue,
                              icon: Icons.water_drop_rounded,
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
