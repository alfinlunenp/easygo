import 'dart:io';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/views/bottombar/home_bottombar.dart';
import 'package:easygonww/views/profile.dart';
import 'package:flutter/material.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/widgets/button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileScreen extends StatefulWidget {
  final String userid;
  final String name;
  final String email;
  final String mobile;
  final String dob;
  final String imageurl;

  EditProfileScreen({
    super.key,
    required this.userid,
    required this.name,
    required this.email,
    required this.mobile,
    required this.dob,
    required this.imageurl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Text controllers
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // State variables
  dynamic _profileimg;
  bool _buttonLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Image picker function
  Future<void> _pickProfile(ImageSource source) async {
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      await Permission.photos.request();
      await Permission.storage.request();
    }

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileimg = File(pickedFile.path);
      });
    }
  }

  String formatDobForApi(String dob) {
    final parts = dob.split('-');
    if (parts.length != 3) return dob;

    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];

    // API format: YYYY-MM-DD
    return "$year-$month-$day";
  }

  void _showdialogueprofile() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        iconColor: primaryColor,
        title: const Text("Select Image"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickProfile(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickProfile(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Update profile function
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _buttonLoading = true);

    try {
      print("dob :4444444444444444444 ${formatDobForApi(_dobController.text)}");
      bool success = await PostFunctions().updateUser(
        context,
        _profileimg,
        _emailController.text,
        _nameController.text,
        _mobileController.text,
        formatDobForApi(_dobController.text),
        () => setState(() => _buttonLoading = true),
        () => setState(() => _buttonLoading = false),
      );

      if (success) {
        // Show success message
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('),
        //     backgroundColor: Colors.green,
        //   ),
        // );

        Fluttertoast.showToast(
          msg: 'Profile updated successfully',
          textColor: secondprimaryColor,
          // backgroundColor: Colors.white,
        );

        // Navigate back or refresh data
        Navigations.push(HomebottomBar(navindex: 2), context);
      }
    } catch (e) {
      setState(() => _buttonLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    assignValues();
  }

  void assignValues() {
    print("dob :::::::: ${widget.dob}");
    _idController.text = widget.userid;
    _nameController.text = widget.name;
    _emailController.text = widget.email;
    _mobileController.text = widget.mobile;
    _dobController.text = widget.dob;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text('Edit Profile', style: mediumblack),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: dividercolor, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _profileimg != null
                          ? Image.file(
                              _profileimg as File,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            )
                          : widget.imageurl.isNotEmpty
                          ? Image.network(
                              widget.imageurl,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 50,
                                  color: primaryColor,
                                );
                              },
                            )
                          : Icon(Icons.person, size: 50, color: primaryColor),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: GestureDetector(
                      onTap: _showdialogueprofile,
                      child: Container(
                        height: 35,
                        width: 35,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Full Name
              TextFormField(
                controller: _nameController,
                style: normalblack,
                decoration: InputDecoration(
                  labelText: "Full name",
                  labelStyle: hintgrey,
                  hintText: "Enter your name",
                  hintStyle: hintgrey,

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderradius),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderradius),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderradius),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  } else if (RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Numbers not allowed in name';
                  }
                  return null;
                },
              ),
              SizedBox(height: heightgapnormal),

              // Email
              TextFormField(
                style: normalblack,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Enter your email",
                  hintStyle: hintgrey,
                  labelStyle: hintgrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderradius),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderradius),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderradius),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: heightgapnormal),

              // Mobile with Country Code
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(borderradius),
                    ),
                    child: Text('+91', style: normalblack),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      style: normalblack,
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Mobile Number",
                        hintText: "Enter your mobile number",
                        hintStyle: hintgrey,
                        labelStyle: hintgrey,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderradius),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderradius),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderradius),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mobile number is required';
                        } else if (value.length != 10) {
                          return 'Enter a valid 10-digit mobile number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: heightgapnormal),

              // Date of Birth
              TextFormField(
                controller: _dobController,
                style: normalblack,
                decoration: InputDecoration(
                  labelText: "Date of Birth",
                  hintText: "DD/MM/YYYY",
                  hintStyle: hintgrey,
                  labelStyle: hintgrey,
                  suffixIcon: Icon(Icons.calendar_today),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderradius),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderradius),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderradius),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    print(pickedDate);
                    String formattedDate =
                        "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                    setState(() {
                      print('formattedDate $formattedDate');
                      _dobController.text = formattedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 30),

              // Update Button
              GlobalButton(
                ontap: () => _updateProfile(),
                text: "Update",
                // isLoading: _buttonLoading,
                // onPressed: _updateProfile,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
