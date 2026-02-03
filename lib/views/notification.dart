import 'package:easygonww/utils/navigations.dart';
import 'package:flutter/material.dart';
import 'package:easygonww/controllers/notificationslist.dart';
import 'package:easygonww/controllers_/controllers.dart';
import 'package:easygonww/model/models.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationController _notificationController =
      NotificationController();

  String selectedStatus = 'Show All';

  List<NotificationModel> getFilteredNotifications() {
    if (selectedStatus == 'Show All') {
      return _notificationController.notificationList;
    }

    // Map UI tab names to actual API response "type"
    final typeMap = {
      'Bookings': 'Booking',
      'Payments': 'payment',
      // 'Cancelled': 'cancelled',
    };

    String? filterType = typeMap[selectedStatus];

    return _notificationController.notificationList
        .where((notification) => notification.type == filterType)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await _notificationController.fetchNotifications(); // pass user_id
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = getFilteredNotifications();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        surfaceTintColor: Colors.white,
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
        title: Text("Notifications", style: mediumblack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(padding),
        child: ListView(
          children: [
            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Show All', 'Bookings', 'Payments']
                    .asMap()
                    .entries
                    .map((entry) {
                      final index = entry.key;
                      final status = entry.value;
                      final isSelected =
                          selectedStatus.toLowerCase() == status.toLowerCase();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedStatus = status;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : bordercolorgrey,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected ? primaryColor : Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          margin: EdgeInsets.only(
                            left: index == 0 ? 0 : 4,
                            right: 4,
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: isSelected ? Colors.white : secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Notification List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: dividercolor,
                      borderRadius: BorderRadius.circular(borderradius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 8,
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 52,
                                width: 52,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.notifications,
                                  size: 28,
                                  color: secondprimaryColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${notification.type}!" ?? "",
                                      style: notification.status == 'unread'
                                          ? readtitle
                                          : unreadtitle,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      notification.message ?? "",
                                      style: notification.status == 'unread'
                                          ? readsubtitle
                                          : unreadsubtitle,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                              if (notification.status == 'unread')
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 16.0,
                                    left: 6,
                                  ),
                                  child: Container(
                                    height: 7,
                                    width: 7,
                                    decoration: BoxDecoration(
                                      color: secondprimaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
