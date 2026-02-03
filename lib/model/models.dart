class BikeListResponse {
  final bool result;
  final String message;
  final List<BikeModel> list;

  BikeListResponse({
    required this.result,
    required this.message,
    required this.list,
  });

  factory BikeListResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return BikeListResponse(result: false, message: "", list: []);
    }

    return BikeListResponse(
      result: json["result"] == true,
      message: json["message"]?.toString() ?? "",
      list:
          (json["list"] as List?)?.map((x) => BikeModel.fromJson(x)).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "result": result,
    "message": message,
    "list": list.map((e) => e.toJson()).toList(),
  };
}

class BikeModel {
  final int bId;
  final String bName;
  final double bRatings;
  final String bDescription;
  final int bPrice;
  final String bStatus;
  final String bLocation;
  final String bLatitude;
  final String bLongitude;
  final String bExtras;
  final double bMilage;
  final String bGeartype;
  final String bFueltype;
  final double bBhp;
  final dynamic bImage;
  final String bReviews;
  int distance;
  final int maxSpeed;
  final String maintainceStatus;
  final String center;
  final List<BikeImageModel> bikeimages;
  final List<BikeReviewModel> bikereviews;
  final List<BikeCenter> bikeCenters;

  BikeModel({
    required this.bId,
    required this.bName,
    required this.bRatings,
    required this.bDescription,
    required this.bPrice,
    required this.bStatus,
    required this.bLocation,
    required this.bLatitude,
    required this.bLongitude,
    required this.bExtras,
    required this.bMilage,
    required this.bGeartype,
    required this.bFueltype,
    required this.bBhp,
    this.bImage,
    required this.bReviews,
    required this.distance,
    required this.maxSpeed,
    required this.maintainceStatus,
    required this.center,
    required this.bikeimages,
    required this.bikereviews,
    required this.bikeCenters,
  });

  factory BikeModel.fromJson(dynamic json) {
    if (json == null) {
      return BikeModel(
        bId: 0,
        bName: "",
        bRatings: 0,
        bDescription: "",
        bPrice: 0,
        bStatus: "",
        bLocation: "",
        bLatitude: "",
        bLongitude: "",
        bExtras: "",
        bMilage: 0,
        bGeartype: "",
        bFueltype: "",
        bBhp: 0,
        bImage: null,
        bReviews: "",
        distance: 0,
        maxSpeed: 0,
        maintainceStatus: "",
        center: "",
        bikeimages: [],
        bikereviews: [],
        bikeCenters: [],
      );
    }

    return BikeModel(
      bId: _parseInt(json["b_id"]),
      bName: json["b_name"]?.toString() ?? "",
      bRatings: _parseDouble(json["b_ratings"]),
      bDescription: json["b_description"]?.toString() ?? "",
      bPrice: _parseInt(json["b_price"]),
      bStatus: json["b_status"]?.toString() ?? "",
      bLocation: json["b_location"]?.toString() ?? "",
      bLatitude: json["b_latitude"]?.toString() ?? "",
      bLongitude: json["b_longitude"]?.toString() ?? "",
      bExtras: json["b_extras"]?.toString() ?? "",
      bMilage: _parseDouble(json["b_milage"]),
      bGeartype: json["b_geartype"]?.toString() ?? "",
      bFueltype: json["b_fueltype"]?.toString() ?? "",
      bBhp: _parseDouble(json["b_bhp"]),
      bImage: json["b_image"],
      bReviews: json["b_reviews"]?.toString() ?? "",
      distance: _parseInt(json["distance"]),
      maxSpeed: _parseInt(json["max_speed"]),
      maintainceStatus: json["maintaince_status"]?.toString() ?? "",
      center: json["center"]?.toString() ?? "",
      bikeimages:
          (json["bikeimages"] as List?)
              ?.map((x) => BikeImageModel.fromJson(x))
              .toList() ??
          [],
      bikereviews:
          (json["bikereviews"] as List?)
              ?.map((x) => BikeReviewModel.fromJson(x))
              .toList() ??
          [],
      bikeCenters:
          (json["bike_centers"] as List?)
              ?.map((x) => BikeCenter.fromJson(x))
              .toList() ??
          [],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
    "b_id": bId,
    "b_name": bName,
    "b_ratings": bRatings,
    "b_description": bDescription,
    "b_price": bPrice,
    "b_status": bStatus,
    "b_location": bLocation,
    "b_latitude": bLatitude,
    "b_longitude": bLongitude,
    "b_extras": bExtras,
    "b_milage": bMilage,
    "b_geartype": bGeartype,
    "b_fueltype": bFueltype,
    "b_bhp": bBhp,
    "b_image": bImage,
    "b_reviews": bReviews,
    "distance": distance,
    "max_speed": maxSpeed,
    "maintaince_status": maintainceStatus,
    "center": center,
    "bikeimages": bikeimages.map((e) => e.toJson()).toList(),
    "bikereviews": bikereviews.map((e) => e.toJson()).toList(),
    "bike_centers": bikeCenters.map((e) => e.toJson()).toList(),
  };
}

class BikeReviewModel {
  final int brId;
  final int brUsedId;
  final int brBikeId;
  final String brReview;
  final int brRating;
  final String date;
  final String? uName;
  final String? uProfilePic;

  BikeReviewModel({
    required this.brId,
    required this.brUsedId,
    required this.brBikeId,
    required this.brReview,
    required this.brRating,
    required this.date,
    this.uName,
    this.uProfilePic,
  });

  factory BikeReviewModel.fromJson(dynamic json) {
    if (json == null) {
      return BikeReviewModel(
        brId: 0,
        brUsedId: 0,
        brBikeId: 0,
        brReview: "",
        brRating: 0,
        date: "",
      );
    }

    return BikeReviewModel(
      brId: _parseInt(json["br_id"]),
      brUsedId: _parseInt(json["br_used_id"]),
      brBikeId: _parseInt(json["br_bike_id"]),
      brReview: json["br_review"]?.toString() ?? "",
      brRating: _parseInt(json["br_rating"]),
      date: json["date"]?.toString() ?? "",
      uName: json["u_name"]?.toString(),
      uProfilePic: json["u_profile_pic"]?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
    "br_id": brId,
    "br_used_id": brUsedId,
    "br_bike_id": brBikeId,
    "br_review": brReview,
    "br_rating": brRating,
    "date": date,
    "u_name": uName,
    "u_profile_pic": uProfilePic,
  };
}

class BikeImageModel {
  final int imgId;
  final int bikeId;
  final String imagePath;

  BikeImageModel({
    required this.imgId,
    required this.bikeId,
    required this.imagePath,
  });

  factory BikeImageModel.fromJson(dynamic json) {
    if (json == null) {
      return BikeImageModel(imgId: 0, bikeId: 0, imagePath: "");
    }

    return BikeImageModel(
      imgId: _parseInt(json["img_id"]),
      bikeId: _parseInt(json["bike_id"]),
      imagePath: json["image_path"]?.toString() ?? "",
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
    "img_id": imgId,
    "bike_id": bikeId,
    "image_path": imagePath,
  };
}

class BikeCenter {
  final int bcId;
  final int bcBikeId;
  final int bcCenterId;
  final int lId;
  final String lLocation;
  final String lDistrict;

  BikeCenter({
    required this.bcId,
    required this.bcBikeId,
    required this.bcCenterId,
    required this.lId,
    required this.lLocation,
    required this.lDistrict,
  });

  factory BikeCenter.fromJson(dynamic json) {
    if (json == null) {
      return BikeCenter(
        bcId: 0,
        bcBikeId: 0,
        bcCenterId: 0,
        lId: 0,
        lLocation: "",
        lDistrict: "",
      );
    }

    return BikeCenter(
      bcId: _parseInt(json["bc_id"]),
      bcBikeId: _parseInt(json["bc_bike_id"]),
      bcCenterId: _parseInt(json["bc_center_id"]),
      lId: _parseInt(json["l_id"]),
      lLocation: json["l_location"]?.toString() ?? "",
      lDistrict: json["l_district"]?.toString() ?? "",
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
    "bc_id": bcId,
    "bc_bike_id": bcBikeId,
    "bc_center_id": bcCenterId,
    "l_id": lId,
    "l_location": lLocation,
    "l_district": lDistrict,
  };
}

class BookingModel {
    int bId;
    int bUId;
    dynamic bBkId;
    int bPriceId;
    double bRentAmount;
    int bFineAmount;
    double bTotalAmount;
    String bPickupLocation;
    DateTime bPickupDate;
    DateTime bPicupTime;
    String bDropLocation;
    DateTime bDropDate;
    DateTime bDropTime;
    dynamic bRole;
    dynamic bType;
    dynamic bMessage;
    DateTime bookingDate;
    dynamic invoice;
    String bSelfie;
    dynamic bAdharfront;
    dynamic bAdharback;
    dynamic bLicensefront;
    dynamic bLicenseback;
    dynamic viewReason;
    dynamic bBikeName;
    dynamic extendReason;
    String bPaymentStatus;
    String bStatus;
    int uId;
    String uName;
    String uEmail;
    int uMobile;
    String uAddress;
    String uState;
    String uDistrict;
    int uPincode;
    DateTime uJoindate;
    String uProfilePic;
    String uAdharfront;
    String uAddarback;
    String uLicensefront;
    String uLicenseback;
    dynamic uDob;
    String uRole;

  BookingModel({
      required this.bId,
        required this.bUId,
        required this.bBkId,
        required this.bPriceId,
        required this.bRentAmount,
        required this.bFineAmount,
        required this.bTotalAmount,
        required this.bPickupLocation,
        required this.bPickupDate,
        required this.bPicupTime,
        required this.bDropLocation,
        required this.bDropDate,
        required this.bDropTime,
        required this.bRole,
        required this.bType,
        required this.bMessage,
        required this.bookingDate,
        required this.invoice,
        required this.bSelfie,
        required this.bAdharfront,
        required this.bAdharback,
        required this.bLicensefront,
        required this.bLicenseback,
        required this.viewReason,
        required this.bBikeName,
        required this.extendReason,
        required this.bPaymentStatus,
        required this.bStatus,
        required this.uId,
        required this.uName,
        required this.uEmail,
        required this.uMobile,
        required this.uAddress,
        required this.uState,
        required this.uDistrict,
        required this.uPincode,
        required this.uJoindate,
        required this.uProfilePic,
        required this.uAdharfront,
        required this.uAddarback,
        required this.uLicensefront,
        required this.uLicenseback,
        required this.uDob,
        required this.uRole,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
bId: json["b_id"] ?? "",
bUId: json["b_u_id"] ?? "",
bBkId: json["b_bk_id"] ?? "",
bPriceId: json["b_price_id"] ?? "",
bRentAmount: json["b_rent_amount"]?.toDouble() ?? 0.0,
bFineAmount: json["b_fine_amount"] ?? 0,
bTotalAmount: json["b_total_amount"]?.toDouble() ?? 0.0,
bPickupLocation: json["b_pickup_location"] ?? "",
bPickupDate: json["b_pickup_date"] != null ? DateTime.parse(json["b_pickup_date"]) : DateTime.now(),
bPicupTime: json["b_picup_time"] != null ? DateTime.parse(json["b_picup_time"]) : DateTime.now(),
bDropLocation: json["b_drop_location"] ?? "",
bDropDate: json["b_drop_date"] != null ? DateTime.parse(json["b_drop_date"]) : DateTime.now(),
bDropTime: json["b_drop_time"] != null ? DateTime.parse(json["b_drop_time"]) : DateTime.now(),
bRole: json["b_role"] ?? "",
bType: json["b_type"] ?? "",
bMessage: json["b_message"] ?? "",
bookingDate: json["booking_date"] != null ? DateTime.parse(json["booking_date"]) : DateTime.now(),
invoice: json["invoice"] ?? "",
bSelfie: json["b_selfie"] ?? "",
bAdharfront: json["b_adharfront"] ?? "",
bAdharback: json["b_adharback"] ?? "",
bLicensefront: json["b_licensefront"] ?? "",
bLicenseback: json["b_licenseback"] ?? "",
viewReason: json["view_reason"] ?? "",
bBikeName: json["b_bike_name"] ?? "",
extendReason: json["extend_reason"] ?? "",
bPaymentStatus: json["b_payment_status"] ?? "",
bStatus: json["b_status"] ?? "",
uId: json["u_id"] ?? "",
uName: json["u_name"] ?? "",
uEmail: json["u_email"] ?? "",
uMobile: json["u_mobile"] ?? "",
uAddress: json["u_address"] ?? "",
uState: json["u_state"] ?? "",
uDistrict: json["u_district"] ?? "",
uPincode: json["u_pincode"] ?? "",
uJoindate: json["u_joindate"] != null ? DateTime.parse(json["u_joindate"]) : DateTime.now(),
uProfilePic: json["u_profile_pic"] ?? "",
uAdharfront: json["u_adharfront"] ?? "",
uAddarback: json["u_addarback"] ?? "",
uLicensefront: json["u_licensefront"] ?? "",
uLicenseback: json["u_licenseback"] ?? "",
uDob: json["u_dob"] ?? "",
uRole: json["u_role"] ?? "",

    );
  }
}

class NotificationModel {
  int? nId;
  int? userId;
  int? adminId;
  String? role;
  String? type;
  String? message;
  String? status;

  NotificationModel({
    this.nId,
    this.userId,
    this.adminId,
    this.role,
    this.type,
    this.message,
    this.status,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      nId: json['n_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      adminId: json['admin_id'] ?? 0,
      role: json['role'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class UserModel {
  int? uId;
  String? uName;
  String? uEmail;
  String? uPassword;
  int? uMobile;
  String? uAddress;
  String? uState;
  String? uDistrict;
  int? uPincode;
  String? uJoinDate;
  String? uRole;
  int? uToken;
  String? uTokenExpiry;
  String? uOtpStatus;
  String? uProfilePic;
  String? uAdharFront;
  String? uAddarBack;
  String? uLicenseFront;
  String? uLicenseBack;
  String? uDob;
  String? verifyEmail;

  UserModel({
    this.uId,
    this.uName,
    this.uEmail,
    this.uPassword,
    this.uMobile,
    this.uAddress,
    this.uState,
    this.uDistrict,
    this.uPincode,
    this.uJoinDate,
    this.uRole,
    this.uToken,
    this.uTokenExpiry,
    this.uOtpStatus,
    this.uProfilePic,
    this.uAdharFront,
    this.uAddarBack,
    this.uLicenseFront,
    this.uLicenseBack,
    this.uDob,
    this.verifyEmail,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    uId = json['u_id'];
    uName = json['u_name'];
    uEmail = json['u_email'];
    uPassword = json['u_password'];
    uMobile = json['u_mobile'];
    uAddress = json['u_address'];
    uState = json['u_state'];
    uDistrict = json['u_district'];
    uPincode = json['u_pincode'];
    uJoinDate = json['u_joindate'];
    uRole = json['u_role'];
    uToken = json['u_token'];
    uTokenExpiry = json['u_token_expiry'];
    uOtpStatus = json['u_otp_status'];
    uProfilePic = json['u_profile_pic'];
    uAdharFront = json['u_adharfront'];
    uAddarBack = json['u_addarback'];
    uLicenseFront = json['u_licensefront'];
    uLicenseBack = json['u_licenseback'];
    uDob = json['u_dob'];
    verifyEmail = json['verify_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['u_id'] = uId;
    data['u_name'] = uName;
    data['u_email'] = uEmail;
    data['u_password'] = uPassword;
    data['u_mobile'] = uMobile;
    data['u_address'] = uAddress;
    data['u_state'] = uState;
    data['u_district'] = uDistrict;
    data['u_pincode'] = uPincode;
    data['u_joindate'] = uJoinDate;
    data['u_role'] = uRole;
    data['u_token'] = uToken;
    data['u_token_expiry'] = uTokenExpiry;
    data['u_otp_status'] = uOtpStatus;
    data['u_profile_pic'] = uProfilePic;
    data['u_adharfront'] = uAdharFront;
    data['u_addarback'] = uAddarBack;
    data['u_licensefront'] = uLicenseFront;
    data['u_licenseback'] = uLicenseBack;
    data['u_dob'] = uDob;
    data['verify_email'] = verifyEmail;
    return data;
  }
}

class BikeCenterLocationResponse {
  final bool result;
  final String message;
  final List<BikeCenterLocationModel> list;

  BikeCenterLocationResponse({
    required this.result,
    required this.message,
    required this.list,
  });

  factory BikeCenterLocationResponse.fromJson(Map<String, dynamic> json) {
    return BikeCenterLocationResponse(
      result: json['result'],
      message: json['message'],
      list:
          (json['list'] as List)
              .map((e) => BikeCenterLocationModel.fromJson(e))
              .toList(),
    );
  }
}

class BikeCenterLocationModel {
  final int lId;
  final String lLocation;
  final String lDistrict;
  final String? lLatitude;
  final String? lLongitude;

  BikeCenterLocationModel({
    required this.lId,
    required this.lLocation,
    required this.lDistrict,
    this.lLatitude,
    this.lLongitude,
  });

  factory BikeCenterLocationModel.fromJson(Map<String, dynamic> json) {
    return BikeCenterLocationModel(
      lId: json['l_id'],
      lLocation: json['l_location'],
      lDistrict: json['l_district'],
      lLatitude: json['l_latitude'],
      lLongitude: json['l_longitude'],
    );
  }
}


class RentModel {
    int rentId;
    int rentDuration;
    String rentDurationText;
    int rentAmount;
    double rentGst;
    int rentDeposit;
    double rentTotal;

    RentModel({
        required this.rentId,
        required this.rentDuration,
        required this.rentDurationText,
        required this.rentAmount,
        required this.rentGst,
        required this.rentDeposit,
        required this.rentTotal,

    });

   factory RentModel.fromJson(Map<String, dynamic> json) => RentModel(
        rentId: json["rent_id"],
        rentDuration: json["rent_duration"],
        rentDurationText: json["rent_duration_text"],
        rentAmount: json["rent_amount"],
        rentGst: json["rent_gst"]?.toDouble(),
        rentDeposit: json["rent_deposit"],
        rentTotal: json["rent_total"]?.toDouble(),
);


}