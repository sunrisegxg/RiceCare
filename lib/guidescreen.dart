import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:translator/translator.dart';

import 'constants/colors.dart';
import 'guide_result_screen.dart';
import 'models/guidemodel.dart';
import 'other_result_screen.dart';
import 'services/guide_service.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final TextEditingController searchController = TextEditingController();

  List<GuideModel> filteredGuides = [];
  List<GuideModel> guides = [];
  bool isLoading = true;

  int selectedIndex = 0;

  late PageController _pageController;
  late ScrollController _tabScrollController;

  final List<String> riceImages = [
    "assets/images/rice1.jpg",
    "assets/images/rice2.jpg",
    "assets/images/rice3.jpg",
    "assets/images/rice4.jpg",
    "assets/images/rice5.jpg",
  ];

  final List<String> tabs = [
    'tab_all',
    'tab_diseases',
    'tab_farming',
    'tab_fertilizer',
    'tab_tips',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabScrollController = ScrollController();
    loadGuides();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  Future<void> loadGuides() async {
    try {
      final data = await GuideService.fetchGuides();

      if (!mounted) return;

      setState(() {
        guides = data;
        filteredGuides = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR LOAD GUIDES: $e");
      if (!mounted) return;

      setState(() => isLoading = false);
    }
  }

  void searchGuide(String keyword) {
    setState(() {
      if (keyword.trim().isEmpty) {
        filteredGuides = guides;
      } else {
        filteredGuides = guides.where((guide) {
          return guide.title.toLowerCase().contains(keyword.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// 🔍 Search
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: searchGuide,
                        decoration: InputDecoration(
                          hintText: 'search'.tr(),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// 🔹 Tabs
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xffEDEFF3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    controller: _tabScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedIndex = index);

                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tabs[index].tr(),
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: isLoading
                    ? ListView.builder(
                        itemCount: 5, // số shimmer items
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundlistTileColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 14,
                                          width: double.infinity,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 12,
                                          width: double.infinity,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 12,
                                          width: 150,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => selectedIndex = index);
                        },
                        itemCount: tabs.length,
                        itemBuilder: (context, pageIndex) {
                          List<GuideModel> pageGuides = [];

                          /// TAB ALL
                          if (pageIndex == 0) {
                            pageGuides = filteredGuides;
                          }
                          /// TAB DISEASES
                          else if (pageIndex == 1) {
                            pageGuides = filteredGuides.where((guide) {
                              return guide.type == "Bệnh hại lúa";
                            }).toList();
                          }
                          /// TAB FARMING
                          else if (pageIndex == 2) {
                            pageGuides = filteredGuides.where((guide) {
                              return guide.type == "Kỹ thuật trồng lúa";
                            }).toList();
                          }
                          /// TAB FERTILIZER
                          else if (pageIndex == 3) {
                            pageGuides = filteredGuides.where((guide) {
                              return guide.type == "Chất dinh dưỡng ";
                            }).toList();
                          }
                          /// TAB TIPS
                          else {
                            pageGuides = filteredGuides.where((guide) {
                              return guide.type == "Mẹo";
                            }).toList();
                          }

                          if (pageGuides.isEmpty) {
                            return Center(
                              child: Text(
                                "no_guides_found".tr(),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(top: 4),
                            itemCount: pageGuides.length,
                            itemBuilder: (context, index) {
                              final item = pageGuides[index];

                              return buildGuideItem(item, index);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGuideItem(GuideModel item, int index) {
    return FutureBuilder<GuideModel>(
      future: _translateIfNeeded(item),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundlistTileColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(height: 12, width: 150, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final translatedItem = snapshot.data ?? item;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    translatedItem.type == "Kỹ thuật trồng lúa" ||
                        translatedItem.type == "Chất dinh dưỡng "
                    ? OtherResultScreen(
                        guide: translatedItem,
                        imagePath: riceImages[index % riceImages.length],
                      )
                    : GuideResultScreen(
                        guide: translatedItem,
                        imagePath: riceImages[index % riceImages.length],
                      ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.backgroundlistTileColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      translatedItem.type == "Kỹ thuật trồng lúa" ||
                          translatedItem.type == "Chất dinh dưỡng "
                      ? Image.network(
                          translatedItem.url!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              riceImages[index % riceImages.length],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          riceImages[index % riceImages.length],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translatedItem.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        translatedItem.type == "Kỹ thuật trồng lúa" ||
                                translatedItem.type == "Chất dinh dưỡng "
                            ? (translatedItem.content ?? "")
                            : (translatedItem.definition ?? ""),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<GuideModel> _translateIfNeeded(GuideModel item) async {
    if (context.locale.languageCode == 'en') {
      final translator = GoogleTranslator();

      final titleTrans = await translator.translate(
        item.title,
        from: 'auto',
        to: 'en',
      );

      final defTrans = await translator.translate(
        item.definition ?? "",
        from: 'auto',
        to: 'en',
      );
      final contentTrans = await translator.translate(
        item.content ?? "",
        from: 'auto',
        to: 'en',
      );

      final symptomTrans = await translator.translate(
        item.symptoms ?? "",
        from: 'auto',
        to: 'en',
      );

      final measurementTrans = await translator.translate(
        item.measurement ?? "",
        from: 'auto',
        to: 'en',
      );

      final causeTrans = await translator.translate(
        item.cause ?? "",
        from: 'auto',
        to: 'en',
      );

      final spreadRiskTrans = await translator.translate(
        item.spreadRisk ?? "",
        from: 'auto',
        to: 'en',
      );

      final humidityTrans = await translator.translate(
        item.humidity ?? "",
        from: 'auto',
        to: 'en',
      );

      final severityTrans = await translator.translate(
        item.severity ?? "",
        from: 'auto',
        to: 'en',
      );

      return GuideModel(
        idFE: item.idFE,
        title: titleTrans.text,
        definition: defTrans.text,
        symptoms: symptomTrans.text,
        measurement: measurementTrans.text,
        cause: causeTrans.text,
        spreadRisk: spreadRiskTrans.text,
        humidity: humidityTrans.text,
        severity: severityTrans.text,
        content: contentTrans.text,
        url: item.url,
      );
    }

    return item;
  }
}
