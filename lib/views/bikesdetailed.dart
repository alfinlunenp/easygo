import 'package:easygonww/model/models.dart';
import 'package:flutter/material.dart';
import 'package:easygonww/controllers/reviewslist.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/pickundrop.dart';
import 'package:easygonww/widgets/button.dart';
import 'package:easygonww/widgets/colorcontainer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Bikesdetailed extends StatefulWidget {
  final BikeModel bikemodel;
  final List bikeReviewModel;
  final List BikeImages;

  Bikesdetailed({
    super.key,
    required this.bikemodel,
    required this.bikeReviewModel,
    required this.BikeImages,
  });

  @override
  State<Bikesdetailed> createState() => _BikesdetailedState();
}

class _BikesdetailedState extends State<Bikesdetailed> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // final List<String> images = [
    //    widget.bikemodel.bImage ??" "
    // ];

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              Navigations.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            ),
          ),
        ),
        centerTitle: false,
        title: Text(widget.bikemodel.bName, style: largelack),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                CarouselSlider(
                  items: widget.BikeImages.isEmpty
                      ? [
                          Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: primaryColor,
                              size: 80,
                            ),
                          ),
                        ]
                      : widget.BikeImages.map<Widget>(
                          (image) => ClipRRect(
                            child: Image.network(
                              "https://lunarsenterprises.com:6032/${image.imagePath}",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.broken_image_rounded,
                                    color: primaryColor,
                                    size: 50,
                                  ),
                            ),
                          ),
                        ).toList(),
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    // enableInfiniteScroll: true,
                    enableInfiniteScroll: false, // ✅ will stop at last item
                    autoPlay: false,
                    autoPlayInterval: const Duration(seconds: 3),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(borderradius),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.bikemodel.distance.toString()} km",
                            style: normalwhite,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(borderradius),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Center(
                        child: Text(
                          widget.bikemodel.maintainceStatus,
                          style: normalwhite,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.BikeImages.asMap().entries.map((entry) {
                      return Container(
                        width: 6.0,
                        height: 6.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == entry.key
                              ? primaryColor
                              : Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + ratings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.bikemodel.bName}',
                            style: detailedname,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${widget.bikemodel.bPrice} / Day',
                            style: detailedname,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      Spacer(),
                      Flexible(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            Text(
                              widget.bikemodel.bRatings.toString(),
                              style: normalblack,
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              " (${widget.bikeReviewModel.length} reviews)",
                              style: normalblack,
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: [
                      Colorcontainer(
                        childtext: widget.bikemodel.bGeartype ?? "",
                      ),
                      Colorcontainer(
                        childtext:
                            "max speed ${widget.bikemodel.maxSpeed.toString()} km/hr",
                      ),
                      Colorcontainer(
                        childtext: '${widget.bikemodel.bMilage} mileage',
                      ),
                      Colorcontainer(
                        childtext: "${widget.bikemodel.bBhp.toString()} bhp ",
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.bikemodel.bDescription ?? "", style: normalgrey),
                  const SizedBox(height: 10),
                  Text('Extras', style: largelack),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: [Text(widget.bikemodel.bExtras ?? "")],
                    // (widget.bikemodel.bExtras List).map<Widget>((extra) {
                    //   return Colorcontainer(childtext: extra);
                    // }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(color: Color.fromARGB(255, 228, 228, 231)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: padding),
              child: Text("Review", style: largelack),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.bikemodel.bikereviews.length,
              itemBuilder: (context, index) {
                var review = widget.bikemodel.bikereviews[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reviewer name (optional, if you add it to model)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${review.uName}", style: normalgrey),
                              Text("${review.date}", style: normalblack),
                            ],
                          ),

                          // Star ratings
                          RatingBarIndicator(
                            rating: (review.brRating.toDouble()),
                            itemBuilder: (context, _) =>
                                const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Text(review.brReview, style: normalgrey),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlobalButton(
          text: 'Rent Now',
          ontap: () {
            print("object");
            // Navigations.push(PickundropPage(totalamount: , rentamount: widget.bikemodel.bPrice, gstamount: widget.bikemodel.bPrice, rentdeposite: widget.bikemodel.bPrice), context);
          },
          context: context,
          textcolor: Colors.white,
          backgroundcolor: primaryColor,
        ),
      ),
    );
  }
}
