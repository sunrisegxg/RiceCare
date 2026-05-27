import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ricecare/constants/colors.dart';
import 'package:ricecare/profileuiscreen.dart';
import 'package:ricecare/scanscreen.dart';
import 'package:ricecare/services/location_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

import 'models/notemodel.dart';
import 'other_result_screen.dart';
import 'services/notification_service.dart';
import 'services/planner_service.dart';
import 'services/token_service.dart';
import 'services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onTabSelected;

  const HomeScreen({super.key, this.onTabSelected});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? weather;
  bool loadingWeather = true;
  String? userId;
  final noteService = PlannerService();
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  StreamSubscription? _noteSub;

  final CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<PlannerNote>> notes = {};
  @override
  void initState() {
    super.initState();
    loadUser();
    loadWeather();
  }

  Future<void> loadWeather() async {
    final pos = await LocationService().getPosition();

    if (pos == null) return;

    final data = await WeatherService().getWeather(pos.latitude, pos.longitude);

    if (!mounted) return;

    setState(() {
      weather = data;
      loadingWeather = false;
    });
  }

  DateTime normalize(DateTime day) {
    return DateTime.utc(day.year, day.month, day.day);
  }

  void loadUser() async {
    final id = await TokenService.getUserId();

    userId = id;
    if (!mounted || userId == null) return;

    await _noteSub?.cancel();

    _noteSub = noteService.getNotes(userId!).listen((list) {
      if (!mounted) return;

      final Map<DateTime, List<PlannerNote>> loaded = {};

      for (final note in list) {
        final key = normalize(note.date);
        loaded.putIfAbsent(key, () => []);
        loaded[key]!.add(note);
      }

      setState(() {
        notes = loaded;
      });
    });
  }

  @override
  void dispose() {
    _noteSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Rice",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "Care",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "good_morning".tr(),
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProfileScreenUI()),
                      );
                    },
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const CircleAvatar(
                            radius: 22,
                            backgroundImage: AssetImage(
                              "assets/images/paddy1.jpg",
                            ),
                          );
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;

                        final imageUrl = data['imageUrl'];

                        return CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage:
                              imageUrl != null && imageUrl.toString().isNotEmpty
                              ? NetworkImage(imageUrl)
                              : const AssetImage("assets/images/paddy1.jpg")
                                    as ImageProvider,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 🔹 Weather
              sectionTitle("today_weather".tr()),
              const SizedBox(height: 12),
              weatherCard(),

              const SizedBox(height: 22),

              // 🔹 Quick Actions
              sectionTitle("quick_actions".tr()),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  actionCard(
                    "ask_ai".tr(),
                    Icons.smart_toy,
                    Colors.blue,
                    onTap: () {
                      widget.onTabSelected?.call(1);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const OtherResultScreen(
                      //       title: "Nhu cầu dinh dưỡng của cây lúa",

                      //       description:
                      //           "Cây lúa cần được cung cấp đầy đủ các chất dinh dưỡng như đạm, lân và kali để phát triển tốt trong từng giai đoạn sinh trưởng. "
                      //           "Việc bón phân hợp lý giúp tăng năng suất, cải thiện chất lượng hạt và hạn chế sâu bệnh. "
                      //           "Ngoài ra, nông dân cần chú ý đến điều kiện đất, nước và thời tiết để điều chỉnh lượng phân bón phù hợp. "
                      //           "Trong giai đoạn đẻ nhánh, cây lúa cần nhiều đạm để phát triển thân lá. "
                      //           "Ở giai đoạn làm đòng và trổ bông, kali và lân đóng vai trò quan trọng giúp cây cứng cáp và tăng khả năng chống chịu.",

                      //       image: "assets/images/rice1.jpg",
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                  actionCard(
                    "history".tr(),
                    Icons.history,
                    Colors.orange,
                    onTap: () {
                      widget.onTabSelected?.call(3);
                    },
                  ),
                  actionCard(
                    "guide".tr(),
                    Icons.menu_book,
                    Colors.purple,
                    onTap: () {
                      widget.onTabSelected?.call(2);
                    },
                  ),
                  actionCard(
                    "scan_ai".tr(),
                    Icons.document_scanner,
                    Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScanScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // 🔹 Planner
              sectionTitle("my_planner".tr()),
              const SizedBox(height: 12),

              calendarPlanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget calendarPlanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TableCalendar(
            availableGestures: AvailableGestures.horizontalSwipe,
            calendarFormat: _calendarFormat,
            pageAnimationEnabled: true,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),

            eventLoader: (day) {
              return notes[normalize(day)] ?? [];
            },

            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = selected; // quan trọng: dùng selected
              });
            },
            onDayLongPressed: (selected, focused) async {
              setState(() {
                selectedDay = selected;
                focusedDay = selected; // nhảy đúng tháng của ngày bấm
              });

              await showAddNoteSheet(selected);
            },

            onPageChanged: (newFocusedDay) {
              focusedDay = newFocusedDay;
            },

            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),

            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),

            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final dayNotes = notes[normalize(day)] ?? [];

                final hasReminder = dayNotes.any(
                  (item) => item.reminder != null,
                );

                if (hasReminder) {
                  return const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(Icons.star, size: 12, color: Colors.amber),
                  );
                }

                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }

                return null;
              },
            ),
          ),

          const SizedBox(height: 14),

          ...getNotesForDay(selectedDay).map(
            (note) => Dismissible(
              key: ValueKey(note.id),
              direction: DismissDirection.horizontal,
              background: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'edit'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              secondaryBackground: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'delete'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.delete, color: Colors.white),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  await showAddNoteSheet(selectedDay, note: note);
                  return false;
                }

                if (direction == DismissDirection.endToStart) {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: Colors.white,
                        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        contentPadding: const EdgeInsets.fromLTRB(
                          24,
                          12,
                          24,
                          0,
                        ),
                        actionsPadding: const EdgeInsets.fromLTRB(
                          16,
                          24,
                          16,
                          16,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Container(
                            //   padding: const EdgeInsets.all(10),
                            //   decoration: BoxDecoration(
                            //     color: Colors.red.withOpacity(0.12),
                            //     shape: BoxShape.circle,
                            //   ),
                            //   child: const Icon(
                            //     Icons.delete_outline,
                            //     color: Colors.red,
                            //     size: 24,
                            //   ),
                            // ),
                            // const SizedBox(width: 12),
                            Text(
                              'delete_note'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'delete_note_confirm'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                        actions: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey[800],
                                    backgroundColor: Colors.grey.shade100,
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    'cancel'.tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    'delete'.tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldDelete == true && userId != null) {
                    await noteService.deleteNote(userId!, note.id);
                    await NotificationService.cancel(note.id.hashCode);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('note_deleted'.tr()),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      ),
                    );
                    return true;
                  }

                  return false;
                }

                return false;
              },
              child: noteItem(note),
            ),
          ),
        ],
      ),
    );
  }

  List<PlannerNote> getNotesForDay(DateTime day) {
    return notes[normalize(day)] ?? [];
  }

  Widget noteItem(PlannerNote note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            note.reminder != null ? Icons.star : Icons.event_note,
            color: note.reminder != null ? Colors.amber : Colors.green,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                if (note.description != null &&
                    note.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    note.description!,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],

                if (note.reminder != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.alarm, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        note.reminder!.format(context),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showAddNoteSheet(DateTime day, {PlannerNote? note}) async {
    final titleController = TextEditingController(text: note?.title ?? '');
    final descController = TextEditingController(text: note?.description ?? '');
    TimeOfDay? reminder = note?.reminder;
    final noteDate = note?.date ?? day;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                18,
                14,
                18,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Handle
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          "add_planner_note".tr(),
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// Date Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF5F7F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${noteDate.day}/${noteDate.month}/${noteDate.year}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// Title
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: "title_required".tr(),
                      prefixIcon: const Icon(Icons.title),
                      filled: true,
                      fillColor: const Color(0xffF8FAF8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Description
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "description_optional".tr(),
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 52),
                        child: Icon(Icons.notes),
                      ),
                      filled: true,
                      fillColor: const Color(0xffF8FAF8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Reminder
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (picked != null) {
                        setSheetState(() {
                          reminder = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffF8FAF8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.alarm, color: Colors.orange),
                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              reminder == null
                                  ? "set_reminder".tr()
                                  : reminder!.format(context),
                              style: TextStyle(
                                color: reminder == null
                                    ? Colors.black54
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          if (reminder != null)
                            InkWell(
                              onTap: () {
                                setSheetState(() {
                                  reminder = null;
                                });
                              },
                              child: const Icon(Icons.close, size: 18),
                            )
                          else
                            const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.btnbgrColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;
                        if (userId == null) return;

                        final eventDateTime = DateTime(
                          noteDate.year,
                          noteDate.month,
                          noteDate.day,
                          reminder?.hour ?? 0,
                          reminder?.minute ?? 0,
                        );

                        final updatedNote = PlannerNote(
                          id: note?.id ?? '',
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          date: noteDate,
                          reminder: reminder,
                        );

                        if (note == null) {
                          // 👉 ADD NOTE
                          final newId = DateTime.now().millisecondsSinceEpoch
                              .toString();

                          final noteToSave = PlannerNote(
                            id: newId,
                            title: updatedNote.title,
                            description: updatedNote.description,
                            date: updatedNote.date,
                            reminder: updatedNote.reminder,
                          );

                          await noteService.addNote(userId!, noteToSave);

                          // 🔔 NOTIFY ĐÚNG GIỜ
                          await NotificationService.scheduleNotification(
                            id: newId.hashCode,
                            title: noteToSave.title,
                            body: noteToSave.description ?? '',
                            notifyTime: eventDateTime,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('note_saved'.tr())),
                          );
                        } else {
                          // 👉 UPDATE NOTE
                          await noteService.updateNote(userId!, updatedNote);

                          await NotificationService.cancel(note.id.hashCode);

                          await NotificationService.scheduleNotification(
                            id: note.id.hashCode,
                            title: updatedNote.title,
                            body: updatedNote.description ?? '',
                            notifyTime: eventDateTime, // 👈 ĐÚNG GIỜ LUÔN
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('note_updated'.tr())),
                          );
                        }

                        Navigator.pop(context);
                      },
                      child: Text(
                        note == null ? "save_note".tr() : "update_note".tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🔹 Section Title
  Widget sectionTitle(
    String title, {
    bool showAction = false,
    String actionText = "View all",
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (showAction)
          Text(
            actionText,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
      ],
    );
  }

  Widget weatherCard() {
    final now = DateTime.now();
    final formattedTime = DateFormat('dd/MM/yyyy').format(now);
    if (loadingWeather) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(height: 20, width: 120, color: Colors.white),
              const SizedBox(height: 20),
              Container(height: 80, width: 80, color: Colors.white),
              const SizedBox(height: 20),
              Container(height: 30, width: 100, color: Colors.white),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(width: 40, height: 40, color: Colors.white),
                  Container(width: 40, height: 40, color: Colors.white),
                  Container(width: 40, height: 40, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (weather == null) {
      return const Text("Không lấy được thời tiết");
    }

    final temp = weather!['main']['temp'];
    final humidity = weather!['main']['humidity'];
    final wind = weather!['wind']['speed'];
    final conditionKey = weather!['weather'][0]['main']
        .toString()
        .toLowerCase();
    final icon = weather!['weather'][0]['icon'];
    final rain = weather?['rain_mm'] ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          /// 🔹 TOP 50 / 50 (GIỮ UI CŨ)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: Center(
                    child: Image.network(
                      "https://openweathermap.org/img/wn/$icon@4x.png",
                      height: 90,
                    ),
                  ),
                ),
              ),

              Container(
                width: 1,
                height: 95,
                color: Colors.white.withOpacity(0.25),
              ),

              Expanded(
                child: SizedBox(
                  height: 120,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "location".tr(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "${temp.round()}°",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "weather.$conditionKey".tr(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// Divider ngang
          Container(height: 1, color: Colors.white.withOpacity(0.25)),

          const SizedBox(height: 14),

          /// 🔹 Bottom Info (GIỮ UI CŨ)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              weatherInfoBlue(
                "assets/images/wind.png",
                "wind".tr(),
                "${wind.toStringAsFixed(1)} m/s",
              ),
              weatherInfoBlue(
                "assets/images/humidity.png",
                "humidity".tr(),
                "$humidity%",
              ),
              weatherInfoBlue(
                "assets/images/rain.png",
                "rain".tr(),
                "$rain mm",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget weatherInfoBlue(String image, String title, String value) {
    return Column(
      children: [
        Image.asset(image, height: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  // 🔹 Quick Action Card
  Widget actionCard(
    String title,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Planner Card
  Widget plannerCard(String title, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_outline, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
