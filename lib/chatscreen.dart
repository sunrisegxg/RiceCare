import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

import 'languagescreen.dart';
import 'models/chatmodel.dart';
import 'services/chat_service.dart';
import 'services/token_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? userId;

  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final ChatService _chatService = ChatService();

  List<Map<String, Object>> messages = [];

  bool isLoading = true;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final id = await TokenService.getUserId();

      if (!mounted || id == null) return;

      final data = await _chatService.getMessagesOnce(id);

      setState(() {
        userId = id;

        messages = data.map((e) {
          return {"text": e.text, "isMe": e.isMe};
        }).toList();

        // nếu chưa có chat
        if (messages.isEmpty) {
          messages.add({"text": 'chat_welcome'.tr(), "isMe": false});
        }

        isLoading = false;
      });

      scrollToBottom();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendMessage([String? value]) async {
    final text = controller.text.trim();

    if (text.isEmpty || userId == null) return;

    // UI add user message
    setState(() {
      messages.add({"text": text, "isMe": true});

      isSending = true;
    });

    controller.clear();

    scrollToBottom();

    // save user message
    await _chatService.sendMessage(
      userId!,
      ChatMessageModel(
        id: 'abc',
        text: text,
        isMe: true,
        createdAt: DateTime.now(),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      messages.add({"text": "abcndđ", "isMe": false});
    });
    await _chatService.sendMessage(
      userId!,
      ChatMessageModel(
        id: 'edf',
        text: "abcndđ",
        isMe: false,
        createdAt: DateTime.now(),
      ),
    );

    // try {
    //   final response = await http.post(
    //     Uri.parse("https://9589-14-233-226-148.ngrok-free.app/chat"),
    //     headers: {"Content-Type": "application/json"},
    //     body: jsonEncode({"question": text}),
    //   );

    //   if (response.statusCode == 200) {
    //     final data = jsonDecode(response.body);

    //     String answer = data["answer"] ?? 'no_response'.tr();

    //     // translate EN
    //     if (context.locale.languageCode == 'en') {
    //       final translator = GoogleTranslator();

    //       final translation = await translator.translate(
    //         answer,
    //         from: 'auto',
    //         to: 'en',
    //       );

    //       answer = translation.text;
    //     }

    //     // UI add bot message
    //     setState(() {
    //       messages.add({"text": answer, "isMe": false});
    //     });

    //     // save bot message
    //     await _chatService.sendMessage(
    //       userId!,
    //       ChatMessageModel(
    //         id: '',
    //         text: answer,
    //         isMe: false,
    //         createdAt: DateTime.now(),
    //       ),
    //     );
    //   } else {
    //     final errorText = '${'ai_server_error'.tr()} (${response.statusCode})';

    //     setState(() {
    //       messages.add({"text": errorText, "isMe": false});
    //     });

    //     await _chatService.sendMessage(
    //       userId!,
    //       ChatMessageModel(
    //         id: '',
    //         text: errorText,
    //         isMe: false,
    //         createdAt: DateTime.now(),
    //       ),
    //     );
    //   }
    // } catch (e) {
    //   final errorText = 'cannot_connect_to_ai'.tr();

    //   setState(() {
    //     messages.add({"text": errorText, "isMe": false});
    //   });

    //   await _chatService.sendMessage(
    //     userId!,
    //     ChatMessageModel(
    //       id: '',
    //       text: errorText,
    //       isMe: false,
    //       createdAt: DateTime.now(),
    //     ),
    //   );
    // }

    setState(() {
      isSending = false;
    });

    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && messages.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Image.asset(
                      "assets/images/chatbot.png",
                      width: 40,
                      height: 40,
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: "Rice",
                              style: TextStyle(color: Colors.green),
                            ),
                            TextSpan(
                              text: "Care",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: " AI",
                              style: TextStyle(color: Color(0xFF4CAF50)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LanguageScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.language, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // CHAT
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: messages.length + (isSending ? 1 : 0),
                itemBuilder: (context, index) {
                  // loading bubble
                  if (index == messages.length) {
                    return chatBubble(isMe: false, text: 'ai_replying'.tr());
                  }

                  final msg = messages[index];

                  return chatBubble(
                    isMe: msg["isMe"] as bool,
                    text: msg["text"] as String,
                  );
                },
              ),
            ),

            // suggestions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'quick_suggestions'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        suggestionChip(
                          'suggestion_rice_blast_treatment',
                          const Color(0xFFEDF8EC),
                        ),

                        const SizedBox(width: 8),

                        suggestionChip(
                          'suggestion_brown_spot',
                          const Color(0xFFF8EFEC),
                        ),

                        const SizedBox(width: 8),

                        suggestionChip(
                          'suggestion_prevent_disease',
                          const Color(0xFFECF6F8),
                        ),

                        const SizedBox(width: 8),

                        suggestionChip(
                          'suggestion_yellow_leaves',
                          const Color(0xFFFEF9EF),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            inputBar(),
          ],
        ),
      ),
    );
  }

  Widget chatBubble({required bool isMe, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Image.asset("assets/images/chatbot.png", width: 36, height: 36),

            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? Colors.green : const Color(0xFFE6EFE7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget suggestionChip(String textKey, Color color) {
    return GestureDetector(
      onTap: () {
        sendMessage(textKey.tr());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(textKey.tr(), style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget inputBar() {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green, width: 1.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.add, color: Colors.black54),

          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => sendMessage(),
              decoration: InputDecoration(
                hintText: 'ask_me_something'.tr(),
                border: InputBorder.none,
              ),
            ),
          ),

          GestureDetector(
            onTap: sendMessage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
