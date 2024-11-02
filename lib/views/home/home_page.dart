// ignore_for_file: sort_child_properties_last, unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_user/common/custom_appbar.dart';
import 'package:foodly_user/common/custom_container.dart';
import 'package:foodly_user/common/heading.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/controllers/catergory_controller.dart';
import 'package:foodly_user/models/environment.dart';
import 'package:foodly_user/views/home/all_nearby_restaurants.dart';
import 'package:foodly_user/views/home/fastest_foods_page.dart';
import 'package:foodly_user/views/home/recommendations.dart';
import 'package:foodly_user/views/home/widgets/categories_list.dart';
import 'package:foodly_user/views/home/widgets/category_foodlist.dart';
import 'package:foodly_user/views/home/widgets/chat_tab.dart';
import 'package:foodly_user/views/home/widgets/food_list.dart';
import 'package:foodly_user/views/home/widgets/nearby_restaurants.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulHookWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = GetStorage();
  late final String uid = box.read("userId").replaceAll('"', '');

  List<dynamic> messages = [];
  bool isLoading = false;
  String? error;

  // Hàm fetch dữ liệu
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final url =
          Uri.parse('${Environment.appBaseUrl}/api/chats/messages-cus/$uid');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          messages = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> navigateToChatTab() async {
    final result = await Get.to(() => const ChatTab(),
        duration: const Duration(milliseconds: 400));

    // Kiểm tra giá trị trả về
    if (result == true) {
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());
    final countUnreadMessage = messages.isNotEmpty
        ? messages.where((msg) => msg['isRead'] == 'unread').toList()
        : [];
    return Scaffold(
      backgroundColor: kOffWhite,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130.h),
        child: const CustomAppBar(),
      ),
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
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 60.0),
        child: Stack(
          clipBehavior: Clip.none, // Để phần badge hiển thị bên ngoài
          children: [
            FloatingActionButton(
              focusColor: kPrimary,
              hoverColor: kPrimary,
              onPressed: navigateToChatTab,
              child: const Icon(Icons.chat_bubble),
              backgroundColor: kPrimary,
            ),
            Positioned(
              top: 4, // Đặt vị trí của badge
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red, // Màu nền cho badge
                  shape: BoxShape.circle, // Đặt hình dạng là hình tròn
                ),
                child: Text(
                  '${countUnreadMessage != null ? countUnreadMessage.length : 0}', // Số đếm
                  style: const TextStyle(
                    color: Colors.white, // Màu chữ của số đếm
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
