import 'dart:io';

import 'package:flutter/material.dart';
import 'package:easygonww/controllers_/controllers.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/widgets/button.dart';
import 'package:easygonww/widgets/profilefield.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:image_picker/image_picker.dart';

class Contactsupport extends StatefulWidget {
  String name;
  String email;
  String phno;
  Contactsupport({
    super.key,
    required this.name,
    required this.email,
    required this.phno,
  }); // ✅ Made const

  @override
  State<Contactsupport> createState() => _ContactsupportState();
}

class _ContactsupportState extends State<Contactsupport> {
  TextEditingController _nameController = TextEditingController(); // ✅ final
  TextEditingController _emailController = TextEditingController(); // ✅ final
  TextEditingController _contactcontroller = TextEditingController(); // ✅ final
  TextEditingController _messagecontroller = TextEditingController(); // ✅ final

  String selectedIssue = 'Booking Issue';
  bool isSubmitted = false; // ✅ track success state
  File? _selectedImage; // ✅ holds picked image

  UserController _userController = UserController();

  // Future<void> _sendSupportRequest() async {
  //   print("here we go");

  //   PostFunctions().supportRequest(
  //     _nameController.text,
  //     _emailController.text,
  //     _messagecontroller.text,
  //     _contactcontroller.text,
  //     selectedIssue,
  //     _selectedImage!,
  //     onSuccess: () {
  //       setState(() {
  //         isSubmitted = true;
  //       });
  //     },
  //   );
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdata();
    _nameController.text = widget.name;
    _contactcontroller.text = widget.phno;
    _emailController.text = widget.email;
  }

  String admincontact = "";
  String adminemail = "";
  String adminlocation = "";
  String admintiming = "";
  bool _buttonLoading = false; // only for button

  Future<void> fetchdata() async {
    await _userController.fetchUser("admin");

    if (_userController.userList.isNotEmpty) {
      final user = _userController.userList.first;

      setState(() {
        admincontact = user.uMobile.toString();
        adminemail = user.uEmail.toString();
        adminlocation = user.uAddress.toString();
        admintiming = user.uState.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              Navigations.pop(context);
            },
            child: Container(
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            ),
          ),
        ),
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text("Contact Support", style: mediumblack)],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Easy Go Support: ", style: mediumblack),
                    Text(
                      'We are Here to Help!',
                      style: largelack.copyWith(color: secondprimaryColor),
                    ),
                    Text(
                      'Reach out to our dedicated team 24/7 for any ride, billing, or technical assistance.',
                      style: normalgrey,
                    ),
                  ],
                ),
              ),
              _buildContactInfo(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text("Contact Form", style: poppinscaps),
                    ),
                    SizedBox(height: 10),
                    Profilefield(
                      editsts: false,
                      controller: _nameController,
                      category: "Name",
                      content: widget.name,
                    ),

                    Profilefield(
                      editsts: false,
                      controller: _emailController,
                      category: 'Email',
                      content: widget.email,
                    ),

                    Profilefield(
                      editsts: false,
                      controller: _contactcontroller,
                      category: 'Mobile Number',
                      content: widget.phno,
                    ),
                    _buildIssueDropdown(),
                    _buildMessageField(),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                child: GestureDetector(
                  onTap: _showImageSourceBottomSheet,
                  child: Card(
                    color: Colors.white,
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  borderradius,
                                ),
                                color: _selectedImage != null
                                    ? Colors.green[50]
                                    : Colors.green.withOpacity(0.3),
                              ),
                              child: _selectedImage != null
                                  ? Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: const Icon(
                                        Icons.check_circle_outline_sharp,
                                        color: Colors.green,
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Icon(
                                        Icons.add,
                                        color: const Color(0xFF878787),
                                      ),
                                    ),
                            ),

                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _selectedImage != null
                                    ? "Image Selected"
                                    : "Add Attachments (Optional)",
                                style: _selectedImage != null
                                    ? normalblack
                                    : normalblack,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // _selectedImage == null ? GestureDetector(
              //   onTap: (){
              //     _pickImage();
              //   },
              //   child: _buildAttachmentField()) : Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     border: Border.all(color: bordercolorgrey),
              //     borderRadius: BorderRadius.circular(borderradius),
              //   ),
              //   child: TextFormField(
              //     readOnly: true,
              //     style: normalgrey,
              //     decoration: InputDecoration(
              //       filled: true,
              //       enabled: true,
              //       fillColor: primaryColor.withValues(alpha: 0.012), // ✅ updated
              //       contentPadding:
              //           const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              //       border: InputBorder.none,
              //       hintText: "Image Already Uploaded",
              //       suffixIcon: Icon(Icons.image, color: secondaryColor),
              //       hintStyle: normalgrey,
              //     ),
              //   ),
              // ),
              SizedBox(height: 250),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isSubmitted
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    backgroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigations.pop(context);
                  },
                  child: Text(
                    'Your message has been sent. Our team will get back to you shortly.',
                    textAlign: TextAlign.center,
                    style: colortext,
                  ),
                ),
              )
            : _buttonLoading
            ? SizedBox(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 3,
                  ),
                ),
              )
            : GlobalButton(
                text: 'Submit',
                ontap: () {
                  PostFunctions().supportRequest(
                    _nameController.text,
                    _emailController.text,
                    _messagecontroller.text,
                    _contactcontroller.text,
                    selectedIssue,
                    _selectedImage ?? File(""),
                    () => setState(() => _buttonLoading = true),
                    () => setState(() => _buttonLoading = false),
                    onSuccess: () {
                      setState(() {
                        isSubmitted = true;
                      });
                    },
                  );
                },
                context: context,
                textcolor: Colors.white,
                backgroundcolor: primaryColor,
              ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: padding),
      child: Container(
        decoration: BoxDecoration(
          color: dividercolor,
          borderRadius: BorderRadius.circular(borderradius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            children: [
              _contactItem(Icons.phone, '$admincontact', 'Call Us Anytime'),
              _contactItem(Icons.mail, '$adminemail', 'Email Support'),
              _contactItem(
                Icons.my_location_rounded,
                '$adminlocation',
                'Easy Go Headquarters:',
              ),
              _contactItem(
                Icons.access_time_sharp,
                '24/7 Available',
                'Support Hours:',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactItem(IconData icon, String text, String label) {
    print(text);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [Text("• $label", style: normalblack)]),

            Text(text, style: normalblack),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueDropdown() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: bordercolorgrey),
              borderRadius: BorderRadius.circular(borderradius),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedIssue,
                dropdownColor: Colors.white,
                items:
                    [
                          'Booking Issue',
                          'Payment Problem',
                          'Bike Condition',
                          'Help',
                          'Other',
                        ]
                        .map(
                          (issue) => DropdownMenuItem(
                            value: issue,
                            child: Text(issue, style: normalgrey),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedIssue = value!;
                  });
                },
              ),
            ),
          ),
          Positioned(
            top: -10,
            left: 12,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text("Issue Type", style: smalltextblk),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageField() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Describe Your issue here:", style: normalblack),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: dividercolor,
              border: Border.all(color: bordercolorgrey),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextFormField(
              controller: _messagecontroller,
              maxLines: 4,
              style: normalgrey,
              decoration: InputDecoration(
                filled: true,
                enabled: true,
                fillColor: primaryColor.withValues(alpha: 0.012), // ✅ updated
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 16,
                ),
                border: InputBorder.none,
                hintText: "Type Here...",
                hintStyle: normalgrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentField() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              print("object");
              // _pickImage();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: bordercolorgrey),
                borderRadius: BorderRadius.circular(borderradius),
              ),
              child: TextFormField(
                readOnly: true,
                style: normalgrey,
                decoration: InputDecoration(
                  filled: true,
                  enabled: true,
                  fillColor: primaryColor.withValues(alpha: 0.012), // ✅ updated
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                  hintText: "(e.g., damaged bike photo)",
                  suffixIcon: Icon(Icons.image, color: secondaryColor),
                  hintStyle: normalgrey,
                ),
              ),
            ),
          ),
          Positioned(
            top: -10,
            left: 12,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text("Attachments(Optional)", style: smalltextblk),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _showImageSourceBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: primaryColor),
                title: Text("Take Photo", style: normalgrey),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: primaryColor),
                title: Text("Choose from Gallery", style: normalgrey),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.red),
                title: Text(
                  "Cancel",
                  style: normalgrey.copyWith(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
