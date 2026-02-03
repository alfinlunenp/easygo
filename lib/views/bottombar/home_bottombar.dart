import 'package:flutter/material.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/allbikes.dart';
import 'package:easygonww/views/bookings.dart';
import 'package:easygonww/views/home2.dart';
import 'package:easygonww/views/profile.dart';
import 'package:easygonww/views/search.dart';

class HomebottomBar extends StatefulWidget {
  final int? navindex;

  const HomebottomBar({super.key, this.navindex});

  @override
  State<HomebottomBar> createState() => _HomebottomBarState();
}

class _HomebottomBarState extends State<HomebottomBar> {
  late int selectedIndex;
  PageController? _pageController;

  final List<Widget> screens = [Home2(), Mybookings(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    // Use navindex if passed, otherwise default to 0
    selectedIndex = widget.navindex ?? 0;
    _pageController = PageController(initialPage: selectedIndex);
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,

      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          children: screens,
        ),
        bottomNavigationBar: buildBottomBar(),
      ),
    );
  }

  Widget buildBottomBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: [
          buildNavItem('assets/imgicons/House.png', 'Home', 0),
          buildNavItem('assets/imgicons/MopedFront.png', 'Bookings', 1),
          buildNavItem('assets/imgicons/User.png', 'Profile', 2),
        ],
      ),
    );
  }

  Widget buildNavItem(String icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageIcon(
            AssetImage(icon),
            color: isSelected ? secondprimaryColor : secondaryColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? secondprimaryColor : secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCenterItem(IconData icon, int index) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemTapped(index),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            width: 2,
            color: isSelected ? Colors.black : Colors.transparent,
          ),
          color: primaryColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
