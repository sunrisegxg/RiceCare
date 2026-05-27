import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'models/guidemodel.dart';

class OtherResultScreen extends StatelessWidget {
  final GuideModel guide;
  final String imagePath;

  const OtherResultScreen({
    super.key,
    required this.guide,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
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
                        guide.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// CONTENT
                      ReadMoreText(
                        guide.content ?? "",
                        trimLines: 5,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: ' Read more',
                        trimExpandedText: ' Show less',
                        style: const TextStyle(fontSize: 14, height: 1.6),
                        moreStyle: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        lessStyle: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
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
