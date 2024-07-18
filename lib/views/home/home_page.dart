import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_user/common/custom_appbar.dart';
import 'package:foodly_user/common/custom_container.dart';
import 'package:foodly_user/common/heading.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/controllers/catergory_controller.dart';
import 'package:foodly_user/views/home/all_nearby_restaurants.dart';
import 'package:foodly_user/views/home/fastest_foods_page.dart';
import 'package:foodly_user/views/home/recommendations.dart';
import 'package:foodly_user/views/home/widgets/categories_list.dart';
import 'package:foodly_user/views/home/widgets/category_foodlist.dart';
import 'package:foodly_user/views/home/widgets/food_list.dart';
import 'package:foodly_user/views/home/widgets/nearby_restaurants.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());
    return Scaffold(
      backgroundColor: kOffWhite,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(130.h), child: const CustomAppBar()),
      body: SafeArea(
          child: CustomContainer(
              containerContent: Column(
        children: [
          const CategoriesWidget(),
          Obx(
            () => categoryController.categoryValue == ''
                ? Column(
                    children: [
                      // HomeHeading(
                      //   heading: "Pick Restaurants",
                      //   restaurant: true,
                      // ),
                      // const RestaurantOptions(),
                      HomeHeading(
                        heading: "Nearby Restaurants",
                        onTap: () {
                          Get.to(() => const AllNearbyRestaurants());
                        },
                      ),
                      const NearbyRestaurants(),
                      HomeHeading(
                        heading: "Try Something New",
                        onTap: () {
                          Get.to(() => const Recommendations());
                        },
                      ),
                      const FoodList(),
                      HomeHeading(
                        heading: "Fastest food closer to you",
                        onTap: () {
                          Get.to(() => const FastestFoods());
                        },
                      ),
                      const FoodList(),
                    ],
                  )
                : CustomContainer(
                    containerContent: Column(
                      children: [
                        HomeHeading(
                          heading:
                              "Explore ${categoryController.titleValue} Category",
                          restaurant: true,
                        ),
                        const CategoryFoodList(),
                      ],
                    ),
                  ),
          ),
        ],
      ))),
    );
  }
}
