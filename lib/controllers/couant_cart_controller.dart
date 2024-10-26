import 'package:get/get.dart';

class CounterCartController extends GetxController {
  var counts = <String, RxInt>{}; // Map to hold counts for each product

  // Initialize count for a specific product ID
  void initializeCount(String productId, int quantity) {
    counts[productId] = quantity.obs; // Initialize count to 1 for new product
  }

  // Increment the count for a specific product
  void increment(String productId) {
    if (counts[productId] != null) {
      counts[productId]!.value++;
    }
  }

  // Decrement the count for a specific product
  void decrement(String productId) {
    if (counts[productId] != null && counts[productId]!.value > 1) {
      counts[productId]!.value--;
    }
  }

  // Get the count for a specific product
  int getCount(String productId) {
    return counts[productId]?.value ?? 1; // Default to 1 if not found
  }
}
