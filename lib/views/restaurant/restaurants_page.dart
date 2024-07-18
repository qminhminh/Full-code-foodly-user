// ignore_for_file: prefer_final_fields

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:foodly_user/common/app_style.dart';
import 'package:foodly_user/common/divida.dart';
import 'package:foodly_user/common/reusable_text.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/controllers/location_controller.dart';
import 'package:foodly_user/models/distance_time.dart';
import 'package:foodly_user/models/restaurants.dart';
import 'package:foodly_user/services/distance.dart';
import 'package:foodly_user/views/auth/login_page.dart';
import 'package:foodly_user/views/home/widgets/custom_btn.dart';
import 'package:foodly_user/views/restaurant/directions_page.dart';
import 'package:foodly_user/views/restaurant/rating_page.dart';
import 'package:foodly_user/views/restaurant/widgets/explore.dart';
import 'package:foodly_user/views/restaurant/widgets/menu.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glass/glass.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key, required this.restaurant});

  final Restaurants restaurant;

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage>
    with TickerProviderStateMixin {
  late TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  Widget build(BuildContext context) {
    final location = Get.put(UserLocationController());

    DistanceTime distanceTime = Distance().calculateDistanceTimePrice(
        location.currentLocation.latitude,
        location.currentLocation.longitude,
        widget.restaurant.coords.latitude,
        widget.restaurant.coords.longitude,
        10,
        2.00);

    // String numberString = widget.restaurant.time.substring(0, 2);
    double totalTime = 25 + distanceTime.time;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: kLightWhite,
          body: ListView(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 230.h,
                    width: width,
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.restaurant.imageUrl),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    child: RestaurantTopBar(
                      title: widget.restaurant.title,
                      restaurant: widget.restaurant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                height: 80.h,
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    RowText(
                        first: "Distance To Restaurant",
                        second:
                            "${distanceTime.distance.toStringAsFixed(3)} km"),
                    SizedBox(
                      height: 10.h,
                    ),
                    RowText(
                        first: "Delivery Price From Current Location",
                        second: "\$ ${distanceTime.price.toStringAsFixed(3)}"),
                    SizedBox(
                      height: 10.h,
                    ),
                    RowText(
                        first: "Estimated Delivery Time to Current Location",
                        second: "${totalTime.toStringAsFixed(0)} mins")
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Divida(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: SizedBox(
                  height: 25.h,
                  width: MediaQuery.of(context).size.width,
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelPadding: EdgeInsets.zero,
                    labelColor: Colors.white,
                    dividerColor: Colors.transparent,
                    labelStyle: appStyle(12, kLightWhite, FontWeight.normal),
                    unselectedLabelColor: Colors.grey.withOpacity(0.7),
                    tabs: <Widget>[
                      Tab(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          //margin: EdgeInsets.only(left: 20, right: 20),
                          height: 25,
                          child: const Center(child: Text("Menu")),
                        ),
                      ),
                      Tab(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          height: 25,
                          child: const Center(child: Text("Explore")),
                        ),
                      )
                    ],
                  ),
                ).asGlass(
                    tintColor: kPrimary,
                    clipBorderRadius: BorderRadius.circular(19.0),
                    blurX: 8,
                    blurY: 8),
              ),
              SizedBox(
                  height: hieght / 1.3,
                  child: TabBarView(controller: _tabController, children: [
                    RestaurantMenu(
                      restaurantId: widget.restaurant.id,
                    ),
                    const Explore()
                  ]))
            ],
          )),
    );
  }
}

class RestaurantRatingBar extends StatelessWidget {
  const RestaurantRatingBar({
    super.key,
    required this.restaurant,
  });

  final Restaurants restaurant;

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    String? token = box.read("token");
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35.h,
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.5),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6.r), topRight: Radius.circular(6.r)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RatingBarIndicator(
              rating: restaurant.rating.toDouble(),
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.yellow,
              ),
              itemCount: 5,
              itemSize: 25.0,
              direction: Axis.horizontal,
            ),
            CustomButton(
              onTap: () {
                if (token == null) {
                  Get.to(() => const Login(),
                      transition: Transition.fadeIn,
                      duration: const Duration(seconds: 2));
                } else {
                  Get.to(() => RatingPage(
                        restaurant: restaurant,
                      ));
                }
              },
              text: "Rate Restaurant",
              btnWidth: width / 3,
            )
          ],
        ),
      ),
    );
  }
}

class RestaurantTopBar extends StatelessWidget {
  const RestaurantTopBar({
    super.key,
    required this.title,
    required this.restaurant,
  });

  final String title;
  final Restaurants restaurant;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(12.w, 30.h, 12.w, 0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const Icon(
              Ionicons.chevron_back_circle,
              color: kLightWhite,
              size: 28,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ReusableText(
                text: title, style: appStyle(14, kDark, FontWeight.w500)),
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => DirectionsPage(
                    restaurant: restaurant,
                  ));
            },
            child: const Icon(
              Entypo.direction,
              color: kLightWhite,
            ),
          )
        ],
      ),
    );
  }
}

class RowText extends StatelessWidget {
  const RowText({
    super.key,
    required this.first,
    required this.second,
  });

  final String first;
  final String second;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ReusableText(text: first, style: appStyle(10, kGray, FontWeight.w500)),
        SizedBox(
            child: Text(second,
                overflow: TextOverflow.ellipsis,
                style: appStyle(10, kGray, FontWeight.w400)))
      ],
    );
  }
}
