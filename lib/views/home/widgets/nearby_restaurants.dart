// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_user/common/shimmers/nearby_shimmer.dart';
import 'package:foodly_user/controllers/location_controller.dart';
import 'package:foodly_user/hooks/fetchNearbyRestaurants.dart';
import 'package:foodly_user/models/restaurants.dart';
import 'package:foodly_user/views/home/widgets/restaurant_widget.dart';
import 'package:foodly_user/views/restaurant/restaurants_page.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearbyRestaurants extends HookWidget {
  const NearbyRestaurants({super.key});

  @override
  Widget build(BuildContext context) {
    final location = Get.put(UserLocationController());

    final hookResult = useFetchRestaurants();
    final restaurants = hookResult.data;
    final isLoading = hookResult.isLoading;
    final error = hookResult.error;
    final refetch = hookResult.refetch;

    return isLoading
        ? const NearbyShimmer()
        : Container(
            padding: const EdgeInsets.only(left: 12, top: 10),
            height: 194.h,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  Restaurants restaurant = restaurants[index];

                  return RestaurantWidget(
                    image: restaurant.imageUrl,
                    title: restaurant.title,
                    time: restaurant.time,
                    logo: restaurant.logoUrl,
                    rating: "${restaurant.ratingCount} + reviews and ratings",
                    onTap: () {
                      location.setLocation(LatLng(restaurant.coords.latitude,
                          restaurant.coords.longitude));
                      Get.to(() => RestaurantPage(
                            restaurant: restaurant,
                          ));
                    },
                  );
                }),
          );
  }
}
