import 'dart:convert';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'services/cloudinary_service.dart';
import 'services/token_service.dart';
import 'services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? userId;

  bool isLoading = true;
  bool isUploadingImage = false;
  String? userImageUrl;
  Uint8List? selectedImageBytes;

  final UserService _userService = UserService();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final bioController = TextEditingController();
  @override
  void initState() {
    super.initState();

    loadUser();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    try {
      final id = await TokenService.getUserId();

      if (id == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final user = await _userService.getUser(id);

      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      setState(() {
        userId = id;

        nameController.text = user.username;
        emailController.text = user.email;
        phoneController.text = user.phone;
        locationController.text = user.location;
        bioController.text = user.bio;

        userImageUrl = user.imageUrl;

        isLoading = false;
      });
    } catch (e) {
      print("LOAD USER ERROR: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null || userId == null) return;

    setState(() {
      isUploadingImage = true;
    });

    try {
      final bytes = await image.readAsBytes();

      final base64Image = base64Encode(bytes);

      final imageUrl = await CloudinaryService.uploadImage(base64Image);

      await _userService.updateUser(userId!, {'imageUrl': imageUrl});

      setState(() {
        selectedImageBytes = bytes;
        userImageUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile_updated_successfully'.tr())),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload image failed")));
    }

    setState(() {
      isUploadingImage = false;
    });
  }

  Future<void> saveProfile() async {
    if (userId == null) return;

    await _userService.updateUser(userId!, {
      'username': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'location': locationController.text.trim(),
      'bio': bioController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('profile_updated_successfully'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F4),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        'edit_profile'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    /// AVATAR
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: selectedImageBytes != null
                                ? MemoryImage(selectedImageBytes!)
                                : (userImageUrl != null &&
                                      userImageUrl!.isNotEmpty)
                                ? NetworkImage(userImageUrl!)
                                : const AssetImage("assets/images/paddy1.jpg")
                                      as ImageProvider,
                          ),
                        ),

                        GestureDetector(
                          onTap: isUploadingImage ? null : pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: isUploadingImage
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    buildField(
                      title: 'full_name'.tr(),
                      icon: Icons.person_outline,
                      controller: nameController,
                    ),

                    buildField(
                      title: 'email'.tr(),
                      icon: Icons.email_outlined,
                      controller: emailController,
                    ),

                    buildField(
                      title: 'phone_number'.tr(),
                      icon: Icons.phone_outlined,
                      controller: phoneController,
                    ),

                    buildField(
                      title: 'location_label'.tr(),
                      icon: Icons.location_on_outlined,
                      controller: locationController,
                    ),

                    buildField(
                      title: 'bio'.tr(),
                      icon: Icons.edit_note,
                      controller: bioController,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 18),

                    /// SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'save_changes'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.green[900],
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.green),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
