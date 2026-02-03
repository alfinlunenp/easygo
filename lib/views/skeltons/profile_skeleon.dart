import 'dart:io';
import 'package:easygonww/controllers_/controllers.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/changepassword.dart';
import 'package:easygonww/views/contactsupport.dart';
import 'package:easygonww/views/login.dart';
import 'package:easygonww/widgets/othersettings.dart';
import 'package:easygonww/widgets/profilefield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileSkeleton extends StatefulWidget {
  const ProfileSkeleton({super.key});

  @override
  State<ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends State<ProfileSkeleton> {
  bool iseditable = false;
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController(
    text: "",
  );
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String _selectedliscencePdf = "";
  String _selectedAadhaarPdf = "";
  File? _profileimage;
  File? _aadaar;
  File? _liscenceimage;

  String userId = "";
  String userPassword = "";
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchUserData();
  }

  Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("user_id") ?? "";
      _nameController.text = prefs.getString("user_name") ?? "";
      _emailController.text = prefs.getString("user_email") ?? "";
      userPassword = prefs.getString("user_password") ?? "";
    });
  }

  Future<void> fetchUserData() async {
    await _userController.fetchUser("user");
    if (_userController.userList.isNotEmpty) {
      final user = _userController.userList.first;
      setState(() {
        _nameController.text = user.uName ?? _nameController.text;
        _emailController.text = user.uEmail ?? _emailController.text;
        _mobileController.text =
            user.uMobile?.toString() ?? _mobileController.text;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      String fileName = result.files.single.name;

      setState(() {
        _selectedliscencePdf = fileName;
        _liscenceimage = File(path);
      });
    } else {
      print('No file selected');
    }
  }

  Future<void> pickAadhaarFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      String fileName = result.files.single.name;

      setState(() {
        _selectedAadhaarPdf = fileName;
        _aadaar = File(path);
      });
    } else {
      print('No file selected');
    }
  }

  void _showPickerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        iconColor: primaryColor,
        title: const Text("Select Document"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text("Driving License"),
              onTap: () {
                Navigator.of(ctx).pop();
                pickPdfFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text("Aadhaar Card"),
              onTap: () {
                Navigator.of(ctx).pop();
                pickAadhaarFile();
              },
            ),
          ],
        ),
      ),
    );
  }

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
      setState(() => _profileimage = File(pickedFile.path));
    }
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

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color.fromARGB(255, 34, 129, 140),
                            width: 5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _profileimage != null
                              ? Image.file(_profileimage!, fit: BoxFit.cover)
                              : Icon(
                                  Icons.person,
                                  size: 50,
                                  color: primaryColor,
                                ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: GestureDetector(
                          onTap: _showdialogueprofile,
                          child: Container(
                            height: 30,
                            width: 30,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${_nameController.text.isNotEmpty ? _nameController.text : "User"}',
                          softWrap: true,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lets keep your details updated for a smoother booking experience',
                          style: normalgrey,
                          softWrap: true,
                        ),
                        SizedBox(height: 5),
                        Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(
                                  borderradius,
                                ),
                                border: Border.all(color: primaryColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _emailController.text.isNotEmpty
                                      ? _emailController.text
                                      : "Email not set",
                                  style: colortextmall,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(
                                  borderradius,
                                ),
                                border: Border.all(color: primaryColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _mobileController.text.isNotEmpty
                                      ? _mobileController.text
                                      : "Mobile not set",
                                  style: colortextmall,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPersonalDetailsSection(),
                      SizedBox(height: 16),
                      _buildIdDocumentsSection(),
                      SizedBox(height: 16),
                      _buildOtherSettingsSection(),
                      SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            _logoutbottomsheet(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(borderradius),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50.0,
                                vertical: 10,
                              ),
                              child: Text("Logout", style: poppinscapswhite),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsSection() {
    return _profileContainer(
      title: 'Personal Details',
      editable: true,
      children: [
        iseditable
            ? _editableField("Name", _nameController)
            : Profilefield(
                editsts: true,
                category: "Name",
                content: _nameController.text.isNotEmpty
                    ? _nameController.text
                    : "Not set",
              ),
        iseditable
            ? _editableField(
                "Mobile Number",
                _mobileController,
                keyboardType: TextInputType.phone,
              )
            : Profilefield(
                editsts: true,
                category: "Mobile Number",
                content: _mobileController.text.isNotEmpty
                    ? _mobileController.text
                    : "Not set",
              ),
        iseditable
            ? _editableField(
                "Email Address",
                _emailController,
                keyboardType: TextInputType.emailAddress,
              )
            : Profilefield(
                editsts: true,
                category: "Email Address",
                content: _emailController.text.isNotEmpty
                    ? _emailController.text
                    : "Not set",
              ),
        iseditable
            ? _editableField(
                "Date of Birth",
                _dobController,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    _dobController.text = DateFormat(
                      'dd MMMM y',
                    ).format(pickedDate);
                    setState(() {});
                  }
                },
                readOnly: true,
              )
            : Profilefield(
                editsts: true,
                category: "DOB",
                content: _dobController.text.isNotEmpty
                    ? _dobController.text
                    : "Not set",
              ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIdDocumentsSection() {
    return _profileContainer(
      title: 'ID Documents',
      subtitle: 'Upload necessary verification documents for renting',
      onEdit: _showPickerDialog,
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: bordercolorgrey),
              borderRadius: BorderRadius.circular(borderradius),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16,
              ),
              child: Row(
                // alignment: WrapAlignment.spaceBetween,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: WrapCrossAlignment.center,
                // runSpacing: 8.0,
                // spacing: 10.0,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        (_liscenceimage == null) && _selectedliscencePdf.isEmpty
                            ? Icon(
                                Icons.insert_drive_file_rounded,
                                color: Color(0xFFB12A27),
                              )
                            : _selectedliscencePdf.isNotEmpty
                            ? Icon(Icons.picture_as_pdf, color: primaryColor)
                            : Icon(Icons.image, color: primaryColor),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            _selectedliscencePdf.isEmpty
                                ? (_userController.userList.isNotEmpty)
                                      ? "License Uploaded"
                                      : "Upload Your License"
                                : _selectedliscencePdf,
                            style: normalgrey,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(borderradius),
                      color: Colors.green.shade100,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.star, color: Colors.green, size: 20),
                        SizedBox(width: 5),
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: Color.fromARGB(255, 53, 147, 56),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: bordercolorgrey),
              borderRadius: BorderRadius.circular(borderradius),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16,
              ),
              child: Row(
                // alignment: WrapAlignment.spaceBetween,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: WrapCrossAlignment.center,
                // runSpacing: 8.0,
                // spacing: 10.0,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        (_aadaar == null) && _selectedAadhaarPdf.isEmpty
                            ? Icon(Icons.credit_card, color: Color(0xFFB12A27))
                            : _selectedAadhaarPdf.isNotEmpty
                            ? Icon(Icons.picture_as_pdf, color: primaryColor)
                            : Icon(Icons.image, color: primaryColor),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            _selectedAadhaarPdf.isEmpty
                                ? (_userController.userList.isNotEmpty)
                                      ? "Aadhaar Uploaded"
                                      : "Upload Your Aadhaar"
                                : _selectedAadhaarPdf,
                            style: normalgrey,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(borderradius),
                      color: Colors.green.shade100,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.star, color: Colors.green, size: 20),
                        SizedBox(width: 5),
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: Color.fromARGB(255, 53, 147, 56),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherSettingsSection() {
    return _profileContainer(
      title: 'Other Settings',
      children: [
        GestureDetector(
          onTap: () {
            Navigations.push(ChangePassword(), context);
          },
          child: OtherSettings(
            settingname: 'Change Password',
            icon: Icons.lock_outline,
          ),
        ),
        OtherSettings(
          settingname: 'Terms & Conditions',
          icon: Icons.content_paste_outlined,
        ),
        GestureDetector(
          onTap: () {},
          child: OtherSettings(
            settingname: 'Contact Support',
            icon: Icons.support_agent_rounded,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _editableField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    TextInputType? keyboardType,
    void Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: normalgrey,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: normalblack,
          filled: true,
          fillColor: primaryColor.withOpacity(0.012),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: bordercolorgrey),
          ),
        ),
      ),
    );
  }

  Widget _profileContainer({
    required String title,
    String? subtitle,
    VoidCallback? onEdit,
    required List<Widget> children,
    bool editable = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16),
                topLeft: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: poppinscapswhite),
                        if (subtitle != null)
                          Text(subtitle, style: smalltextwhite),
                      ],
                    ),
                  ),
                  title == "Other Settings"
                      ? SizedBox.shrink()
                      : onEdit != null
                      ? GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(3.0),
                            child: Icon(Icons.edit, color: primaryColor),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              iseditable = !iseditable;
                              if (!iseditable) {}
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: iseditable
                                  ? BoxShape.rectangle
                                  : BoxShape.circle,
                              borderRadius: iseditable
                                  ? BorderRadius.circular(borderradius)
                                  : null,
                              color: Colors.white,
                            ),
                            padding: iseditable
                                ? const EdgeInsets.symmetric(
                                    vertical: 2.0,
                                    horizontal: 6,
                                  )
                                : const EdgeInsets.all(3.0),
                            child: iseditable
                                ? Row(
                                    children: [
                                      Text(
                                        'Save',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Icon(Icons.save, color: primaryColor),
                                    ],
                                  )
                                : Icon(Icons.edit, color: primaryColor),
                          ),
                        ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  void _logoutbottomsheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderradius),
              topRight: Radius.circular(borderradius),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Are you sure you want to logout?", style: poppinscaps),
              SizedBox(height: 8),
              Text(
                "You'll need to log in again to access your account.",
                style: normalgrey,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: bordercolorgrey),
                          borderRadius: BorderRadius.circular(borderradius),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text("Cancel", style: normalgrey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: bordercolorgrey),
                          borderRadius: BorderRadius.circular(borderradius),
                          color: Colors.red,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text("Logout", style: normalwhite),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
