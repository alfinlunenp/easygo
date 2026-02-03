import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easygonww/controllers_/controllers.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/model/models.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/bottombar/home_bottombar.dart';
import 'package:easygonww/views/cancellationpolicy.dart';
import 'package:easygonww/views/insructions.dart';
import 'package:easygonww/views/pickundrop.dart';
import 'package:easygonww/views/terms&conditions.dart';
import 'package:easygonww/widgets/button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ConfirmBooking extends StatefulWidget {
  final String pickuploation;
  final String pickuptime;
  final String pickupdate;
  final String dropoffdate;
  final String dropoffloation;
  final String dropofftime;
  final double gstamount;
  final double rentdeposite;
  final double totalpayableamount;
  final String rentID;
  final String rentDurationText;
  final int rentDuration;
  final double locationCharge;
  final double rentamount;

  const ConfirmBooking({
    super.key,
    required this.pickupdate,
    required this.pickuploation,
    required this.pickuptime,
    required this.dropoffdate,
    required this.dropoffloation,
    required this.dropofftime,
    required this.gstamount,
    required this.rentdeposite,
    required this.totalpayableamount,
    required this.rentID,
    required this.rentDurationText,
    required this.rentDuration,
    required this.locationCharge,
    required this.rentamount,
  });

  @override
  State<ConfirmBooking> createState() => _ConfirmBookingState();
}

class _ConfirmBookingState extends State<ConfirmBooking> {
  final UserController _userController = UserController();

  File? _selfieImage;
  dynamic totalamount;
  bool isconformChecked = false;
  bool isconditionsChecked = false;
  String? userId;
  bool _isLoading = true;
  bool _buttonLoading = false;

  // Computed properties for cleaner code
  bool get _allImagesUploaded {
    return _selfieImage != null;
  }

  bool get _canProceedToPayment {
    return _allImagesUploaded && isconformChecked && isconditionsChecked;
  }

  // Get total amount including location charge
  double get totalAmountWithLocationCharge {
    return widget.totalpayableamount;
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      await _userController.fetchUser("user");
      if (_userController.userList.isNotEmpty) {
        final user = _userController.userList.first;
        setState(() {
          userId = user.uId?.toString();
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error loading user data");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String formatTime(String datetimeString) {
    return formatStringTimeToDisplay(datetimeString);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        await Permission.camera.request();
      } else {
        await [Permission.photos, Permission.storage].request();
      }

      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selfieImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error picking image");
    }
  }

  void _showPickerDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          iconColor: primaryColor,
          title: Text("Upload Selfie"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleConfirmdetails() {
    if (!isconformChecked) {
      Fluttertoast.showToast(
        msg: "Please confirm that your details are correct",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (!isconditionsChecked) {
      Fluttertoast.showToast(
        msg: "Please accept Terms & Conditions and Cancellation Policy",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (_selfieImage == null) {
      Fluttertoast.showToast(
        msg: "Please upload a selfie",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    Navigations.push(
      CustomerInstructionsPage(
        dropoffdate: widget.dropoffdate,
        dropoffloation: widget.dropoffloation,
        dropofftime: widget.dropofftime,
        pickupdate: widget.pickupdate,
        pickuploation: widget.pickuploation,
        pickuptime: widget.pickuptime,
        rentamount: widget.rentamount,
        gstamount: widget.gstamount,
        rentdeposite: widget.rentdeposite,
        totalpayableamount: totalAmountWithLocationCharge,
        rentID: widget.rentID,
        rentDurationText: widget.rentDurationText,
        rentDuration: widget.rentDuration,
        locationCharge: widget.locationCharge,
        selfieImage: _selfieImage!,
        totalamount: totalAmountWithLocationCharge,
      ),
      context,
    );
  }

  Widget _buildDocumentUploadItem({
    required String title,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isUploaded ? null : onTap,
      child: Card(
        color: Colors.white,
        child: Container(
          height: 70,
          width: 160,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderradius),
                    color: isUploaded ? Colors.green[50] : dividercolor,
                  ),
                  child: isUploaded
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            Icons.check_circle_outline_sharp,
                            color: Colors.green,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(Icons.add, color: Color(0xFF878787)),
                        ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    title,
                    style: isUploaded ? normalblack : normalgrey,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBikeDetailsCard() {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: secondprimaryColor.withOpacity(0.2),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(borderradius),
                      border: Border.all(
                        color: containerColor ?? Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderradius),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          "assets/home/bikeimg.png",
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network("$Noimage", fit: BoxFit.cover);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Easy Go Scooter', style: mediumblack),
                        Text(
                          "${formatDateTimeToDisplay(DateTime.parse(widget.pickupdate))} | ${formatTime(widget.pickuptime)}",
                          style: smalltextblk,
                        ),
                        Text(" - ", style: smalltextblk),
                        Text(
                          "${formatDateTimeToDisplay(DateTime.parse(widget.dropoffdate))} | ${formatTime(widget.dropofftime)}",
                          style: smalltextblk,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(Icons.location_on, color: primaryColor),
                      Dash(
                        direction: Axis.vertical,
                        length: 20,
                        dashLength: 2,
                        dashColor: primaryColor,
                      ),
                      Icon(Icons.location_on, color: primaryColor),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: "Pickup: ", style: smalltextblk),
                              TextSpan(
                                text: widget.pickuploation,
                                style: smalltextgrey,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 30),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: "Dropoff: ", style: smalltextblk),
                              TextSpan(
                                text: widget.dropoffloation,
                                style: smalltextgrey,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigations.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(borderradius),
                      border: Border.all(color: bordercolorgrey),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10,
                    ),
                    child: Text(
                      'Edit Location, Date & Time',
                      style: normalgrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFareBreakdown() {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Container(
        decoration: BoxDecoration(
          color: dividercolor,
          borderRadius: BorderRadius.circular(borderradius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rental Item', style: mediumblack),
                  Text('Amount', style: mediumblack),
                ],
              ),
              const SizedBox(height: 10),
              _buildFareItem('Easy Go Scooter :', '₹ ${widget.rentamount}'),
              const SizedBox(height: 10),
              _buildFareItem('Security Amount :', '₹ ${widget.rentdeposite}'),
              const SizedBox(height: 10),
              _buildFareItem('GST(5%) :', '₹ ${widget.gstamount}'),
              if (widget.locationCharge > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _buildFareItem(
                    'Different location fee :',
                    '₹ ${widget.locationCharge}',
                  ),
                ),
              const SizedBox(height: 10),
              // _buildFareItem('Total Amount :', '₹ $totalAmountWithLocationCharge'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: mediumblack),
                  Text('₹ $totalAmountWithLocationCharge', style: mediumblack),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFareItem(String label, String value) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: normalgrey,
              overflow: TextOverflow.visible,
            ),
          ),
          Text(value, style: normalblack),
        ],
      ),
    );
  }

  Widget _buildCheckboxes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCheckbox(
            value: isconformChecked,
            onChanged: (value) => setState(() => isconformChecked = value!),
            text: "I confirm the details entered are correct",
          ),
          const SizedBox(height: 8),
          _buildTermsCheckbox(),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          activeColor: primaryColor,
          side: BorderSide(color: secondaryColor, width: 2),
          value: value,
          onChanged: onChanged,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Text(text, style: normalgrey, softWrap: true),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          activeColor: primaryColor,
          side: BorderSide(color: secondaryColor, width: 2),
          value: isconditionsChecked,
          onChanged: (value) => setState(() => isconditionsChecked = value!),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: "I accept the "),
                  TextSpan(
                    text: "Terms & Conditions",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: secondprimaryColor,
                      decorationColor: secondprimaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          Navigations.push(Termsconditions(), context),
                  ),
                  const TextSpan(text: " & "),
                  TextSpan(
                    text: "Cancellation Policy",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: secondprimaryColor,
                      decorationColor: secondprimaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          Navigations.push(Cancellationpolicy(), context),
                  ),
                ],
                style: normalgrey,
              ),
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: padding),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Upload Selfie', style: mediumblack),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(padding),
          child: Row(
            children: [
              _buildDocumentUploadItem(
                title: "Selfie",
                isUploaded: _selfieImage != null,
                onTap: _showPickerDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () => Navigations.pop(context),
            child: Container(
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            ),
          ),
        ),
        centerTitle: false,
        title: Text("Confirm Your Ride & Payment", style: mediumblack),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        _buildBikeDetailsCard(),
                        _buildDocumentUploadSection(),
                        Padding(
                          padding: const EdgeInsets.all(padding),
                          child: Text(
                            "A refundable security deposit of ₹${widget.rentdeposite.toInt()} is collected at the time of booking and will be returned to the customer upon safe return of the bike. However, in the event of any damages such as scratches, dents, or missing parts, loss of helmet, or fines imposed by traffic or police authorities during the rental period, the applicable charges will be deducted from the security deposit. If the deductions exceed the deposit amount, the customer will be responsible for paying the additional charges.",
                            textAlign: TextAlign.justify,
                            style: smalltextgrey,
                          ),
                        ),
                        _buildCheckboxes(),
                        const Divider(color: dividercolor),
                        _buildFareBreakdown(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlobalButton(
          text: 'Confirm & Pay',
          ontap: _buttonLoading ? null : _handleConfirmdetails,
          context: context,
          backgroundcolor: _canProceedToPayment ? primaryColor : Colors.grey,
        ),
      ),
    );
  }
}
