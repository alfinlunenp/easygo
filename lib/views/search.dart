import 'package:flutter/material.dart';
import 'package:easygonww/controllers/list.dart';
import 'package:easygonww/controllers/popularlist.dart';
import 'package:easygonww/controllers_/controllers.dart';
import 'package:easygonww/model/models.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/allbikes.dart';
import 'package:easygonww/views/bikesdetailed.dart';
import 'package:easygonww/views/skeltons/search_skeleton.dart';
import 'package:easygonww/widgets/globalcontainer.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final BikesearchhController _bikecontroller = BikesearchhController();
  final BikeController _topratedbikescontoller = BikeController();
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = false; // initially not loading

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchdata() async {
    setState(() {
      // isLoading = true; // show loader
    });

    await _bikecontroller.fetchBikes(_searchController.text.trim());

    setState(() {
      isLoading = false; // hide loader after data fetched
    });
  }

  @override
  void initState() {
    super.initState();
    // load initial data
    fetchtoprated();
  }

  Future<void> fetchtoprated() async {
    setState(() {
      isLoading = true; // show loader while fetching top-rated
    });

    await _topratedbikescontoller.fetchBikes();

    setState(() {
      isLoading = false; // hide loader after data fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const SearchSkeleton()
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Globalcontainer(
                        height: 50,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Icon(Icons.search, color: bordercolorgrey),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search by bike model or location",
                                  hintStyle: normalgrey,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.trim().isNotEmpty) {
                                    fetchdata();
                                  } else {
                                    setState(() {
                                      _bikecontroller.searchlist.clear();
                                    });
                                  }
                                },
                              ),
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                              ),
                              onPressed: fetchdata,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Most Popular',
                        style: normalblack,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          _topratedbikescontoller.topRatedBikes.length,
                          (index) {
                            BikeModel topratedmodel =
                                _topratedbikescontoller.topRatedBikes[index];

                            print(
                              "top rated bikes are  ::::::::: ${topratedmodel.bName}",
                            );
                            return GestureDetector(
                              onTap: () {
                                Navigations.push(
                                  Bikesdetailed(
                                    bikemodel: topratedmodel,
                                    bikeReviewModel: topratedmodel.bikereviews,
                                    BikeImages: topratedmodel.bikeimages,
                                  ),
                                  context,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: secondaryColor),
                                  borderRadius: BorderRadius.circular(
                                    borderradius,
                                  ),
                                ),
                                child: Text(
                                  topratedmodel.bName ?? "",
                                  textAlign: TextAlign.center,
                                  style: smalltextgrey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      isLoading == true
                          ? Center(child: CircularProgressIndicator())
                          : Expanded(
                              child: isLoading == true
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : _searchController.text.isEmpty
                                  ? const SizedBox() // show nothing when no search query
                                  : _bikecontroller.searchlist.isEmpty
                                  ? const Center(child: Text("No Bikes"))
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets
                                          .zero, // Remove default padding
                                      // physics: const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          _bikecontroller.searchlist.length,
                                      itemBuilder: (context, index) {
                                        BikeModel bikemodel =
                                            _bikecontroller.searchlist[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigations.push(
                                              Bikesdetailed(
                                                bikemodel: bikemodel,
                                                bikeReviewModel:
                                                    bikemodel.bikereviews,
                                                BikeImages:
                                                    bikemodel.bikeimages,
                                              ),
                                              context,
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: containerColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFE4E4E7,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 122,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          child: AspectRatio(
                                                            aspectRatio: 3 / 4,
                                                            child: Image.network(
                                                              bikemodel
                                                                      .bikeimages
                                                                      .isNotEmpty
                                                                  ? "https://lunarsenterprises.com:6032/${bikemodel.bikeimages[0].imagePath}"
                                                                  : "$Noimage", // fallback image

                                                              fit: BoxFit.cover,
                                                              errorBuilder:
                                                                  (
                                                                    context,
                                                                    error,
                                                                    stackTrace,
                                                                  ) => Image.network(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    '$Noimage',
                                                                  ),
                                                              loadingBuilder:
                                                                  (
                                                                    context,
                                                                    child,
                                                                    loadingProgress,
                                                                  ) {
                                                                    if (loadingProgress ==
                                                                        null)
                                                                      return child;
                                                                    return Skeletonizer(
                                                                      child: Image.network(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        '$Noimage',
                                                                      ),
                                                                    );
                                                                  },
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 100,
                                                          height: 30,
                                                          decoration: BoxDecoration(
                                                            color:
                                                                secondaryColor,
                                                            borderRadius:
                                                                const BorderRadius.only(
                                                                  topRight:
                                                                      Radius.circular(
                                                                        8,
                                                                      ),
                                                                  bottomLeft:
                                                                      Radius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                          ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .location_on,
                                                                color: Colors
                                                                    .white,
                                                                size: 16,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                " ${bikemodel.distance.toString()} km",
                                                                style:
                                                                    normalwhite,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  bikemodel
                                                                          .bName ??
                                                                      "",
                                                                  style:
                                                                      mediumblack,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines:
                                                                      1000,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    '(',
                                                                    style:
                                                                        normalblack,
                                                                  ),
                                                                  const Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .amber,
                                                                    size: 16,
                                                                  ),
                                                                  Text(
                                                                    bikemodel
                                                                        .bRatings
                                                                        .toString(),
                                                                    style:
                                                                        normalblack,
                                                                  ),
                                                                  Text(
                                                                    ')',
                                                                    style:
                                                                        normalblack,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  '${bikemodel.bPrice}/Day',
                                                                  style:
                                                                      normalblack,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  "${bikemodel.bikereviews.length} reviews",
                                                                  style:
                                                                      normalblack,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Wrap(
                                                            spacing: 8.0,
                                                            runSpacing: 8.0,
                                                            children: [
                                                              _specTag(
                                                                "max speed ${bikemodel.maxSpeed.toString()}",
                                                              ),
                                                              _specTag(
                                                                "mileage ${bikemodel.bMilage}",
                                                              ),
                                                              _specTag(
                                                                "${bikemodel.bBhp} bhp",
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      right:
                                                                          16.0,
                                                                    ),
                                                                child: GestureDetector(
                                                                  onTap: () {
                                                                    Navigations.push(
                                                                      Bikesdetailed(
                                                                        bikemodel:
                                                                            bikemodel,
                                                                        bikeReviewModel:
                                                                            bikemodel.bikereviews,
                                                                        BikeImages:
                                                                            bikemodel.bikeimages,
                                                                      ),
                                                                      context,
                                                                    );
                                                                  },
                                                                  child: Globalcontainer(
                                                                    bgcolor:
                                                                        primaryColor,
                                                                    width: double
                                                                        .infinity,
                                                                    child: Center(
                                                                      child: Text(
                                                                        "Rent Now",
                                                                        style:
                                                                            normalwhite,
                                                                      ),
                                                                    ),
                                                                    bordercolor:
                                                                        Colors
                                                                            .transparent,
                                                                    textstyle:
                                                                        normalwhite,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _specTag(String text) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderradius),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
      child: Text(text, style: colortextmall),
    );
  }
}
