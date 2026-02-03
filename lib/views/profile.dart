import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easygonww/aadummy.dart';
import 'package:easygonww/controllers_/controllers.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/views/profile/editprofile.dart';
import 'package:easygonww/views/skeltons/profile_skeleon.dart';
import 'package:easygonww/views/terms&conditions.dart';
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
import 'package:easygonww/pref/add_pref.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool iseditable = false;
  bool _isLoading = true;
  bool _buttonLoading = false; // only for button
  bool notificationEnabled = false;
  DateTime? dob;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String _selectedliscencePdf = "";
  String _selectedAadhaarPdf = "";
  // File? _profileimage;
  dynamic _profileimg;
  File? _aadaar;
  File? _liscenceimage;

  File? _licenseFront;
  File? _licenseBack;
  File? _aadhaarFront;
  File? _aadhaarBack;

  String userId = "";
  String userPassword = "";
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    loadUserData();
    print("isloading : $_isLoading");

    fetchUserData();
  }

  Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // userId = prefs.getString("user_id") ?? "";
      // _nameController.text = prefs.getString("user_name") ?? "";
      // _emailController.text = prefs.getString("user_email") ?? "";
      // userPassword = prefs.getString("user_password") ?? "";
    });
  }

  Future<void> fetchUserData() async {
    // Set loading state
    setState(() {
      _isLoading = true;
    });

    await _userController.fetchUser('user');

    if (_userController.userList.isNotEmpty) {
      final user = _userController.userList.first;

      setState(() {
        _profileimg = "https://lunarsenterprises.com:7006/${user.uProfilePic}";

        print("profile image : $_profileimg");

        // Update license status based on database
        if (user.uLicenseFront?.isNotEmpty == true &&
            user.uLicenseBack?.isNotEmpty == true) {
          _selectedliscencePdf = "License Uploaded";
        } else {
          _selectedliscencePdf = "";
        }

        // Update Aadhaar status based on database
        if (user.uAdharFront?.isNotEmpty == true &&
            user.uAddarBack?.isNotEmpty == true) {
          _selectedAadhaarPdf = "Aadhaar Uploaded";
        } else {
          _selectedAadhaarPdf = "";
        }

        print('dob :::::::::::: ${user.uDob}');

        _nameController.text = user.uName ?? "";
        _emailController.text = user.uEmail ?? "";
        _mobileController.text = user.uMobile?.toString() ?? "";

        if (user.uDob != null && user.uDob.toString().isNotEmpty) {
          final parsedDob = DateTime.tryParse(user.uDob.toString());
          if (parsedDob != null) {
            _dobController.text = DateFormat('dd MMMM yyyy').format(parsedDob);
          } else {
            _dobController.text = "DOB Not Added";
          }
        } else {
          _dobController.text = "DOB Not Added";
        }

        // ✅ Safe DOB handling
        // if (user.uDob != null && user.uDob.toString().isNotEmpty) {
        //   final parsedDob = DateTime.tryParse(user.uDob.toString());
        //   if (parsedDob != null) {
        //     _dobController.text = DateFormat('dd MMMM yyyy').format(parsedDob);
        //   } else {
        //     _dobController.text = "DOB Not Added";
        //   }
        // } else {
        //   _dobController.text = "DOB Not Added";
        // }

        userId = user.uId?.toString() ?? "";
      });
    }

    // ✅ Only one setState for loading state
    setState(() {
      _isLoading = false;
    });
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
            // License Options
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Capture License (Front & Back)"),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickDoubleImage(isLicense: true, fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Upload License (Gallery - Front & Back)"),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickDoubleImage(isLicense: true, fromCamera: false);
              },
            ),

            const Divider(),

            // Aadhaar Options
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Capture Aadhaar (Front & Back)"),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickDoubleImage(isLicense: false, fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Upload Aadhaar (Gallery - Front & Back)"),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickDoubleImage(isLicense: false, fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDoubleImage({
    required bool isLicense,
    bool fromCamera = true,
  }) async {
    final picker = ImagePicker();

    // Pick Front
    final XFile? frontFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (frontFile == null) return; // user cancelled

    // Pick Back
    final XFile? backFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (backFile == null) return; // user cancelled

    setState(() {
      if (isLicense) {
        _licenseFront = File(frontFile.path);
        _licenseBack = File(backFile.path);
        _selectedliscencePdf = "License Images Selected";
      } else {
        _aadhaarFront = File(frontFile.path);
        _aadhaarBack = File(backFile.path);
        _selectedAadhaarPdf = "Aadhaar Images Selected";
      }
    });

    print("${isLicense ? "License" : "Aadhaar"} front: ${frontFile.path}");
    print("${isLicense ? "License" : "Aadhaar"} back: ${backFile.path}");

    // Upload documents and refresh data
    bool success = await PostFunctions().updateDocuments(
      context,
      userId,
      isLicense ? _licenseFront : null,
      isLicense ? _licenseBack : null,
      !isLicense ? _aadhaarFront : null,
      !isLicense ? _aadhaarBack : null,
      () => setState(() => _buttonLoading = true),
      () => setState(() => _buttonLoading = false),
    );

    // Refresh user data if upload was successful
    if (success) {
      await fetchUserData();

      // Clear the selected files after successful upload
      setState(() {
        if (isLicense) {
          _licenseFront = null;
          _licenseBack = null;
        } else {
          _aadhaarFront = null;
          _aadhaarBack = null;
        }
      });
    }
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
      // bool success = await PostFunctions().updateUser(
      //   context,
      //   File(pickedFile.path),
      //   _emailController.text,
      //   _nameController.text,
      //   _mobileController.text,
      //   _dobController.text,
      //   () => setState(() => _buttonLoading = true),
      //   () => setState(() => _buttonLoading = false),
      // );

      bool success = await PostFunctions().updateUser(
        context,
        File(pickedFile.path),
        _emailController.text,
        _nameController.text,
        _mobileController.text,
        _dobController.text,
        () => setState(() => _buttonLoading = true),
        () => setState(() => _buttonLoading = false),
      );

      if (success) {
        await fetchUserData();
      }
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? ProfileSkeleton()
          : Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Padding(
                padding: const EdgeInsets.all(padding),
                child: GestureDetector(
                  onTap: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus &&
                        currentFocus.focusedChild != null) {
                      currentFocus.unfocus();
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: secondaryColor,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child:
                                  _profileimg != null && _profileimg!.isNotEmpty
                                  ? Image.network(
                                      _profileimg!,
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 50,
                                              color: primaryColor,
                                            );
                                          },
                                    )
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
                      Text(
                        '${_nameController.text.isNotEmpty ? _nameController.text : "User"}',
                        softWrap: true,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 0,
                        runSpacing: 0,
                        children: [
                          Text(
                            _emailController.text.isNotEmpty
                                ? _emailController.text
                                : "Email not set",
                            style: normalblack,
                          ),
                          Text(' | ', style: normalblack),
                          Text(
                            _mobileController.text.isNotEmpty
                                ? _mobileController.text
                                : "Mobile not set",
                            style: normalblack,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFE3E3E3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SettingsItem(
                              icon: Icons.person_outline,
                              title: 'Edit Profile',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      userid: userId,
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      mobile: _mobileController.text,
                                      dob: _dobController.text,
                                      imageurl: _profileimg,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // SettingsItem(
                            //   icon: Icons.description_outlined,
                            //   title: 'ID Documents',
                            //   onTap: () {},
                            // ),
                            SettingsItem(
                              icon: Icons.lock_outline,
                              title: 'Change Password',
                              onTap: () {
                                Navigations.push(ChangePassword(), context);
                              },
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 0,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Notification',
                                      style: normalblack,
                                    ),
                                  ),
                                  Switch(
                                    value: notificationEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        notificationEnabled = value;
                                      });
                                    },
                                    activeColor: Colors.white,
                                    activeTrackColor: Colors.grey,
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.grey,
                                  ),
                                ],
                              ),
                            ),

                            SettingsItem(
                              icon: Icons.description_outlined,
                              title: 'Terms & Conditions',
                              onTap: () {
                                Navigations.push(Termsconditions(), context);
                              },
                            ),

                            SettingsItem(
                              icon: Icons.help_outline,
                              title: 'Contact Support',
                              onTap: () {
                                Navigations.push(
                                  Contactsupport(
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    phno: _mobileController.text,
                                  ),
                                  context,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
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
                    ],
                  ),
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
                  print("dob 1 :::::::  ${_dobController.text}");

                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate:
                        DateTime.now(), // Can't select a future date for DOB
                  );
                  print("dob 2 :::::::  $pickedDate");
                  if (pickedDate != null) {
                    // Calculate age precisely
                    print("dob 3 :::::::  $pickedDate");

                    DateTime today = DateTime.now();
                    int age = today.year - pickedDate.year;

                    // Check if birthday has already occurred this year
                    if (today.month < pickedDate.month ||
                        (today.month == pickedDate.month &&
                            today.day < pickedDate.day)) {
                      age--;
                      print("dob 4 :::::::  $pickedDate");
                    }

                    if (age < 18) {
                      print("dob :::::::  $pickedDate");

                      Fluttertoast.showToast(
                        msg: "You must be at least 18 years old",
                        textColor: Colors.red,
                        backgroundColor: Colors.white,
                      );
                      return; // Don't set the date if user is a minor
                    }

                    _dobController.text = DateFormat(
                      'dd MMMM y',
                    ).format(pickedDate);
                    dob = pickedDate;
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
      subtitle:
          "Please upload both the front and back sides of your License and Aadhaar for verification.",
      onEdit: _showPickerDialog,
      children: [
        // License Section
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Check if license is uploaded (both front and back from database)
                            (_userController.userList.isNotEmpty &&
                                    _userController
                                            .userList
                                            .first
                                            .uLicenseFront
                                            ?.isNotEmpty ==
                                        true &&
                                    _userController
                                            .userList
                                            .first
                                            .uLicenseBack
                                            ?.isNotEmpty ==
                                        true)
                                ? Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 24,
                                  )
                                : (_licenseFront != null &&
                                      _licenseBack != null)
                                ? Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 24,
                                  )
                                : Icon(
                                    Icons.card_membership_rounded,
                                    color: Color(0xFFB12A27),
                                    size: 24,
                                  ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                // Check database first, then selected files, then show default text
                                (_userController.userList.isNotEmpty &&
                                        _userController
                                                .userList
                                                .first
                                                .uLicenseFront
                                                ?.isNotEmpty ==
                                            true &&
                                        _userController
                                                .userList
                                                .first
                                                .uLicenseBack
                                                ?.isNotEmpty ==
                                            true)
                                    ? "License Uploaded"
                                    : (_licenseFront != null &&
                                          _licenseBack != null)
                                    ? "License Images Selected"
                                    : "Upload Your License",
                                style:
                                    (_userController.userList.isNotEmpty &&
                                        _userController
                                                .userList
                                                .first
                                                .uLicenseFront
                                                ?.isNotEmpty ==
                                            true &&
                                        _userController
                                                .userList
                                                .first
                                                .uLicenseBack
                                                ?.isNotEmpty ==
                                            true)
                                    ? normalblack.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      )
                                    : (_licenseFront != null &&
                                          _licenseBack != null)
                                    ? normalblack.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                      )
                                    : normalgrey,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Show license status - check for both database values and newly selected files
                  if ((_userController.userList.isNotEmpty &&
                          _userController
                                  .userList
                                  .first
                                  .uLicenseFront
                                  ?.isNotEmpty ==
                              true &&
                          _userController
                                  .userList
                                  .first
                                  .uLicenseBack
                                  ?.isNotEmpty ==
                              true) ||
                      (_licenseFront != null && _licenseBack != null))
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          // Front status
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color:
                                    (_userController.userList.isNotEmpty &&
                                            _userController
                                                    .userList
                                                    .first
                                                    .uLicenseFront
                                                    ?.isNotEmpty ==
                                                true) ||
                                        _licenseFront != null
                                    ? Colors.green
                                    : Colors.grey,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Front",
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      (_userController.userList.isNotEmpty &&
                                              _userController
                                                      .userList
                                                      .first
                                                      .uLicenseFront
                                                      ?.isNotEmpty ==
                                                  true) ||
                                          _licenseFront != null
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                              SizedBox(width: 12),
                            ],
                          ),
                          // Back status
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color:
                                    (_userController.userList.isNotEmpty &&
                                            _userController
                                                    .userList
                                                    .first
                                                    .uLicenseBack
                                                    ?.isNotEmpty ==
                                                true) ||
                                        _licenseBack != null
                                    ? Colors.green
                                    : Colors.grey,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Back",
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      (_userController.userList.isNotEmpty &&
                                              _userController
                                                      .userList
                                                      .first
                                                      .uLicenseBack
                                                      ?.isNotEmpty ==
                                                  true) ||
                                          _licenseBack != null
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Aadhaar Section
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Check if Aadhaar is uploaded (both front and back from database)
                            (_userController.userList.isNotEmpty &&
                                    _userController
                                            .userList
                                            .first
                                            .uAdharFront
                                            ?.isNotEmpty ==
                                        true &&
                                    _userController
                                            .userList
                                            .first
                                            .uAddarBack
                                            ?.isNotEmpty ==
                                        true)
                                ? Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 24,
                                  )
                                : (_aadhaarFront != null &&
                                      _aadhaarBack != null)
                                ? Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 24,
                                  )
                                : Icon(
                                    Icons.credit_card,
                                    color: Color(0xFFB12A27),
                                    size: 24,
                                  ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                // Check database first, then selected files, then show default text
                                (_userController.userList.isNotEmpty &&
                                        _userController
                                                .userList
                                                .first
                                                .uAdharFront
                                                ?.isNotEmpty ==
                                            true &&
                                        _userController
                                                .userList
                                                .first
                                                .uAddarBack
                                                ?.isNotEmpty ==
                                            true)
                                    ? "Aadhaar Uploaded"
                                    : (_aadhaarFront != null &&
                                          _aadhaarBack != null)
                                    ? "Aadhaar Images Selected"
                                    : "Upload Your Aadhaar",
                                style:
                                    (_userController.userList.isNotEmpty &&
                                        _userController
                                                .userList
                                                .first
                                                .uAdharFront
                                                ?.isNotEmpty ==
                                            true &&
                                        _userController
                                                .userList
                                                .first
                                                .uAddarBack
                                                ?.isNotEmpty ==
                                            true)
                                    ? normalblack.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      )
                                    : (_aadhaarFront != null &&
                                          _aadhaarBack != null)
                                    ? normalblack.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                      )
                                    : normalgrey,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Show Aadhaar status - check for both database values and newly selected files
                  if ((_userController.userList.isNotEmpty &&
                          _userController
                                  .userList
                                  .first
                                  .uAdharFront
                                  ?.isNotEmpty ==
                              true &&
                          _userController
                                  .userList
                                  .first
                                  .uAddarBack
                                  ?.isNotEmpty ==
                              true) ||
                      (_aadhaarFront != null && _aadhaarBack != null))
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          // Front status
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color:
                                    (_userController.userList.isNotEmpty &&
                                            _userController
                                                    .userList
                                                    .first
                                                    .uAdharFront
                                                    ?.isNotEmpty ==
                                                true) ||
                                        _aadhaarFront != null
                                    ? Colors.green
                                    : Colors.grey,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Front",
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      (_userController.userList.isNotEmpty &&
                                              _userController
                                                      .userList
                                                      .first
                                                      .uAdharFront
                                                      ?.isNotEmpty ==
                                                  true) ||
                                          _aadhaarFront != null
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                              SizedBox(width: 12),
                            ],
                          ),
                          // Back status
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color:
                                    (_userController.userList.isNotEmpty &&
                                            _userController
                                                    .userList
                                                    .first
                                                    .uAddarBack
                                                    ?.isNotEmpty ==
                                                true) ||
                                        _aadhaarBack != null
                                    ? Colors.green
                                    : Colors.grey,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Back",
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      (_userController.userList.isNotEmpty &&
                                              _userController
                                                      .userList
                                                      .first
                                                      .uAddarBack
                                                      ?.isNotEmpty ==
                                                  true) ||
                                          _aadhaarBack != null
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
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
        GestureDetector(
          onTap: () {
            Navigations.push(Termsconditions(), context);
          },
          child: OtherSettings(
            settingname: 'Terms & Conditions',
            icon: Icons.content_paste_outlined,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigations.push(
              Contactsupport(
                name: _nameController.text,
                email: _emailController.text,
                phno: _mobileController.text,
              ),
              context,
            );
          },
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
                              if (!iseditable) {
                                // PostFunctions().updateUser(
                                //   context,
                                //   _profileimg ?? File(''),
                                //   _emailController.text,
                                //   _nameController.text,
                                //   // userId,
                                //   _mobileController.text,
                                //   _dobController.text,
                                //   _liscenceimage ?? File(''),
                                //   _aadaar ?? File(''),

                                // );

                                PostFunctions().updateUser(
                                  context,
                                  _profileimg is File ? _profileimg : null,
                                  _emailController.text,
                                  _nameController.text,
                                  _mobileController.text,
                                  _dobController.text,
                                  () => setState(() => _buttonLoading = true),
                                  () => setState(() => _buttonLoading = false),
                                );
                              }
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
                                ? GestureDetector(
                                    onTap: _buttonLoading
                                        ? null
                                        : () {
                                            PostFunctions().updateUserStrings(
                                              context,
                                              _emailController.text,
                                              _nameController.text,
                                              _mobileController.text,
                                              dob.toString(),
                                              () => setState(
                                                () => _buttonLoading = true,
                                              ),
                                              () => setState(
                                                () => _buttonLoading = false,
                                              ),
                                            );
                                          },
                                    child: Row(
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
                                    ),
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
        return SafeArea(
          top: false,
          bottom: true,
          left: false,
          right: false,
          child: Container(
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
                        onTap: () async {
                          clearSharedPreferences();
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
          ),
        );
      },
    );
  }

  Future<void> clearSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove all except email & password
    await prefs.remove("user_id");
    await prefs.remove("user_name");
    await prefs.remove("user_role");
    await prefs.remove("token");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
